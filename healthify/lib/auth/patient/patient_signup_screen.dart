import 'package:flutter/material.dart';
import '../../core/provider/repository_provider.dart';
import '../../utils/page_transitions.dart';
import '../../shared/widgets/animated_pulse_background.dart';
import '../../shared/widgets/glass_components.dart';
import './patient_login_screen.dart';
import './patient_otp_screen.dart';

class PatientSignupScreen extends StatefulWidget {
  const PatientSignupScreen({super.key});

  @override
  State<PatientSignupScreen> createState() => _PatientSignupScreenState();
}

class _PatientSignupScreenState extends State<PatientSignupScreen> {
  final _formKey = GlobalKey<FormState>();

  final _fullNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isPasswordVisible = false;
  bool _isLoading = false;
  String? _phoneErrorMessage;

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleCreateAccount() async {
    setState(() {
      _phoneErrorMessage = null;
    });

    if (_formKey.currentState!.validate()) {
      final phone = _phoneController.text.trim();
      final email = _emailController.text.trim().toLowerCase();
      final client = RepositoryContainer.instance.serverpodClient;
      if (client == null) {
        setState(() => _phoneErrorMessage = 'Patient account server is not configured.');
        return;
      }
      setState(() => _isLoading = true);
      try {
        final accountRequestId = await client.emailIdp.startRegistration(email: email);
        if (!mounted) return;
        Navigator.push(
          context,
          FadePageRoute(
            page: PatientOtpScreen(
              phoneNumber: phone.length == 10 ? '+91 $phone' : phone,
              fullName: _fullNameController.text.trim(),
              email: email,
              password: _passwordController.text,
              accountRequestId: accountRequestId,
            ),
          ),
        );
      } catch (error) {
        if (mounted) setState(() => _phoneErrorMessage = error.toString());
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  double _calculatePasswordStrength(String password) {
    if (password.isEmpty) return 0.0;
    double strength = 0.0;
    if (password.length >= 8) strength += 0.35;
    if (RegExp(r'[A-Z]').hasMatch(password)) strength += 0.25;
    if (RegExp(r'[0-9]').hasMatch(password)) strength += 0.2;
    if (RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password)) strength += 0.2;
    return strength.clamp(0.0, 1.0);
  }

  Color _getStrengthColor(double strength) {
    if (strength <= 0.35) return Colors.redAccent;
    if (strength <= 0.7) return Colors.orangeAccent;
    return const Color(0xFF10B981);
  }

  String _getStrengthText(double strength) {
    if (strength == 0) return '';
    if (strength <= 0.35) return 'Weak password (add numbers & symbols)';
    if (strength <= 0.7) return 'Medium password';
    return 'Strong password';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = HealthifyGlassTheme.isDarkMode(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 900;

    final primaryTextColor = HealthifyGlassTheme.getTextPrimary(isDark);
    final secondaryTextColor = HealthifyGlassTheme.getTextSecondary(isDark);
    final mutedTextColor = HealthifyGlassTheme.getTextMuted(isDark);

    final passwordStrength = _calculatePasswordStrength(_passwordController.text);

    return Scaffold(
      backgroundColor: HealthifyGlassTheme.getBackgroundColor(isDark),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: primaryTextColor),
          onPressed: () => Navigator.pop(context),
        ),
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
                constraints: BoxConstraints(maxWidth: isDesktop ? 500 : 440),
                child: GlassCard(
                  borderRadius: 24,
                  hasTealGlow: true,
                  padding: EdgeInsets.all(isDesktop ? 32.0 : 24.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Header Title
                        Center(
                          child: GlassIconContainer(
                            icon: Icons.person_add_alt_1_rounded,
                            size: 58,
                            iconSize: 32,
                            color: HealthifyGlassTheme.primaryTeal,
                            borderRadius: 18,
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Create your account',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                            color: HealthifyGlassTheme.primaryTeal,
                            letterSpacing: -0.3,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Fast 1-minute registration to book doctors & access care',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 13,
                            color: secondaryTextColor,
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Error Banner for Existing Phone Number
                        if (_phoneErrorMessage != null) ...[
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.red.withValues(alpha: isDark ? 0.18 : 0.08),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: Colors.red.withValues(alpha: 0.35)),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.error_outline_rounded, color: Colors.redAccent, size: 20),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    _phoneErrorMessage!,
                                    style: const TextStyle(fontSize: 12.5, color: Colors.redAccent, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],

                        // 1. FULL NAME FIELD
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
                          textCapitalization: TextCapitalization.words,
                          style: TextStyle(color: primaryTextColor),
                          decoration: GlassTextFieldTheme.getDecoration(
                            context: context,
                            hintText: 'John Doe',
                            prefixIcon: const Icon(Icons.person_outline_rounded),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter your full name';
                            }
                            if (value.trim().length < 2) {
                              return 'Name must be at least 2 characters';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 16),

                        // 2. PHONE NUMBER FIELD
                        Text(
                          'Phone Number',
                          style: TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w600,
                            color: primaryTextColor,
                          ),
                        ),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                          style: TextStyle(color: primaryTextColor),
                          decoration: GlassTextFieldTheme.getDecoration(
                            context: context,
                            hintText: '+91 98765 43210',
                            prefixIcon: const Icon(Icons.phone_iphone_rounded),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter your phone number';
                            }
                            final cleanStr = value.replaceAll(RegExp(r'\D'), '');
                            if (cleanStr.length < 10) {
                              return 'Please enter a valid 10-digit phone number';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 16),
                        Text(
                          'Email Address',
                          style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600, color: primaryTextColor),
                        ),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          autocorrect: false,
                          style: TextStyle(color: primaryTextColor),
                          decoration: GlassTextFieldTheme.getDecoration(
                            context: context,
                            hintText: 'you@example.com',
                            prefixIcon: const Icon(Icons.email_outlined),
                          ),
                          validator: (value) {
                            final email = value?.trim() ?? '';
                            if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email)) {
                              return 'Please enter a valid email address';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 16),

                        // 3. PASSWORD FIELD
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
                          onChanged: (val) => setState(() {}),
                          decoration: GlassTextFieldTheme.getDecoration(
                            context: context,
                            hintText: '••••••••',
                            prefixIcon: const Icon(Icons.lock_outline_rounded),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _isPasswordVisible ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                                color: secondaryTextColor,
                              ),
                              onPressed: () {
                                setState(() => _isPasswordVisible = !_isPasswordVisible);
                              },
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please create a password';
                            }
                            if (value.length < 6) {
                              return 'Password must be at least 6 characters';
                            }
                            return null;
                          },
                        ),

                        if (_passwordController.text.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: passwordStrength,
                              backgroundColor: isDark
                                  ? Colors.white.withValues(alpha: 0.1)
                                  : Colors.black.withValues(alpha: 0.08),
                              color: _getStrengthColor(passwordStrength),
                              minHeight: 4,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _getStrengthText(passwordStrength),
                            style: TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.bold,
                              color: _getStrengthColor(passwordStrength),
                            ),
                          ),
                        ],

                        const SizedBox(height: 24),

                        // PRIMARY CTA: CREATE ACCOUNT
                        GlassPrimaryButton(
                          height: 52,
                          isLoading: _isLoading,
                          onPressed: _handleCreateAccount,
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Create Account',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(width: 8),
                              Icon(Icons.arrow_forward_rounded, size: 18),
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Divider OR
                        Row(
                          children: [
                            Expanded(child: Divider(color: HealthifyGlassTheme.getGlassBorder(isDark))),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 12.0),
                              child: Text(
                                'OR',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: mutedTextColor,
                                ),
                              ),
                            ),
                            Expanded(child: Divider(color: HealthifyGlassTheme.getGlassBorder(isDark))),
                          ],
                        ),

                        const SizedBox(height: 16),

                        // Social Sign In (Google / Apple)
                        Row(
                          children: [
                            Expanded(
                              child: GlassSecondaryButton(
                                height: 46,
                                onPressed: () {},
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.g_mobiledata_rounded, color: Colors.redAccent, size: 24),
                                    const SizedBox(width: 6),
                                    Text('Google', style: TextStyle(fontSize: 13.5, color: primaryTextColor)),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: GlassSecondaryButton(
                                height: 46,
                                onPressed: () {},
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.apple_rounded, size: 20, color: primaryTextColor),
                                    const SizedBox(width: 6),
                                    Text('Apple', style: TextStyle(fontSize: 13.5, color: primaryTextColor)),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 22),

                        // SECONDARY: ALREADY HAVE AN ACCOUNT? SIGN IN
                        Wrap(
                          alignment: WrapAlignment.center,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Text(
                              'Already have an account? ',
                              style: TextStyle(color: secondaryTextColor, fontSize: 13.5),
                            ),
                            InkWell(
                              onTap: () {
                                Navigator.pushReplacement(
                                  context,
                                  FadePageRoute(page: const PatientLoginScreen()),
                                );
                              },
                              child: const Text(
                                'Sign In',
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
