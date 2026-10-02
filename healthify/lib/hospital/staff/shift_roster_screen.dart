import 'package:flutter/material.dart';
import '../../core/core.dart';
import '../../shared/widgets/glass_components.dart';

class ShiftRosterScreen extends StatefulWidget {
  const ShiftRosterScreen({super.key});

  @override
  State<ShiftRosterScreen> createState() => _ShiftRosterScreenState();
}

class _ShiftRosterScreenState extends State<ShiftRosterScreen> {
  UiState<List<ShiftRoster>> _uiState = UiState.initial();

  @override
  void initState() {
    super.initState();
    _loadRoster();
  }

  Future<void> _loadRoster() async {
    setState(() => _uiState = UiState.loading());
    try {
      final repository = RepositoryScope.of(context).shiftRosterRepository;
      final roster = await repository.getShiftRoster();
      if (mounted) {
        setState(() => _uiState = roster.isEmpty ? UiState.empty() : UiState.success(roster));
      }
    } catch (e) {
      if (mounted) {
        setState(() => _uiState = UiState.error('Failed to load shift roster: $e'));
      }
    }
  }

  void _showCreateShiftModal() {
    final isDark = HealthifyGlassTheme.isDarkMode(context);
    final staffIdController = TextEditingController(text: 'STF-301');
    final wardController = TextEditingController(text: 'ICU Main Wing');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark
            ? HealthifyGlassTheme.darkBackground.withValues(alpha: 0.95)
            : Colors.white.withValues(alpha: 0.95),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Create Shift Roster Entry', style: TextStyle(fontWeight: FontWeight.bold)),
        content: SizedBox(
          width: 450,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: staffIdController,
                decoration: const InputDecoration(labelText: 'Staff ID (e.g. STF-301)'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: wardController,
                decoration: const InputDecoration(labelText: 'Assigned Ward / Unit'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          GlassPrimaryButton(
            height: 42,
            onPressed: () async {
              Navigator.pop(context);
              final repository = RepositoryScope.of(context).shiftRosterRepository;
              final newShift = ShiftRoster(
                id: 'SFT-${DateTime.now().millisecondsSinceEpoch}',
                staffId: staffIdController.text,
                hospitalId: 'HOSP-101',
                startTime: DateTime.now(),
                endTime: DateTime.now().add(const Duration(hours: 8)),
                shiftStatus: ShiftStatus.scheduled,
                ward: wardController.text,
                createdAt: DateTime.now(),
                updatedAt: DateTime.now(),
              );
              await repository.createShift(newShift);
              _loadRoster();
            },
            child: const Text('Create Shift'),
          ),
        ],
      ),
    );
  }

  void _cancelShift(String shiftId) async {
    final repository = RepositoryScope.of(context).shiftRosterRepository;
    await repository.cancelShift(shiftId);
    _loadRoster();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = HealthifyGlassTheme.isDarkMode(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Operational Shift Roster',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: HealthifyGlassTheme.getTextPrimary(isDark),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Daily/Weekly staffing schedule, on-call coverage, and shift status',
                    style: TextStyle(fontSize: 13, color: HealthifyGlassTheme.getTextSecondary(isDark)),
                  ),
                ],
              ),
              GlassPrimaryButton(
                height: 42,
                onPressed: _showCreateShiftModal,
                child: const Row(
                  children: [
                    Icon(Icons.calendar_today_rounded, size: 18),
                    SizedBox(width: 6),
                    Text('Create Shift'),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Shift List View
          if (_uiState.isLoading)
            const MedrixLoadingState(message: 'Loading operational shift roster...')
          else if (_uiState.isError)
            MedrixErrorState(errorMessage: _uiState.errorMessage ?? 'Error', onRetry: _loadRoster)
          else if (_uiState.isEmpty || (_uiState.data?.isEmpty ?? true))
            MedrixEmptyState(
              title: 'No Active Roster',
              description: 'No shifts currently scheduled.',
              icon: Icons.calendar_month_rounded,
              actionLabel: 'Create Shift',
              onAction: _showCreateShiftModal,
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _uiState.data!.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final shift = _uiState.data![index];
                return GlassCard(
                  padding: const EdgeInsets.all(16),
                  borderRadius: 16,
                  child: Row(
                    children: [
                      GlassIconContainer(
                        icon: Icons.schedule_rounded,
                        color: shift.shiftStatus == ShiftStatus.inProgress
                            ? const Color(0xFF10B981)
                            : HealthifyGlassTheme.primaryTeal,
                        size: 40,
                        iconSize: 20,
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Staff ID: ${shift.staffId} • Ward: ${shift.ward}',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: HealthifyGlassTheme.getTextPrimary(isDark)),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${shift.startTime.hour}:00 - ${shift.endTime.hour}:00 • Status: ${shift.shiftStatus.name.toUpperCase()}',
                              style: TextStyle(fontSize: 12, color: HealthifyGlassTheme.getTextSecondary(isDark)),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.cancel_outlined, color: Colors.redAccent, size: 18),
                        onPressed: () => _cancelShift(shift.id),
                        tooltip: 'Cancel Shift',
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}
