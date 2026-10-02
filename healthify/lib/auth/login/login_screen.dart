import 'dart:ui';
import 'package:flutter/material.dart';
import '../../doctor/dashboard/doctor_dashboard_screen.dart';
import '../../hospital/dashboard/main_dashboard_screen.dart';
import '../../patient/dashboard/patient_dashboard_screen.dart';
import '../../utils/page_transitions.dart';
import '../../shared/widgets/animated_pulse_background.dart';
import '../../shared/widgets/glass_components.dart';
import '../doctor/doctor_signup_screen.dart';
import '../patient/patient_login_screen.dart';
import '../patient/patient_signup_screen.dart';
import '../signup/signup_screen.dart';

enum MedrixRole { patient, doctor, hospital }

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  MedrixRole _selectedRole = MedrixRole.hospital;
  bool _isPasswordVisible = false;
  bool _rememberMe = false;
  bool _isLoading = false;
  bool _isEmailValid = false;

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

    _emailController.addListener(() {
      setState(() {
        _isEmailValid = RegExp(
          r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
        ).hasMatch(_emailController.text.trim());
      });
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      Future.delayed(const Duration(milliseconds: 800), () {
        if (!mounted) return;
        setState(() {
          _isLoading = false;
        });

        // Navigate based on selected persona role
        Widget destinationScreen;
        switch (_selectedRole) {
          case MedrixRole.patient:
            destinationScreen = const PatientDashboardScreen();
            break;
          case MedrixRole.doctor:
            destinationScreen = const DoctorDashboardScreen();
            break;
          case MedrixRole.hospital:
            destinationScreen = const MainDashboardScreen(
              hospitalName: 'St. Jude Memorial Hospital',
            );
            break;
        }

        Navigator.pushAndRemoveUntil(
          context,
          FadePageRoute(page: destinationScreen),
          (route) => false,
        );
      });
    }
  }

  void _showForgotPasswordDialog() {
    final isDark = HealthifyGlassTheme.isDarkMode(context);
    final resetEmailController = TextEditingController(
      text: _emailController.text,
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark
            ? HealthifyGlassTheme.darkBackground.withValues(alpha: 0.95)
            : Colors.white.withValues(alpha: 0.95),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: const [
            GlassIconContainer(
              icon: Icons.lock_reset_rounded,
              size: 38,
              iconSize: 20,
              color: HealthifyGlassTheme.primaryTeal,
              borderRadius: 10,
            ),
            SizedBox(width: 10),
            Text(
              'Reset Password',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Enter your account email address. We will send a secure password reset link.',
              style: TextStyle(
                fontSize: 13.5,
                color: HealthifyGlassTheme.getTextSecondary(isDark),
                height: 1.4,
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: resetEmailController,
              keyboardType: TextInputType.emailAddress,
              style: TextStyle(
                color: HealthifyGlassTheme.getTextPrimary(isDark),
              ),
              decoration: GlassTextFieldTheme.getDecoration(
                context: context,
                hintText: 'user@medrix.org',
                labelText: 'Account Email',
                prefixIcon: const Icon(Icons.email_outlined),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: HealthifyGlassTheme.getTextSecondary(isDark),
              ),
            ),
          ),
          GlassPrimaryButton(
            height: 42,
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Password reset link sent to ${resetEmailController.text}',
                  ),
                  backgroundColor: HealthifyGlassTheme.primaryTeal,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: const Text('Send Reset Link'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = HealthifyGlassTheme.isDarkMode(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 900;

    return Scaffold(
      backgroundColor: HealthifyGlassTheme.getBackgroundColor(isDark),
      body: AnimatedPulseBackground(
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: isDesktop ? 32 : 12,
                vertical: isDesktop ? 32 : 16,
              ),
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: isDesktop ? 1040 : 520,
                    ),
                    child: GlassCard(
                      borderRadius: 24,
                      hasTealGlow: true,
                      padding: EdgeInsets.zero,
                      child: isDesktop
                          ? Row(
                              children: [
                                // Left Hero Showcase for Desktop
                                const Expanded(
                                  flex: 5,
                                  child: _LoginHeroPanel(),
                                ),
                                // Right Form Section
                                Expanded(
                                  flex: 6,
                                  child: Padding(
                                    padding: const EdgeInsets.all(36.0),
                                    child: _buildLoginForm(isDark: isDark),
                                  ),
                                ),
                              ],
                            )
                          : Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: _buildLoginForm(isDark: isDark),
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

  Widget _buildLoginForm({required bool isDark}) {
    final primaryTextColor = HealthifyGlassTheme.getTextPrimary(isDark);
    final secondaryTextColor = HealthifyGlassTheme.getTextSecondary(isDark);
    final roleColor = _getRoleColor();

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header Logo & Title (MEDRIX)
          Center(
            child: GlassIconContainer(
              icon: Icons.local_hospital_rounded,
              size: 60,
              iconSize: 34,
              color: HealthifyGlassTheme.primaryTeal,
              borderRadius: 18,
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            'MEDRIX',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w900,
              color: HealthifyGlassTheme.primaryTeal,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Unified Healthcare Platform',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: primaryTextColor,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'Select your role to access your dedicated portal',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12.5, color: secondaryTextColor),
          ),

          const SizedBox(height: 20),

          // Role Selector Bar (PATIENT | DOCTOR | HOSPITAL)
          Text(
            'SELECT PORTAL ROLE',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.1,
              color: secondaryTextColor,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildRoleCard(
                  context: context,
                  role: MedrixRole.patient,
                  label: 'PATIENT',
                  icon: Icons.person_rounded,
                  activeColor: HealthifyGlassTheme.primaryTeal,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildRoleCard(
                  context: context,
                  role: MedrixRole.doctor,
                  label: 'DOCTOR',
                  icon: Icons.medical_services_rounded,
                  activeColor: Colors.indigo,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildRoleCard(
                  context: context,
                  role: MedrixRole.hospital,
                  label: 'HOSPITAL',
                  icon: Icons.local_hospital_rounded,
                  activeColor: HealthifyGlassTheme.primaryTeal,
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Dynamic Email Field based on selected role
          Text(
            _getEmailLabel(),
            style: TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w600,
              color: primaryTextColor,
            ),
          ),
          const SizedBox(height: 6),
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            style: TextStyle(color: primaryTextColor),
            decoration: GlassTextFieldTheme.getDecoration(
              context: context,
              hintText: _getEmailHint(),
              prefixIcon: const Icon(Icons.email_outlined),
              suffixIcon: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: _isEmailValid
                    ? const Icon(
                        Icons.check_circle_rounded,
                        color: HealthifyGlassTheme.primaryTeal,
                        size: 20,
                      )
                    : const SizedBox.shrink(),
              ),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter your email or ID';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          // Password Field
          Text(
            'Password',
            style: TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w600,
              color: primaryTextColor,
            ),
          ),
          const SizedBox(height: 6),
          TextFormField(
            controller: _passwordController,
            obscureText: !_isPasswordVisible,
            style: TextStyle(color: primaryTextColor),
            decoration: GlassTextFieldTheme.getDecoration(
              context: context,
              hintText: 'Enter your password',
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
                return 'Please enter your password';
              }
              return null;
            },
          ),
          const SizedBox(height: 12),

          // Remember Me & Forgot Password
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            runSpacing: 8,
            children: [
              InkWell(
                onTap: () {
                  setState(() {
                    _rememberMe = !_rememberMe;
                  });
                },
                borderRadius: BorderRadius.circular(6),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: _rememberMe
                            ? roleColor
                            : HealthifyGlassTheme.getGlassSurface(isDark),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: _rememberMe
                              ? roleColor
                              : HealthifyGlassTheme.getGlassBorder(isDark),
                        ),
                      ),
                      child: _rememberMe
                          ? const Icon(
                              Icons.check,
                              size: 14,
                              color: Colors.white,
                            )
                          : null,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Remember this device',
                      style: TextStyle(fontSize: 13, color: secondaryTextColor),
                    ),
                  ],
                ),
              ),
              InkWell(
                onTap: _showForgotPasswordDialog,
                borderRadius: BorderRadius.circular(4),
                child: Text(
                  'Forgot Password?',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: roleColor,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Submit Button
          GlassPrimaryButton(
            height: 50,
            color: roleColor,
            isLoading: _isLoading,
            onPressed: _handleLogin,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Sign In to ${_selectedRole.name.toUpperCase()}',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.arrow_forward_rounded, size: 18),
              ],
            ),
          ),

          const SizedBox(height: 18),

          // Switch to Sign Up
          Wrap(
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                "Don't have a ${_selectedRole.name} account? ",
                style: TextStyle(color: secondaryTextColor, fontSize: 13.5),
              ),
              InkWell(
                onTap: () {
                  Widget signupPage;
                  switch (_selectedRole) {
                    case MedrixRole.patient:
                      signupPage = const PatientSignupScreen();
                      break;
                    case MedrixRole.doctor:
                      signupPage = const DoctorSignupScreen();
                      break;
                    case MedrixRole.hospital:
                      signupPage = const HospitalSignupScreen();
                      break;
                  }
                  Navigator.pushReplacement(
                    context,
                    FadePageRoute(page: signupPage),
                  );
                },
                borderRadius: BorderRadius.circular(4),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 2,
                  ),
                  child: Text(
                    'Sign Up',
                    style: TextStyle(
                      color: roleColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 13.5,
                      decoration: TextDecoration.underline,
                      decorationColor: roleColor,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRoleCard({
    required BuildContext context,
    required MedrixRole role,
    required String label,
    required IconData icon,
    required Color activeColor,
  }) {
    final isDark = HealthifyGlassTheme.isDarkMode(context);
    final isSelected = _selectedRole == role;

    return InkWell(
      onTap: () {
        if (role == MedrixRole.patient) {
          Navigator.pushReplacement(
            context,
            FadePageRoute(page: const PatientLoginScreen()),
          );
        } else {
          setState(() {
            _selectedRole = role;
          });
        }
      },
      borderRadius: BorderRadius.circular(14),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? activeColor.withValues(alpha: isDark ? 0.22 : 0.12)
              : HealthifyGlassTheme.getGlassSurface(isDark),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected
                ? activeColor
                : HealthifyGlassTheme.getGlassBorder(isDark),
            width: isSelected ? 1.8 : 1.0,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected
                  ? activeColor
                  : HealthifyGlassTheme.getTextSecondary(isDark),
              size: 24,
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                color: isSelected
                    ? (isDark ? Colors.white : activeColor)
                    : HealthifyGlassTheme.getTextSecondary(isDark),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getRoleColor() {
    switch (_selectedRole) {
      case MedrixRole.patient:
        return HealthifyGlassTheme.primaryTeal;
      case MedrixRole.doctor:
        return Colors.indigo;
      case MedrixRole.hospital:
        return HealthifyGlassTheme.primaryTeal;
    }
  }

  String _getEmailLabel() {
    switch (_selectedRole) {
      case MedrixRole.patient:
        return 'Patient Email or Registration ID';
      case MedrixRole.doctor:
        return 'Doctor Official Email or Medical License ID';
      case MedrixRole.hospital:
        return 'Official Hospital Admin Email';
    }
  }

  String _getEmailHint() {
    switch (_selectedRole) {
      case MedrixRole.patient:
        return 'e.g. patient@gmail.com or PAT-8842';
      case MedrixRole.doctor:
        return 'e.g. dr.jenkins@hospital.org';
      case MedrixRole.hospital:
        return 'e.g. admin@cityhospital.org';
    }
  }
}

class _LoginHeroPanel extends StatelessWidget {
  const _LoginHeroPanel();

  @override
  Widget build(BuildContext context) {
    final isDark = HealthifyGlassTheme.isDarkMode(context);

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [const Color(0xFF0A2E2B), const Color(0xFF061817)]
              : [
                  HealthifyGlassTheme.primaryTeal,
                  HealthifyGlassTheme.primaryDarkTeal,
                ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          bottomLeft: Radius.circular(24),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(36.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.local_hospital_rounded,
                    color: Colors.white,
                    size: 26,
                  ),
                ),
                const SizedBox(width: 12),
                const Flexible(
                  child: Text(
                    'MEDRIX System',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Connected Healthcare Ecosystem',
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'MEDRIX seamlessly connects Patients, Doctors, and Hospital Facilities in real-time across beds, queues, and blood inventory.',
                  style: TextStyle(
                    fontSize: 13.5,
                    color: Colors.white.withValues(alpha: 0.88),
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 24),
                const _LoginFeatureRow(
                  icon: Icons.person_outline_rounded,
                  label: 'PATIENT: Queue tracking & digital lab records',
                ),
                const SizedBox(height: 12),
                const _LoginFeatureRow(
                  icon: Icons.medical_services_outlined,
                  label: 'DOCTOR: OPD schedule, rounds & Rx management',
                ),
                const SizedBox(height: 12),
                const _LoginFeatureRow(
                  icon: Icons.domain_rounded,
                  label: 'HOSPITAL: Beds, ICU, staff & blood bank ops',
                ),
              ],
            ),
            const SizedBox(height: 24),
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.15),
                    ),
                  ),
                  child: const Row(
                    children: [
                      Icon(
                        Icons.shield_moon_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'All MEDRIX connections are HIPAA compliant and encrypted.',
                          style: TextStyle(fontSize: 11.5, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LoginFeatureRow extends StatelessWidget {
  final IconData icon;
  final String label;

  const _LoginFeatureRow({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.15),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: Colors.white, size: 16),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}
