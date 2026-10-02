import 'package:flutter/material.dart';
import '../../../shared/widgets/glass_components.dart';
import '../../../theme/app_theme.dart';

class BedOccupancyChartWidget extends StatefulWidget {
  const BedOccupancyChartWidget({super.key});

  @override
  State<BedOccupancyChartWidget> createState() => _BedOccupancyChartWidgetState();
}

class _BedOccupancyChartWidgetState extends State<BedOccupancyChartWidget> {
  String _selectedTimeframe = '24H';

  // Mocked 24H bed occupancy data percentage (00:00 to 22:00)
  final List<double> _data24H = [65, 68, 70, 72, 75, 82, 88, 91, 89, 85, 84, 86];
  final List<String> _labels24H = ['00:00', '02:00', '04:00', '06:00', '08:00', '10:00', '12:00', '14:00', '16:00', '18:00', '20:00', '22:00'];

  final List<double> _data7D = [72, 75, 80, 84, 88, 82, 84];
  final List<String> _labels7D = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  final List<double> _data30D = [60, 65, 70, 78, 85, 88, 84, 80, 82, 86];
  final List<String> _labels30D = ['W1', 'W2', 'W3', 'W4', 'W5', 'W6', 'W7', 'W8', 'W9', 'W10'];

  List<double> get _currentData {
    if (_selectedTimeframe == '7D') return _data7D;
    if (_selectedTimeframe == '30D') return _data30D;
    return _data24H;
  }

  List<String> get _currentLabels {
    if (_selectedTimeframe == '7D') return _labels7D;
    if (_selectedTimeframe == '30D') return _labels30D;
    return _labels24H;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = HealthifyGlassTheme.isDarkMode(context);

    return GlassCard(
      padding: const EdgeInsets.all(20.0),
      borderRadius: 20,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 12,
            runSpacing: 10,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const GlassIconContainer(
                        icon: Icons.show_chart_rounded,
                        color: AppTheme.primaryColor,
                        size: 34,
                        iconSize: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '24-Hour Bed Occupancy Trend',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : AppTheme.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Real-time bed occupancy rate & peak capacity limit',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? Colors.white70 : AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
              // Timeframe Selectors
              Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  color: HealthifyGlassTheme.getGlassSurface(isDark),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: HealthifyGlassTheme.getGlassBorder(isDark), width: 1.2),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: ['24H', '7D', '30D'].map((timeframe) {
                    final isSelected = _selectedTimeframe == timeframe;
                    return InkWell(
                      onTap: () {
                        setState(() {
                          _selectedTimeframe = timeframe;
                        });
                      },
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: isSelected ? AppTheme.primaryColor : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          timeframe,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: isSelected ? Colors.white : (isDark ? Colors.white70 : AppTheme.textSecondary),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Peak Summary Pills
          Wrap(
            spacing: 16,
            runSpacing: 8,
            children: [
              _buildStatPill(context, 'Current Occupancy', '84%', const Color(0xFF10B981)),
              _buildStatPill(context, 'Peak Today', '91% (14:00)', const Color(0xFFF59E0B)),
              _buildStatPill(context, 'Critical Threshold', '85%', const Color(0xFFEF4444)),
            ],
          ),

          const SizedBox(height: 20),

          // Custom Chart Render Area
          SizedBox(
            height: 180,
            width: double.infinity,
            child: CustomPaint(
              painter: _LineChartPainter(
                data: _currentData,
                labels: _currentLabels,
                thresholdValue: 85.0,
                lineColor: AppTheme.primaryColor,
                isDark: isDark,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatPill(BuildContext context, String label, String value, Color color) {
    final isDark = HealthifyGlassTheme.isDarkMode(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: isDark ? 0.2 : 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: isDark ? 0.4 : 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            '$label: ',
            style: TextStyle(fontSize: 11.5, color: isDark ? Colors.white70 : AppTheme.textSecondary),
          ),
          Text(
            value,
            style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: color),
          ),
        ],
      ),
    );
  }
}

class PatientActivityTrendChart extends StatefulWidget {
  const PatientActivityTrendChart({super.key});

  @override
  State<PatientActivityTrendChart> createState() => _PatientActivityTrendChartState();
}

class _PatientActivityTrendChartState extends State<PatientActivityTrendChart> {
  // Multi-series metrics
  final List<double> _admissions = [12, 18, 25, 30, 42, 38, 24];
  final List<double> _discharges = [8, 14, 20, 28, 35, 40, 30];
  final List<double> _emergency = [5, 10, 15, 22, 18, 12, 8];
  final List<String> _days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  @override
  Widget build(BuildContext context) {
    final isDark = HealthifyGlassTheme.isDarkMode(context);

    return GlassCard(
      padding: const EdgeInsets.all(20.0),
      borderRadius: 20,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 12,
            runSpacing: 10,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const GlassIconContainer(
                        icon: Icons.timeline_rounded,
                        color: AppTheme.accentColor,
                        size: 34,
                        iconSize: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Weekly Patient Activity Trend',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : AppTheme.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Admissions, discharges & emergency visit volume comparison',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? Colors.white70 : AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),

              // Chart Legends
              Wrap(
                spacing: 12,
                children: [
                  _buildLegend(context, 'Admissions', AppTheme.primaryColor),
                  _buildLegend(context, 'Discharges', const Color(0xFF10B981)),
                  _buildLegend(context, 'ER Visits', const Color(0xFFEF4444)),
                ],
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Dual Line Chart
          SizedBox(
            height: 180,
            width: double.infinity,
            child: CustomPaint(
              painter: _MultiSeriesChartPainter(
                series: [
                  _SeriesData(data: _admissions, color: AppTheme.primaryColor),
                  _SeriesData(data: _discharges, color: const Color(0xFF10B981)),
                  _SeriesData(data: _emergency, color: const Color(0xFFEF4444)),
                ],
                labels: _days,
                isDark: isDark,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegend(BuildContext context, String title, Color color) {
    final isDark = HealthifyGlassTheme.isDarkMode(context);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(3)),
        ),
        const SizedBox(width: 4),
        Text(
          title,
          style: TextStyle(
            fontSize: 11.5,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white70 : AppTheme.textSecondary,
          ),
        ),
      ],
    );
  }
}

class _SeriesData {
  final List<double> data;
  final Color color;

  _SeriesData({required this.data, required this.color});
}

class _LineChartPainter extends CustomPainter {
  final List<double> data;
  final List<String> labels;
  final double thresholdValue;
  final Color lineColor;
  final bool isDark;

  _LineChartPainter({
    required this.data,
    required this.labels,
    required this.thresholdValue,
    required this.lineColor,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double paddingLeft = 30;
    final double paddingBottom = 25;
    final double paddingTop = 15;
    final double paddingRight = 15;

    final double chartWidth = size.width - paddingLeft - paddingRight;
    final double chartHeight = size.height - paddingTop - paddingBottom;

    final double maxVal = 100.0;
    final double minVal = 0.0;

    // Grid lines
    final Paint gridPaint = Paint()
      ..color = isDark ? Colors.white12 : AppTheme.borderLight
      ..strokeWidth = 1;

    final TextPainter textPainter = TextPainter(textDirection: TextDirection.ltr);

    for (int i = 0; i <= 4; i++) {
      final double val = minVal + (maxVal - minVal) * (i / 4);
      final double y = paddingTop + chartHeight - (chartHeight * (i / 4));

      canvas.drawLine(Offset(paddingLeft, y), Offset(size.width - paddingRight, y), gridPaint);

      textPainter.text = TextSpan(
        text: '${val.toInt()}%',
        style: TextStyle(color: isDark ? Colors.white38 : AppTheme.textMuted, fontSize: 10),
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(0, y - 6));
    }

    // Threshold Line
    final double thresholdY = paddingTop + chartHeight - (chartHeight * (thresholdValue / maxVal));
    final Paint thresholdPaint = Paint()
      ..color = const Color(0xFFEF4444).withValues(alpha: 0.6)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    // Draw dashed line for threshold
    final double dashWidth = 5;
    final double dashSpace = 3;
    double startX = paddingLeft;
    while (startX < size.width - paddingRight) {
      canvas.drawLine(
        Offset(startX, thresholdY),
        Offset(startX + dashWidth, thresholdY),
        thresholdPaint,
      );
      startX += dashWidth + dashSpace;
    }

    if (data.isEmpty) return;

    final double dx = chartWidth / (data.length - 1);
    final Path path = Path();
    final List<Offset> points = [];

    for (int i = 0; i < data.length; i++) {
      final double x = paddingLeft + (i * dx);
      final double normalized = (data[i] - minVal) / (maxVal - minVal);
      final double y = paddingTop + chartHeight - (chartHeight * normalized);
      points.add(Offset(x, y));

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        final double prevX = points[i - 1].dx;
        final double prevY = points[i - 1].dy;
        final double controlX1 = prevX + (x - prevX) / 2;
        path.cubicTo(controlX1, prevY, controlX1, y, x, y);
      }
    }

    // Gradient area under curve
    final Path fillPath = Path.from(path);
    fillPath.lineTo(points.last.dx, paddingTop + chartHeight);
    fillPath.lineTo(points.first.dx, paddingTop + chartHeight);
    fillPath.close();

    final Paint fillPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          lineColor.withValues(alpha: 0.3),
          lineColor.withValues(alpha: 0.0),
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(paddingLeft, paddingTop, chartWidth, chartHeight));

    canvas.drawPath(fillPath, fillPaint);

    // Main line stroke
    final Paint linePaint = Paint()
      ..color = lineColor
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(path, linePaint);

    // Data points & X-Labels
    for (int i = 0; i < points.length; i++) {
      final point = points[i];

      // Draw dot
      final Paint dotOuter = Paint()..color = isDark ? const Color(0xFF0F2928) : Colors.white;
      final Paint dotInner = Paint()..color = data[i] >= thresholdValue ? const Color(0xFFEF4444) : lineColor;

      canvas.drawCircle(point, 5, dotOuter);
      canvas.drawCircle(point, 3.5, dotInner);

      // X Label
      if (i % 2 == 0 || data.length <= 7) {
        textPainter.text = TextSpan(
          text: labels[i],
          style: TextStyle(color: isDark ? Colors.white60 : AppTheme.textSecondary, fontSize: 10, fontWeight: FontWeight.w500),
        );
        textPainter.layout();
        textPainter.paint(canvas, Offset(point.dx - (textPainter.width / 2), size.height - 15));
      }
    }
  }

  @override
  bool shouldRepaint(covariant _LineChartPainter oldDelegate) => true;
}

class _MultiSeriesChartPainter extends CustomPainter {
  final List<_SeriesData> series;
  final List<String> labels;
  final bool isDark;

  _MultiSeriesChartPainter({
    required this.series,
    required this.labels,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double paddingLeft = 30;
    final double paddingBottom = 25;
    final double paddingTop = 15;
    final double paddingRight = 15;

    final double chartWidth = size.width - paddingLeft - paddingRight;
    final double chartHeight = size.height - paddingTop - paddingBottom;

    final double maxVal = 50.0;
    final double minVal = 0.0;

    // Grid lines
    final Paint gridPaint = Paint()
      ..color = isDark ? Colors.white12 : AppTheme.borderLight
      ..strokeWidth = 1;

    final TextPainter textPainter = TextPainter(textDirection: TextDirection.ltr);

    for (int i = 0; i <= 4; i++) {
      final double val = minVal + (maxVal - minVal) * (i / 4);
      final double y = paddingTop + chartHeight - (chartHeight * (i / 4));

      canvas.drawLine(Offset(paddingLeft, y), Offset(size.width - paddingRight, y), gridPaint);

      textPainter.text = TextSpan(
        text: '${val.toInt()}',
        style: TextStyle(color: isDark ? Colors.white38 : AppTheme.textMuted, fontSize: 10),
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(5, y - 6));
    }

    if (series.isEmpty || labels.isEmpty) return;

    final double dx = chartWidth / (labels.length - 1);

    for (var s in series) {
      final Path path = Path();
      final List<Offset> points = [];

      for (int i = 0; i < s.data.length; i++) {
        final double x = paddingLeft + (i * dx);
        final double normalized = (s.data[i] - minVal) / (maxVal - minVal);
        final double y = paddingTop + chartHeight - (chartHeight * normalized);
        points.add(Offset(x, y));

        if (i == 0) {
          path.moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }
      }

      final Paint linePaint = Paint()
        ..color = s.color
        ..strokeWidth = 2.5
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;

      canvas.drawPath(path, linePaint);

      for (var pt in points) {
        canvas.drawCircle(pt, 3, Paint()..color = isDark ? const Color(0xFF0F2928) : Colors.white);
        canvas.drawCircle(pt, 2, Paint()..color = s.color);
      }
    }

    // X Labels
    for (int i = 0; i < labels.length; i++) {
      final double x = paddingLeft + (i * dx);
      textPainter.text = TextSpan(
        text: labels[i],
        style: TextStyle(color: isDark ? Colors.white60 : AppTheme.textSecondary, fontSize: 10, fontWeight: FontWeight.w500),
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(x - (textPainter.width / 2), size.height - 15));
    }
  }

  @override
  bool shouldRepaint(covariant _MultiSeriesChartPainter oldDelegate) => true;
}