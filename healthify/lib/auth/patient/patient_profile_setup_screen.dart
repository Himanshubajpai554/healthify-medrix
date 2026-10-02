import 'package:flutter/material.dart';
import '../../utils/page_transitions.dart';
import '../../shared/widgets/animated_pulse_background.dart';
import '../../shared/widgets/glass_components.dart';
import './patient_location_permission_screen.dart';

class PatientProfileSetupScreen extends StatefulWidget {
  final String fullName;
  final String phoneNumber;

  const PatientProfileSetupScreen({
    super.key,
    this.fullName = 'Alex Rivera',
    this.phoneNumber = '+91 98765 43210',
  });

  @override
  State<PatientProfileSetupScreen> createState() => _PatientProfileSetupScreenState();
}

class _PatientProfileSetupScreenState extends State<PatientProfileSetupScreen> {
  DateTime? _dateOfBirth;
  String _selectedGender = 'Prefer not to say';
  String _selectedBloodGroup = 'O+';

  final _emergencyNameController = TextEditingController();
  final _emergencyPhoneController = TextEditingController();
  final _allergiesController = TextEditingController();
  final _medicalConditionsController = TextEditingController();

  bool _isSaving = false;

  final List<String> _genderOptions = const [
    'Male',
    'Female',
    'Other',
    'Prefer not to say'
  ];

  final List<String> _bloodGroupOptions = const [
    'A+', 'A-', 'B+', 'B-', 'O+', 'O-', 'AB+', 'AB-'
  ];

  @override
  void dispose() {
    _emergencyNameController.dispose();
    _emergencyPhoneController.dispose();
    _allergiesController.dispose();
    _medicalConditionsController.dispose();
    super.dispose();
  }

  void _proceedNext() {
    setState(() => _isSaving = true);

    Future.delayed(const Duration(milliseconds: 600), () {
      if (!mounted) return;
      setState(() => _isSaving = false);

      Navigator.pushReplacement(
        context,
        FadePageRoute(page: const PatientLocationPermissionScreen()),
      );
    });
  }

  void _selectDob() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(1995, 5, 15),
      firstDate: DateTime(1920),
      lastDate: DateTime.now(),
      builder: (context, child) {
        final isDark = HealthifyGlassTheme.isDarkMode(context);
        return Theme(
          data: isDark ? ThemeData.dark() : ThemeData.light(),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _dateOfBirth = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = HealthifyGlassTheme.isDarkMode(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 900;

    final primaryTextColor = HealthifyGlassTheme.getTextPrimary(isDark);
    final secondaryTextColor = HealthifyGlassTheme.getTextSecondary(isDark);

    return Scaffold(
      backgroundColor: HealthifyGlassTheme.getBackgroundColor(isDark),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text(
          'Quick Health Setup',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: primaryTextColor),
        ),
        actions: [
          // PROMINENT SKIP BUTTON
          TextButton.icon(
            onPressed: _proceedNext,
            icon: const Icon(Icons.skip_next_rounded, color: HealthifyGlassTheme.primaryTeal),
            label: const Text(
              'Skip for Now',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: HealthifyGlassTheme.primaryTeal,
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: AnimatedPulseBackground(
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: isDesktop ? 32 : 20,
                vertical: isDesktop ? 24 : 12,
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: isDesktop ? 540 : 460),
                child: GlassCard(
                  borderRadius: 24,
                  hasTealGlow: true,
                  padding: EdgeInsets.all(isDesktop ? 32.0 : 24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Onboarding Header
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: HealthifyGlassTheme.primaryTeal.withValues(alpha: isDark ? 0.18 : 0.08),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: HealthifyGlassTheme.primaryTeal.withValues(alpha: 0.25),
                          ),
                        ),
                        child: Row(
                          children: const [
                            GlassIconContainer(
                              icon: Icons.badge_outlined,
                              size: 40,
                              iconSize: 20,
                              color: HealthifyGlassTheme.primaryTeal,
                              borderRadius: 12,
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Optional Patient Profile Setup',
                                style: TextStyle(
                                  fontSize: 15.5,
                                  fontWeight: FontWeight.bold,
                                  color: HealthifyGlassTheme.primaryTeal,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Provide your basic health indicators for faster ER triage & appointment booking. You can complete this anytime in your profile settings.',
                        style: TextStyle(fontSize: 13, color: secondaryTextColor, height: 1.4),
                      ),
                      const SizedBox(height: 20),
                      Divider(color: HealthifyGlassTheme.getGlassBorder(isDark)),
                      const SizedBox(height: 16),

                      // 1. DATE OF BIRTH
                      Text(
                        'Date of Birth (Optional)',
                        style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600, color: primaryTextColor),
                      ),
                      const SizedBox(height: 6),
                      InkWell(
                        onTap: _selectDob,
                        borderRadius: BorderRadius.circular(15),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          decoration: BoxDecoration(
                            border: Border.all(color: HealthifyGlassTheme.getGlassBorder(isDark), width: 1.2),
                            borderRadius: BorderRadius.circular(15),
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.075)
                                : Colors.white.withValues(alpha: 0.90),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.calendar_today_rounded, size: 18, color: secondaryTextColor),
                              const SizedBox(width: 10),
                              Text(
                                _dateOfBirth == null
                                    ? 'Select Date of Birth'
                                    : '${_dateOfBirth!.day}/${_dateOfBirth!.month}/${_dateOfBirth!.year}',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: _dateOfBirth == null
                                      ? HealthifyGlassTheme.getTextMuted(isDark)
                                      : primaryTextColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),

                      // 2. GENDER SELECTION (GLASS CHIPS)
                      Text(
                        'Gender (Optional)',
                        style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600, color: primaryTextColor),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _genderOptions.map((gender) {
                          return GlassSelectionChip(
                            label: gender,
                            isSelected: _selectedGender == gender,
                            onTap: () => setState(() => _selectedGender = gender),
                          );
                        }).toList(),
                      ),

                      const SizedBox(height: 18),

                      // 3. BLOOD GROUP SELECTION (GLASS CHIPS)
                      Text(
                        'Blood Group (Optional)',
                        style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600, color: primaryTextColor),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _bloodGroupOptions.map((bg) {
                          return GlassSelectionChip(
                            label: bg,
                            isSelected: _selectedBloodGroup == bg,
                            onTap: () => setState(() => _selectedBloodGroup = bg),
                          );
                        }).toList(),
                      ),

                      const SizedBox(height: 20),

                      // 4. EMERGENCY CONTACT
                      Text(
                        'Emergency Contact Name & Phone (Optional)',
                        style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600, color: primaryTextColor),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _emergencyNameController,
                              style: TextStyle(color: primaryTextColor),
                              decoration: GlassTextFieldTheme.getDecoration(
                                context: context,
                                hintText: 'Contact Name',
                                prefixIcon: const Icon(Icons.contact_phone_outlined),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextFormField(
                              controller: _emergencyPhoneController,
                              keyboardType: TextInputType.phone,
                              style: TextStyle(color: primaryTextColor),
                              decoration: GlassTextFieldTheme.getDecoration(
                                context: context,
                                hintText: '+91 Phone',
                                prefixIcon: const Icon(Icons.phone),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),

                      // 5. ALLERGIES & CONDITIONS
                      Text(
                        'Known Allergies or Medical Conditions (Optional)',
                        style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600, color: primaryTextColor),
                      ),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _allergiesController,
                        maxLines: 2,
                        style: TextStyle(color: primaryTextColor),
                        decoration: GlassTextFieldTheme.getDecoration(
                          context: context,
                          hintText: 'e.g. Penicillin allergy, Hypertension, Asthma...',
                          prefixIcon: const Icon(Icons.healing_outlined),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // FOOTER ACTION BUTTONS
                      Row(
                        children: [
                          Expanded(
                            child: GlassSecondaryButton(
                              height: 50,
                              onPressed: _proceedNext,
                              child: const Text('Skip for Now', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: GlassPrimaryButton(
                              height: 50,
                              isLoading: _isSaving,
                              onPressed: _proceedNext,
                              child: const Text('Save & Continue', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}