import 'dart:ui';
import 'package:flutter/material.dart';
import '../../utils/page_transitions.dart';
import '../../shared/widgets/animated_pulse_background.dart';
import '../../shared/widgets/glass_components.dart';
import '../login/login_screen.dart';
import '../patient/patient_signup_screen.dart';
import '../signup/signup_screen.dart';

class DoctorSignupScreen extends StatefulWidget {
  const DoctorSignupScreen({super.key});

  @override
  State<DoctorSignupScreen> createState() => _DoctorSignupScreenState();
}

class _DoctorSignupScreenState extends State<DoctorSignupScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();

  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  bool _isPasswordVisible = false;
  bool _isNameValid = false;
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

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.03),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOutCubic,
    ));

    _fadeController.forward();

    _fullNameController.addListener(() {
      setState(() {
        _isNameValid = _fullNameController.text.trim().isNotEmpty;
      });
    });

    _emailController.addListener(() {
      setState(() {
        _isEmailValid = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
            .hasMatch(_emailController.text.trim());
      });
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleDoctorSignup() {
    if (!_formKey.currentState!.validate()) return;

    final refId = 'DOC-REQ-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';
    final email = _emailController.text.trim();
    final name = _fullNameController.text.trim();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: const [
            Icon(Icons.verified_user_rounded, color: Colors.teal, size: 24),
            SizedBox(width: 10),
            Text('Doctor Application Received', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Dr. $name, your hospital clinical credential application has been registered.'),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.teal.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.teal.withValues(alpha: 0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Application Reference ID:', style: TextStyle(fontSize: 11, color: Colors.teal)),
                  Text(refId, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.teal)),
                  const SizedBox(height: 4),
                  Text('Registered Email: $email', style: const TextStyle(fontSize: 11)),
                ],
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Under hospital governance, a hospital administrator must verify your medical council registration before clinical chart access is activated. Once verified, you will receive an invitation email to activate your account.',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
              );
            },
            child: const Text('Back to Sign In'),
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
                      maxWidth: isDesktop ? 980 : 480,
                    ),
                    child: GlassCard(
                      borderRadius: 24,
                      hasTealGlow: true,
                      padding: EdgeInsets.zero,
                      child: isDesktop
                          ? Row(
                              children: [
                                // Left Hero Showcase for Doctor Desktop
                                const Expanded(
                                  flex: 5,
                                  child: _DoctorHeroPanel(),
                                ),
                                // Right Form Section
                                Expanded(
                                  flex: 6,
                                  child: Padding(
                                    padding: const EdgeInsets.all(36.0),
                                    child: _buildDoctorForm(isDark),
                                  ),
                                ),
                              ],
                            )
                          : Padding(
                              padding: const EdgeInsets.all(24.0),
                              child: _buildDoctorForm(isDark),
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

  Widget _buildDoctorForm(bool isDark) {
    final primaryTextColor = HealthifyGlassTheme.getTextPrimary(isDark);
    final secondaryTextColor = HealthifyGlassTheme.getTextSecondary(isDark);

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header Badge & Title
          Center(
            child: GlassIconContainer(
              icon: Icons.medical_services_rounded,
              size: 58,
              iconSize: 32,
              color: Colors.indigo,
              borderRadius: 18,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Create doctor account',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w900,
              color: Colors.indigo,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Register as a physician to manage consultation schedules and clinical notes',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: secondaryTextColor,
            ),
          ),

          const SizedBox(height: 24),

          // Role Switcher Chips (Patient | Doctor | Hospital)
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 8,
            runSpacing: 8,
            children: [
              GlassSelectionChip(
                label: 'PATIENT',
                icon: Icons.person_rounded,
                isSelected: false,
                activeColor: HealthifyGlassTheme.primaryTeal,
                onTap: () {
                  Navigator.pushReplacement(context, FadePageRoute(page: const PatientSignupScreen()));
                },
              ),
              GlassSelectionChip(
                label: 'DOCTOR',
                icon: Icons.medical_services_rounded,
                isSelected: true,
                activeColor: Colors.indigo,
                onTap: () {},
              ),
              GlassSelectionChip(
                label: 'HOSPITAL',
                icon: Icons.local_hospital_rounded,
                isSelected: false,
                activeColor: HealthifyGlassTheme.primaryTeal,
                onTap: () {
                  Navigator.pushReplacement(context, FadePageRoute(page: const HospitalSignupScreen()));
                },
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Full Name Field
          Text(
            'Full Name',
            style: TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w600,
              color: primaryTextColor,
            ),
          ),
          const SizedBox(height: 6),
          TextFormField(
            controller: _fullNameController,
            keyboardType: TextInputType.name,
            style: TextStyle(color: primaryTextColor),
            decoration: GlassTextFieldTheme.getDecoration(
              context: context,
              hintText: 'Dr. John Doe',
              prefixIcon: const Icon(Icons.badge_outlined),
              suffixIcon: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: _isNameValid
                    ? const Icon(Icons.check_circle_rounded, color: Colors.indigo, size: 20)
                    : const SizedBox.shrink(),
              ),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter your full name';
              }
              return null;
            },
          ),

          const SizedBox(height: 18),

          // Email Field
          Text(
            'Email',
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
              hintText: 'doctor@email.com',
              prefixIcon: const Icon(Icons.email_outlined),
              suffixIcon: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: _isEmailValid
                    ? const Icon(Icons.check_circle_rounded, color: Colors.indigo, size: 20)
                    : const SizedBox.shrink(),
              ),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter your email address';
              }
              if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value.trim())) {
                return 'Please enter a valid email address';
              }
              return null;
            },
          ),

          const SizedBox(height: 18),

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
              hintText: '••••••••',
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
                return 'Please enter a password';
              }
              if (value.length < 6) {
                return 'Password must be at least 6 characters long';
              }
              return null;
            },
          ),

          const SizedBox(height: 28),

          // Submit Button
          GlassPrimaryButton(
            height: 52,
            color: Colors.indigo,
            isLoading: false,
            onPressed: _handleDoctorSignup,
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Create Doctor Account',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(width: 8),
                Icon(Icons.arrow_forward_rounded, size: 20),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Footer link to Sign In
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Already have a doctor account? ',
                style: TextStyle(color: secondaryTextColor, fontSize: 13.5),
              ),
              InkWell(
                onTap: () {
                  Navigator.pushReplacement(
                    context,
                    FadePageRoute(page: const LoginScreen()),
                  );
                },
                child: const Text(
                  'Sign In',
                  style: TextStyle(
                    color: Colors.indigo,
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
}

class _DoctorHeroPanel extends StatelessWidget {
  const _DoctorHeroPanel();

  @override
  Widget build(BuildContext context) {
    final isDark = HealthifyGlassTheme.isDarkMode(context);

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [const Color(0xFF1E1B4B), const Color(0xFF0F172A)]
              : [const Color(0xFF3F51B5), const Color(0xFF1A237E)],
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
                    Icons.medical_services_rounded,
                    color: Colors.white,
                    size: 26,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'MEDRIX Physician',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Clinical Excellence.',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Create your doctor account to streamline OPD patient consultations, monitor assigned ICU bed rounds, and issue e-prescriptions.',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withValues(alpha: 0.88),
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 24),
                const _HeroFeatureRow(icon: Icons.queue_play_next_rounded, label: 'OPD Schedule & Patient Queue Management'),
                const SizedBox(height: 12),
                const _HeroFeatureRow(icon: Icons.airline_seat_flat_rounded, label: 'Inpatient ICU Rounds & Vitals Alerts'),
                const SizedBox(height: 12),
                const _HeroFeatureRow(icon: Icons.note_add_rounded, label: 'Instant Digital Prescriptions & Lab Requests'),
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
                    border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.verified_user_rounded, color: Colors.white, size: 20),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Encrypted medical data access for certified healthcare professionals.',
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

class _HeroFeatureRow extends StatelessWidget {
  final IconData icon;
  final String label;

  const _HeroFeatureRow({required this.icon, required this.label});

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
