import 'package:flutter/material.dart';
import '../../../shared/widgets/glass_components.dart';
import '../../../theme/app_theme.dart';

class OccupancyTrendChart extends StatefulWidget {
  final String filter; // 24H, 7D, 30D

  const OccupancyTrendChart({super.key, required this.filter});

  @override
  State<OccupancyTrendChart> createState() => _OccupancyTrendChartState();
}

class _OccupancyTrendChartState extends State<OccupancyTrendChart> {
  List<double> get points {
    switch (widget.filter) {
      case '24H':
        return [65, 68, 72, 75, 82, 88, 91, 86, 80, 78, 76, 79];
      case '7D':
        return [70, 74, 85, 88, 91, 84, 79];
      case '30D':
        return [68, 72, 75, 80, 85, 88, 86, 82, 79, 78, 83, 89, 91, 84, 79];
      default:
        return [70, 75, 80, 85, 90, 84, 79];
    }
  }

  List<String> get labels {
    switch (widget.filter) {
      case '24H':
        return ['00:00', '04:00', '08:00', '12:00', '16:00', '20:00', '24:00'];
      case '7D':
        return ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      case '30D':
        return ['Week 1', 'Week 2', 'Week 3', 'Week 4'];
      default:
        return ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = HealthifyGlassTheme.isDarkMode(context);

    return Container(
      height: 200,
      padding: const EdgeInsets.only(top: 16, bottom: 8, left: 8, right: 8),
      child: CustomPaint(
        size: Size.infinite,
        painter: _ChartPainter(
          dataPoints: points,
          lineColor: AppTheme.primaryColor,
          fillColor: AppTheme.primaryColor.withValues(alpha: isDark ? 0.25 : 0.12),
          isDark: isDark,
        ),
      ),
    );
  }
}

class _ChartPainter extends CustomPainter {
  final List<double> dataPoints;
  final Color lineColor;
  final Color fillColor;
  final bool isDark;

  _ChartPainter({
    required this.dataPoints,
    required this.lineColor,
    required this.fillColor,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (dataPoints.isEmpty) return;

    final paintLine = Paint()
      ..color = lineColor
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final paintFill = Paint()
      ..color = fillColor
      ..style = PaintingStyle.fill;

    final paintGrid = Paint()
      ..color = isDark ? Colors.white12 : AppTheme.borderLight
      ..strokeWidth = 1.0;

    // Draw horizontal grid lines
    for (int i = 0; i <= 4; i++) {
      final y = size.height * (i / 4);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paintGrid);
    }

    final double stepX = size.width / (dataPoints.length - 1);
    final double minY = 50.0;
    final double maxY = 100.0;

    final path = Path();
    final fillPath = Path();

    for (int i = 0; i < dataPoints.length; i++) {
      final x = i * stepX;
      final normalizedY = (dataPoints[i] - minY) / (maxY - minY);
      final y = size.height - (normalizedY * size.height);

      if (i == 0) {
        path.moveTo(x, y);
        fillPath.moveTo(x, size.height);
        fillPath.lineTo(x, y);
      } else {
        final prevX = (i - 1) * stepX;
        final prevNormalizedY = (dataPoints[i - 1] - minY) / (maxY - minY);
        final prevY = size.height - (prevNormalizedY * size.height);

        final controlX1 = prevX + (stepX / 2);
        final controlY1 = prevY;
        final controlX2 = prevX + (stepX / 2);
        final controlY2 = y;

        path.cubicTo(controlX1, controlY1, controlX2, controlY2, x, y);
        fillPath.cubicTo(controlX1, controlY1, controlX2, controlY2, x, y);
      }
    }

    fillPath.lineTo(size.width, size.height);
    fillPath.close();

    canvas.drawPath(fillPath, paintFill);
    canvas.drawPath(path, paintLine);

    // Draw data points dots
    final dotPaint = Paint()
      ..color = isDark ? const Color(0xFF0F2928) : Colors.white
      ..style = PaintingStyle.fill;

    final dotBorderPaint = Paint()
      ..color = lineColor
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;

    for (int i = 0; i < dataPoints.length; i++) {
      final x = i * stepX;
      final normalizedY = (dataPoints[i] - minY) / (maxY - minY);
      final y = size.height - (normalizedY * size.height);

      canvas.drawCircle(Offset(x, y), 5, dotPaint);
      canvas.drawCircle(Offset(x, y), 5, dotBorderPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _ChartPainter oldDelegate) {
    return oldDelegate.dataPoints != dataPoints || oldDelegate.isDark != isDark;
  }
}