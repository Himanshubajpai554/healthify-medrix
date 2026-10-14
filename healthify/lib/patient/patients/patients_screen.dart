import 'package:flutter/material.dart';

import '../../core/core.dart';
import '../../shared/widgets/animated_pulse_background.dart';
import '../../shared/widgets/glass_components.dart';
import '../../theme/app_theme.dart';
import './admit_patient_modal.dart';
import './patient_profile_drawer.dart';
import '../../hospital/patients/account_link_requests_modal.dart';

class PatientsScreen extends StatefulWidget {
  const PatientsScreen({super.key});

  @override
  State<PatientsScreen> createState() => _PatientsScreenState();
}

class _PatientsScreenState extends State<PatientsScreen> {
  UiState<List<PatientItem>> _uiState = UiState.initial();
  UiState<PatientOverviewMetrics> _metricsState = UiState.initial();

  // Glass Theme Constants
  static const Color _primary = Color(0xFF0D9488);
  static const Color _blue = Color(0xFF3B82F6);
  static const Color _red = Color(0xFFEF4444);
  static const Color _orange = Color(0xFFF59E0B);
  static const Color _green = Color(0xFF10B981);

  Color _background(bool isDark) {
    return isDark ? const Color(0xFF061817) : const Color(0xFFF3FAF9);
  }

  Color _surfaceStrong(bool isDark) {
    return isDark
        ? Colors.white.withValues(alpha: 0.075)
        : Colors.white.withValues(alpha: 0.90);
  }

  Color _border(bool isDark) {
    return isDark
        ? Colors.white.withValues(alpha: 0.075)
        : Colors.white.withValues(alpha: 0.88);
  }

  Color _primaryText(bool isDark) {
    return isDark ? Colors.white : AppTheme.textPrimary;
  }

  Color _secondaryText(bool isDark) {
    return isDark
        ? Colors.white.withValues(alpha: 0.55)
        : AppTheme.textSecondary;
  }

  // Filter & Search State
  String _searchQuery = '';
  String _selectedStatusFilter = 'All Statuses';
  String _selectedBloodFilter = 'All Blood Groups';
  DateTime? _selectedAdmissionDate;

  PatientItem? _selectedPatient;
  List<PatientItem> _patients = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadPatients();
  }

  Future<void> _loadPatients() async {
    setState(() {
      _uiState = UiState.loading();
      _metricsState = UiState.loading();
    });

    try {
      final repo = RepositoryScope.of(context).patientRepository;
      final query = PatientQuery(
        searchQuery: _searchQuery,
        statusFilter: _selectedStatusFilter,
        bloodGroupFilter: _selectedBloodFilter,
        admissionDate: _selectedAdmissionDate,
      );

      final fetched = await repo.getPatients(query: query);
      final metrics = await repo.getPatientMetrics('HOSP-101');

      setState(() {
        _patients = fetched;
        _uiState = fetched.isEmpty ? UiState.empty() : UiState.success(fetched);
        _metricsState = UiState.success(metrics);
      });
    } catch (e) {
      setState(() {
        _uiState = UiState.error('Failed to load patient directory: ${e.toString()}');
        _metricsState = UiState.error('Failed to load metrics');
      });
    }
  }

  List<PatientItem> get _filteredPatients {
    return _patients.where((p) {
      final query = _searchQuery.trim().toLowerCase();
      final matchesSearch =
          query.isEmpty ||
          p.name.toLowerCase().contains(query) ||
          p.id.toLowerCase().contains(query) ||
          p.ward.toLowerCase().contains(query);

      bool matchesStatus = true;
      if (_selectedStatusFilter != 'All Statuses') {
        switch (_selectedStatusFilter) {
          case 'Admitted':
            matchesStatus = p.status == PatientStatus.admitted;
            break;
          case 'ICU':
            matchesStatus = p.status == PatientStatus.icu;
            break;
          case 'Observation':
            matchesStatus = p.status == PatientStatus.observation;
            break;
          case 'Discharged':
            matchesStatus = p.status == PatientStatus.discharged;
            break;
        }
      }

      bool matchesBlood = true;
      if (_selectedBloodFilter != 'All Blood Groups') {
        matchesBlood = p.bloodGroup.toUpperCase() == _selectedBloodFilter.toUpperCase();
      }

      bool matchesDate = true;
      if (_selectedAdmissionDate != null) {
        matchesDate =
            p.admissionDate.year == _selectedAdmissionDate!.year &&
            p.admissionDate.month == _selectedAdmissionDate!.month &&
            p.admissionDate.day == _selectedAdmissionDate!.day;
      }

      return matchesSearch && matchesStatus && matchesBlood && matchesDate;
    }).toList();
  }

  void _clearAllFilters() {
    setState(() {
      _searchQuery = '';
      _selectedStatusFilter = 'All Statuses';
      _selectedBloodFilter = 'All Blood Groups';
      _selectedAdmissionDate = null;
    });
    _loadPatients();
  }

  void _openAdmitPatientModal() {
    showDialog(
      context: context,
      builder: (dialogContext) {
        final messenger = ScaffoldMessenger.of(dialogContext);
        return AdmitPatientModal(
          onPatientAdmitted: (newPatient) async {
            final repo = RepositoryScope.of(context).patientRepository;
            final req = PatientAdmissionRequest(
              name: newPatient.name,
              age: newPatient.age,
              gender: newPatient.gender,
              bloodGroup: newPatient.bloodGroup,
              ward: newPatient.ward,
              status: newPatient.status,
              doctorName: newPatient.doctorName,
              vitals: newPatient.vitals,
            );
            await repo.admitPatient(req);
            await _loadPatients();

            messenger.showSnackBar(
              SnackBar(
                content: Text('Patient ${newPatient.name} admitted successfully'),
                backgroundColor: _primary,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
            );
          },
        );
      },
    );
  }

  Color _getStatusColor(PatientStatus status) {
    switch (status) {
      case PatientStatus.admitted:
        return _blue;
      case PatientStatus.icu:
        return _red;
      case PatientStatus.observation:
        return _orange;
      case PatientStatus.discharged:
        return _green;
      default:
        return const Color(0xFF6B7280);
    }
  }

  String _getStatusLabel(PatientStatus status) {
    switch (status) {
      case PatientStatus.admitted:
        return 'Admitted';
      case PatientStatus.icu:
        return 'ICU (Critical)';
      case PatientStatus.observation:
        return 'Observation';
      case PatientStatus.discharged:
        return 'Discharged';
      default:
        return status.name;
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;
    final isDark = HealthifyGlassTheme.isDark(context);

    return Stack(
      children: [
        Scaffold(
          backgroundColor: _background(isDark),
          body: AnimatedPulseBackground(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.fromLTRB(
                isMobile ? 16 : 24,
                20,
                isMobile ? 16 : 24,
                40,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(isMobile, isDark),

                  const SizedBox(height: 18),

                  // Repository-driven Overview KPI Cards
                  _buildQuickStatsDashboard(isMobile, isDark),

                  const SizedBox(height: 18),

                  // Search & Filter Toolbar
                  _buildSearchAndFilterToolbar(isMobile, isDark),

                  const SizedBox(height: 16),

                  // Privacy Access Banner
                  _buildPrivacyBanner(isDark),

                  const SizedBox(height: 20),

                  if (_uiState.isLoading)
                    const MedrixLoadingState(message: 'Loading patient directory...')
                  else if (_uiState.isError)
                    MedrixErrorState(
                      errorMessage: _uiState.errorMessage ?? 'Error loading patients',
                      onRetry: _loadPatients,
                    )
                  else if (_filteredPatients.isEmpty)
                    _buildEmptyState(isDark)
                  else if (isMobile)
                    _buildMobileCardsView(isDark)
                  else
                    _buildPatientDataTable(isDark),

                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ),

        // Patient Profile Drawer Overlay
        if (_selectedPatient != null)
          Positioned.fill(
            child: Stack(
              children: [
                GestureDetector(
                  onTap: () => setState(() => _selectedPatient = null),
                  child: Container(color: Colors.black.withValues(alpha: 0.45)),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: PatientProfileDrawer(
                    patient: _selectedPatient!,
                    onClose: () => setState(() => _selectedPatient = null),
                    onStatusChanged: (newStatus) async {
                      final repo = RepositoryScope.of(context).patientRepository;
                      await repo.updatePatientStatus(_selectedPatient!.id, newStatus);
                      setState(() {
                        _selectedPatient!.status = newStatus;
                      });
                      _loadPatients();
                    },
                    onWardChanged: (newWard) async {
                      final repo = RepositoryScope.of(context).patientRepository;
                      await repo.updatePatientWard(_selectedPatient!.id, newWard);
                      setState(() {
                        _selectedPatient!.ward = newWard;
                      });
                      _loadPatients();
                    },
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildHeader(bool isMobile, bool isDark) {
    final title = Text(
      'Patient Operations & Intake',
      style: TextStyle(
        color: _primaryText(isDark),
        fontSize: isMobile ? 23 : 26,
        fontWeight: FontWeight.w900,
        letterSpacing: -0.7,
      ),
    );

    final subtitle = Text(
      'Centralized hospital command center for patient directory, MRN tracking, and admissions.',
      style: TextStyle(
        color: _secondaryText(isDark),
        fontSize: isMobile ? 12 : 13,
        height: 1.4,
      ),
    );

    final button = SizedBox(
      height: 46,
      child: ElevatedButton.icon(
        onPressed: _openAdmitPatientModal,
        style: ElevatedButton.styleFrom(
          backgroundColor: _primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 18),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
        icon: const Icon(Icons.person_add_outlined, size: 18),
        label: const Text(
          'Admit / Readmit Patient',
          style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800),
        ),
      ),
    );

    final linkClaimsButton = SizedBox(
      height: 46,
      child: OutlinedButton.icon(
        onPressed: () => AccountLinkRequestsModal.show(context),
        style: OutlinedButton.styleFrom(
          foregroundColor: _primary,
          side: const BorderSide(color: _primary, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
        icon: const Icon(Icons.link_rounded, size: 18),
        label: const Text(
          'Account-Link Claims',
          style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800),
        ),
      ),
    );

    if (isMobile) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          title,
          const SizedBox(height: 5),
          subtitle,
          const SizedBox(height: 15),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [button, linkClaimsButton],
          ),
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [title, const SizedBox(height: 5), subtitle],
          ),
        ),
        const SizedBox(width: 14),
        linkClaimsButton,
        const SizedBox(width: 10),
        button,
      ],
    );
  }

  Widget _buildQuickStatsDashboard(bool isMobile, bool isDark) {
    final metrics = _metricsState.data;
    final totalActive = metrics?.totalActiveAdmissions ?? 342;
    final icuCount = metrics?.icuPatients ?? 28;
    final admittedToday = metrics?.admissionsToday ?? 15;

    final cards = [
      _StatData(
        title: 'Total Active Admissions',
        count: '$totalActive',
        subtitle: 'Active hospital stay',
        icon: Icons.people_alt_outlined,
        color: _blue,
      ),
      _StatData(
        title: 'Critical Care (ICU)',
        count: '$icuCount',
        subtitle: 'High-risk monitoring',
        icon: Icons.warning_amber_rounded,
        color: _red,
      ),
      _StatData(
        title: 'Admitted Today',
        count: '$admittedToday',
        subtitle: 'Daily intake volume',
        icon: Icons.trending_up_rounded,
        color: _green,
      ),
    ];

    if (isMobile) {
      return Column(
        children: [
          for (int i = 0; i < cards.length; i++) ...[
            _buildStatCard(data: cards[i], isDark: isDark),
            if (i != cards.length - 1) const SizedBox(height: 10),
          ],
        ],
      );
    }

    return Row(
      children: [
        for (int i = 0; i < cards.length; i++) ...[
          Expanded(
            child: _buildStatCard(data: cards[i], isDark: isDark),
          ),
          if (i != cards.length - 1) const SizedBox(width: 14),
        ],
      ],
    );
  }

  Widget _buildStatCard({required _StatData data, required bool isDark}) {
    return GlassCard(
      padding: const EdgeInsets.all(16),
      borderRadius: 18,
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: data.color.withValues(alpha: isDark ? 0.14 : 0.08),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: data.color.withValues(alpha: 0.15)),
            ),
            child: Icon(data.icon, color: data.color, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: _secondaryText(isDark),
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  data.count,
                  style: TextStyle(
                    color: _primaryText(isDark),
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.5,
                  ),
                ),
                Text(
                  data.subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: data.color,
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrivacyBanner(bool isDark) {
    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      borderRadius: 14,
      child: Row(
        children: [
          const GlassIconContainer(
            icon: Icons.shield_outlined,
            color: _primary,
            size: 32,
            iconSize: 18,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Administrative Command View: Patient Identity, MRN & Ward details visible. Clinical notes & diagnostic reports are restricted to treating physicians.',
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

  Widget _buildSearchAndFilterToolbar(bool isMobile, bool isDark) {
    return GlassCard(
      padding: const EdgeInsets.all(14),
      borderRadius: 18,
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          SizedBox(
            width: isMobile ? double.infinity : 280,
            height: 44,
            child: TextField(
              onChanged: (value) {
                setState(() => _searchQuery = value);
                _loadPatients();
              },
              style: TextStyle(color: _primaryText(isDark), fontSize: 13.5),
              cursorColor: _primary,
              decoration: GlassTextFieldTheme.getDecoration(
                context: context,
                hintText: 'Search patient by Name, MRN, or ID...',
                prefixIcon: const Icon(Icons.search_rounded, size: 20),
              ),
            ),
          ),

          _buildFilterDropdown(
            value: _selectedStatusFilter,
            items: const [
              'All Statuses',
              'Admitted',
              'ICU',
              'Observation',
              'Discharged',
            ],
            icon: Icons.filter_alt_outlined,
            isDark: isDark,
            onChanged: (value) {
              setState(() => _selectedStatusFilter = value);
              _loadPatients();
            },
          ),

          _buildFilterDropdown(
            value: _selectedBloodFilter,
            items: const [
              'All Blood Groups',
              'A+',
              'A-',
              'B+',
              'B-',
              'AB+',
              'AB-',
              'O+',
              'O-',
            ],
            icon: Icons.bloodtype_outlined,
            isDark: isDark,
            onChanged: (value) {
              setState(() => _selectedBloodFilter = value);
              _loadPatients();
            },
          ),

          _buildDateButton(isDark),

          if (_selectedAdmissionDate != null || _searchQuery.isNotEmpty || _selectedStatusFilter != 'All Statuses' || _selectedBloodFilter != 'All Blood Groups')
            SizedBox(
              height: 44,
              child: TextButton.icon(
                onPressed: _clearAllFilters,
                style: TextButton.styleFrom(
                  foregroundColor: Colors.redAccent,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                ),
                icon: const Icon(Icons.filter_alt_off_rounded, size: 16),
                label: const Text(
                  'Reset Filters',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFilterDropdown({
    required String value,
    required List<String> items,
    required IconData icon,
    required bool isDark,
    required ValueChanged<String> onChanged,
  }) {
    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 11),
      decoration: BoxDecoration(
        color: _surfaceStrong(isDark),
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: _border(isDark)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          icon: Icon(
            Icons.keyboard_arrow_down_rounded,
            color: _secondaryText(isDark),
            size: 19,
          ),
          dropdownColor: isDark ? const Color(0xFF122524) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          style: TextStyle(
            color: _primaryText(isDark),
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
          items: items.map((item) {
            return DropdownMenuItem(
              value: item,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (item == value) ...[
                    Icon(icon, color: _primary, size: 16),
                    const SizedBox(width: 7),
                  ],
                  Text(item),
                ],
              ),
            );
          }).toList(),
          onChanged: (val) {
            if (val != null) onChanged(val);
          },
        ),
      ),
    );
  }

  Widget _buildDateButton(bool isDark) {
    return SizedBox(
      height: 44,
      child: OutlinedButton.icon(
        onPressed: () async {
          final picked = await showDatePicker(
            context: context,
            initialDate: _selectedAdmissionDate ?? DateTime.now(),
            firstDate: DateTime(2020),
            lastDate: DateTime.now(),
          );
          if (picked != null) {
            setState(() => _selectedAdmissionDate = picked);
            _loadPatients();
          }
        },
        style: OutlinedButton.styleFrom(
          foregroundColor: _primaryText(isDark),
          backgroundColor: _surfaceStrong(isDark),
          side: BorderSide(color: _border(isDark)),
          padding: const EdgeInsets.symmetric(horizontal: 13),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13)),
        ),
        icon: const Icon(Icons.calendar_today_outlined, size: 16, color: _primary),
        label: Text(
          _selectedAdmissionDate == null
              ? 'Admission Date'
              : '${_selectedAdmissionDate!.day}/${_selectedAdmissionDate!.month}/${_selectedAdmissionDate!.year}',
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Widget _buildPatientDataTable(bool isDark) {
    return GlassCard(
      padding: const EdgeInsets.all(20),
      borderRadius: 22,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const GlassIconContainer(
                icon: Icons.people_alt_outlined,
                color: _primary,
                size: 40,
                iconSize: 20,
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hospital Patient Roster',
                      style: TextStyle(
                        color: _primaryText(isDark),
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Showing ${_filteredPatients.length} active record(s)',
                      style: TextStyle(color: _secondaryText(isDark), fontSize: 11.5),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Divider(color: _border(isDark), height: 1),
          const SizedBox(height: 12),

          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingRowHeight: 48,
              dataRowMinHeight: 68,
              dataRowMaxHeight: 78,
              horizontalMargin: 8,
              columnSpacing: 28,
              headingTextStyle: TextStyle(
                color: _secondaryText(isDark),
                fontSize: 11.5,
                fontWeight: FontWeight.w800,
              ),
              dataTextStyle: TextStyle(
                color: _primaryText(isDark),
                fontSize: 12.5,
              ),
              columns: const [
                DataColumn(label: Text('Patient Details')),
                DataColumn(label: Text('ID & Blood Group')),
                DataColumn(label: Text('Ward / Department')),
                DataColumn(label: Text('Admission Date')),
                DataColumn(label: Text('Status')),
                DataColumn(label: Text('Actions')),
              ],
              rows: _filteredPatients.map((patient) {
                final statusColor = _getStatusColor(patient.status);
                final isDischarged = patient.status == PatientStatus.discharged;

                return DataRow(
                  cells: [
                    DataCell(
                      Row(
                        children: [
                          _buildAvatar(patient, 18),
                          const SizedBox(width: 10),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                patient.name,
                                style: TextStyle(
                                  color: _primaryText(isDark),
                                  fontWeight: FontWeight.w800,
                                  fontSize: 12.5,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${patient.age} yrs • ${patient.gender}',
                                style: TextStyle(color: _secondaryText(isDark), fontSize: 10.5),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    DataCell(
                      Row(
                        children: [
                          Text(
                            patient.id,
                            style: TextStyle(
                              color: _primaryText(isDark),
                              fontWeight: FontWeight.w700,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(width: 8),
                          _bloodBadge(patient.bloodGroup, isDark),
                        ],
                      ),
                    ),
                    DataCell(
                      Text(
                        isDischarged ? 'N/A - Discharged' : patient.ward,
                        style: TextStyle(
                          color: isDischarged ? Colors.grey : _primaryText(isDark),
                          fontSize: 12,
                          fontWeight: isDischarged ? FontWeight.normal : FontWeight.w600,
                        ),
                      ),
                    ),
                    DataCell(
                      Text(
                        '${patient.admissionDate.day}/${patient.admissionDate.month}/${patient.admissionDate.year}',
                        style: TextStyle(color: _primaryText(isDark), fontSize: 12, fontWeight: FontWeight.w500),
                      ),
                    ),
                    DataCell(_statusBadge(patient.status, statusColor, isDark)),
                    DataCell(
                      Row(
                        children: [
                          GlassSecondaryButton(
                            height: 34,
                            onPressed: () => setState(() => _selectedPatient = patient),
                            child: const Row(
                              children: [
                                Icon(Icons.person_outline_rounded, size: 14),
                                SizedBox(width: 4),
                                Text('Profile', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                          const SizedBox(width: 6),
                          PopupMenuButton<String>(
                            icon: Icon(Icons.more_vert_rounded, size: 19, color: _secondaryText(isDark)),
                            color: isDark ? const Color(0xFF122524) : Colors.white,
                            onSelected: (value) async {
                              if (value == 'profile') {
                                setState(() => _selectedPatient = patient);
                              } else if (value == 'discharge') {
                                final repo = RepositoryScope.of(context).patientRepository;
                                await repo.dischargePatient(patient.id);
                                _loadPatients();
                              }
                            },
                            itemBuilder: (context) => [
                              const PopupMenuItem(value: 'profile', child: Text('View Profile & MRN')),
                              if (!isDischarged)
                                const PopupMenuItem(value: 'discharge', child: Text('Discharge Patient')),
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

  Widget _buildMobileCardsView(bool isDark) {
    return Column(
      children: _filteredPatients.map((patient) {
        final statusColor = _getStatusColor(patient.status);
        final isDischarged = patient.status == PatientStatus.discharged;

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: GlassCard(
            padding: const EdgeInsets.all(16),
            borderRadius: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _buildAvatar(patient, 20),
                    const SizedBox(width: 11),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            patient.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: _primaryText(isDark),
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            '${patient.id} • ${patient.age} Yrs • ${patient.gender}',
                            style: TextStyle(color: _secondaryText(isDark), fontSize: 10.5),
                          ),
                        ],
                      ),
                    ),
                    _statusBadge(patient.status, statusColor, isDark),
                  ],
                ),
                const SizedBox(height: 14),
                Divider(color: _border(isDark), height: 1),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Ward: ${isDischarged ? 'Discharged' : patient.ward}',
                        style: TextStyle(color: _primaryText(isDark), fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ),
                    _bloodBadge(patient.bloodGroup, isDark, large: true),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Admitted: ${patient.admissionDate.day}/${patient.admissionDate.month}/${patient.admissionDate.year}',
                      style: TextStyle(color: _secondaryText(isDark), fontSize: 11.5),
                    ),
                    GlassSecondaryButton(
                      height: 34,
                      onPressed: () => setState(() => _selectedPatient = patient),
                      child: const Text('View Profile', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
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

  Widget _buildEmptyState(bool isDark) {
    return MedrixEmptyState(
      title: 'No Patient Records Found',
      description: 'No patient records matched your search query or active filter criteria.',
      icon: Icons.search_off_rounded,
      actionLabel: 'Reset Filters',
      onAction: _clearAllFilters,
    );
  }

  Widget _buildAvatar(PatientItem patient, double radius) {
    return Container(
      width: radius * 2,
      height: radius * 2,
      decoration: BoxDecoration(
        color: patient.avatarGradientStart,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          patient.initials,
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w900,
            fontSize: radius * 0.55,
          ),
        ),
      ),
    );
  }

  Widget _bloodBadge(String bloodGroup, bool isDark, {bool large = false}) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: large ? 10 : 7,
        vertical: large ? 7 : 4,
      ),
      decoration: BoxDecoration(
        color: _red.withValues(alpha: isDark ? 0.10 : 0.075),
        borderRadius: BorderRadius.circular(large ? 10 : 7),
        border: Border.all(color: _red.withValues(alpha: 0.14)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.bloodtype_rounded, color: _red, size: large ? 17 : 13),
          const SizedBox(width: 4),
          Text(
            large ? 'Blood: $bloodGroup' : bloodGroup,
            style: TextStyle(
              color: _red,
              fontSize: large ? 11 : 10.5,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  Widget _statusBadge(PatientStatus status, Color color, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: isDark ? 0.11 : 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.15)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 5),
          Text(
            _getStatusLabel(status),
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatData {
  final String title;
  final String count;
  final String subtitle;
  final IconData icon;
  final Color color;

  const _StatData({
    required this.title,
    required this.count,
    required this.subtitle,
    required this.icon,
    required this.color,
  });
}