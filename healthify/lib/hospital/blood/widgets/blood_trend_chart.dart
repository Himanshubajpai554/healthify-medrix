import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';
import '../../../shared/widgets/glass_components.dart';

class BloodUsageTrendChart extends StatefulWidget {
  final String filter; // 24H, 7D, 30D, 90D

  const BloodUsageTrendChart({super.key, required this.filter});

  @override
  State<BloodUsageTrendChart> createState() => _BloodUsageTrendChartState();
}

class _BloodUsageTrendChartState extends State<BloodUsageTrendChart> {
  List<double> get points {
    switch (widget.filter) {
      case '24H':
        return [32, 38, 45, 52, 60, 68, 58, 48, 42, 39, 44, 46];

      case '7D':
        return [38, 42, 55, 68, 62, 49, 42];

      case '30D':
        return [35, 40, 48, 52, 65, 68, 54, 46, 42, 40, 47, 58, 62, 50, 42];

      case '90D':
        return [30, 35, 42, 50, 68, 60, 52, 45, 42];

      default:
        return [38, 42, 55, 68, 62, 49, 42];
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = HealthifyGlassTheme.isDarkMode(context);

    return SizedBox(
      width: double.infinity,
      height: 200,
      child: Padding(
        padding: const EdgeInsets.only(top: 16, bottom: 8, left: 8, right: 8),
        child: CustomPaint(
          painter: _BloodChartPainter(
            dataPoints: points,
            lineColor: const Color(0xFFE11D48),
            fillColor: const Color(
              0xFFE11D48,
            ).withValues(alpha: isDark ? 0.25 : 0.12),
            isDark: isDark,
          ),
          child: const SizedBox.expand(),
        ),
      ),
    );
  }
}

class _BloodChartPainter extends CustomPainter {
  final List<double> dataPoints;
  final Color lineColor;
  final Color fillColor;
  final bool isDark;

  _BloodChartPainter({
    required this.dataPoints,
    required this.lineColor,
    required this.fillColor,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (dataPoints.isEmpty || size.width <= 0 || size.height <= 0) {
      return;
    }

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

    // Horizontal grid lines
    for (int i = 0; i <= 4; i++) {
      final y = size.height * (i / 4);

      canvas.drawLine(Offset(0, y), Offset(size.width, y), paintGrid);
    }

    // Prevent division by zero if a future filter contains one point.
    final stepX = dataPoints.length > 1
        ? size.width / (dataPoints.length - 1)
        : 0.0;

    const minY = 20.0;
    const maxY = 80.0;

    double getY(double value) {
      final normalizedY = (value - minY) / (maxY - minY);

      return size.height - (normalizedY * size.height);
    }

    final path = Path();
    final fillPath = Path();

    for (int i = 0; i < dataPoints.length; i++) {
      final x = i * stepX;
      final y = getY(dataPoints[i]);

      if (i == 0) {
        path.moveTo(x, y);

        fillPath.moveTo(x, size.height);

        fillPath.lineTo(x, y);
      } else {
        final previousX = (i - 1) * stepX;
        final previousY = getY(dataPoints[i - 1]);

        final controlX1 = previousX + (stepX / 2);

        final controlY1 = previousY;

        final controlX2 = previousX + (stepX / 2);

        final controlY2 = y;

        path.cubicTo(controlX1, controlY1, controlX2, controlY2, x, y);

        fillPath.cubicTo(controlX1, controlY1, controlX2, controlY2, x, y);
      }
    }

    fillPath.lineTo(size.width, size.height);

    fillPath.close();

    canvas.drawPath(fillPath, paintFill);

    canvas.drawPath(path, paintLine);

    // Data point dots
    final dotPaint = Paint()
      ..color = isDark ? const Color(0xFF0F2928) : Colors.white
      ..style = PaintingStyle.fill;

    final dotBorderPaint = Paint()
      ..color = lineColor
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;

    for (int i = 0; i < dataPoints.length; i++) {
      final x = i * stepX;
      final y = getY(dataPoints[i]);

      canvas.drawCircle(Offset(x, y), 5, dotPaint);

      canvas.drawCircle(Offset(x, y), 5, dotBorderPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _BloodChartPainter oldDelegate) {
    return oldDelegate.dataPoints != dataPoints ||
        oldDelegate.lineColor != lineColor ||
        oldDelegate.fillColor != fillColor ||
        oldDelegate.isDark != isDark;
  }
}
