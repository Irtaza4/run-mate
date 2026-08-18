import 'package:flutter/material.dart';
import '../models/models.dart';
import '../state/app_state.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../widgets/cards/challenge_card.dart';
import '../widgets/cards/route_card.dart';
import '../widgets/cards/team_avatar_list.dart';

/// Explore screen focusing on challenges, team social motivation, and routes
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
  String _selectedCategory = 'All';
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final filteredRoutes = widget.state.suggestedRoutes.where((route) {
      final matchesCat = _selectedCategory == 'All' ||
          route.difficulty.toLowerCase() == _selectedCategory.toLowerCase();
      final matchesSearch = _searchQuery.isEmpty ||
          route.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          route.location.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesCat && matchesSearch;
    }).toList();

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // Header Bar
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Explore & Discover',
                          style: AppTypography.headingLarge(
                            color: isDark ? Colors.white : AppColors.primaryText,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Challenges, teammates, and curated trails',
                          style: AppTypography.caption(
                            color: isDark
                                ? AppColors.darkMutedText
                                : AppColors.mutedText,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.darkSecondarySurface
                            : AppColors.cardBackground,
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Icon(
                        Icons.tune_rounded,
                        size: 20,
                        color: isDark ? Colors.white : AppColors.primaryText,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Search Bar
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkCard : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: isDark
                        ? Border.all(color: AppColors.darkDivider)
                        : null,
                  ),
                  child: TextField(
                    onChanged: (val) {
                      setState(() {
                        _searchQuery = val;
                      });
                    },
                    style: AppTypography.bodyMedium(
                      color: isDark ? Colors.white : AppColors.primaryText,
                    ),
                    decoration: InputDecoration(
                      icon: Icon(
                        Icons.search_rounded,
                        color: isDark
                            ? AppColors.darkMutedText
                            : AppColors.mutedText,
                        size: 22,
                      ),
                      hintText: 'Search trails, parks, or challenges...',
                      hintStyle: AppTypography.bodyMedium(
                        color: isDark
                            ? AppColors.darkMutedText
                            : AppColors.mutedText,
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
              ),
            ),

            // Featured Monthly Challenge
            if (widget.state.challenges.isNotEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Monthly Challenge',
                        style: AppTypography.headingSmall(
                          color: isDark ? Colors.white : AppColors.primaryText,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ChallengeCard(
                        challenge: widget.state.challenges.first,
                        onJoinTap: () => widget.state
                            .toggleJoinChallenge(widget.state.challenges.first.id),
                      ),
                    ],
                  ),
                ),
              ),

            const SliverToBoxAdapter(child: SizedBox(height: 24)),

            // Team Section
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: TeamAvatarList(
                  members: widget.state.teamMembers,
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 24)),

            // Suggested Routes Section Header & Filter Pills
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Suggested Routes',
                          style: AppTypography.headingSmall(
                            color: isDark ? Colors.white : AppColors.primaryText,
                          ),
                        ),
                        Text(
                          '${filteredRoutes.length} available',
                          style: AppTypography.caption(
                            color: isDark
                                ? AppColors.darkMutedText
                                : AppColors.mutedText,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildCategoryFilterRow(isDark),
                  ],
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 14)),

            // Suggested Routes List
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final route = filteredRoutes[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: RouteCard(
                        route: route,
                        onStartRun: () => widget.onSelectRouteToRun(route),
                      ),
                    );
                  },
                  childCount: filteredRoutes.length,
                ),
              ),
            ),

            // Bottom Spacing for floating navigation bar
            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryFilterRow(bool isDark) {
    const categories = ['All', 'Easy', 'Moderate', 'Challenging'];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: categories.map((cat) {
          final isSelected = _selectedCategory == cat;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedCategory = cat;
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? (isDark ? AppColors.darkMint : AppColors.primaryText)
                      : (isDark
                          ? AppColors.darkCard
                          : AppColors.secondarySurface),
                  borderRadius: BorderRadius.circular(16),
                  border: isDark
                      ? Border.all(
                          color: isSelected
                              ? AppColors.darkMint
                              : AppColors.darkDivider)
                      : null,
                ),
                child: Text(
                  cat,
                  style: AppTypography.caption(
                    color: isSelected
                        ? (isDark ? AppColors.darkBackground : Colors.white)
                        : (isDark
                            ? AppColors.darkPrimaryText
                            : AppColors.primaryText),
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  ).copyWith(fontSize: 12),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
