import 'package:flutter/material.dart';
import '../../models/models.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';

/// A stacked block-tile bar chart matching the reference design
class StackedTileActivityChart extends StatelessWidget {
  final List<HourlyActivityBlock> blocks;
  final int selectedIndex;
  final ValueChanged<int> onSelectBlock;

  const StackedTileActivityChart({
    super.key,
    required this.blocks,
    required this.selectedIndex,
    required this.onSelectBlock,
  });

  @override
  Widget build(BuildContext context) {
    // Total columns
    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth;
        final count = blocks.length;
        // Compute column width and gap
        final totalGaps = count - 1;
        final colGap = 10.0;
        final colWidth = ((availableWidth - (totalGaps * colGap) - 24) / count)
            .clamp(28.0, 44.0);
        const tileHeight = 32.0;
        const tileSpacing = 3.5;
        const maxTiles = 5;
        final chartHeight = (maxTiles * tileHeight) + ((maxTiles - 1) * tileSpacing) + 30.0;

        return SizedBox(
          height: chartHeight,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Far left subtle baseline dot
              Container(
                width: 10,
                height: 10,
                margin: const EdgeInsets.only(bottom: 24),
                decoration: BoxDecoration(
                  color: AppColors.divider.withValues(alpha: 0.8),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),

              // Hourly Columns
              ...List.generate(count, (index) {
                final block = blocks[index];
                final isSelected = index == selectedIndex;

                return GestureDetector(
                  onTap: () => onSelectBlock(index),
                  behavior: HitTestBehavior.opaque,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      // Stacked Tiles
                      _buildTileStack(
                        block: block,
                        colWidth: colWidth,
                        tileHeight: tileHeight,
                        tileSpacing: tileSpacing,
                        isSelected: isSelected,
                      ),

                      const SizedBox(height: 10),

                      // Time label
                      Text(
                        block.timeLabel,
                        style: AppTypography.caption(
                          color: isSelected
                              ? AppColors.primaryText
                              : AppColors.subtleGray,
                          fontWeight: isSelected
                              ? FontWeight.w700
                              : FontWeight.w500,
                        ).copyWith(fontSize: 12),
                      ),
                    ],
                  ),
                );
              }),

              // Far right subtle baseline dot
              Container(
                width: 10,
                height: 10,
                margin: const EdgeInsets.only(bottom: 24),
                decoration: BoxDecoration(
                  color: AppColors.divider.withValues(alpha: 0.8),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTileStack({
    required HourlyActivityBlock block,
    required double colWidth,
    required double tileHeight,
    required double tileSpacing,
    required bool isSelected,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(block.tileCount, (tileIdx) {
        // tileIdx 0 is bottom, tileIdx == (tileCount - 1) is top tile
        final isTopTile = tileIdx == (block.tileCount - 1);
        final isPeakTop = isTopTile && block.isPeak;

        return Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            Container(
              width: colWidth,
              height: tileHeight,
              margin: EdgeInsets.only(
                bottom: tileIdx > 0 ? tileSpacing : 0,
              ),
              decoration: BoxDecoration(
                color: isPeakTop
                    ? AppColors.tileMintDark
                    : (isSelected
                        ? AppColors.primaryTeal.withValues(alpha: 0.45)
                        : AppColors.tileMint),
                borderRadius: BorderRadius.circular(10),
                border: isSelected && !isPeakTop
                    ? Border.all(
                        color: AppColors.primaryTeal,
                        width: 1.2,
                      )
                    : null,
                boxShadow: isPeakTop
                    ? [
                        BoxShadow(
                          color: AppColors.tileMintDark.withValues(alpha: 0.35),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              alignment: Alignment.center,
              child: isPeakTop
                  ? const _SparkleStarIcon()
                  : null,
            ),

            // "Better result" label positioned to the right of the peak top tile
            if (isPeakTop && block.peakBadgeText != null)
              Positioned(
                left: colWidth + 6,
                child: SizedBox(
                  width: 90,
                  child: Text(
                    block.peakBadgeText!,
                    style: AppTypography.caption(
                      color: AppColors.tileMintDark,
                      fontWeight: FontWeight.w600,
                    ).copyWith(fontSize: 12, height: 1.1),
                    maxLines: 1,
                  ),
                ),
              ),
          ],
        );
      }).reversed.toList(), // Reversed so index 0 is on bottom and top tile is at top
    );
  }
}

/// 8-point white star / sparkle icon matching the reference
class _SparkleStarIcon extends StatelessWidget {
  const _SparkleStarIcon();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(18, 18),
      painter: _EightPointSparklePainter(),
    );
  }
}

class _EightPointSparklePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round;

    final center = Offset(size.width / 2, size.height / 2);
    final longLen = size.width * 0.42;
    final diagLen = size.width * 0.28;

    // Vertical line
    canvas.drawLine(
      Offset(center.dx, center.dy - longLen),
      Offset(center.dx, center.dy + longLen),
      paint,
    );

    // Horizontal line
    canvas.drawLine(
      Offset(center.dx - longLen, center.dy),
      Offset(center.dx + longLen, center.dy),
      paint,
    );

    // Diagonal 1 (\)
    canvas.drawLine(
      Offset(center.dx - diagLen, center.dy - diagLen),
      Offset(center.dx + diagLen, center.dy + diagLen),
      paint,
    );

    // Diagonal 2 (/)
    canvas.drawLine(
      Offset(center.dx - diagLen, center.dy + diagLen),
      Offset(center.dx + diagLen, center.dy - diagLen),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
