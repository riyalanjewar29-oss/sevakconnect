import 'dart:math';
import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_typography.dart';

class LegendItemData {
  final String label;
  final int count;
  final Color color;

  const LegendItemData({
    required this.label,
    required this.count,
    required this.color,
  });
}

class DonutSummaryCard extends StatelessWidget {
  final String title;
  final VoidCallback? onViewAll;
  final List<LegendItemData> items;
  final String emptyText;

  const DonutSummaryCard({
    super.key,
    required this.title,
    this.onViewAll,
    required this.items,
    this.emptyText = 'No data\navailable',
  });

  @override
  Widget build(BuildContext context) {
    final total = items.fold<int>(0, (sum, item) => sum + item.count);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFEEEEEE), width: 1),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Card Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title.toUpperCase(),
                  style: AppTypography.labelLg(color: AppColors.onSurface).copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                    letterSpacing: 0.5,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              if (onViewAll != null)
                InkWell(
                  onTap: onViewAll,
                  borderRadius: BorderRadius.circular(4),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                    child: Text(
                      'View All',
                      style: AppTypography.labelSm(color: const Color(0xFFFF6600)).copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
            ],
          ),

          const SizedBox(height: 18),

          // Donut Ring + Legend Row
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Donut Ring
              SizedBox(
                width: 90,
                height: 90,
                child: CustomPaint(
                  painter: _DonutChartPainter(
                    items: items,
                    total: total,
                  ),
                  child: Center(
                    child: Text(
                      emptyText,
                      textAlign: TextAlign.center,
                      style: AppTypography.labelSm(color: const Color(0xFF888888)).copyWith(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        height: 1.2,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 16),

              // Legend Items
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: items.map((item) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 3),
                      child: Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: item.color,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              item.label,
                              style: AppTypography.labelSm(color: const Color(0xFF333333)).copyWith(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text(
                            '${item.count}',
                            style: AppTypography.labelSm(color: const Color(0xFF333333)).copyWith(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DonutChartPainter extends CustomPainter {
  final List<LegendItemData> items;
  final int total;

  _DonutChartPainter({
    required this.items,
    required this.total,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width / 2) - 6;
    const strokeWidth = 10.0;

    // Background base ring
    final bgPaint = Paint()
      ..color = const Color(0xFFECEFF1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, bgPaint);

    if (total > 0) {
      double startAngle = -pi / 2;
      for (final item in items) {
        if (item.count > 0) {
          final sweepAngle = (item.count / total) * 2 * pi;
          final segmentPaint = Paint()
            ..color = item.color
            ..style = PaintingStyle.stroke
            ..strokeWidth = strokeWidth
            ..strokeCap = StrokeCap.round;

          canvas.drawArc(
            Rect.fromCircle(center: center, radius: radius),
            startAngle,
            sweepAngle,
            false,
            segmentPaint,
          );
          startAngle += sweepAngle;
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DonutChartPainter oldDelegate) {
    return oldDelegate.total != total;
  }
}
