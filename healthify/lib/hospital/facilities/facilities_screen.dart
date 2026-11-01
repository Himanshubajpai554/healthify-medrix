import 'package:flutter/material.dart';
import '../../core/core.dart';
import '../../shared/widgets/glass_components.dart';
import '../../theme/app_theme.dart';
import './widgets/facility_dialogs.dart';

class FacilitiesScreen extends StatefulWidget {
  const FacilitiesScreen({super.key});

  @override
  State<FacilitiesScreen> createState() => _FacilitiesScreenState();
}

class _FacilitiesScreenState extends State<FacilitiesScreen> {
  int _activeTab = 0; // 0 = Facilities & Services, 1 = Equipment & Maintenance

  // Facility State
  UiState<List<FacilityModel>> _facilityUiState = UiState.initial();
  List<FacilityModel> _facilities = [];
  String _facilitySearchQuery = '';
  String _selectedCategory = 'All';
  String _selectedAvailability = 'All';

  // Equipment State
  UiState<List<Equipment>> _equipmentUiState = UiState.initial();
  List<Equipment> _equipmentList = [];
  String _equipmentSearchQuery = '';
  String _selectedEquipmentStatus = 'All';

  final List<String> _categories = [
    'All',
    'Diagnostic',
    'Emergency',
    'Surgery',
    'Imaging',
    'Laboratory',
    'Pharmacy',
    'Specialized Care',
    'Other'
  ];

  final List<String> _statuses = [
    'All',
    'Available',
    'Limited',
    'Unavailable',
    'Maintenance'
  ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadAllData();
  }

  Future<void> _loadAllData() async {
    _loadFacilities();
    _loadEquipment();
  }

  Future<void> _loadFacilities() async {
    setState(() {
      _facilityUiState = UiState.loading();
    });

    try {
      final repo = RepositoryScope.of(context).facilityRepository;
      final fetched = await repo.getFacilities();
      setState(() {
        _facilities = fetched;
        _facilityUiState = fetched.isEmpty ? UiState.empty() : UiState.success(fetched);
      });
    } catch (e) {
      setState(() {
        _facilityUiState = UiState.error('Failed to load facilities directory: ${e.toString()}');
      });
    }
  }

  Future<void> _loadEquipment() async {
    setState(() {
      _equipmentUiState = UiState.loading();
    });

    try {
      final repo = RepositoryScope.of(context).equipmentRepository;
      final fetched = await repo.getEquipment();
      setState(() {
        _equipmentList = fetched;
        _equipmentUiState = fetched.isEmpty ? UiState.empty() : UiState.success(fetched);
      });
    } catch (e) {
      setState(() {
        _equipmentUiState = UiState.error('Failed to load equipment list: ${e.toString()}');
      });
    }
  }

  List<FacilityModel> get _filteredFacilities {
    return _facilities.where((facility) {
      final matchesSearch = facility.name.toLowerCase().contains(_facilitySearchQuery.toLowerCase()) ||
          facility.category.toLowerCase().contains(_facilitySearchQuery.toLowerCase()) ||
          facility.location.toLowerCase().contains(_facilitySearchQuery.toLowerCase()) ||
          facility.capacity.toLowerCase().contains(_facilitySearchQuery.toLowerCase());

      final matchesCategory = _selectedCategory == 'All' || facility.category == _selectedCategory;
      final matchesStatus = _selectedAvailability == 'All' || facility.availability == _selectedAvailability;

      return matchesSearch && matchesCategory && matchesStatus;
    }).toList();
  }

  List<Equipment> get _filteredEquipment {
    return _equipmentList.where((item) {
      final matchesSearch = item.name.toLowerCase().contains(_equipmentSearchQuery.toLowerCase()) ||
          item.model.toLowerCase().contains(_equipmentSearchQuery.toLowerCase()) ||
          item.serialNumber.toLowerCase().contains(_equipmentSearchQuery.toLowerCase());

      final matchesStatus = _selectedEquipmentStatus == 'All' ||
          item.status.name.toLowerCase() == _selectedEquipmentStatus.toLowerCase();

      return matchesSearch && matchesStatus;
    }).toList();
  }

  void _showSnackBar(String message) {
    final isDark = HealthifyGlassTheme.isDark(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: TextStyle(color: isDark ? Colors.white : Colors.black87),
        ),
        backgroundColor: isDark
            ? const Color(0xFF0F2928).withValues(alpha: 0.9)
            : Colors.white.withValues(alpha: 0.95),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(
            color: isDark ? Colors.white.withValues(alpha: 0.15) : AppTheme.borderLight,
          ),
        ),
      ),
    );
  }

  void _toggleVisibility(FacilityModel facility) {
    setState(() {
      final index = _facilities.indexWhere((f) => f.id == facility.id);
      if (index != -1) {
        final updated = _facilities[index].copyWith(
          isVisibleToPatients: !_facilities[index].isVisibleToPatients,
          lastUpdated: 'Just now',
        );
        _facilities[index] = updated;
        final stateText = updated.isVisibleToPatients ? 'visible in' : 'hidden from';
        _showSnackBar('Facility "${updated.name}" is now $stateText Patient App.');
      }
    });
  }

  void _changeAvailability(FacilityModel facility, String newStatus) {
    setState(() {
      final index = _facilities.indexWhere((f) => f.id == facility.id);
      if (index != -1) {
        final updated = _facilities[index].copyWith(
          availability: newStatus,
          lastUpdated: 'Just now',
        );
        _facilities[index] = updated;
        _showSnackBar('Facility "${updated.name}" status set to $newStatus.');
      }
    });
  }

  void _addOrUpdateFacility(FacilityModel newFacility) {
    setState(() {
      final index = _facilities.indexWhere((f) => f.id == newFacility.id);
      if (index != -1) {
        _facilities[index] = newFacility;
        _showSnackBar('Facility "${newFacility.name}" updated successfully.');
      } else {
        _facilities.insert(0, newFacility);
        _showSnackBar('Facility "${newFacility.name}" added successfully.');
      }
    });
  }

  Future<void> _updateEquipmentStatus(Equipment item, EquipmentStatus newStatus) async {
    final repo = RepositoryScope.of(context).equipmentRepository;
    await repo.updateEquipmentStatus(item.id, newStatus);
    _showSnackBar('Updated status for ${item.name} to ${newStatus.name.toUpperCase()}');
    _loadEquipment();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 850;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Header Row & Tab Switcher
          _buildHeader(context),

          const SizedBox(height: 18),

          // Segmented Control Tabs
          _buildTabSelector(context),

          const SizedBox(height: 20),

          if (_activeTab == 0) ...[
            // 2. Facilities Tab Content
            _buildFacilityFilterToolbar(context),
            const SizedBox(height: 16),
            _buildPrivacyCallout(context),
            const SizedBox(height: 20),
            if (_facilityUiState.isLoading)
              const HealthifyLoadingState(message: 'Loading facilities directory...')
            else if (_facilityUiState.isError)
              HealthifyErrorState(
                errorMessage: _facilityUiState.errorMessage ?? 'Error loading facilities',
                onRetry: _loadFacilities,
              )
            else if (_filteredFacilities.isEmpty)
              _buildEmptyState(context, 'No facilities match your filters.')
            else if (isDesktop)
              _buildFacilityDesktopTable(context)
            else
              _buildFacilityMobileCardsList(context),
          ] else ...[
            // 3. Equipment Tab Content
            _buildEquipmentFilterToolbar(context),
            const SizedBox(height: 20),
            if (_equipmentUiState.isLoading)
              const HealthifyLoadingState(message: 'Loading equipment directory & maintenance schedules...')
            else if (_equipmentUiState.isError)
              HealthifyErrorState(
                errorMessage: _equipmentUiState.errorMessage ?? 'Error loading equipment',
                onRetry: _loadEquipment,
              )
            else if (_filteredEquipment.isEmpty)
              _buildEmptyState(context, 'No equipment matches your search/status filter.')
            else if (isDesktop)
              _buildEquipmentDesktopTable(context)
            else
              _buildEquipmentMobileCardsList(context),
          ],
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final isDark = HealthifyGlassTheme.isDark(context);

    return Wrap(
      alignment: WrapAlignment.spaceBetween,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 12,
      runSpacing: 10,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Facilities & Equipment',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Manage hospital facilities, medical equipment inventory, and maintenance logs.',
              style: TextStyle(
                fontSize: 13,
                color: isDark ? Colors.white70 : AppTheme.textSecondary,
              ),
            ),
          ],
        ),
        GlassPrimaryButton(
          onPressed: () {
            if (_activeTab == 0) {
              showDialog(
                context: context,
                builder: (context) => AddEditFacilityModal(
                  onSave: _addOrUpdateFacility,
                ),
              );
            } else {
              _showSnackBar('Add New Equipment feature ready for backend integration.');
            }
          },
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.add_rounded, size: 18, color: Colors.white),
              const SizedBox(width: 6),
              Text(
                _activeTab == 0 ? '+ Add Facility' : '+ Register Equipment',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTabSelector(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(6),
      borderRadius: 14,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildTabButton(context, 0, 'Facilities & Services', Icons.business_rounded),
            const SizedBox(width: 8),
            _buildTabButton(context, 1, 'Equipment & Maintenance', Icons.medical_services_outlined),
          ],
        ),
      ),
    );
  }

  Widget _buildTabButton(BuildContext context, int index, String label, IconData icon) {
    final isDark = HealthifyGlassTheme.isDark(context);
    final isSelected = _activeTab == index;

    return InkWell(
      onTap: () => setState(() => _activeTab = index),
      borderRadius: BorderRadius.circular(10),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.primaryColor
              : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected
                  ? Colors.white
                  : (isDark ? Colors.white70 : AppTheme.textSecondary),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected
                    ? Colors.white
                    : (isDark ? Colors.white70 : AppTheme.textSecondary),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFacilityFilterToolbar(BuildContext context) {
    final isDark = HealthifyGlassTheme.isDark(context);

    return GlassCard(
      padding: const EdgeInsets.all(14.0),
      borderRadius: 16,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth > 700;

          final searchField = SizedBox(
            height: 42,
            child: TextField(
              onChanged: (val) => setState(() => _facilitySearchQuery = val),
              style: TextStyle(color: isDark ? Colors.white : AppTheme.textPrimary),
              decoration: GlassTextFieldTheme.getDecoration(
                context: context,
                hintText: 'Search facilities...',
                prefixIcon: Icon(Icons.search_rounded, color: isDark ? Colors.white60 : AppTheme.textSecondary),
              ),
            ),
          );

          final categoryDropdown = SizedBox(
            width: isWide ? 170 : double.infinity,
            height: 42,
            child: DropdownButtonFormField<String>(
              initialValue: _selectedCategory,
              isExpanded: true,
              dropdownColor: isDark ? const Color(0xFF0F2928) : Colors.white,
              style: TextStyle(fontSize: 13, color: isDark ? Colors.white : AppTheme.textPrimary),
              decoration: GlassTextFieldTheme.getDecoration(
                context: context,
                hintText: '',
                labelText: 'Category',
              ),
              items: _categories
                  .map((c) => DropdownMenuItem(
                        value: c,
                        child: Text(c, overflow: TextOverflow.ellipsis, style: TextStyle(color: isDark ? Colors.white : AppTheme.textPrimary)),
                      ))
                  .toList(),
              onChanged: (val) {
                if (val != null) setState(() => _selectedCategory = val);
              },
            ),
          );

          final statusDropdown = SizedBox(
            width: isWide ? 150 : double.infinity,
            height: 42,
            child: DropdownButtonFormField<String>(
              initialValue: _selectedAvailability,
              isExpanded: true,
              dropdownColor: isDark ? const Color(0xFF0F2928) : Colors.white,
              style: TextStyle(fontSize: 13, color: isDark ? Colors.white : AppTheme.textPrimary),
              decoration: GlassTextFieldTheme.getDecoration(
                context: context,
                hintText: '',
                labelText: 'Status',
              ),
              items: _statuses
                  .map((s) => DropdownMenuItem(
                        value: s,
                        child: Text(s, overflow: TextOverflow.ellipsis, style: TextStyle(color: isDark ? Colors.white : AppTheme.textPrimary)),
                      ))
                  .toList(),
              onChanged: (val) {
                if (val != null) setState(() => _selectedAvailability = val);
              },
            ),
          );

          if (isWide) {
            return Row(
              children: [
                Expanded(flex: 2, child: searchField),
                const SizedBox(width: 12),
                categoryDropdown,
                const SizedBox(width: 12),
                statusDropdown,
              ],
            );
          } else {
            return Column(
              children: [
                searchField,
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(child: categoryDropdown),
                    const SizedBox(width: 10),
                    Expanded(child: statusDropdown),
                  ],
                ),
              ],
            );
          }
        },
      ),
    );
  }

  Widget _buildEquipmentFilterToolbar(BuildContext context) {
    final isDark = HealthifyGlassTheme.isDark(context);

    return GlassCard(
      padding: const EdgeInsets.all(14.0),
      borderRadius: 16,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth > 700;

          final searchField = SizedBox(
            height: 42,
            child: TextField(
              onChanged: (val) => setState(() => _equipmentSearchQuery = val),
              style: TextStyle(color: isDark ? Colors.white : AppTheme.textPrimary),
              decoration: GlassTextFieldTheme.getDecoration(
                context: context,
                hintText: 'Search equipment by name, model, serial #...',
                prefixIcon: Icon(Icons.search_rounded, color: isDark ? Colors.white60 : AppTheme.textSecondary),
              ),
            ),
          );

          final statusDropdown = SizedBox(
            width: isWide ? 200 : double.infinity,
            height: 42,
            child: DropdownButtonFormField<String>(
              initialValue: _selectedEquipmentStatus,
              isExpanded: true,
              dropdownColor: isDark ? const Color(0xFF0F2928) : Colors.white,
              style: TextStyle(fontSize: 13, color: isDark ? Colors.white : AppTheme.textPrimary),
              decoration: GlassTextFieldTheme.getDecoration(
                context: context,
                hintText: '',
                labelText: 'Equipment Status',
              ),
              items: ['All', 'Operational', 'NeedsMaintenance', 'OutOfOrder', 'InUse']
                  .map((s) => DropdownMenuItem(
                        value: s,
                        child: Text(s, overflow: TextOverflow.ellipsis, style: TextStyle(color: isDark ? Colors.white : AppTheme.textPrimary)),
                      ))
                  .toList(),
              onChanged: (val) {
                if (val != null) setState(() => _selectedEquipmentStatus = val);
              },
            ),
          );

          if (isWide) {
            return Row(
              children: [
                Expanded(child: searchField),
                const SizedBox(width: 12),
                statusDropdown,
              ],
            );
          } else {
            return Column(
              children: [
                searchField,
                const SizedBox(height: 10),
                statusDropdown,
              ],
            );
          }
        },
      ),
    );
  }

  Widget _buildPrivacyCallout(BuildContext context) {
    final isDark = HealthifyGlassTheme.isDark(context);

    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      borderRadius: 12,
      child: Row(
        children: [
          const GlassIconContainer(
            icon: Icons.shield_outlined,
            color: AppTheme.primaryColor,
            size: 32,
            iconSize: 18,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Visible facilities may appear in the Patient App. Only general facility availability is exposed to patients. Internal operational notes remain private.',
              style: TextStyle(
                fontSize: 12,
                color: isDark ? Colors.white70 : AppTheme.primaryDark,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, String message) {
    final isDark = HealthifyGlassTheme.isDark(context);

    return GlassCard(
      padding: const EdgeInsets.all(40),
      borderRadius: 16,
      child: Center(
        child: Column(
          children: [
            Icon(Icons.inventory_2_outlined, size: 48, color: isDark ? Colors.white38 : AppTheme.textMuted),
            const SizedBox(height: 12),
            Text(
              message,
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.white70 : AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFacilityDesktopTable(BuildContext context) {
    final isDark = HealthifyGlassTheme.isDark(context);

    return GlassCard(
      padding: EdgeInsets.zero,
      borderRadius: 16,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Table(
          columnWidths: const {
            0: FlexColumnWidth(2.2),
            1: FlexColumnWidth(1.4),
            2: FlexColumnWidth(1.3),
            3: FlexColumnWidth(1.4),
            4: FlexColumnWidth(1.5),
            5: FlexColumnWidth(1.6),
            6: FlexColumnWidth(1.2),
            7: FixedColumnWidth(60),
          },
          defaultVerticalAlignment: TableCellVerticalAlignment.middle,
          children: [
            TableRow(
              decoration: BoxDecoration(
                color: isDark ? Colors.white.withValues(alpha: 0.05) : const Color(0xFFF8FAFC),
              ),
              children: [
                _buildTableHeaderCell(context, 'Facility'),
                _buildTableHeaderCell(context, 'Category'),
                _buildTableHeaderCell(context, 'Availability'),
                _buildTableHeaderCell(context, 'Capacity / Details'),
                _buildTableHeaderCell(context, 'Operating Hours'),
                _buildTableHeaderCell(context, 'Patient Visibility'),
                _buildTableHeaderCell(context, 'Last Updated'),
                _buildTableHeaderCell(context, 'Actions'),
              ],
            ),
            ..._filteredFacilities.map((facility) {
              return TableRow(
                decoration: BoxDecoration(
                  border: Border(top: BorderSide(color: isDark ? Colors.white12 : AppTheme.borderLight, width: 0.8)),
                ),
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          facility.name,
                          style: TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : AppTheme.textPrimary,
                          ),
                        ),
                        if (facility.location.isNotEmpty)
                          Text(
                            facility.location,
                            style: TextStyle(
                              fontSize: 11,
                              color: isDark ? Colors.white60 : AppTheme.textSecondary,
                            ),
                          ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        facility.category,
                        style: const TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    child: _buildAvailabilityBadge(facility.availability),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    child: Text(
                      facility.capacity.isEmpty ? '—' : facility.capacity,
                      style: TextStyle(
                        fontSize: 12.5,
                        color: isDark ? Colors.white70 : AppTheme.textPrimary,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    child: Text(
                      facility.operatingHours.isEmpty ? '24/7' : facility.operatingHours,
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? Colors.white70 : AppTheme.textSecondary,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    child: Row(
                      children: [
                        Transform.scale(
                          scale: 0.8,
                          child: Switch(
                            value: facility.isVisibleToPatients,
                            activeThumbColor: AppTheme.primaryColor,
                            onChanged: (_) => _toggleVisibility(facility),
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          facility.isVisibleToPatients ? 'Visible' : 'Hidden',
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                            color: facility.isVisibleToPatients
                                ? (isDark ? Colors.white : AppTheme.textPrimary)
                                : (isDark ? Colors.white38 : AppTheme.textMuted),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    child: Text(
                      facility.lastUpdated,
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark ? Colors.white38 : AppTheme.textMuted,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                    child: PopupMenuButton<String>(
                      icon: Icon(Icons.more_vert, size: 18, color: isDark ? Colors.white70 : AppTheme.textSecondary),
                      onSelected: (action) {
                        if (action == 'edit') {
                          showDialog(
                            context: context,
                            builder: (context) => AddEditFacilityModal(
                              facility: facility,
                              onSave: _addOrUpdateFacility,
                            ),
                          );
                        } else if (action == 'toggle_vis') {
                          _toggleVisibility(facility);
                        } else if (action.startsWith('avail_')) {
                          final status = action.replaceFirst('avail_', '');
                          _changeAvailability(facility, status);
                        }
                      },
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          value: 'edit',
                          child: Row(
                            children: [
                              Icon(Icons.edit_outlined, size: 16, color: isDark ? Colors.white70 : AppTheme.textSecondary),
                              const SizedBox(width: 8),
                              Text('Edit Facility', style: TextStyle(color: isDark ? Colors.white : AppTheme.textPrimary)),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: 'toggle_vis',
                          child: Row(
                            children: [
                              Icon(
                                facility.isVisibleToPatients ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                                size: 16,
                                color: isDark ? Colors.white70 : AppTheme.textSecondary,
                              ),
                              const SizedBox(width: 8),
                              Text(facility.isVisibleToPatients ? 'Hide from Patients' : 'Show to Patients', style: TextStyle(color: isDark ? Colors.white : AppTheme.textPrimary)),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: 'avail_Available',
                          child: Text('Mark Available', style: TextStyle(color: isDark ? Colors.white : AppTheme.textPrimary)),
                        ),
                        PopupMenuItem(
                          value: 'avail_Limited',
                          child: Text('Mark Limited', style: TextStyle(color: isDark ? Colors.white : AppTheme.textPrimary)),
                        ),
                        PopupMenuItem(
                          value: 'avail_Unavailable',
                          child: Text('Mark Unavailable', style: TextStyle(color: isDark ? Colors.white : AppTheme.textPrimary)),
                        ),
                        PopupMenuItem(
                          value: 'avail_Maintenance',
                          child: Text('Mark Maintenance', style: TextStyle(color: isDark ? Colors.white : AppTheme.textPrimary)),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildFacilityMobileCardsList(BuildContext context) {
    final isDark = HealthifyGlassTheme.isDark(context);

    return Column(
      children: _filteredFacilities.map((facility) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: GlassCard(
            padding: const EdgeInsets.all(16.0),
            borderRadius: 16,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            facility.name,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : AppTheme.textPrimary,
                            ),
                          ),
                          if (facility.location.isNotEmpty)
                            Text(
                              facility.location,
                              style: TextStyle(
                                fontSize: 12,
                                color: isDark ? Colors.white60 : AppTheme.textSecondary,
                              ),
                            ),
                        ],
                      ),
                    ),
                    _buildAvailabilityBadge(facility.availability),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        facility.category,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    if (facility.capacity.isNotEmpty)
                      Text(
                        'Cap: ${facility.capacity}',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? Colors.white70 : AppTheme.textSecondary,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildEquipmentDesktopTable(BuildContext context) {
    final isDark = HealthifyGlassTheme.isDark(context);

    return GlassCard(
      padding: EdgeInsets.zero,
      borderRadius: 16,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Table(
          columnWidths: const {
            0: FlexColumnWidth(2.2),
            1: FlexColumnWidth(1.5),
            2: FlexColumnWidth(1.4),
            3: FlexColumnWidth(1.3),
            4: FlexColumnWidth(1.4),
            5: FlexColumnWidth(1.4),
            6: FixedColumnWidth(60),
          },
          defaultVerticalAlignment: TableCellVerticalAlignment.middle,
          children: [
            TableRow(
              decoration: BoxDecoration(
                color: isDark ? Colors.white.withValues(alpha: 0.05) : const Color(0xFFF8FAFC),
              ),
              children: [
                _buildTableHeaderCell(context, 'Equipment Name'),
                _buildTableHeaderCell(context, 'Model'),
                _buildTableHeaderCell(context, 'Serial Number'),
                _buildTableHeaderCell(context, 'Status'),
                _buildTableHeaderCell(context, 'Last Maintenance'),
                _buildTableHeaderCell(context, 'Next Due'),
                _buildTableHeaderCell(context, 'Actions'),
              ],
            ),
            ..._filteredEquipment.map((item) {
              return TableRow(
                decoration: BoxDecoration(
                  border: Border(top: BorderSide(color: isDark ? Colors.white12 : AppTheme.borderLight, width: 0.8)),
                ),
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.name,
                          style: TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : AppTheme.textPrimary,
                          ),
                        ),
                        Text(
                          item.id,
                          style: TextStyle(
                            fontSize: 11,
                            color: isDark ? Colors.white54 : AppTheme.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    child: Text(
                      item.model,
                      style: TextStyle(
                        fontSize: 12.5,
                        color: isDark ? Colors.white70 : AppTheme.textPrimary,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    child: Text(
                      item.serialNumber,
                      style: TextStyle(
                        fontSize: 12,
                        fontFamily: 'monospace',
                        color: isDark ? Colors.white60 : AppTheme.textSecondary,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    child: _buildEquipmentStatusBadge(item.status),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    child: Text(
                      _formatDate(item.lastMaintenanceDate),
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? Colors.white70 : AppTheme.textSecondary,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    child: Text(
                      _formatDate(item.nextMaintenanceDate),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: item.nextMaintenanceDate.isBefore(DateTime.now())
                            ? Colors.redAccent
                            : (isDark ? Colors.white70 : AppTheme.textPrimary),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                    child: PopupMenuButton<EquipmentStatus>(
                      icon: Icon(Icons.more_vert, size: 18, color: isDark ? Colors.white70 : AppTheme.textSecondary),
                      onSelected: (status) => _updateEquipmentStatus(item, status),
                      itemBuilder: (context) => EquipmentStatus.values
                          .map((s) => PopupMenuItem(
                                value: s,
                                child: Text('Mark as ${s.name.toUpperCase()}'),
                              ))
                          .toList(),
                    ),
                  ),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildEquipmentMobileCardsList(BuildContext context) {
    final isDark = HealthifyGlassTheme.isDark(context);

    return Column(
      children: _filteredEquipment.map((item) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: GlassCard(
            padding: const EdgeInsets.all(16.0),
            borderRadius: 16,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        item.name,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : AppTheme.textPrimary,
                        ),
                      ),
                    ),
                    _buildEquipmentStatusBadge(item.status),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Model: ${item.model} • SN: ${item.serialNumber}',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.white60 : AppTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Next Maintenance: ${_formatDate(item.nextMaintenanceDate)}',
                      style: TextStyle(
                        fontSize: 11.5,
                        color: isDark ? Colors.white70 : AppTheme.textSecondary,
                      ),
                    ),
                    PopupMenuButton<EquipmentStatus>(
                      icon: const Icon(Icons.edit_outlined, size: 18),
                      onSelected: (status) => _updateEquipmentStatus(item, status),
                      itemBuilder: (context) => EquipmentStatus.values
                          .map((s) => PopupMenuItem(
                                value: s,
                                child: Text('Mark ${s.name.toUpperCase()}'),
                              ))
                          .toList(),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTableHeaderCell(BuildContext context, String text) {
    final isDark = HealthifyGlassTheme.isDark(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: isDark ? Colors.white70 : AppTheme.textSecondary,
        ),
      ),
    );
  }

  Widget _buildAvailabilityBadge(String availability) {
    Color bg;
    Color fg;

    switch (availability.toLowerCase()) {
      case 'available':
        bg = const Color(0xFFDCFCE7);
        fg = const Color(0xFF15803D);
        break;
      case 'limited':
        bg = const Color(0xFFFEF3C7);
        fg = const Color(0xFFB45309);
        break;
      case 'unavailable':
        bg = const Color(0xFFFEE2E2);
        fg = const Color(0xFFB91C1C);
        break;
      case 'maintenance':
      default:
        bg = const Color(0xFFF3F4F6);
        fg = const Color(0xFF4B5563);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        availability,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: fg,
        ),
      ),
    );
  }

  Widget _buildEquipmentStatusBadge(EquipmentStatus status) {
    Color bg;
    Color fg;

    switch (status) {
      case EquipmentStatus.operational:
        bg = const Color(0xFFDCFCE7);
        fg = const Color(0xFF15803D);
        break;
      case EquipmentStatus.inUse:
        bg = const Color(0xFFE0F2FE);
        fg = const Color(0xFF0369A1);
        break;
      case EquipmentStatus.needsMaintenance:
        bg = const Color(0xFFFEF3C7);
        fg = const Color(0xFFB45309);
        break;
      case EquipmentStatus.outOfOrder:
        bg = const Color(0xFFFEE2E2);
        fg = const Color(0xFFB91C1C);
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        status.name.toUpperCase(),
        style: TextStyle(
          fontSize: 10.5,
          fontWeight: FontWeight.bold,
          color: fg,
        ),
      ),
    );
  }

  String _formatDate(DateTime dt) {
    return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
  }
}