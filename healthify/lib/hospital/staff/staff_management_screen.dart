import 'package:flutter/material.dart';
import '../../core/core.dart';
import '../../shared/widgets/glass_components.dart';

class StaffManagementScreen extends StatefulWidget {
  const StaffManagementScreen({super.key});

  @override
  State<StaffManagementScreen> createState() => _StaffManagementScreenState();
}

class _StaffManagementScreenState extends State<StaffManagementScreen> {
  UiState<List<StaffModel>> _uiState = UiState.initial();
  String _searchQuery = '';
  String _selectedRole = 'All';

  @override
  void initState() {
    super.initState();
    _loadStaff();
  }

  Future<void> _loadStaff() async {
    setState(() => _uiState = UiState.loading());
    try {
      final repository = RepositoryScope.of(context).staffRepository;
      final staffList = await repository.getStaffList();
      if (mounted) {
        setState(() => _uiState = staffList.isEmpty ? UiState.empty() : UiState.success(staffList));
      }
    } catch (e) {
      if (mounted) {
        setState(() => _uiState = UiState.error('Failed to load staff list: $e'));
      }
    }
  }

  List<StaffModel> get _filteredStaff {
    final list = _uiState.data ?? [];
    return list.where((s) {
      final matchesSearch = s.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          s.department.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          s.phone.contains(_searchQuery);
      final matchesRole = _selectedRole == 'All' || s.role.name.toLowerCase() == _selectedRole.toLowerCase();
      return matchesSearch && matchesRole;
    }).toList();
  }

  void _showAddStaffModal([StaffModel? existing]) {
    final isDark = HealthifyGlassTheme.isDarkMode(context);
    final nameController = TextEditingController(text: existing?.name ?? '');
    final departmentController = TextEditingController(text: existing?.department ?? 'General Ward');
    final phoneController = TextEditingController(text: existing?.phone ?? '');
    final shiftController = TextEditingController(text: existing?.shift ?? 'Morning (07:00 - 15:00)');
    StaffRole selectedRole = existing?.role ?? StaffRole.nurse;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => AlertDialog(
          backgroundColor: isDark
              ? HealthifyGlassTheme.darkBackground.withValues(alpha: 0.95)
              : Colors.white.withValues(alpha: 0.95),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(existing == null ? 'Add Staff Member' : 'Edit Staff Member', style: const TextStyle(fontWeight: FontWeight.bold)),
          content: SizedBox(
            width: 500,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: 'Full Name'),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<StaffRole>(
                    isExpanded: true,
                    initialValue: selectedRole,
                    decoration: const InputDecoration(labelText: 'Role'),
                    items: StaffRole.values.map((role) {
                      return DropdownMenuItem(
                        value: role,
                        child: Text(role.name.toUpperCase()),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) setModalState(() => selectedRole = val);
                    },
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: departmentController,
                    decoration: const InputDecoration(labelText: 'Assigned Department'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: phoneController,
                    decoration: const InputDecoration(labelText: 'Contact Phone Number'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: shiftController,
                    decoration: const InputDecoration(labelText: 'Shift Schedule (e.g. Day Shift)'),
                  ),
                ],
              ),
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
                final repository = RepositoryScope.of(context).staffRepository;
                if (existing == null) {
                  final newStaff = StaffModel(
                    id: 'STF-${DateTime.now().millisecondsSinceEpoch}',
                    name: nameController.text,
                    role: selectedRole,
                    department: departmentController.text,
                    status: StaffStatus.active,
                    phone: phoneController.text,
                    shift: shiftController.text,
                  );
                  await repository.addStaff(newStaff);
                } else {
                  final updated = StaffModel(
                    id: existing.id,
                    name: nameController.text,
                    role: selectedRole,
                    department: departmentController.text,
                    status: existing.status,
                    phone: phoneController.text,
                    shift: shiftController.text,
                  );
                  await repository.updateStaff(updated);
                }
                _loadStaff();
              },
              child: Text(existing == null ? 'Add Staff' : 'Save Changes'),
            ),
          ],
        ),
      ),
    );
  }

  void _updateStatus(StaffModel staff, StaffStatus newStatus) async {
    final repository = RepositoryScope.of(context).staffRepository;
    await repository.updateStaffStatus(staff.id, newStatus);
    _loadStaff();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = HealthifyGlassTheme.isDarkMode(context);
    final isDesktop = MediaQuery.of(context).size.width >= 850;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 12,
            runSpacing: 12,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hospital Staff Management',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: HealthifyGlassTheme.getTextPrimary(isDark),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Operational staffing, roles, and shift assignments',
                    style: TextStyle(fontSize: 13, color: HealthifyGlassTheme.getTextSecondary(isDark)),
                  ),
                ],
              ),
              GlassPrimaryButton(
                height: 42,
                onPressed: () => _showAddStaffModal(),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.person_add_rounded, size: 18),
                    SizedBox(width: 6),
                    Text('Add Staff Member'),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Toolbar
          GlassCard(
            borderRadius: 18,
            padding: const EdgeInsets.all(14),
            child: Wrap(
              spacing: 12,
              runSpacing: 12,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                SizedBox(
                  width: 300,
                  child: TextField(
                    onChanged: (val) => setState(() => _searchQuery = val),
                    decoration: GlassTextFieldTheme.getDecoration(
                      context: context,
                      hintText: 'Search staff by name or dept...',
                      prefixIcon: const Icon(Icons.search_rounded),
                    ),
                  ),
                ),
                DropdownButton<String>(
                  value: _selectedRole,
                  underline: const SizedBox(),
                  dropdownColor: isDark ? const Color(0xFF0F2928) : Colors.white,
                  items: ['All', 'Nurse', 'Technician', 'Pharmacist', 'Administrative', 'Support'].map((role) {
                    return DropdownMenuItem(
                      value: role,
                      child: Text('Role: $role', style: TextStyle(color: HealthifyGlassTheme.getTextPrimary(isDark), fontSize: 13)),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedRole = val);
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // States
          if (_uiState.isLoading)
            const HealthifyLoadingState(message: 'Loading staff directory...')
          else if (_uiState.isError)
            HealthifyErrorState(errorMessage: _uiState.errorMessage ?? 'Error', onRetry: _loadStaff)
          else if (_filteredStaff.isEmpty)
            HealthifyEmptyState(
              title: 'No Staff Found',
              description: 'No active staff records match your criteria.',
              icon: Icons.people_outline_rounded,
              actionLabel: 'Add Staff Member',
              onAction: () => _showAddStaffModal(),
            )
          else if (isDesktop)
            _buildDesktopTable(isDark)
          else
            _buildMobileCards(isDark),
        ],
      ),
    );
  }

  Widget _buildDesktopTable(bool isDark) {
    return GlassCard(
      padding: EdgeInsets.zero,
      borderRadius: 20,
      child: DataTable(
        headingRowHeight: 52,
        dataRowMinHeight: 64,
        dataRowMaxHeight: 64,
        columns: const [
          DataColumn(label: Text('Staff Member', style: TextStyle(fontWeight: FontWeight.bold))),
          DataColumn(label: Text('Role & Department', style: TextStyle(fontWeight: FontWeight.bold))),
          DataColumn(label: Text('Shift Schedule', style: TextStyle(fontWeight: FontWeight.bold))),
          DataColumn(label: Text('Status', style: TextStyle(fontWeight: FontWeight.bold))),
          DataColumn(label: Text('Actions', style: TextStyle(fontWeight: FontWeight.bold))),
        ],
        rows: _filteredStaff.map((staff) {
          return DataRow(
            cells: [
              DataCell(
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(staff.name, style: TextStyle(fontWeight: FontWeight.bold, color: HealthifyGlassTheme.getTextPrimary(isDark))),
                    Text(staff.phone, style: TextStyle(fontSize: 11.5, color: HealthifyGlassTheme.getTextSecondary(isDark))),
                  ],
                ),
              ),
              DataCell(
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(staff.role.name.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: HealthifyGlassTheme.primaryTeal)),
                    Text(staff.department, style: TextStyle(fontSize: 12.5, color: HealthifyGlassTheme.getTextPrimary(isDark))),
                  ],
                ),
              ),
              DataCell(
                Text(staff.shift, style: TextStyle(fontSize: 12.5, color: HealthifyGlassTheme.getTextPrimary(isDark))),
              ),
              DataCell(
                DropdownButton<StaffStatus>(
                  value: staff.status,
                  underline: const SizedBox(),
                  dropdownColor: isDark ? const Color(0xFF0F2928) : Colors.white,
                  items: StaffStatus.values.map((st) {
                    return DropdownMenuItem(
                      value: st,
                      child: Text(st.name.toUpperCase(), style: const TextStyle(fontSize: 12)),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) _updateStatus(staff, val);
                  },
                ),
              ),
              DataCell(
                IconButton(
                  icon: const Icon(Icons.edit_outlined, size: 18),
                  onPressed: () => _showAddStaffModal(staff),
                  tooltip: 'Edit Staff Member',
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildMobileCards(bool isDark) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _filteredStaff.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final staff = _filteredStaff[index];
        return GlassCard(
          padding: const EdgeInsets.all(16),
          borderRadius: 16,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      staff.name,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: HealthifyGlassTheme.getTextPrimary(isDark),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit_outlined, size: 18),
                    onPressed: () => _showAddStaffModal(staff),
                  ),
                ],
              ),
              Text('${staff.role.name.toUpperCase()} • ${staff.department}', style: const TextStyle(fontSize: 12, color: HealthifyGlassTheme.primaryTeal, fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              Text('Shift: ${staff.shift}', style: TextStyle(fontSize: 12, color: HealthifyGlassTheme.getTextSecondary(isDark))),
            ],
          ),
        );
      },
    );
  }
}
