import 'package:flutter/material.dart';
import '../../models/models.dart';
import 'stat_capsule_card.dart';

/// Interactive stacked card deck where cards sit directly on top of each other.
/// When swiping the top card (left or right), it smoothly slides and loops
/// to the BOTTOM/BACK of the stack, and the card behind it pops UP to the top.
class StackedStatCardsCarousel extends StatefulWidget {
  final List<StatMetric> metrics;
  final ValueChanged<StatMetric>? onCardTap;

  const StackedStatCardsCarousel({
    super.key,
    required this.metrics,
    this.onCardTap,
  });

  @override
  State<StackedStatCardsCarousel> createState() =>
      _StackedStatCardsCarouselState();
}

class _StackedStatCardsCarouselState extends State<StackedStatCardsCarousel>
    with TickerProviderStateMixin {
  int _topIndex = 0;
  Offset _dragOffset = Offset.zero;
  bool _isDragging = false;

  // Animation controller for swiping top card away to the back
  late AnimationController _swipeController;
  late Animation<Offset> _swipeAnimation;
  late Animation<double> _rotationAnimation;

  // Animation controller for snapping back if swipe threshold is not met
  late AnimationController _snapBackController;
  late Animation<Offset> _snapBackAnimation;

  // Track the outgoing card that is flying to the back
  int? _outgoingCardIndex;
  Offset _outgoingCardStartOffset = Offset.zero;
  double _outgoingCardStartRotation = 0.0;

  @override
  void initState() {
    super.initState();

    _swipeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 380),
    );

    _snapBackController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
    );

    _swipeController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          // Top card successfully moved to bottom of stack
          _topIndex = (_topIndex + 1) % widget.metrics.length;
          _outgoingCardIndex = null;
          _dragOffset = Offset.zero;
        });
        _swipeController.reset();
      }
    });

    _snapBackController.addListener(() {
      setState(() {
        _dragOffset = _snapBackAnimation.value;
      });
    });

    _snapBackController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          _dragOffset = Offset.zero;
          _isDragging = false;
        });
        _snapBackController.reset();
      }
    });
  }

  @override
  void dispose() {
    _swipeController.dispose();
    _snapBackController.dispose();
    super.dispose();
  }

  void _onPanStart(DragStartDetails details) {
    if (_swipeController.isAnimating || _snapBackController.isAnimating) return;
    _snapBackController.stop();
    setState(() {
      _isDragging = true;
    });
  }

  void _onPanUpdate(DragUpdateDetails details) {
    if (_swipeController.isAnimating) return;
    setState(() {
      _dragOffset += details.delta;
    });
  }

  void _onPanEnd(DragEndDetails details) {
    if (_swipeController.isAnimating) return;

    final velocity = details.velocity.pixelsPerSecond.dx;
    final distance = _dragOffset.dx;
    final screenWidth = MediaQuery.of(context).size.width;

    // Trigger swipe if dragged sufficiently or fast velocity
    if (distance.abs() > 70 || velocity.abs() > 350) {
      final direction = distance != 0
          ? (distance > 0 ? 1.0 : -1.0)
          : (velocity >= 0 ? 1.0 : -1.0);

      final targetX = direction * (screenWidth * 0.9);
      final targetY = _dragOffset.dy + (velocity * 0.05).clamp(-50.0, 50.0);

      _outgoingCardIndex = _topIndex;
      _outgoingCardStartOffset = _dragOffset;
      _outgoingCardStartRotation = (_dragOffset.dx / 300.0).clamp(-0.25, 0.25);

      _swipeAnimation = Tween<Offset>(
        begin: _outgoingCardStartOffset,
        end: Offset(targetX, targetY),
      ).animate(
        CurvedAnimation(
          parent: _swipeController,
          curve: Curves.easeOutCubic,
        ),
      );

      _rotationAnimation = Tween<double>(
        begin: _outgoingCardStartRotation,
        end: direction * 0.35,
      ).animate(
        CurvedAnimation(
          parent: _swipeController,
          curve: Curves.easeOutCubic,
        ),
      );

      _isDragging = false;
      _swipeController.forward(from: 0.0);
    } else {
      // Snap back to center
      _snapBackAnimation = Tween<Offset>(
        begin: _dragOffset,
        end: Offset.zero,
      ).animate(
        CurvedAnimation(
          parent: _snapBackController,
          curve: Curves.easeOutBack,
        ),
      );
      _snapBackController.forward(from: 0.0);
    }
  }

  // Programmatic swipe to next card (e.g. tapping shuffle or dots)
  void _swipeNext({double direction = 1.0}) {
    if (_swipeController.isAnimating || _snapBackController.isAnimating) return;

    final screenWidth = MediaQuery.of(context).size.width;
    final targetX = direction * (screenWidth * 0.85);

    _outgoingCardIndex = _topIndex;
    _outgoingCardStartOffset = Offset.zero;
    _outgoingCardStartRotation = 0.0;

    _swipeAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: Offset(targetX, -10.0),
    ).animate(
      CurvedAnimation(
        parent: _swipeController,
        curve: Curves.easeOutCubic,
      ),
    );

    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: direction * 0.30,
    ).animate(
      CurvedAnimation(
        parent: _swipeController,
        curve: Curves.easeOutCubic,
      ),
    );

    _isDragging = false;
    _swipeController.forward(from: 0.0);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.metrics.isEmpty) return const SizedBox.shrink();

    final totalCards = widget.metrics.length;
    const cardWidth = 180.0;
    const cardHeight = 206.0;
    const containerHeight = 236.0;

    // Progress of the current drag or swipe animation (0.0 to 1.0)
    double progress = 0.0;
    if (_swipeController.isAnimating) {
      progress = _swipeController.value;
    } else if (_isDragging || _snapBackController.isAnimating) {
      progress = (_dragOffset.dx.abs() / 150.0).clamp(0.0, 1.0);
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 1. Stack of Cards
        SizedBox(
          height: containerHeight,
          child: Stack(
            alignment: Alignment.center,
            clipBehavior: Clip.none,
            children: [
              // --- RENDER BACKGROUND CARDS IN REVERSE (Rank 2 -> Rank 1 -> Rank 0) ---
              // Rank 2 (Deepest visible card in the stack)
              if (totalCards > 2)
                _buildCardRank(
                  rank: 2,
                  progress: progress,
                  cardWidth: cardWidth,
                  cardHeight: cardHeight,
                ),

              // Rank 1 (Card directly behind top card)
              if (totalCards > 1)
                _buildCardRank(
                  rank: 1,
                  progress: progress,
                  cardWidth: cardWidth,
                  cardHeight: cardHeight,
                ),

              // Rank 0 (Top foreground active card that user can drag & swipe)
              _buildTopDraggableCard(
                cardWidth: cardWidth,
                cardHeight: cardHeight,
              ),

              // Outgoing card flying to the back during swipe animation
              if (_outgoingCardIndex != null && _swipeController.isAnimating)
                _buildOutgoingCard(cardWidth, cardHeight),
            ],
          ),
        ),

        const SizedBox(height: 10),

        // 2. Deck Pagination Indicators / Dots
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(totalCards, (index) {
            final isCurrent = index == _topIndex;
            return GestureDetector(
              onTap: () {
                if (index != _topIndex) {
                  _swipeNext(direction: index > _topIndex ? 1.0 : -1.0);
                }
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 260),
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: isCurrent ? 20 : 6,
                height: 6,
                decoration: BoxDecoration(
                  color: isCurrent
                      ? const Color(0xFF111214)
                      : Colors.black.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  // Builds cards layered behind the top card (Rank 1, Rank 2)
  Widget _buildCardRank({
    required int rank,
    required double progress,
    required double cardWidth,
    required double cardHeight,
  }) {
    final metricIndex = (_topIndex + rank) % widget.metrics.length;
    final metric = widget.metrics[metricIndex];

    // As progress goes 0.0 -> 1.0 (top card being swiped away),
    // Rank 1 interpolates to Rank 0, and Rank 2 interpolates to Rank 1.
    final currentScale = rank == 1
        ? (0.92 + (progress * 0.08)) // 0.92 -> 1.00
        : (0.84 + (progress * 0.08)); // 0.84 -> 0.92

    final currentOffsetY = rank == 1
        ? (14.0 - (progress * 14.0)) // 14 -> 0
        : (26.0 - (progress * 12.0)); // 26 -> 14

    final currentOpacity = rank == 1
        ? (0.82 + (progress * 0.18)) // 0.82 -> 1.00
        : (0.60 + (progress * 0.22)); // 0.60 -> 0.82

    return Transform.translate(
      offset: Offset(0, currentOffsetY),
      child: Transform.scale(
        scale: currentScale,
        child: Opacity(
          opacity: currentOpacity.clamp(0.0, 1.0),
          child: Container(
            width: cardWidth,
            height: cardHeight,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(38),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: StatCapsuleCard(
              metric: metric,
              onTap: () => _swipeNext(),
            ),
          ),
        ),
      ),
    );
  }

  // Builds the top card that reacts to touch gestures and dragging
  Widget _buildTopDraggableCard({
    required double cardWidth,
    required double cardHeight,
  }) {
    final metric = widget.metrics[_topIndex];

    // If animating swipe away, hide the base top card since _buildOutgoingCard renders it
    if (_swipeController.isAnimating && _outgoingCardIndex == _topIndex) {
      return const SizedBox.shrink();
    }

    final rotation = (_dragOffset.dx / 300.0).clamp(-0.25, 0.25);

    return GestureDetector(
      onPanStart: _onPanStart,
      onPanUpdate: _onPanUpdate,
      onPanEnd: _onPanEnd,
      onTap: () {
        if (_dragOffset.distance < 8) {
          widget.onCardTap?.call(metric);
        }
      },
      child: Transform.translate(
        offset: _dragOffset,
        child: Transform.rotate(
          angle: rotation,
          child: Container(
            width: cardWidth,
            height: cardHeight,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(38),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(
                    alpha: _isDragging ? 0.26 : 0.16,
                  ),
                  blurRadius: _isDragging ? 26 : 18,
                  offset: Offset(
                    _dragOffset.dx * 0.1,
                    8 + (_dragOffset.dy.abs() * 0.1),
                  ),
                ),
              ],
            ),
            child: StatCapsuleCard(
              metric: metric,
              onTap: () {
                if (_dragOffset.distance < 8) {
                  widget.onCardTap?.call(metric);
                }
              },
            ),
          ),
        ),
      ),
    );
  }

  // Outgoing card flying off screen and dropping to bottom of stack
  Widget _buildOutgoingCard(double cardWidth, double cardHeight) {
    final metric = widget.metrics[_outgoingCardIndex!];

    return AnimatedBuilder(
      animation: _swipeController,
      builder: (context, child) {
        return Transform.translate(
          offset: _swipeAnimation.value,
          child: Transform.rotate(
            angle: _rotationAnimation.value,
            child: Container(
              width: cardWidth,
              height: cardHeight,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(38),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.20),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: StatCapsuleCard(
                metric: metric,
              ),
            ),
          ),
        );
      },
    );
  }
}
