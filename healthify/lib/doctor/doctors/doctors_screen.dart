import 'package:flutter/material.dart';
import '../../core/core.dart';
import '../../shared/widgets/glass_components.dart';
import '../../theme/app_theme.dart';
import './widgets/add_doctor_modal.dart';
import './widgets/doctor_schedule_drawer.dart';

class DoctorsScreen extends StatefulWidget {
  const DoctorsScreen({super.key});

  @override
  State<DoctorsScreen> createState() => _DoctorsScreenState();
}

class _DoctorsScreenState extends State<DoctorsScreen> {
  final DoctorRepository _doctorRepository = RepositoryContainer.instance.doctorRepository;
  UiState<List<DoctorItem>> _uiState = UiState.initial();

  // Search & Filter State
  String _searchQuery = '';
  String _selectedDeptFilter = 'All Departments';
  String _selectedStatusFilter = 'All Statuses';

  // Selected Doctor for Schedule Drawer
  DoctorItem? _selectedDoctor;

  // Doctor Roster Data
  List<DoctorItem> _doctors = [];

  @override
  void initState() {
    super.initState();
    _loadDoctors();
  }

  Future<void> _loadDoctors() async {
    setState(() {
      _uiState = UiState.loading();
    });

    try {
      final fetched = await _doctorRepository.getDoctors();
      setState(() {
        _doctors = fetched;
        _uiState = fetched.isEmpty ? UiState.empty() : UiState.success(fetched);
      });
    } catch (e) {
      setState(() {
        _uiState = UiState.error('Failed to load doctor directory: ${e.toString()}');
      });
    }
  }

  // Filtered Doctors List
  List<DoctorItem> get _filteredDoctors {
    return _doctors.where((doc) {
      // 1. Search Query
      final query = _searchQuery.trim().toLowerCase();
      final matchesSearch = query.isEmpty ||
          doc.name.toLowerCase().contains(query) ||
          doc.id.toLowerCase().contains(query) ||
          doc.department.toLowerCase().contains(query);

      // 2. Department Filter
      final matchesDept = _selectedDeptFilter == 'All Departments' ||
          doc.department.toLowerCase() == _selectedDeptFilter.toLowerCase();

      // 3. Status Filter
      bool matchesStatus = true;
      if (_selectedStatusFilter != 'All Statuses') {
        switch (_selectedStatusFilter) {
          case 'Available':
            matchesStatus = doc.status == DoctorStatus.available;
            break;
          case 'In Surgery':
            matchesStatus = doc.status == DoctorStatus.inSurgery;
            break;
          case 'Busy':
            matchesStatus = doc.status == DoctorStatus.busy;
            break;
          case 'Off Duty':
            matchesStatus = doc.status == DoctorStatus.offDuty;
            break;
        }
      }

      return matchesSearch && matchesDept && matchesStatus;
    }).toList();
  }

  // Calculated Stats
  int get _totalCount => _doctors.length;
  int get _availableCount => _doctors.where((d) => d.status == DoctorStatus.available).length;
  int get _inSurgeryCount => _doctors.where((d) => d.status == DoctorStatus.inSurgery).length;
  int get _totalActivePatients => _doctors.fold(0, (sum, d) => sum + d.activePatients);

  void _clearAllFilters() {
    setState(() {
      _searchQuery = '';
      _selectedDeptFilter = 'All Departments';
      _selectedStatusFilter = 'All Statuses';
    });
  }

  void _openAddDoctorModal() {
    showDialog(
      context: context,
      builder: (dialogContext) {
        final messenger = ScaffoldMessenger.of(dialogContext);
        return AddDoctorModal(
          onDoctorAdded: (newDoctor) async {
            await _doctorRepository.addDoctor(newDoctor);
            await _loadDoctors();
            messenger.showSnackBar(
              SnackBar(content: Text('${newDoctor.name} added to staff roster')),
            );
          },
        );
      },
    );
  }

  Color _getStatusColor(DoctorStatus status) {
    switch (status) {
      case DoctorStatus.available:
        return const Color(0xFF10B981); // Emerald
      case DoctorStatus.inSurgery:
        return const Color(0xFF8B5CF6); // Purple Glow
      case DoctorStatus.busy:
        return const Color(0xFFF59E0B); // Amber
      case DoctorStatus.offDuty:
        return const Color(0xFF6B7280); // Gray
      default:
        return const Color(0xFF6B7280);
    }
  }

  String _getStatusLabel(DoctorStatus status) {
    switch (status) {
      case DoctorStatus.available:
        return 'Available';
      case DoctorStatus.inSurgery:
        return 'In Surgery';
      case DoctorStatus.busy:
        return 'Busy';
      case DoctorStatus.offDuty:
        return 'Off Duty';
      default:
        return status.name;
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;

    return Stack(
      children: [
        Scaffold(
          backgroundColor: Colors.transparent,
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. HEADER & PRIMARY ACTIONS
                _buildHeader(isMobile),
                const SizedBox(height: 24),

                // 2. QUICK STATS DASHBOARD
                _buildQuickStatsDashboard(isMobile),
                const SizedBox(height: 24),

                // 3. SEARCH & FILTER TOOLBAR
                _buildSearchAndFilterToolbar(isMobile),
                const SizedBox(height: 24),

                // 4. DOCTOR DATA TABLE / MOBILE CARDS OR EMPTY STATE
                _uiState.isLoading
                    ? const MedrixLoadingState(message: 'Loading doctor roster...')
                    : _uiState.isError
                        ? MedrixErrorState(
                            errorMessage: _uiState.errorMessage ?? 'Error loading doctors',
                            onRetry: _loadDoctors,
                          )
                        : _filteredDoctors.isEmpty
                            ? _buildEmptyState()
                            : (isMobile ? _buildMobileCardsView() : _buildDoctorDataTable()),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),

        // Slide Drawer Overlay for Selected Doctor Schedule
        if (_selectedDoctor != null)
          Positioned.fill(
            child: Stack(
              children: [
                GestureDetector(
                  onTap: () => setState(() => _selectedDoctor = null),
                  child: Container(color: Colors.black45),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: DoctorScheduleDrawer(
                    doctor: _selectedDoctor!,
                    onClose: () => setState(() => _selectedDoctor = null),
                    onStatusChanged: (newStatus) {
                      setState(() {
                        _selectedDoctor!.status = newStatus;
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildHeader(bool isMobile) {
    final isDark = HealthifyGlassTheme.isDark(context);

    return isMobile
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Doctor Directory',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Centralized hospital hub for medical staff management, shift tracking, and patient load balancing.',
                style: TextStyle(
                  fontSize: 13,
                  color: isDark ? Colors.white70 : AppTheme.textSecondary,
                ),
              ),
              const SizedBox(height: 16),
              GlassPrimaryButton(
                onPressed: _openAddDoctorModal,
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.person_add_rounded, size: 18, color: Colors.white),
                    SizedBox(width: 8),
                    Text('Add New Doctor', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ],
          )
        : Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Doctor Directory',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Centralized hospital hub for medical staff management, shift tracking, and patient load balancing.',
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark ? Colors.white70 : AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              GlassPrimaryButton(
                onPressed: _openAddDoctorModal,
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.person_add_rounded, size: 18, color: Colors.white),
                    SizedBox(width: 8),
                    Text('Add New Doctor', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ],
          );
  }

  Widget _buildQuickStatsDashboard(bool isMobile) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final count = isMobile ? 2 : 4;
        return GridView.count(
          crossAxisCount: count,
          crossAxisSpacing: 14,
          mainAxisSpacing: 14,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: isMobile ? 1.4 : 1.6,
          children: [
            _buildStatCard(
              title: 'Total Doctors',
              count: '$_totalCount',
              subtitle: 'Registered staff roster',
              icon: Icons.badge_outlined,
              color: AppTheme.primaryColor,
            ),
            _buildStatCard(
              title: 'Available',
              count: '$_availableCount',
              subtitle: 'On-shift consultation',
              icon: Icons.check_circle_outline_rounded,
              color: const Color(0xFF10B981),
            ),
            _buildStatCard(
              title: 'In Surgery',
              count: '$_inSurgeryCount',
              subtitle: 'Operating theater duty',
              icon: Icons.local_hospital_outlined,
              color: const Color(0xFF8B5CF6),
            ),
            _buildStatCard(
              title: 'Active Patients',
              count: '$_totalActivePatients',
              subtitle: 'Combined workload',
              icon: Icons.people_outline_rounded,
              color: const Color(0xFFF59E0B),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatCard({
    required String title,
    required String count,
    required String subtitle,
    required IconData icon,
    required Color color,
  }) {
    final isDark = HealthifyGlassTheme.isDark(context);

    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      borderRadius: 16,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white70 : AppTheme.textSecondary,
                  ),
                ),
              ),
              GlassIconContainer(
                icon: icon,
                color: color,
                size: 30,
                iconSize: 16,
              ),
            ],
          ),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              count,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : AppTheme.textPrimary,
              ),
            ),
          ),
          Text(
            subtitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 10.5, color: color, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilterToolbar(bool isMobile) {
    final isDark = HealthifyGlassTheme.isDark(context);
    final departments = [
      'All Departments',
      'Cardiology',
      'Neurology',
      'Orthopedics',
      'Pediatrics',
      'Emergency',
      'General Surgery',
      'ICU Medicine',
    ];

    final statuses = ['All Statuses', 'Available', 'In Surgery', 'Busy', 'Off Duty'];

    return GlassCard(
      padding: const EdgeInsets.all(16),
      borderRadius: 16,
      child: Wrap(
        spacing: 12,
        runSpacing: 12,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          // Search Bar Input
          SizedBox(
            width: isMobile ? double.infinity : 280,
            child: TextField(
              onChanged: (val) => setState(() => _searchQuery = val),
              style: TextStyle(color: isDark ? Colors.white : AppTheme.textPrimary),
              decoration: GlassTextFieldTheme.getDecoration(
                context: context,
                hintText: 'Search by Doctor Name or ID...',
                prefixIcon: Icon(Icons.search, color: isDark ? Colors.white60 : AppTheme.textSecondary),
              ),
            ),
          ),

          // Department Dropdown Filter
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF0F2928) : Colors.white.withValues(alpha: 0.8),
              border: Border.all(color: isDark ? Colors.white12 : AppTheme.borderLight),
              borderRadius: BorderRadius.circular(12),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedDeptFilter,
                dropdownColor: isDark ? const Color(0xFF0F2928) : Colors.white,
                style: TextStyle(fontSize: 13, color: isDark ? Colors.white : AppTheme.textPrimary),
                items: departments.map((d) {
                  return DropdownMenuItem(value: d, child: Text(d, style: TextStyle(color: isDark ? Colors.white : AppTheme.textPrimary)));
                }).toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _selectedDeptFilter = val);
                },
              ),
            ),
          ),

          // Status Dropdown Filter
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF0F2928) : Colors.white.withValues(alpha: 0.8),
              border: Border.all(color: isDark ? Colors.white12 : AppTheme.borderLight),
              borderRadius: BorderRadius.circular(12),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedStatusFilter,
                dropdownColor: isDark ? const Color(0xFF0F2928) : Colors.white,
                style: TextStyle(fontSize: 13, color: isDark ? Colors.white : AppTheme.textPrimary),
                items: statuses.map((st) {
                  return DropdownMenuItem(value: st, child: Text(st, style: TextStyle(color: isDark ? Colors.white : AppTheme.textPrimary)));
                }).toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _selectedStatusFilter = val);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDoctorDataTable() {
    final isDark = HealthifyGlassTheme.isDark(context);

    return GlassCard(
      padding: const EdgeInsets.all(20),
      borderRadius: 20,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Doctor Directory Roster',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : AppTheme.textPrimary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Showing ${_filteredDoctors.length} doctor(s)',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white70 : AppTheme.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columns: [
                DataColumn(label: Text('Doctor Details', style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? Colors.white : AppTheme.textPrimary))),
                DataColumn(label: Text('Department', style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? Colors.white : AppTheme.textPrimary))),
                DataColumn(label: Text('Status', style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? Colors.white : AppTheme.textPrimary))),
                DataColumn(label: Text('Active Patients', style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? Colors.white : AppTheme.textPrimary))),
                DataColumn(label: Text('Shift Roster', style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? Colors.white : AppTheme.textPrimary))),
                DataColumn(label: Text('Actions', style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? Colors.white : AppTheme.textPrimary))),
              ],
              rows: _filteredDoctors.map((doc) {
                final statusColor = _getStatusColor(doc.status);
                final isInSurgery = doc.status == DoctorStatus.inSurgery;

                return DataRow(
                  cells: [
                    // Doctor Details Avatar & Name
                    DataCell(
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 18,
                            backgroundColor: doc.avatarGradientStart,
                            child: Text(
                              doc.initials,
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(doc.name, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5, color: isDark ? Colors.white : AppTheme.textPrimary)),
                              Text('${doc.id} • ${doc.experienceYears} Yrs Exp', style: TextStyle(fontSize: 11, color: isDark ? Colors.white60 : AppTheme.textSecondary)),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Department
                    DataCell(
                      Row(
                        children: [
                          Icon(Icons.business_outlined, size: 16, color: isDark ? Colors.white60 : AppTheme.textSecondary),
                          const SizedBox(width: 6),
                          Text(doc.department, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: isDark ? Colors.white : AppTheme.textPrimary)),
                        ],
                      ),
                    ),

                    // Status Badge (Purple glow for In Surgery)
                    DataCell(
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: statusColor.withValues(alpha: isInSurgery ? 0.5 : 0.2)),
                          boxShadow: isInSurgery
                              ? [
                                  BoxShadow(
                                    color: const Color(0xFF8B5CF6).withValues(alpha: 0.3),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ]
                              : [],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.circle, color: statusColor, size: 8),
                            const SizedBox(width: 6),
                            Text(
                              _getStatusLabel(doc.status),
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: statusColor),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Active Patients Count
                    DataCell(
                      Row(
                        children: [
                          const Icon(Icons.people_outline, size: 16, color: AppTheme.primaryColor),
                          const SizedBox(width: 6),
                          Text('${doc.activePatients} Patients', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: isDark ? Colors.white : AppTheme.textPrimary)),
                        ],
                      ),
                    ),

                    // Shift Roster Hours
                    DataCell(
                      Text(doc.shiftHours, style: TextStyle(fontSize: 12.5, color: isDark ? Colors.white70 : AppTheme.textSecondary)),
                    ),

                    // Row-Level Actions
                    DataCell(
                      Row(
                        children: [
                          GlassSecondaryButton(
                            onPressed: () => setState(() => _selectedDoctor = doc),
                            child: const Text('View Schedule'),
                          ),
                          PopupMenuButton<String>(
                            icon: Icon(Icons.more_vert, size: 18, color: isDark ? Colors.white70 : AppTheme.textSecondary),
                            onSelected: (val) {
                              if (val == 'schedule') {
                                setState(() => _selectedDoctor = doc);
                              } else if (val == 'status_avail') {
                                setState(() => doc.status = DoctorStatus.available);
                              } else if (val == 'status_surg') {
                                setState(() => doc.status = DoctorStatus.inSurgery);
                              }
                            },
                            itemBuilder: (context) => [
                              PopupMenuItem(value: 'schedule', child: Text('View Calendar Schedule', style: TextStyle(color: isDark ? Colors.white : AppTheme.textPrimary))),
                              PopupMenuItem(value: 'status_avail', child: Text('Set Available', style: TextStyle(color: isDark ? Colors.white : AppTheme.textPrimary))),
                              PopupMenuItem(value: 'status_surg', child: Text('Set In Surgery', style: TextStyle(color: isDark ? Colors.white : AppTheme.textPrimary))),
                              PopupMenuItem(value: 'reassign', child: Text('Reassign Patients', style: TextStyle(color: isDark ? Colors.white : AppTheme.textPrimary))),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileCardsView() {
    final isDark = HealthifyGlassTheme.isDark(context);

    return Column(
      children: _filteredDoctors.map((doc) {
        final statusColor = _getStatusColor(doc.status);

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: GlassCard(
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
                        CircleAvatar(
                          radius: 18,
                          backgroundColor: doc.avatarGradientStart,
                          child: Text(doc.initials, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        ),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(doc.name, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: isDark ? Colors.white : AppTheme.textPrimary)),
                            Text('${doc.id} • ${doc.department}', style: TextStyle(fontSize: 11, color: isDark ? Colors.white60 : AppTheme.textSecondary)),
                          ],
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(_getStatusLabel(doc.status), style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: statusColor)),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Patients: ${doc.activePatients}', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: isDark ? Colors.white : AppTheme.textPrimary)),
                    Text(doc.shiftHours, style: TextStyle(fontSize: 11.5, color: isDark ? Colors.white70 : AppTheme.textSecondary)),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    GlassSecondaryButton(
                      onPressed: () => setState(() => _selectedDoctor = doc),
                      child: const Text('View Schedule'),
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

  Widget _buildEmptyState() {
    final isDark = HealthifyGlassTheme.isDark(context);

    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
      borderRadius: 20,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          GlassIconContainer(
            icon: Icons.person_search_rounded,
            color: isDark ? Colors.white38 : AppTheme.textMuted,
            size: 64,
            iconSize: 40,
          ),
          const SizedBox(height: 16),
          Text(
            'No Doctors Found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'No medical staff members matched your search or department filter criteria.',
            style: TextStyle(
              fontSize: 13,
              color: isDark ? Colors.white70 : AppTheme.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),

          // Prominent "Clear all filters" Button
          GlassPrimaryButton(
            onPressed: _clearAllFilters,
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.filter_alt_off_rounded, size: 18, color: Colors.white),
                SizedBox(width: 8),
                Text('Clear all filters', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}