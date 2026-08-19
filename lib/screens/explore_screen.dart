import 'package:flutter/material.dart';
import '../models/models.dart';
import '../state/app_state.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../widgets/cards/stat_capsule_card.dart';

/// "Explore and adjust" screen matching the Dribbble design reference
class ExploreScreen extends StatefulWidget {
  final AppState state;
  final Function(SuggestedRoute) onSelectRouteToRun;

  const ExploreScreen({
    super.key,
    required this.state,
    required this.onSelectRouteToRun,
  });

  @override 
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  int _activeChallengePage = 0;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // 1. Top Header Bar: Back Button `<` + "You got 9 Level" + Avatar
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                child: _buildHeader(context, isDark),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 6)),

            // 2. Title: "Explore and adjust"
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'Explore and adjust',
                  style: AppTypography.headingLarge(
                    color: isDark ? Colors.white : AppColors.primaryText,
                  ).copyWith(
                    fontSize: 30,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.6,
                  ),
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 18)),

            // 3. Card 1: "Running Challenge" (Mint Hero Card)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _buildRunningChallengeCard(isDark),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 16)),

            // 4. Card 2: "Your Team" (White Rounded Card)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _buildYourTeamCard(context, isDark),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 16)),

            // 5. Card 3: "View on the map" (Dark/Black Matte Card)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _buildViewOnMapCard(context, isDark),
              ),
            ),

            // Bottom Spacing for floating navigation bar
            const SliverToBoxAdapter(child: SizedBox(height: 110)),
          ],
        ),
      ),
    );
  }

  // --- Header Bar ---
  Widget _buildHeader(BuildContext context, bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Back Button `<`
        GestureDetector(
          onTap: () => widget.state.setTabIndex(1), // Back to Home
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkCard : Colors.white,
              shape: BoxShape.circle,
              border: Border.all(
                color: isDark
                    ? AppColors.darkDivider
                    : Colors.black.withValues(alpha: 0.04),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            alignment: Alignment.center,
            child: Icon(
              Icons.arrow_back_ios_new_rounded,
              color: isDark ? Colors.white : AppColors.primaryText,
              size: 18,
            ),
          ),
        ),

        // Right: "You got 9 Level" + Avatar
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Text(
                  'You got ',
                  style: AppTypography.caption(
                    color: isDark ? AppColors.darkMutedText : AppColors.subtleGray,
                  ).copyWith(fontSize: 13),
                ),
                Text(
                  '9 Level',
                  style: AppTypography.caption(
                    color: isDark ? Colors.white : AppColors.primaryText,
                    fontWeight: FontWeight.w700,
                  ).copyWith(fontSize: 14),
                ),
              ],
            ),
            const SizedBox(width: 10),
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isDark ? AppColors.darkDivider : Colors.white,
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ClipOval(
                child: Image.asset(
                  'assets/images/julia_avatar.jpg',
                  fit: BoxFit.cover,
                  errorBuilder: (ctx, e, st) => Container(
                    color: AppColors.primaryTeal,
                    alignment: Alignment.center,
                    child: const Text('JS', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // --- Card 1: Running Challenge (Mint Hero Card) ---
  Widget _buildRunningChallengeCard(bool isDark) {
    return Container(
      padding: const EdgeInsets.fromLTRB(22, 22, 22, 20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1B2E2B) : AppColors.mint,
        borderRadius: BorderRadius.circular(34),
        boxShadow: [
          BoxShadow(
            color: (isDark ? AppColors.darkMint : AppColors.mint).withValues(alpha: 0.35),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row: "Running Challenge" + "+ 1 Level"
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Running Challenge',
                    style: AppTypography.headingMedium(
                      color: isDark ? Colors.white : AppColors.primaryText,
                    ).copyWith(
                      fontSize: 21,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    'Test your strength',
                    style: AppTypography.caption(
                      color: isDark ? AppColors.darkMutedText : const Color(0xFF435854),
                      fontWeight: FontWeight.w500,
                    ).copyWith(fontSize: 13),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.darkSecondarySurface.withValues(alpha: 0.6)
                      : Colors.white.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  '+ 1 Level',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: isDark ? AppColors.darkMint : const Color(0xFF1E403B),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Pagination Dots (•••)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(3, (idx) {
              final isCurrent = idx == _activeChallengePage;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _activeChallengePage = idx;
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: isCurrent ? 18 : 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: isCurrent
                        ? (isDark ? Colors.white : AppColors.primaryText)
                        : (isDark ? Colors.white30 : Colors.black26),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              );
            }),
          ),

          const SizedBox(height: 14),

          // Inner Dark Pill Container with "43/90 days" & Curved Mint Gauge
          Container(
            width: double.infinity,
            height: 64,
            decoration: BoxDecoration(
              color: AppColors.statCapsuleDark,
              borderRadius: BorderRadius.circular(32),
            ),
            padding: const EdgeInsets.all(4),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(28),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Text in center
                  Text(
                    '43/90 days',
                    style: AppTypography.headingSmall(
                      color: AppColors.primaryText,
                    ).copyWith(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.4,
                    ),
                  ),

                  // Bottom Curved Progress Arc
                  Positioned.fill(
                    child: CustomPaint(
                      painter: BottomCurvedProgressPainter(
                        progress: 0.48, // 43 / 90
                        trackColor: AppColors.statArcTrack,
                        activeStartColor: AppColors.statArcMintLight,
                        activeEndColor: AppColors.statArcMintDark,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- Card 2: Your Team (White Rounded Card) ---
  Widget _buildYourTeamCard(BuildContext context, bool isDark) {
    final members = widget.state.teamMembers;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 22),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(32),
        border: isDark ? Border.all(color: AppColors.darkDivider) : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: 4-point sparkle icon + "Your Team" + "Invite a friend for a joint run"
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.darkSecondarySurface
                      : AppColors.secondarySurface,
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.auto_awesome_rounded,
                  color: AppColors.primaryTeal,
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Your Team',
                    style: AppTypography.headingSmall(
                      color: isDark ? Colors.white : AppColors.primaryText,
                    ).copyWith(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Invite a friend for a joint run',
                    style: AppTypography.caption(
                      color: isDark ? AppColors.darkMutedText : AppColors.subtleGray,
                    ).copyWith(fontSize: 12),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 18),

          // Horizontal Team Avatars List
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: [
                // 1. "+ Add member" Button
                _buildAddMemberButton(isDark),

                const SizedBox(width: 14),

                // 2. Team Member Avatars: Nika, Lisa, Chris, Adel, Jon
                ...members.map((m) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 14),
                    child: _buildTeamMemberAvatar(m, isDark),
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddMemberButton(bool isDark) {
    return Column(
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: isDark ? AppColors.darkDivider : const Color(0xFFD1D5DB),
              width: 1.5,
            ),
          ),
          alignment: Alignment.center,
          child: Icon(
            Icons.add_rounded,
            color: isDark ? Colors.white : AppColors.primaryText,
            size: 24,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Add member',
          style: AppTypography.caption(
            color: isDark ? AppColors.darkMutedText : AppColors.subtleGray,
            fontWeight: FontWeight.w500,
          ).copyWith(fontSize: 11),
        ),
      ],
    );
  }

  Widget _buildTeamMemberAvatar(TeamMember member, bool isDark) {
    return Column(
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: isDark ? AppColors.darkDivider : Colors.white,
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: ClipOval(
            child: member.avatarAssetPath != null
                ? Image.asset(
                    member.avatarAssetPath!,
                    fit: BoxFit.cover,
                    errorBuilder: (ctx, e, st) => _fallbackAvatar(member),
                  )
                : _fallbackAvatar(member),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          member.name,
          style: AppTypography.caption(
            color: isDark ? Colors.white : AppColors.primaryText,
            fontWeight: FontWeight.w600,
          ).copyWith(fontSize: 12),
        ),
      ],
    );
  }

  Widget _fallbackAvatar(TeamMember member) {
    return Container(
      color: member.avatarBgColor,
      alignment: Alignment.center,
      child: Text(
        member.avatarInitials,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 15,
        ),
      ),
    );
  }

  // --- Card 3: View on the map (Dark Matte Card) ---
  Widget _buildViewOnMapCard(BuildContext context, bool isDark) {
    final route = widget.state.suggestedRoutes.first;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
      decoration: BoxDecoration(
        color: AppColors.statCapsuleDark,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.18),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header Row: Compass Icon + "View on the map / Best places to run" + Share Button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: const Icon(
                      Icons.explore_outlined,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'View on the map',
                        style: AppTypography.bodyLarge(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ).copyWith(fontSize: 16),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Best places to run',
                        style: AppTypography.caption(
                          color: Colors.white.withValues(alpha: 0.6),
                        ).copyWith(fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),

              // Circular share / route button
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.3),
                    width: 1.2,
                  ),
                ),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.alt_route_rounded,
                  color: Colors.white,
                  size: 18,
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          // Inset Route Tile: Park Photo + "One Sino Park / 2 km from you" + "View >"
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFF1B1D20),
              borderRadius: BorderRadius.circular(22),
            ),
            child: Row(
              children: [
                // Thumbnail Photo
                ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: SizedBox(
                    width: 52,
                    height: 52,
                    child: Image.asset(
                      'assets/images/one_sino_park.jpg',
                      fit: BoxFit.cover,
                      errorBuilder: (ctx, e, st) => Container(
                        color: AppColors.primaryTeal,
                        child: const Icon(Icons.park_rounded, color: Colors.white),
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                // Name & Distance
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        route.name,
                        style: AppTypography.bodyMedium(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ).copyWith(fontSize: 15),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        route.location,
                        style: AppTypography.caption(
                          color: Colors.white.withValues(alpha: 0.6),
                        ).copyWith(fontSize: 12),
                      ),
                    ],
                  ),
                ),

                // "View >" Capsule Action Button
                GestureDetector(
                  onTap: () => widget.onSelectRouteToRun(route),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.white,
                        width: 1.2,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'View',
                          style: AppTypography.caption(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ).copyWith(fontSize: 13),
                        ),
                        const SizedBox(width: 3),
                        const Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 10,
                          color: Colors.white,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
