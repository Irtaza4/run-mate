import 'package:flutter/material.dart';
import '../models/models.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../widgets/reel/holographic_reel_card.dart';

/// Interactive Reel & Story Studio screen allowing users to:
/// - Showcase runs in 3D Holographic Perspective
/// - Switch aesthetic themes (Cyberpunk, Mint, Sunset, Stealth)
/// - Replay neon route at 1x / 2x / 5x speeds
/// - Burst confetti celebration effects
/// - Toggle 9:16 Instagram Reel story mode
class ReelShowcaseScreen extends StatefulWidget {
  final RunActivity run;

  const ReelShowcaseScreen({
    super.key,
    required this.run,
  });

  @override
  State<ReelShowcaseScreen> createState() => _ReelShowcaseScreenState();
}

class _ReelShowcaseScreenState extends State<ReelShowcaseScreen> {
  ReelCardTheme _selectedTheme = ReelCardTheme.cyberpunkNeon;
  bool _autoTilt = true;
  bool _isStoryMode = false;
  double _playbackSpeed = 1.0;

  final GlobalKey<HolographicReelCardState> _cardKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF090A0E),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF833AB4), Color(0xFFFD1D1D), Color(0xFFFCB045)],
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                children: [
                  Icon(Icons.camera_alt_rounded, color: Colors.white, size: 12),
                  SizedBox(width: 4),
                  Text(
                    'REEL STUDIO',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: 'Burst Confetti',
            icon: const Text('🎉', style: TextStyle(fontSize: 20)),
            onPressed: () {
              _cardKey.currentState?.triggerConfettiBurst();
            },
          ),
          IconButton(
            tooltip: 'Toggle 9:16 Reel Format',
            icon: Icon(
              _isStoryMode
                  ? Icons.aspect_ratio_rounded
                  : Icons.crop_portrait_rounded,
              color: AppColors.mint,
            ),
            onPressed: () {
              setState(() {
                _isStoryMode = !_isStoryMode;
              });
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Top Hint Banner
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.touch_app_rounded,
                      size: 14, color: Colors.white.withValues(alpha: 0.6)),
                  const SizedBox(width: 6),
                  Text(
                    'Drag to tilt in 3D • Tap to blast confetti',
                    style: AppTypography.caption(
                      color: Colors.white.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            // 1. Central 3D Interactive Card Showcase
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  physics: const NeverScrollableScrollPhysics(),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: HolographicReelCard(
                      key: _cardKey,
                      run: widget.run,
                      theme: _selectedTheme,
                      autoTilt: _autoTilt,
                      isStoryMode: _isStoryMode,
                      playbackSpeed: _playbackSpeed,
                    ),
                  ),
                ),
              ),
            ),

            // 2. Bottom Controls Studio Panel
            Container(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
              decoration: BoxDecoration(
                color: const Color(0xFF13151D),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.08),
                  width: 1,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Theme Selector Chips
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Aesthetic Theme',
                        style: AppTypography.bodySmall(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      // Auto-tilt Toggle
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _autoTilt = !_autoTilt;
                          });
                        },
                        child: Row(
                          children: [
                            Icon(
                              _autoTilt
                                  ? Icons.motion_photos_on_rounded
                                  : Icons.motion_photos_off_rounded,
                              size: 14,
                              color: _autoTilt ? AppColors.mint : Colors.white38,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _autoTilt ? 'Auto Float ON' : 'Manual Tilt',
                              style: TextStyle(
                                fontSize: 11,
                                color: _autoTilt ? AppColors.mint : Colors.white38,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Horizontal Theme Pills
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    child: Row(
                      children: [
                        _buildThemePill(
                          title: 'Cyberpunk',
                          theme: ReelCardTheme.cyberpunkNeon,
                          icon: '⚡',
                          accent: AppColors.primaryTeal,
                        ),
                        const SizedBox(width: 8),
                        _buildThemePill(
                          title: 'Mint Frosted',
                          theme: ReelCardTheme.mintAesthetic,
                          icon: '🌿',
                          accent: AppColors.mint,
                        ),
                        const SizedBox(width: 8),
                        _buildThemePill(
                          title: 'Sunset Gold',
                          theme: ReelCardTheme.sunsetGold,
                          icon: '🌅',
                          accent: const Color(0xFFFFB03A),
                        ),
                        const SizedBox(width: 8),
                        _buildThemePill(
                          title: 'Stealth Blue',
                          theme: ReelCardTheme.stealthTitanium,
                          icon: '🌑',
                          accent: const Color(0xFF38BDF8),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 14),

                  // Speed Scrub & Reel Export Bar
                  Row(
                    children: [
                      // Speed Controls
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.06),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: [
                            _buildSpeedBtn('1x', 1.0),
                            _buildSpeedBtn('2x', 2.0),
                            _buildSpeedBtn('4x', 4.0),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Post to Reel / Share Button
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            _cardKey.currentState?.triggerConfettiBurst();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Row(
                                  children: [
                                    Text('✨', style: TextStyle(fontSize: 16)),
                                    SizedBox(width: 8),
                                    Text('3D Reel Card ready to record / share!'),
                                  ],
                                ),
                                backgroundColor: const Color(0xFF1F2430),
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                            );
                          },
                          child: Container(
                            height: 44,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [
                                  Color(0xFF833AB4),
                                  Color(0xFFFD1D1D),
                                  Color(0xFFFCB045),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(22),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFFFD1D1D)
                                      .withValues(alpha: 0.35),
                                  blurRadius: 14,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.share_rounded,
                                    color: Colors.white, size: 16),
                                SizedBox(width: 6),
                                Text(
                                  'Share to Instagram',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThemePill({
    required String title,
    required ReelCardTheme theme,
    required String icon,
    required Color accent,
  }) {
    final isSelected = _selectedTheme == theme;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedTheme = theme;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? accent.withValues(alpha: 0.2)
              : Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? accent : Colors.white.withValues(alpha: 0.1),
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(icon, style: const TextStyle(fontSize: 12)),
            const SizedBox(width: 6),
            Text(
              title,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.white60,
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSpeedBtn(String text, double speed) {
    final isSelected = _playbackSpeed == speed;
    return GestureDetector(
      onTap: () {
        setState(() {
          _playbackSpeed = speed;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.mint : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 11,
            color: isSelected ? Colors.black : Colors.white60,
            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
