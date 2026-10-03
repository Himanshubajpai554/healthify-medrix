import 'package:flutter/material.dart';
import '../../../shared/widgets/glass_components.dart';
import '../../../theme/app_theme.dart';

class QuickActionsModals {
  static void showRegisterPatientModal(BuildContext context, {Function(String)? onSuccess}) {
    final nameController = TextEditingController();
    final ageController = TextEditingController();
    String gender = 'Male';
    String department = 'Emergency';
    String priority = 'Level 2 - Urgent';

    showHealthifyGlassBottomSheet(
      context: context,
      builder: (context) {
        final isDark = HealthifyGlassTheme.isDarkMode(context);
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      const GlassIconContainer(
                        icon: Icons.person_add_rounded,
                        color: AppTheme.primaryColor,
                        size: 40,
                        iconSize: 22,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Admit New Patient',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : AppTheme.textPrimary,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.close_rounded, color: isDark ? Colors.white70 : AppTheme.textSecondary),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  TextField(
                    controller: nameController,
                    style: TextStyle(color: isDark ? Colors.white : AppTheme.textPrimary),
                    decoration: GlassTextFieldTheme.getDecoration(
                      context: context,
                      hintText: 'Enter full name',
                      labelText: 'Patient Full Name',
                      prefixIcon: const Icon(Icons.person_outline),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: ageController,
                    keyboardType: TextInputType.number,
                    style: TextStyle(color: isDark ? Colors.white : AppTheme.textPrimary),
                    decoration: GlassTextFieldTheme.getDecoration(
                      context: context,
                      hintText: 'Enter age',
                      labelText: 'Age',
                      prefixIcon: const Icon(Icons.cake_outlined),
                    ),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    isExpanded: true,
                    initialValue: gender,
                    dropdownColor: isDark ? const Color(0xFF0F2928) : Colors.white,
                    style: TextStyle(color: isDark ? Colors.white : AppTheme.textPrimary),
                    decoration: GlassTextFieldTheme.getDecoration(
                      context: context,
                      hintText: 'Select gender',
                      labelText: 'Gender',
                      prefixIcon: const Icon(Icons.wc_outlined),
                    ),
                    items: ['Male', 'Female', 'Other']
                        .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                        .toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setModalState(() => gender = val);
                      }
                    },
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    isExpanded: true,
                    initialValue: department,
                    dropdownColor: isDark ? const Color(0xFF0F2928) : Colors.white,
                    style: TextStyle(color: isDark ? Colors.white : AppTheme.textPrimary),
                    decoration: GlassTextFieldTheme.getDecoration(
                      context: context,
                      hintText: 'Select department',
                      labelText: 'Admitting Department',
                      prefixIcon: const Icon(Icons.local_hospital_outlined),
                    ),
                    items: ['Emergency', 'Cardiology', 'ICU', 'Neurology', 'Pediatrics']
                        .map((d) => DropdownMenuItem(value: d, child: Text(d)))
                        .toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setModalState(() => department = val);
                      }
                    },
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    isExpanded: true,
                    initialValue: priority,
                    dropdownColor: isDark ? const Color(0xFF0F2928) : Colors.white,
                    style: TextStyle(color: isDark ? Colors.white : AppTheme.textPrimary),
                    decoration: GlassTextFieldTheme.getDecoration(
                      context: context,
                      hintText: 'Select priority',
                      labelText: 'Triage Priority Level',
                      prefixIcon: const Icon(Icons.warning_amber_rounded),
                    ),
                    items: ['Level 1 - Critical', 'Level 2 - Urgent', 'Level 3 - Standard']
                        .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                        .toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setModalState(() => priority = val);
                      }
                    },
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: GlassSecondaryButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Cancel'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: GlassPrimaryButton(
                          onPressed: () {
                            final name = nameController.text.trim();
                            if (name.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Please enter patient name')),
                              );
                              return;
                            }
                            Navigator.pop(context);
                            if (onSuccess != null) {
                              onSuccess('Patient "$name" admitted to $department under triage $priority');
                            }
                          },
                          child: const Text('Admit Patient'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  static void showAddDoctorModal(BuildContext context, {Function(String)? onSuccess}) {
    final nameController = TextEditingController();
    String dept = 'Cardiology';
    String shift = 'Day Shift (08:00 - 16:00)';

    showHealthifyGlassBottomSheet(
      context: context,
      builder: (context) {
        final isDark = HealthifyGlassTheme.isDarkMode(context);
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      const GlassIconContainer(
                        icon: Icons.badge_outlined,
                        color: AppTheme.accentColor,
                        size: 40,
                        iconSize: 22,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Schedule Doctor Shift',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : AppTheme.textPrimary,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.close_rounded, color: isDark ? Colors.white70 : AppTheme.textSecondary),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  TextField(
                    controller: nameController,
                    style: TextStyle(color: isDark ? Colors.white : AppTheme.textPrimary),
                    decoration: GlassTextFieldTheme.getDecoration(
                      context: context,
                      hintText: 'e.g. Dr. Robert Chen',
                      labelText: 'Doctor Name',
                      prefixIcon: const Icon(Icons.person_pin_outlined),
                    ),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    isExpanded: true,
                    initialValue: dept,
                    dropdownColor: isDark ? const Color(0xFF0F2928) : Colors.white,
                    style: TextStyle(color: isDark ? Colors.white : AppTheme.textPrimary),
                    decoration: GlassTextFieldTheme.getDecoration(
                      context: context,
                      hintText: 'Select department',
                      labelText: 'Department',
                      prefixIcon: const Icon(Icons.medical_services_outlined),
                    ),
                    items: ['Cardiology', 'Neurology', 'Orthopedics', 'Emergency', 'Pediatrics']
                        .map((d) => DropdownMenuItem(value: d, child: Text(d)))
                        .toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setModalState(() => dept = val);
                      }
                    },
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    isExpanded: true,
                    initialValue: shift,
                    dropdownColor: isDark ? const Color(0xFF0F2928) : Colors.white,
                    style: TextStyle(color: isDark ? Colors.white : AppTheme.textPrimary),
                    decoration: GlassTextFieldTheme.getDecoration(
                      context: context,
                      hintText: 'Select shift',
                      labelText: 'Shift Duration',
                      prefixIcon: const Icon(Icons.access_time_rounded),
                    ),
                    items: [
                      'Day Shift (08:00 - 16:00)',
                      'Evening Shift (16:00 - 00:00)',
                      'Night Shift (00:00 - 08:00)',
                      'On Call'
                    ]
                        .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                        .toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setModalState(() => shift = val);
                      }
                    },
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: GlassSecondaryButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Cancel'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: GlassPrimaryButton(
                          color: AppTheme.accentColor,
                          onPressed: () {
                            final name = nameController.text.trim();
                            if (name.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Please enter doctor name')),
                              );
                              return;
                            }
                            Navigator.pop(context);
                            if (onSuccess != null) {
                              onSuccess('$name assigned to $dept ($shift)');
                            }
                          },
                          child: const Text('Schedule Doctor'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  static void showAllocateBedModal(BuildContext context, {Function(String)? onSuccess}) {
    String wardType = 'ICU';
    String bedId = 'ICU-105';

    showHealthifyGlassBottomSheet(
      context: context,
      builder: (context) {
        final isDark = HealthifyGlassTheme.isDarkMode(context);
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      const GlassIconContainer(
                        icon: Icons.king_bed_outlined,
                        color: Color(0xFFD97706),
                        size: 40,
                        iconSize: 22,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Allocate Emergency Bed',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : AppTheme.textPrimary,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.close_rounded, color: isDark ? Colors.white70 : AppTheme.textSecondary),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  DropdownButtonFormField<String>(
                    isExpanded: true,
                    initialValue: wardType,
                    dropdownColor: isDark ? const Color(0xFF0F2928) : Colors.white,
                    style: TextStyle(color: isDark ? Colors.white : AppTheme.textPrimary),
                    decoration: GlassTextFieldTheme.getDecoration(
                      context: context,
                      hintText: 'Select category',
                      labelText: 'Ward Category',
                      prefixIcon: const Icon(Icons.domain_outlined),
                    ),
                    items: ['ICU', 'General Ward', 'Emergency Care', 'Pediatric Care', 'Surgical Ward']
                        .map((w) => DropdownMenuItem(value: w, child: Text(w)))
                        .toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setModalState(() {
                          wardType = val;
                          if (val == 'ICU') {
                            bedId = 'ICU-105';
                          } else if (val == 'General Ward') {
                            bedId = 'GW-204';
                          } else {
                            bedId = 'EM-04';
                          }
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    isExpanded: true,
                    initialValue: bedId,
                    dropdownColor: isDark ? const Color(0xFF0F2928) : Colors.white,
                    style: TextStyle(color: isDark ? Colors.white : AppTheme.textPrimary),
                    decoration: GlassTextFieldTheme.getDecoration(
                      context: context,
                      hintText: 'Select bed',
                      labelText: 'Available Bed Number',
                      prefixIcon: const Icon(Icons.bed_rounded),
                    ),
                    items: [bedId, '${bedId.split('-')[0]}-08', '${bedId.split('-')[0]}-12']
                        .map((b) => DropdownMenuItem(value: b, child: Text(b)))
                        .toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setModalState(() => bedId = val);
                      }
                    },
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: GlassSecondaryButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Cancel'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: GlassPrimaryButton(
                          color: const Color(0xFFD97706),
                          onPressed: () {
                            Navigator.pop(context);
                            if (onSuccess != null) {
                              onSuccess('Bed $bedId successfully allocated in $wardType');
                            }
                          },
                          child: const Text('Allocate Bed'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  static void showRequestBloodModal(BuildContext context, {Function(String)? onSuccess}) {
    String bloodGroup = 'O-ve';
    int units = 2;
    String priority = 'Immediate Critical (Emergency)';

    showHealthifyGlassBottomSheet(
      context: context,
      builder: (context) {
        final isDark = HealthifyGlassTheme.isDarkMode(context);
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      const GlassIconContainer(
                        icon: Icons.bloodtype_outlined,
                        color: Color(0xFFE11D48),
                        size: 40,
                        iconSize: 22,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Request Blood Dispatch',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : AppTheme.textPrimary,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.close_rounded, color: isDark ? Colors.white70 : AppTheme.textSecondary),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  DropdownButtonFormField<String>(
                    isExpanded: true,
                    initialValue: bloodGroup,
                    dropdownColor: isDark ? const Color(0xFF0F2928) : Colors.white,
                    style: TextStyle(color: isDark ? Colors.white : AppTheme.textPrimary),
                    decoration: GlassTextFieldTheme.getDecoration(
                      context: context,
                      hintText: 'Select group',
                      labelText: 'Required Blood Group',
                      prefixIcon: const Icon(Icons.water_drop_outlined),
                    ),
                    items: ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-ve']
                        .map((bg) => DropdownMenuItem(value: bg, child: Text(bg)))
                        .toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setModalState(() => bloodGroup = val);
                      }
                    },
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<int>(
                    isExpanded: true,
                    initialValue: units,
                    dropdownColor: isDark ? const Color(0xFF0F2928) : Colors.white,
                    style: TextStyle(color: isDark ? Colors.white : AppTheme.textPrimary),
                    decoration: GlassTextFieldTheme.getDecoration(
                      context: context,
                      hintText: 'Select units',
                      labelText: 'Units Required',
                      prefixIcon: const Icon(Icons.inventory_2_outlined),
                    ),
                    items: [1, 2, 3, 4, 5, 10]
                        .map((u) => DropdownMenuItem(value: u, child: Text('$u Units')))
                        .toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setModalState(() => units = val);
                      }
                    },
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    isExpanded: true,
                    initialValue: priority,
                    dropdownColor: isDark ? const Color(0xFF0F2928) : Colors.white,
                    style: TextStyle(color: isDark ? Colors.white : AppTheme.textPrimary),
                    decoration: GlassTextFieldTheme.getDecoration(
                      context: context,
                      hintText: 'Select urgency',
                      labelText: 'Urgency Priority',
                      prefixIcon: const Icon(Icons.priority_high_rounded),
                    ),
                    items: [
                      'Immediate Critical (Emergency)',
                      'Urgent Surgical Reserve',
                      'Routine Inventory Top-up'
                    ]
                        .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                        .toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setModalState(() => priority = val);
                      }
                    },
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: GlassSecondaryButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Cancel'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: GlassPrimaryButton(
                          color: const Color(0xFFE11D48),
                          onPressed: () {
                            Navigator.pop(context);
                            if (onSuccess != null) {
                              onSuccess('Dispatch request for $units units of $bloodGroup ($priority) placed!');
                            }
                          },
                          child: const Text('Request Blood'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  static void showUploadReportModal(BuildContext context, {Function(String)? onSuccess}) {
    final patientIdController = TextEditingController();
    String reportType = 'Complete Blood Count (CBC)';

    showHealthifyGlassBottomSheet(
      context: context,
      builder: (context) {
        final isDark = HealthifyGlassTheme.isDarkMode(context);
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      const GlassIconContainer(
                        icon: Icons.upload_file_rounded,
                        color: AppTheme.primaryColor,
                        size: 40,
                        iconSize: 22,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Upload Diagnostic Report',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : AppTheme.textPrimary,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.close_rounded, color: isDark ? Colors.white70 : AppTheme.textSecondary),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  TextField(
                    controller: patientIdController,
                    style: TextStyle(color: isDark ? Colors.white : AppTheme.textPrimary),
                    decoration: GlassTextFieldTheme.getDecoration(
                      context: context,
                      hintText: 'e.g. PAT-8842',
                      labelText: 'Patient ID / Registration Number',
                      prefixIcon: const Icon(Icons.tag),
                    ),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    isExpanded: true,
                    initialValue: reportType,
                    dropdownColor: isDark ? const Color(0xFF0F2928) : Colors.white,
                    style: TextStyle(color: isDark ? Colors.white : AppTheme.textPrimary),
                    decoration: GlassTextFieldTheme.getDecoration(
                      context: context,
                      hintText: 'Select category',
                      labelText: 'Report Category',
                      prefixIcon: const Icon(Icons.science_outlined),
                    ),
                    items: [
                      'Complete Blood Count (CBC)',
                      'Chest X-Ray Digital Scan',
                      'MRI Brain & Spine Scan',
                      'ECG Cardiac Evaluation',
                      'CT Abdomen Contrast'
                    ]
                        .map((r) => DropdownMenuItem(value: r, child: Text(r)))
                        .toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setModalState(() => reportType = val);
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: HealthifyGlassTheme.getGlassSurface(isDark),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: HealthifyGlassTheme.getGlassBorder(isDark), width: 1.2),
                    ),
                    child: Column(
                      children: [
                        const Icon(Icons.cloud_upload_outlined, color: AppTheme.primaryColor, size: 36),
                        const SizedBox(height: 8),
                        Text(
                          'Click or Drag DICOM/PDF files to upload',
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : AppTheme.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Supports DICOM, PDF, JPG up to 50MB',
                          style: TextStyle(
                            fontSize: 11,
                            color: isDark ? Colors.white54 : AppTheme.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: GlassSecondaryButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Cancel'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: GlassPrimaryButton(
                          onPressed: () {
                            final pid = patientIdController.text.trim();
                            final target = pid.isEmpty ? 'PAT-8842' : pid;
                            Navigator.pop(context);
                            if (onSuccess != null) {
                              onSuccess('$reportType uploaded for Patient $target!');
                            }
                          },
                          child: const Text('Upload & Save'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}