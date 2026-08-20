import 'package:flutter/material.dart';
import '../../models/models.dart';
import 'stat_capsule_card.dart';

/// Interactive stacked card deck where swiping a card (left or right)
/// causes it to arc out, drop in depth, and visibly slide BACK INTO THE DECK
/// at the bottom slot, while the cards behind make space and elevate to the top.
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

  // Animation controller for the full swipe-out & re-insert to deck loop
  late AnimationController _reinsertController;

  // Animation controller for snapping back if swipe threshold was not reached
  late AnimationController _snapBackController;
  late Animation<Offset> _snapBackAnimation;

  // State of the card currently undergoing the re-insertion loop
  int? _animatingCardIndex;
  Offset _animatingCardStartOffset = Offset.zero;
  double _swipeDirection = 1.0; // +1.0 = right, -1.0 = left

  @override
  void initState() {
    super.initState();

    // Re-insertion animation: Outwards arc -> slides back into the bottom slot
    _reinsertController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 480),
    );

    _snapBackController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
    );

    _reinsertController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          // Advance top index: the animated card is now resting at the back
          _topIndex = (_topIndex + 1) % widget.metrics.length;
          _animatingCardIndex = null;
          _dragOffset = Offset.zero;
        });
        _reinsertController.reset();
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
    _reinsertController.dispose();
    _snapBackController.dispose();
    super.dispose();
  }

  void _onPanStart(DragStartDetails details) {
    if (_reinsertController.isAnimating || _snapBackController.isAnimating) {
      return;
    }
    _snapBackController.stop();
    setState(() {
      _isDragging = true;
    });
  }

  void _onPanUpdate(DragUpdateDetails details) {
    if (_reinsertController.isAnimating) return;
    setState(() {
      _dragOffset += details.delta;
    });
  }

  void _onPanEnd(DragEndDetails details) {
    if (_reinsertController.isAnimating) return;

    final velocity = details.velocity.pixelsPerSecond.dx;
    final distance = _dragOffset.dx;

    // Trigger re-insertion loop if dragged past threshold or swiped fast
    if (distance.abs() > 65 || velocity.abs() > 320) {
      final direction = distance != 0
          ? (distance > 0 ? 1.0 : -1.0)
          : (velocity >= 0 ? 1.0 : -1.0);

      _triggerReinsert(direction: direction, startOffset: _dragOffset);
    } else {
      // Snap back onto the top of the deck
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

  void _triggerReinsert({
    required double direction,
    Offset startOffset = Offset.zero,
  }) {
    if (_reinsertController.isAnimating) return;

    _animatingCardIndex = _topIndex;
    _animatingCardStartOffset = startOffset;
    _swipeDirection = direction;
    _isDragging = false;

    _reinsertController.forward(from: 0.0);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.metrics.isEmpty) return const SizedBox.shrink();

    final totalCards = widget.metrics.length;
    const cardWidth = 182.0;
    const cardHeight = 206.0;
    const containerHeight = 240.0;

    // Transition progress (0.0 to 1.0) for the cards behind moving forward
    double progress = 0.0;
    if (_reinsertController.isAnimating) {
      progress = _reinsertController.value;
    } else if (_isDragging || _snapBackController.isAnimating) {
      progress = (_dragOffset.dx.abs() / 150.0).clamp(0.0, 1.0);
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 1. Deck Stack Container
        SizedBox(
          height: containerHeight,
          child: Stack(
            alignment: Alignment.center,
            clipBehavior: Clip.none,
            children: [
              // --- LAYER 0 (Bottom-most): The re-inserting card sliding back into the deck ---
              if (_animatingCardIndex != null && _reinsertController.isAnimating)
                _buildReinsertingCard(cardWidth, cardHeight),

              // --- LAYER 1: Rank 2 Card (Deepest stationary card in deck) ---
              if (totalCards > 2)
                _buildCardRank(
                  rank: 2,
                  progress: progress,
                  cardWidth: cardWidth,
                  cardHeight: cardHeight,
                ),

              // --- LAYER 2: Rank 1 Card (Card immediately behind top) ---
              if (totalCards > 1)
                _buildCardRank(
                  rank: 1,
                  progress: progress,
                  cardWidth: cardWidth,
                  cardHeight: cardHeight,
                ),

              // --- LAYER 3 (Top foreground): Draggable Active Card ---
              if (_animatingCardIndex == null || !_reinsertController.isAnimating)
                _buildTopDraggableCard(
                  cardWidth: cardWidth,
                  cardHeight: cardHeight,
                ),
            ],
          ),
        ),

        const SizedBox(height: 12),

        // 2. Pagination Indicator Dots with Tap-to-Cycle
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(totalCards, (index) {
            final isCurrent = index == _topIndex;
            return GestureDetector(
              onTap: () {
                if (index != _topIndex) {
                  _triggerReinsert(
                    direction: index > _topIndex ? 1.0 : -1.0,
                  );
                }
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 260),
                margin: const EdgeInsets.symmetric(horizontal: 3.5),
                width: isCurrent ? 22 : 6,
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

  // --- BUILD THE RE-INSERTING CARD SLIDING BACK INTO THE DECK ---
  Widget _buildReinsertingCard(double cardWidth, double cardHeight) {
    final metric = widget.metrics[_animatingCardIndex!];

    return AnimatedBuilder(
      animation: _reinsertController,
      builder: (context, child) {
        final t = _reinsertController.value;

        // Two-phase physical trajectory:
        // Phase 1 (0.0 -> 0.35): Card swings outwards, clears the deck, and dips in depth
        // Phase 2 (0.35 -> 1.0): Card slides back IN from the side into the bottom slot Offset(0, 26)
        double currentX;
        double currentY;
        double currentScale;
        double currentRotation;
        double currentOpacity;

        final maxOutX = _swipeDirection * 155.0;
        final targetBackY = 26.0; // Vertical position of bottom slot in deck
        final targetBackScale = 0.84; // Scale at bottom slot

        if (t <= 0.35) {
          final p1 = t / 0.35; // 0.0 -> 1.0
          currentX = _animatingCardStartOffset.dx +
              (maxOutX - _animatingCardStartOffset.dx) * Curves.easeOutQuad.transform(p1);
          currentY = _animatingCardStartOffset.dy +
              (targetBackY - _animatingCardStartOffset.dy) * p1;
          currentScale = 1.0 - ((1.0 - targetBackScale) * p1);
          currentRotation = (_swipeDirection * 0.20) * (1.0 - (p1 * 0.5));
          currentOpacity = 1.0 - (0.35 * p1);
        } else {
          final p2 = (t - 0.35) / 0.65; // 0.0 -> 1.0
          final easeP2 = Curves.easeInOutCubic.transform(p2);
          // Slide back from maxOutX -> 0 into the bottom of the deck
          currentX = maxOutX * (1.0 - easeP2);
          currentY = targetBackY;
          currentScale = targetBackScale;
          currentRotation = (_swipeDirection * 0.10) * (1.0 - easeP2);
          currentOpacity = 0.65 + (0.05 * easeP2);
        }

        return Transform.translate(
          offset: Offset(currentX, currentY),
          child: Transform.scale(
            scale: currentScale,
            child: Transform.rotate(
              angle: currentRotation,
              child: Opacity(
                opacity: currentOpacity.clamp(0.0, 1.0),
                child: Container(
                  width: cardWidth,
                  height: cardHeight,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(38),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.10),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: StatCapsuleCard(
                    metric: metric,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // --- BUILDS CARDS IN DECK BEHIND TOP CARD (Rank 1, Rank 2) ---
  Widget _buildCardRank({
    required int rank,
    required double progress,
    required double cardWidth,
    required double cardHeight,
  }) {
    final metricIndex = (_topIndex + rank) % widget.metrics.length;
    final metric = widget.metrics[metricIndex];

    // As top card is pulled away / re-inserts (progress: 0.0 -> 1.0):
    // Rank 1 elevates to Rank 0 (scale: 0.92 -> 1.0, offsetY: 14 -> 0)
    // Rank 2 elevates to Rank 1 (scale: 0.84 -> 0.92, offsetY: 26 -> 14)
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
              onTap: () => _triggerReinsert(direction: 1.0),
            ),
          ),
        ),
      ),
    );
  }

  // --- BUILDS THE TOP FOREGROUND CARD ---
  Widget _buildTopDraggableCard({
    required double cardWidth,
    required double cardHeight,
  }) {
    final metric = widget.metrics[_topIndex];
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
}
