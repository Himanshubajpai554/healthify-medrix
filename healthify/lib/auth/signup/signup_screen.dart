import 'package:flutter/material.dart';
import '../../utils/page_transitions.dart';
import '../../shared/widgets/animated_pulse_background.dart';
import '../widgets/form_progress_indicator.dart';
import '../../shared/widgets/glass_components.dart';
import '../widgets/hospital_hero_panel.dart';
import '../widgets/password_strength_meter.dart';
import '../doctor/doctor_signup_screen.dart';
import '../login/login_screen.dart';
import '../patient/patient_signup_screen.dart';

class HospitalSignupScreen extends StatefulWidget {
  const HospitalSignupScreen({super.key});

  @override
  State<HospitalSignupScreen> createState() => _HospitalSignupScreenState();
}

class _HospitalSignupScreenState extends State<HospitalSignupScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();

  // Process Card Stepper State (Step 1 to 5)
  int _currentStep = 1;

  // Text Controllers
  final _hospitalNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _licenseIdController = TextEditingController();
  final _cityController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  // Animation Controllers
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  // State Variables
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isAuthorizedChecked = false;
  bool _isSubmitted = false;

  // Validation States for Micro-Feedback Icons & Progress Tracking
  bool _isNameValid = false;
  bool _isEmailValid = false;
  bool _isPhoneValid = false;
  bool _isLicenseValid = false;
  bool _isCityValid = false;

  double get _formProgress {
    int total = 7;
    int count = 0;
    if (_isNameValid) count++;
    if (_isEmailValid) count++;
    if (_isPhoneValid) count++;
    if (_isLicenseValid) count++;
    if (_isCityValid) count++;
    if (_passwordController.text.length >= 8) count++;
    if (_isAuthorizedChecked) count++;
    return count / total;
  }

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.03), end: Offset.zero).animate(
          CurvedAnimation(parent: _fadeController, curve: Curves.easeOutCubic),
        );

    _fadeController.forward();

    _hospitalNameController.addListener(_validateFields);
    _emailController.addListener(_validateFields);
    _phoneController.addListener(_validateFields);
    _licenseIdController.addListener(_validateFields);
    _cityController.addListener(_validateFields);
    _passwordController.addListener(() => setState(() {}));
    _confirmPasswordController.addListener(() => setState(() {}));
  }

  void _validateFields() {
    setState(() {
      _isNameValid = _hospitalNameController.text.trim().isNotEmpty;
      _isEmailValid = RegExp(
        r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
      ).hasMatch(_emailController.text.trim());
      _isPhoneValid = _phoneController.text.trim().length >= 7;
      _isLicenseValid = _licenseIdController.text.trim().isNotEmpty;
      _isCityValid = _cityController.text.trim().isNotEmpty;
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _hospitalNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _licenseIdController.dispose();
    _cityController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // Step Validation & Navigation
  void _nextStep() {
    FocusScope.of(context).unfocus(); // Close active keyboard

    if (_currentStep == 2) {
      if (!_isNameValid) {
        _showValidationToast('Please enter the official hospital name');
        return;
      }
      if (!_isEmailValid) {
        _showValidationToast(
          'Please enter a valid official hospital email address',
        );
        return;
      }
    } else if (_currentStep == 3) {
      if (!_isPhoneValid) {
        _showValidationToast('Please enter a valid hospital phone number');
        return;
      }
      if (!_isLicenseValid) {
        _showValidationToast(
          'Please enter your hospital registration / license ID',
        );
        return;
      }
      if (!_isCityValid) {
        _showValidationToast('Please enter your hospital city');
        return;
      }
    } else if (_currentStep == 4) {
      if (_passwordController.text.length < 8) {
        _showValidationToast('Password must be at least 8 characters long');
        return;
      }
      if (_passwordController.text != _confirmPasswordController.text) {
        _showValidationToast('Passwords do not match');
        return;
      }
    }

    if (_currentStep < 5) {
      setState(() {
        _currentStep++;
      });
    }
  }

  void _previousStep() {
    FocusScope.of(context).unfocus();
    if (_currentStep > 1) {
      setState(() {
        _currentStep--;
      });
    }
  }

  void _jumpToStep(int step) {
    if (step < _currentStep) {
      FocusScope.of(context).unfocus();
      setState(() {
        _currentStep = step;
      });
    }
  }

  void _showValidationToast(String message) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(
              Icons.error_outline_rounded,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        backgroundColor: HealthifyGlassTheme.errorColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  // Handle Create Account Click: Shows Confirmation Modal
  void _onTapCreateAccount() {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;
    if (!_isAuthorizedChecked) return;

    _showConfirmationModal();
  }

  // Glassmorphic Confirmation Modal
  void _showConfirmationModal() {
    final isDark = HealthifyGlassTheme.isDarkMode(context);

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => AlertDialog(
        backgroundColor: isDark
            ? HealthifyGlassTheme.darkBackground.withValues(alpha: 0.95)
            : Colors.white.withValues(alpha: 0.95),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        contentPadding: const EdgeInsets.all(28),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                GlassIconContainer(
                  icon: Icons.shield_rounded,
                  size: 44,
                  iconSize: 24,
                  color: HealthifyGlassTheme.primaryTeal,
                  borderRadius: 14,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Confirm Registration',
                    style: TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.bold,
                      color: HealthifyGlassTheme.getTextPrimary(isDark),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Text(
              'By continuing, you certify that you are an authorized representative of this hospital and that all submitted credentials are valid and verifiable.',
              style: TextStyle(
                fontSize: 14,
                color: HealthifyGlassTheme.getTextSecondary(isDark),
                height: 1.48,
              ),
            ),
            const SizedBox(height: 24),
            Wrap(
              alignment: WrapAlignment.end,
              spacing: 12,
              runSpacing: 10,
              children: [
                GlassSecondaryButton(
                  height: 44,
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Review Details'),
                ),
                GlassPrimaryButton(
                  height: 44,
                  onPressed: () {
                    Navigator.pop(context); // Close Modal
                    setState(() {
                      _isSubmitted = true; // Switch to Success State
                    });
                  },
                  child: const Text('Submit for Verification'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = HealthifyGlassTheme.isDarkMode(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 980;

    return Scaffold(
      backgroundColor: HealthifyGlassTheme.getBackgroundColor(isDark),
      body: AnimatedPulseBackground(
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: isDesktop ? 32 : 14,
                vertical: isDesktop ? 32 : 16,
              ),
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: isDesktop ? 1200 : 680,
                    ),
                    child: GlassCard(
                      borderRadius: 28,
                      hasTealGlow: true,
                      padding: EdgeInsets.zero,
                      child: isDesktop
                          ? Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Expanded(
                                  flex: 5,
                                  child: HospitalHeroPanel(),
                                ),
                                Expanded(
                                  flex: 7,
                                  child: Padding(
                                    padding: const EdgeInsets.all(40.0),
                                    child: _isSubmitted
                                        ? _buildSuccessState(isDark: isDark)
                                        : _buildPremiumProcessCard(
                                            isDark: isDark,
                                            isDesktop: true,
                                          ),
                                  ),
                                ),
                              ],
                            )
                          : Padding(
                              padding: const EdgeInsets.all(22.0),
                              child: _isSubmitted
                                  ? _buildSuccessState(isDark: isDark)
                                  : _buildPremiumProcessCard(
                                      isDark: isDark,
                                      isDesktop: false,
                                    ),
                            ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // --- PREMIUM SUCCESS STATE VIEW ---
  Widget _buildSuccessState({required bool isDark}) {
    final primaryTextColor = HealthifyGlassTheme.getTextPrimary(isDark);
    final secondaryTextColor = HealthifyGlassTheme.getTextSecondary(isDark);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Center(
          child: TweenAnimationBuilder<double>(
            duration: const Duration(milliseconds: 700),
            tween: Tween(begin: 0.0, end: 1.0),
            curve: Curves.elasticOut,
            builder: (context, value, child) {
              return Transform.scale(
                scale: value,
                child: GlassIconContainer(
                  icon: Icons.verified_rounded,
                  size: 80,
                  iconSize: 48,
                  color: HealthifyGlassTheme.primaryTeal,
                  borderRadius: 28,
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 24),
        Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
            decoration: BoxDecoration(
              color: const Color(
                0xFFF59E0B,
              ).withValues(alpha: isDark ? 0.20 : 0.12),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: const Color(0xFFF59E0B).withValues(alpha: 0.4),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.hourglass_top_rounded,
                  size: 14,
                  color: Color(0xFFF59E0B),
                ),
                const SizedBox(width: 6),
                Text(
                  'Pending Official Verification',
                  style: TextStyle(
                    color: isDark
                        ? Colors.amberAccent
                        : const Color(0xFFB45309),
                    fontSize: 12.5,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'Hospital Registration Received',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w900,
            color: primaryTextColor,
            letterSpacing: -0.4,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          "Your hospital credentials have been submitted for verification. Our administrative compliance team will review your license and activate your portal access.",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14.5,
            color: secondaryTextColor,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 28),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: HealthifyGlassTheme.getGlassSurface(isDark),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: HealthifyGlassTheme.getGlassBorder(isDark),
            ),
          ),
          child: Column(
            children: [
              _buildSummaryRow(
                isDark,
                'Hospital Name',
                _hospitalNameController.text,
              ),
              Divider(
                color: HealthifyGlassTheme.getGlassBorder(isDark),
                height: 20,
              ),
              _buildSummaryRow(
                isDark,
                'Registration / License ID',
                _licenseIdController.text,
              ),
              Divider(
                color: HealthifyGlassTheme.getGlassBorder(isDark),
                height: 20,
              ),
              _buildSummaryRow(isDark, 'Official Email', _emailController.text),
              Divider(
                color: HealthifyGlassTheme.getGlassBorder(isDark),
                height: 20,
              ),
              _buildSummaryRow(isDark, 'City', _cityController.text),
            ],
          ),
        ),
        const SizedBox(height: 30),
        GlassPrimaryButton(
          height: 52,
          onPressed: () {
            Navigator.pushReplacement(
              context,
              FadePageRoute(page: const LoginScreen()),
            );
          },
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.arrow_back_rounded, size: 20),
              SizedBox(width: 8),
              Text(
                'Return to MEDRIX Sign In',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryRow(bool isDark, String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: HealthifyGlassTheme.getTextSecondary(isDark),
          ),
        ),
        Flexible(
          child: Text(
            value.isNotEmpty ? value : '—',
            style: TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.bold,
              color: HealthifyGlassTheme.getTextPrimary(isDark),
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  // --- PREMIUM PROCESS CARD MULTI-STEP FORM VIEW ---
  Widget _buildPremiumProcessCard({
    required bool isDark,
    required bool isDesktop,
  }) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Premium Interactive Stepper Header Nodes
          _buildStepperHeaderNodes(isDark),

          const SizedBox(height: 24),

          // Smooth Animated Step Content View
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 350),
            switchInCurve: Curves.easeOutCubic,
            switchOutCurve: Curves.easeInCubic,
            transitionBuilder: (child, animation) {
              return FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0.02, 0),
                    end: Offset.zero,
                  ).animate(animation),
                  child: child,
                ),
              );
            },
            child: KeyedSubtree(
              key: ValueKey(_currentStep),
              child: _buildCurrentStepContent(
                isDark: isDark,
                isDesktop: isDesktop,
              ),
            ),
          ),

          const SizedBox(height: 28),

          // Process Card Responsive Action Controls (Back & Next / Submit)
          Row(
            children: [
              if (_currentStep > 1) ...[
                Expanded(
                  flex: 2,
                  child: GlassSecondaryButton(
                    height: 54,
                    onPressed: _previousStep,
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.arrow_back_rounded, size: 19),
                        SizedBox(width: 7),
                        Text(
                          'Back',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
              ],

              Expanded(
                flex: 3,
                child: SizedBox(
                  height: 54,
                  child: _currentStep < 5
                      ? GlassPrimaryButton(
                          height: 54,
                          onPressed: _nextStep,
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Next Step',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              SizedBox(width: 8),
                              Icon(Icons.arrow_forward_rounded, size: 19),
                            ],
                          ),
                        )
                      : GlassPrimaryButton(
                          height: 54,
                          onPressed: _isAuthorizedChecked
                              ? _onTapCreateAccount
                              : null,
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  _isAuthorizedChecked
                                      ? Icons.check_circle_rounded
                                      : Icons.lock_outline_rounded,
                                  size: 19,
                                ),
                                const SizedBox(width: 8),
                                const Text(
                                  'Create Hospital Account',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 22),

          // Footer Switch to Sign In
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Already registered? ',
                style: TextStyle(
                  color: HealthifyGlassTheme.getTextSecondary(isDark),
                  fontSize: 13.5,
                ),
              ),
              InkWell(
                onTap: () {
                  Navigator.pushReplacement(
                    context,
                    FadePageRoute(page: const LoginScreen()),
                  );
                },
                borderRadius: BorderRadius.circular(4),
                child: const Text(
                  'Sign in to your portal',
                  style: TextStyle(
                    color: HealthifyGlassTheme.primaryTeal,
                    fontWeight: FontWeight.bold,
                    fontSize: 13.5,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Stepper Header Node Indicator Bar
  Widget _buildStepperHeaderNodes(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: HealthifyGlassTheme.primaryTeal.withValues(
          alpha: isDark ? 0.18 : 0.08,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: HealthifyGlassTheme.primaryTeal.withValues(alpha: 0.25),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Step $_currentStep of 5',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: HealthifyGlassTheme.primaryTeal,
                  letterSpacing: 0.5,
                ),
              ),
              Text(
                _getStepTitle(),
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: HealthifyGlassTheme.getTextPrimary(isDark),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: List.generate(5, (index) {
              final stepNum = index + 1;
              final isDone = stepNum < _currentStep;
              final isActive = stepNum == _currentStep;

              return Expanded(
                child: Row(
                  children: [
                    InkWell(
                      onTap: isDone ? () => _jumpToStep(stepNum) : null,
                      borderRadius: BorderRadius.circular(20),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: isDone || isActive
                              ? HealthifyGlassTheme.primaryTeal
                              : HealthifyGlassTheme.getGlassSurface(isDark),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isDone || isActive
                                ? HealthifyGlassTheme.primaryTeal
                                : HealthifyGlassTheme.getGlassBorder(isDark),
                            width: 2,
                          ),
                          boxShadow: isActive
                              ? [
                                  BoxShadow(
                                    color: HealthifyGlassTheme.primaryTeal
                                        .withValues(alpha: 0.35),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ]
                              : [],
                        ),
                        child: Center(
                          child: isDone
                              ? const Icon(
                                  Icons.check,
                                  size: 16,
                                  color: Colors.white,
                                )
                              : Text(
                                  '$stepNum',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: isActive
                                        ? Colors.white
                                        : HealthifyGlassTheme.getTextSecondary(
                                            isDark,
                                          ),
                                  ),
                                ),
                        ),
                      ),
                    ),
                    if (stepNum < 5)
                      Expanded(
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          height: 3,
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          decoration: BoxDecoration(
                            color: stepNum < _currentStep
                                ? HealthifyGlassTheme.primaryTeal
                                : HealthifyGlassTheme.getGlassBorder(isDark),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  String _getStepTitle() {
    switch (_currentStep) {
      case 1:
        return 'Overview & Features';
      case 2:
        return 'Name & Official Email';
      case 3:
        return 'Registration & Contact';
      case 4:
        return 'Security Password';
      case 5:
        return 'Authorization Check';
      default:
        return 'Overview & Features';
    }
  }

  Widget _buildCurrentStepContent({
    required bool isDark,
    required bool isDesktop,
  }) {
    switch (_currentStep) {
      case 1:
        return _buildStep1Content(isDark: isDark, isDesktop: isDesktop);
      case 2:
        return _buildStep2Content(isDark: isDark);
      case 3:
        return _buildStep3Content(isDark: isDark);
      case 4:
        return _buildStep4Content(isDark: isDark);
      case 5:
        return _buildStep5Content(isDark: isDark);
      default:
        return _buildStep1Content(isDark: isDark, isDesktop: isDesktop);
    }
  }

  // --- STEP 1: Overview & Feature Badges Bar ---
  Widget _buildStep1Content({required bool isDark, required bool isDesktop}) {
    final primaryTextColor = HealthifyGlassTheme.getTextPrimary(isDark);
    final secondaryTextColor = HealthifyGlassTheme.getTextSecondary(isDark);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (!isDesktop) ...[
          Center(
            child: GlassIconContainer(
              icon: Icons.local_hospital_rounded,
              size: 58,
              iconSize: 32,
              color: HealthifyGlassTheme.primaryTeal,
              borderRadius: 18,
            ),
          ),
          const SizedBox(height: 12),
        ],
        Text(
          'Create your hospital account',
          style: TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.w900,
            color: primaryTextColor,
            letterSpacing: -0.4,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Register your facility to manage doctors, patients, beds, blood inventory, and wing facilities.',
          style: TextStyle(
            fontSize: 13.5,
            color: secondaryTextColor,
            height: 1.45,
          ),
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GlassSelectionChip(
              label: 'PATIENT',
              icon: Icons.person_rounded,
              isSelected: false,
              activeColor: HealthifyGlassTheme.primaryTeal,
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  FadePageRoute(page: const PatientSignupScreen()),
                );
              },
            ),
            const SizedBox(width: 8),
            GlassSelectionChip(
              label: 'DOCTOR',
              icon: Icons.medical_services_rounded,
              isSelected: false,
              activeColor: Colors.indigo,
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  FadePageRoute(page: const DoctorSignupScreen()),
                );
              },
            ),
            const SizedBox(width: 8),
            GlassSelectionChip(
              label: 'HOSPITAL',
              icon: Icons.local_hospital_rounded,
              isSelected: true,
              activeColor: HealthifyGlassTheme.primaryTeal,
              onTap: () {},
            ),
          ],
        ),
        const SizedBox(height: 22),
        Text(
          'INCLUDED HOSPITAL MANAGEMENT MODULES',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.1,
            color: secondaryTextColor,
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: const [
            _FeatureBadge(icon: Icons.badge_outlined, label: 'Doctors Roster'),
            _FeatureBadge(
              icon: Icons.people_outline,
              label: 'Patients Records',
            ),
            _FeatureBadge(icon: Icons.king_bed_outlined, label: 'ICU & Beds'),
            _FeatureBadge(
              icon: Icons.bloodtype_outlined,
              label: 'Blood Inventory',
            ),
            _FeatureBadge(icon: Icons.business_outlined, label: 'Facilities'),
          ],
        ),
      ],
    );
  }

  // --- STEP 2: Hospital Name & Email ---
  Widget _buildStep2Content({required bool isDark}) {
    final primaryTextColor = HealthifyGlassTheme.getTextPrimary(isDark);
    final secondaryTextColor = HealthifyGlassTheme.getTextSecondary(isDark);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Hospital Identity & Contact',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: primaryTextColor,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Enter the official name and primary administrative email of your hospital.',
          style: TextStyle(fontSize: 13, color: secondaryTextColor),
        ),
        const SizedBox(height: 20),
        _buildFieldLabel(isDark, 'Hospital Name', required: true),
        const SizedBox(height: 6),
        TextFormField(
          controller: _hospitalNameController,
          textCapitalization: TextCapitalization.words,
          textInputAction: TextInputAction.next,
          style: TextStyle(color: primaryTextColor),
          decoration: GlassTextFieldTheme.getDecoration(
            context: context,
            hintText: 'e.g. St. Jude Memorial Hospital',
            prefixIcon: const Icon(Icons.apartment_rounded),
            suffixIcon: _buildValidationCheckmark(_isNameValid),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Hospital name is required';
            }
            return null;
          },
        ),
        const SizedBox(height: 18),
        _buildEmailField(isDark),
      ],
    );
  }

  // --- STEP 3: Hospital Registration Details (Phone, License ID, City) ---
  Widget _buildStep3Content({required bool isDark}) {
    final primaryTextColor = HealthifyGlassTheme.getTextPrimary(isDark);
    final secondaryTextColor = HealthifyGlassTheme.getTextSecondary(isDark);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Registration & License Credentials',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: primaryTextColor,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Provide official accreditation details and emergency contact numbers.',
          style: TextStyle(fontSize: 13, color: secondaryTextColor),
        ),
        const SizedBox(height: 20),
        _buildPhoneField(isDark),
        const SizedBox(height: 18),
        _buildLicenseField(isDark),
        const SizedBox(height: 18),
        _buildCityField(isDark),
      ],
    );
  }

  // --- STEP 4: Password & Confirm Password ---
  Widget _buildStep4Content({required bool isDark}) {
    final primaryTextColor = HealthifyGlassTheme.getTextPrimary(isDark);
    final secondaryTextColor = HealthifyGlassTheme.getTextSecondary(isDark);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Account Security',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: primaryTextColor,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Set a strong administrator password to secure your hospital portal.',
          style: TextStyle(fontSize: 13, color: secondaryTextColor),
        ),
        const SizedBox(height: 20),
        _buildPasswordField(isDark),
        const SizedBox(height: 18),
        _buildConfirmPasswordField(isDark),
      ],
    );
  }

  // --- STEP 5: Authorization & Creation ---
  Widget _buildStep5Content({required bool isDark}) {
    final primaryTextColor = HealthifyGlassTheme.getTextPrimary(isDark);
    final secondaryTextColor = HealthifyGlassTheme.getTextSecondary(isDark);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Final Authorization & Submission',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: primaryTextColor,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Review authorization agreement before creating your hospital account.',
          style: TextStyle(fontSize: 13, color: secondaryTextColor),
        ),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: HealthifyGlassTheme.primaryTeal.withValues(
              alpha: isDark ? 0.16 : 0.08,
            ),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: _isAuthorizedChecked
                  ? HealthifyGlassTheme.primaryTeal
                  : HealthifyGlassTheme.getGlassBorder(isDark),
              width: _isAuthorizedChecked ? 1.5 : 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.shield_outlined,
                    color: HealthifyGlassTheme.primaryTeal,
                    size: 22,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Authorization Agreement',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: primaryTextColor,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              InkWell(
                onTap: () {
                  setState(() {
                    _isAuthorizedChecked = !_isAuthorizedChecked;
                  });
                },
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: HealthifyGlassTheme.getGlassSurface(isDark),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _isAuthorizedChecked
                          ? HealthifyGlassTheme.primaryTeal
                          : HealthifyGlassTheme.getGlassBorder(isDark),
                      width: _isAuthorizedChecked ? 1.5 : 1,
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        width: 22,
                        height: 22,
                        decoration: BoxDecoration(
                          color: _isAuthorizedChecked
                              ? HealthifyGlassTheme.primaryTeal
                              : HealthifyGlassTheme.getGlassSurface(isDark),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: _isAuthorizedChecked
                                ? HealthifyGlassTheme.primaryTeal
                                : HealthifyGlassTheme.getGlassBorder(isDark),
                          ),
                        ),
                        child: _isAuthorizedChecked
                            ? const Icon(
                                Icons.check,
                                size: 16,
                                color: Colors.white,
                              )
                            : null,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'I confirm that I am authorized to create and manage this hospital account, and that all information provided is accurate.',
                          style: TextStyle(
                            fontSize: 13.5,
                            color: primaryTextColor,
                            height: 1.4,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.red.withValues(alpha: isDark ? 0.18 : 0.08),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.gavel_rounded,
                color: Colors.redAccent,
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Only register a hospital that you own, operate, or are officially authorized to represent.',
                  style: TextStyle(
                    fontSize: 12.5,
                    color: isDark ? Colors.red.shade200 : Colors.red.shade900,
                    height: 1.4,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        FormProgressIndicator(progress: _formProgress),
      ],
    );
  }

  Widget _buildValidationCheckmark(bool isValid) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 250),
      transitionBuilder: (child, animation) => ScaleTransition(
        scale: animation,
        child: FadeTransition(opacity: animation, child: child),
      ),
      child: isValid
          ? const Icon(
              Icons.check_circle_rounded,
              key: ValueKey(true),
              color: HealthifyGlassTheme.primaryTeal,
              size: 20,
            )
          : const SizedBox.shrink(key: ValueKey(false)),
    );
  }

  Widget _buildFieldLabel(bool isDark, String label, {bool required = false}) {
    return RichText(
      text: TextSpan(
        text: label,
        style: TextStyle(
          fontSize: 13.5,
          fontWeight: FontWeight.w600,
          color: HealthifyGlassTheme.getTextPrimary(isDark),
        ),
        children: required
            ? const [
                TextSpan(
                  text: ' *',
                  style: TextStyle(color: Colors.redAccent),
                ),
              ]
            : [],
      ),
    );
  }

  Widget _buildEmailField(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFieldLabel(isDark, 'Official Hospital Email', required: true),
        const SizedBox(height: 6),
        TextFormField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          style: TextStyle(color: HealthifyGlassTheme.getTextPrimary(isDark)),
          decoration: GlassTextFieldTheme.getDecoration(
            context: context,
            hintText: 'admin@hospital.org',
            prefixIcon: const Icon(Icons.email_outlined),
            suffixIcon: _buildValidationCheckmark(_isEmailValid),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Official hospital email is required';
            }
            if (!RegExp(
              r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
            ).hasMatch(value.trim())) {
              return 'Enter a valid email address';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildPhoneField(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFieldLabel(isDark, 'Phone Number', required: true),
        const SizedBox(height: 6),
        TextFormField(
          controller: _phoneController,
          keyboardType: TextInputType.phone,
          textInputAction: TextInputAction.next,
          style: TextStyle(color: HealthifyGlassTheme.getTextPrimary(isDark)),
          decoration: GlassTextFieldTheme.getDecoration(
            context: context,
            hintText: '+1 (555) 000-0000',
            prefixIcon: const Icon(Icons.phone_outlined),
            suffixIcon: _buildValidationCheckmark(_isPhoneValid),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Phone number is required';
            }
            if (value.trim().length < 7) {
              return 'Enter a valid phone number';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildLicenseField(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFieldLabel(
          isDark,
          'Hospital Registration / License ID',
          required: true,
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: _licenseIdController,
          textCapitalization: TextCapitalization.characters,
          textInputAction: TextInputAction.next,
          style: TextStyle(color: HealthifyGlassTheme.getTextPrimary(isDark)),
          decoration: GlassTextFieldTheme.getDecoration(
            context: context,
            hintText: 'e.g. REG-HOSP-2026-9874',
            prefixIcon: const Icon(Icons.verified_user_outlined),
            suffixIcon: _buildValidationCheckmark(_isLicenseValid),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Registration / License ID is required';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildCityField(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFieldLabel(isDark, 'City', required: true),
        const SizedBox(height: 6),
        TextFormField(
          controller: _cityController,
          textCapitalization: TextCapitalization.words,
          textInputAction: TextInputAction.done,
          style: TextStyle(color: HealthifyGlassTheme.getTextPrimary(isDark)),
          decoration: GlassTextFieldTheme.getDecoration(
            context: context,
            hintText: 'e.g. New York',
            prefixIcon: const Icon(Icons.location_city_outlined),
            suffixIcon: _buildValidationCheckmark(_isCityValid),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'City is required';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildPasswordField(bool isDark) {
    final secondaryTextColor = HealthifyGlassTheme.getTextSecondary(isDark);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFieldLabel(isDark, 'Password', required: true),
        const SizedBox(height: 6),
        TextFormField(
          controller: _passwordController,
          obscureText: !_isPasswordVisible,
          textInputAction: TextInputAction.next,
          style: TextStyle(color: HealthifyGlassTheme.getTextPrimary(isDark)),
          decoration: GlassTextFieldTheme.getDecoration(
            context: context,
            hintText: 'Minimum 8 characters',
            prefixIcon: const Icon(Icons.lock_outline_rounded),
            suffixIcon: IconButton(
              icon: Icon(
                _isPasswordVisible
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                color: secondaryTextColor,
              ),
              onPressed: () {
                setState(() {
                  _isPasswordVisible = !_isPasswordVisible;
                });
              },
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Password is required';
            }
            if (value.length < 8) {
              return 'Password must be at least 8 characters';
            }
            return null;
          },
        ),
        PasswordStrengthMeter(password: _passwordController.text),
      ],
    );
  }

  Widget _buildConfirmPasswordField(bool isDark) {
    final secondaryTextColor = HealthifyGlassTheme.getTextSecondary(isDark);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFieldLabel(isDark, 'Confirm Password', required: true),
        const SizedBox(height: 6),
        TextFormField(
          controller: _confirmPasswordController,
          obscureText: !_isConfirmPasswordVisible,
          textInputAction: TextInputAction.done,
          style: TextStyle(color: HealthifyGlassTheme.getTextPrimary(isDark)),
          decoration: GlassTextFieldTheme.getDecoration(
            context: context,
            hintText: 'Re-enter your password',
            prefixIcon: const Icon(Icons.lock_reset_rounded),
            suffixIcon: IconButton(
              icon: Icon(
                _isConfirmPasswordVisible
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                color: secondaryTextColor,
              ),
              onPressed: () {
                setState(() {
                  _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                });
              },
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please confirm your password';
            }
            if (value != _passwordController.text) {
              return 'Passwords do not match';
            }
            return null;
          },
        ),
      ],
    );
  }
}

class _FeatureBadge extends StatelessWidget {
  final IconData icon;
  final String label;

  const _FeatureBadge({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    final isDark = HealthifyGlassTheme.isDarkMode(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
      decoration: BoxDecoration(
        color: HealthifyGlassTheme.primaryTeal.withValues(
          alpha: isDark ? 0.18 : 0.08,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: HealthifyGlassTheme.primaryTeal.withValues(alpha: 0.25),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: HealthifyGlassTheme.primaryTeal),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: HealthifyGlassTheme.primaryTeal,
            ),
          ),
        ],
      ),
    );
  }
}