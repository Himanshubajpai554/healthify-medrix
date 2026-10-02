import 'package:flutter/material.dart';
import '../../../shared/widgets/glass_components.dart';
import '../../models/followup_models.dart';

enum CalendarMode { day, week, month }

class FollowUpCalendarView extends StatefulWidget {
  final List<DoctorFollowUpFullModel> followUps;
  final ValueChanged<DoctorFollowUpFullModel> onSelectFollowUp;

  const FollowUpCalendarView({
    super.key,
    required this.followUps,
    required this.onSelectFollowUp,
  });

  @override
  State<FollowUpCalendarView> createState() => _FollowUpCalendarViewState();
}

class _FollowUpCalendarViewState extends State<FollowUpCalendarView> {
  CalendarMode _calendarMode = CalendarMode.month;
  DateTime _focusedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final isDark = HealthifyGlassTheme.isDarkMode(context);

    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Calendar Header controls
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_left_rounded),
                    onPressed: () {
                      setState(() {
                        if (_calendarMode == CalendarMode.month) {
                          _focusedDate = DateTime(_focusedDate.year, _focusedDate.month - 1, 1);
                        } else if (_calendarMode == CalendarMode.week) {
                          _focusedDate = _focusedDate.subtract(const Duration(days: 7));
                        } else {
                          _focusedDate = _focusedDate.subtract(const Duration(days: 1));
                        }
                      });
                    },
                  ),
                  Text(
                    _getCalendarHeaderTitle(),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.chevron_right_rounded),
                    onPressed: () {
                      setState(() {
                        if (_calendarMode == CalendarMode.month) {
                          _focusedDate = DateTime(_focusedDate.year, _focusedDate.month + 1, 1);
                        } else if (_calendarMode == CalendarMode.week) {
                          _focusedDate = _focusedDate.add(const Duration(days: 7));
                        } else {
                          _focusedDate = _focusedDate.add(const Duration(days: 1));
                        }
                      });
                    },
                  ),
                  TextButton(
                    onPressed: () => setState(() => _focusedDate = DateTime.now()),
                    child: const Text('Today'),
                  ),
                ],
              ),
              // View mode selector
              SegmentedButton<CalendarMode>(
                segments: const [
                  ButtonSegment(value: CalendarMode.day, label: Text('Day')),
                  ButtonSegment(value: CalendarMode.week, label: Text('Week')),
                  ButtonSegment(value: CalendarMode.month, label: Text('Month')),
                ],
                selected: {_calendarMode},
                onSelectionChanged: (val) {
                  setState(() => _calendarMode = val.first);
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(height: 1),
          const SizedBox(height: 16),

          // Calendar Grid / List based on selected mode
          if (_calendarMode == CalendarMode.month)
            _buildMonthGrid(isDark)
          else if (_calendarMode == CalendarMode.week)
            _buildWeekView(isDark)
          else
            _buildDayView(isDark),
        ],
      ),
    );
  }

  String _getCalendarHeaderTitle() {
    final months = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'];
    if (_calendarMode == CalendarMode.month) {
      return '${months[_focusedDate.month - 1]} ${_focusedDate.year}';
    } else if (_calendarMode == CalendarMode.week) {
      final start = _focusedDate.subtract(Duration(days: _focusedDate.weekday - 1));
      final end = start.add(const Duration(days: 6));
      return '${start.day} ${months[start.month - 1]} - ${end.day} ${months[end.month - 1]} ${_focusedDate.year}';
    } else {
      return '${_focusedDate.day} ${months[_focusedDate.month - 1]} ${_focusedDate.year}';
    }
  }

  Widget _buildMonthGrid(bool isDark) {
    final daysInMonth = DateUtils.getDaysInMonth(_focusedDate.year, _focusedDate.month);
    final firstDayWeekday = DateTime(_focusedDate.year, _focusedDate.month, 1).weekday;
    final weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    return Column(
      children: [
        // Weekday labels
        Row(
          children: weekdays.map((w) {
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Text(
                  w,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white60 : const Color(0xFF64748B),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 8),

        // Days Grid
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: daysInMonth + (firstDayWeekday - 1),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            childAspectRatio: 1.2,
            mainAxisSpacing: 6,
            crossAxisSpacing: 6,
          ),
          itemBuilder: (context, index) {
            if (index < firstDayWeekday - 1) {
              return const SizedBox();
            }

            final day = index - (firstDayWeekday - 1) + 1;
            final date = DateTime(_focusedDate.year, _focusedDate.month, day);
            final isToday = DateUtils.isSameDay(date, DateTime.now());
            final dayEvents = widget.followUps.where((f) => DateUtils.isSameDay(f.followUpDate, date)).toList();

            return Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: isToday
                    ? const Color(0xFF0D9488).withValues(alpha: 0.15)
                    : (isDark ? Colors.white.withValues(alpha: 0.03) : const Color(0xFFF8FAFC)),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isToday
                      ? const Color(0xFF0D9488)
                      : (isDark ? Colors.white12 : const Color(0xFFE2E8F0)),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$day',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                      color: isToday
                          ? const Color(0xFF0D9488)
                          : (isDark ? Colors.white : const Color(0xFF0F172A)),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: dayEvents.map((e) {
                          return InkWell(
                            onTap: () => widget.onSelectFollowUp(e),
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 2),
                              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                              decoration: BoxDecoration(
                                color: e.status.color.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                '${e.followUpTime} - ${e.patientName}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.bold,
                                  color: e.status.color,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildWeekView(bool isDark) {
    final startOfWeek = _focusedDate.subtract(Duration(days: _focusedDate.weekday - 1));
    final weekDays = List.generate(7, (i) => startOfWeek.add(Duration(days: i)));

    return Column(
      children: weekDays.map((d) {
        final events = widget.followUps.where((f) => DateUtils.isSameDay(f.followUpDate, d)).toList();
        final isToday = DateUtils.isSameDay(d, DateTime.now());

        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isToday
                ? const Color(0xFF0D9488).withValues(alpha: 0.1)
                : (isDark ? Colors.white.withValues(alpha: 0.03) : const Color(0xFFF8FAFC)),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: isToday ? const Color(0xFF0D9488) : (isDark ? Colors.white12 : const Color(0xFFE2E8F0))),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 100,
                child: Text(
                  '${d.day}/${d.month} (${_weekdayName(d.weekday)})',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: isToday ? const Color(0xFF0D9488) : (isDark ? Colors.white : const Color(0xFF0F172A)),
                  ),
                ),
              ),
              Expanded(
                child: events.isEmpty
                    ? Text('No follow-ups scheduled', style: TextStyle(fontSize: 12, color: isDark ? Colors.white38 : const Color(0xFF94A3B8)))
                    : Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        children: events.map((e) {
                          return ActionChip(
                            avatar: Icon(Icons.circle, size: 8, color: e.status.color),
                            label: Text('${e.followUpTime} • ${e.patientName} (${e.department})'),
                            onPressed: () => widget.onSelectFollowUp(e),
                          );
                        }).toList(),
                      ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDayView(bool isDark) {
    final events = widget.followUps.where((f) => DateUtils.isSameDay(f.followUpDate, _focusedDate)).toList();

    if (events.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(32),
        child: Center(
          child: Text(
            'No follow-ups scheduled for this day.',
            style: TextStyle(fontSize: 14, color: isDark ? Colors.white54 : const Color(0xFF64748B)),
          ),
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: events.length,
      separatorBuilder: (context, index) => const Divider(height: 12),
      itemBuilder: (context, index) {
        final e = events[index];
        return ListTile(
          onTap: () => widget.onSelectFollowUp(e),
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: e.status.color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(8)),
            child: Icon(Icons.event_repeat_rounded, color: e.status.color, size: 20),
          ),
          title: Text(e.patientName, style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? Colors.white : const Color(0xFF0F172A))),
          subtitle: Text('${e.followUpTime} • ${e.department} • ${e.reason}'),
          trailing: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(color: e.status.color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(6)),
            child: Text(e.status.label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: e.status.color)),
          ),
        );
      },
    );
  }

  String _weekdayName(int day) {
    const names = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return names[day - 1];
  }
}
