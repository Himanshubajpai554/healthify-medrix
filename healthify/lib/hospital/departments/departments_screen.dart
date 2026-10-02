import 'package:flutter/material.dart';
import '../../core/core.dart';
import '../../shared/widgets/glass_components.dart';

class DepartmentsScreen extends StatefulWidget {
  const DepartmentsScreen({super.key});

  @override
  State<DepartmentsScreen> createState() => _DepartmentsScreenState();
}

class _DepartmentsScreenState extends State<DepartmentsScreen> {
  UiState<List<Department>> _uiState = UiState.initial();
  String _searchQuery = '';
  String _selectedStatus = 'All';

  @override
  void initState() {
    super.initState();
    _loadDepartments();
  }

  Future<void> _loadDepartments() async {
    setState(() => _uiState = UiState.loading());
    try {
      final repository = RepositoryScope.of(context).departmentRepository;
      final departments = await repository.getDepartments('HOSP-101');
      if (mounted) {
        setState(() => _uiState = departments.isEmpty ? UiState.empty() : UiState.success(departments));
      }
    } catch (e) {
      if (mounted) {
        setState(() => _uiState = UiState.error('Failed to load departments: $e'));
      }
    }
  }

  List<Department> get _filteredDepartments {
    final list = _uiState.data ?? [];
    return list.where((d) {
      final matchesSearch = d.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          d.code.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          d.description.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesStatus = _selectedStatus == 'All' ||
          (_selectedStatus == 'Active' && d.isActive) ||
          (_selectedStatus == 'Inactive' && !d.isActive);
      return matchesSearch && matchesStatus;
    }).toList();
  }

  void _showAddOrEditDepartmentModal([Department? existing]) {
    final isDark = HealthifyGlassTheme.isDarkMode(context);
    final nameController = TextEditingController(text: existing?.name ?? '');
    final codeController = TextEditingController(text: existing?.code ?? '');
    final descriptionController = TextEditingController(text: existing?.description ?? '');
    final locationController = TextEditingController(text: existing?.location ?? '');
    final phoneController = TextEditingController(text: existing?.contactPhone ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark
            ? HealthifyGlassTheme.darkBackground.withValues(alpha: 0.95)
            : Colors.white.withValues(alpha: 0.95),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(existing == null ? 'Add New Department' : 'Edit Department', style: const TextStyle(fontWeight: FontWeight.bold)),
        content: SizedBox(
          width: 500,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Department Name (e.g. Cardiology)'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: codeController,
                  decoration: const InputDecoration(labelText: 'Department Code (e.g. CARD)'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: locationController,
                  decoration: const InputDecoration(labelText: 'Building & Floor Location'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: phoneController,
                  decoration: const InputDecoration(labelText: 'Contact Extension / Phone'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: descriptionController,
                  maxLines: 2,
                  decoration: const InputDecoration(labelText: 'Description'),
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
              final repository = RepositoryScope.of(context).departmentRepository;
              if (existing == null) {
                final newDep = Department(
                  id: 'DEP-${DateTime.now().millisecondsSinceEpoch}',
                  hospitalId: 'HOSP-101',
                  name: nameController.text,
                  code: codeController.text,
                  description: descriptionController.text,
                  location: locationController.text,
                  contactPhone: phoneController.text,
                  totalStaff: 20,
                  doctorCount: 5,
                  createdAt: DateTime.now(),
                  updatedAt: DateTime.now(),
                );
                await repository.createDepartment(newDep);
              } else {
                final updated = existing.copyWith(
                  name: nameController.text,
                  code: codeController.text,
                  description: descriptionController.text,
                  location: locationController.text,
                  contactPhone: phoneController.text,
                );
                await repository.updateDepartment(updated);
              }
              _loadDepartments();
            },
            child: Text(existing == null ? 'Create Department' : 'Save Changes'),
          ),
        ],
      ),
    );
  }

  void _toggleDepartmentStatus(Department department) async {
    final repository = RepositoryScope.of(context).departmentRepository;
    await repository.updateDepartmentStatus(department.id, !department.isActive);
    _loadDepartments();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Department "${department.name}" status updated.')),
      );
    }
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Department Management',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: HealthifyGlassTheme.getTextPrimary(isDark),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Configure hospital departments, staffing, and clinical leadership',
                    style: TextStyle(fontSize: 13, color: HealthifyGlassTheme.getTextSecondary(isDark)),
                  ),
                ],
              ),
              GlassPrimaryButton(
                height: 42,
                onPressed: () => _showAddOrEditDepartmentModal(),
                child: const Row(
                  children: [
                    Icon(Icons.add_rounded, size: 18),
                    SizedBox(width: 6),
                    Text('Add Department'),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Search & Filter Toolbar
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
                      hintText: 'Search departments...',
                      prefixIcon: const Icon(Icons.search_rounded),
                    ),
                  ),
                ),
                DropdownButton<String>(
                  value: _selectedStatus,
                  underline: const SizedBox(),
                  dropdownColor: isDark ? const Color(0xFF0F2928) : Colors.white,
                  items: ['All', 'Active', 'Inactive'].map((status) {
                    return DropdownMenuItem(
                      value: status,
                      child: Text('Status: $status', style: TextStyle(color: HealthifyGlassTheme.getTextPrimary(isDark), fontSize: 13)),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedStatus = val);
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Content States
          if (_uiState.isLoading)
            const MedrixLoadingState(message: 'Loading department matrix...')
          else if (_uiState.isError)
            MedrixErrorState(errorMessage: _uiState.errorMessage ?? 'Error', onRetry: _loadDepartments)
          else if (_filteredDepartments.isEmpty)
            MedrixEmptyState(
              title: 'No Departments Found',
              description: 'No medical departments match your query filter.',
              icon: Icons.corporate_fare_rounded,
              actionLabel: 'Add Department',
              onAction: () => _showAddOrEditDepartmentModal(),
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
          DataColumn(label: Text('Code & Name', style: TextStyle(fontWeight: FontWeight.bold))),
          DataColumn(label: Text('Location & Phone', style: TextStyle(fontWeight: FontWeight.bold))),
          DataColumn(label: Text('Doctors / Staff', style: TextStyle(fontWeight: FontWeight.bold))),
          DataColumn(label: Text('Status', style: TextStyle(fontWeight: FontWeight.bold))),
          DataColumn(label: Text('Actions', style: TextStyle(fontWeight: FontWeight.bold))),
        ],
        rows: _filteredDepartments.map((dep) {
          final isDepActive = dep.isActive;
          return DataRow(
            cells: [
              DataCell(
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: HealthifyGlassTheme.primaryTeal.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            dep.code,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: HealthifyGlassTheme.primaryTeal),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(dep.name, style: TextStyle(fontWeight: FontWeight.bold, color: HealthifyGlassTheme.getTextPrimary(isDark))),
                      ],
                    ),
                    Text(dep.description, style: TextStyle(fontSize: 11.5, color: HealthifyGlassTheme.getTextSecondary(isDark)), maxLines: 1, overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
              DataCell(
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(dep.location ?? 'Main Block', style: TextStyle(fontSize: 12.5, color: HealthifyGlassTheme.getTextPrimary(isDark))),
                    Text(dep.contactPhone ?? 'Ext 101', style: TextStyle(fontSize: 11.5, color: HealthifyGlassTheme.getTextSecondary(isDark))),
                  ],
                ),
              ),
              DataCell(
                Text('${dep.doctorCount} Doctors • ${dep.totalStaff} Staff', style: TextStyle(fontSize: 12.5, color: HealthifyGlassTheme.getTextPrimary(isDark))),
              ),
              DataCell(
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: (isDepActive ? const Color(0xFF10B981) : Colors.grey).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    isDepActive ? 'Active' : 'Inactive',
                    style: TextStyle(
                      color: isDepActive ? const Color(0xFF10B981) : Colors.grey,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
              DataCell(
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit_outlined, size: 18),
                      onPressed: () => _showAddOrEditDepartmentModal(dep),
                      tooltip: 'Edit Department',
                    ),
                    IconButton(
                      icon: Icon(isDepActive ? Icons.block_rounded : Icons.check_circle_outline_rounded, size: 18),
                      color: isDepActive ? Colors.redAccent : const Color(0xFF10B981),
                      onPressed: () => _toggleDepartmentStatus(dep),
                      tooltip: isDepActive ? 'Deactivate' : 'Activate',
                    ),
                  ],
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
      itemCount: _filteredDepartments.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final dep = _filteredDepartments[index];
        return GlassCard(
          padding: const EdgeInsets.all(16),
          borderRadius: 16,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: HealthifyGlassTheme.primaryTeal.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(dep.code, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: HealthifyGlassTheme.primaryTeal)),
                      ),
                      const SizedBox(width: 8),
                      Text(dep.name, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: HealthifyGlassTheme.getTextPrimary(isDark))),
                    ],
                  ),
                  Switch(
                    value: dep.isActive,
                    onChanged: (val) => _toggleDepartmentStatus(dep),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(dep.description, style: TextStyle(fontSize: 12, color: HealthifyGlassTheme.getTextSecondary(isDark))),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('${dep.doctorCount} Doctors • ${dep.totalStaff} Staff', style: TextStyle(fontSize: 12, color: HealthifyGlassTheme.getTextSecondary(isDark))),
                  TextButton.icon(
                    onPressed: () => _showAddOrEditDepartmentModal(dep),
                    icon: const Icon(Icons.edit_outlined, size: 16),
                    label: const Text('Edit'),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
