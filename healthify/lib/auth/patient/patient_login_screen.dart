import 'package:flutter/material.dart';
import 'package:serverpod_auth_idp_flutter/serverpod_auth_idp_flutter.dart';
import '../../core/provider/repository_provider.dart';
import '../../utils/page_transitions.dart';
import '../../shared/widgets/animated_pulse_background.dart';
import '../../shared/widgets/glass_components.dart';
import './patient_forgot_password_screen.dart';
import './patient_location_permission_screen.dart';
import './patient_signup_screen.dart';
import '../login/login_screen.dart';

class PatientLoginScreen extends StatefulWidget {
  const PatientLoginScreen({super.key});

  @override
  State<PatientLoginScreen> createState() => _PatientLoginScreenState();
}

class _PatientLoginScreenState extends State<PatientLoginScreen> {
  final _formKey = GlobalKey<FormState>();

  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isPasswordVisible = false;
  bool _rememberMe = false;
  bool _isLoading = false;
  String? _loginErrorMessage;

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    setState(() => _loginErrorMessage = null);

    if (_formKey.currentState!.validate()) {
      final email = _phoneController.text.trim().toLowerCase();
      final client = RepositoryContainer.instance.serverpodClient;
      if (client == null) {
        setState(() => _loginErrorMessage = 'Patient account server is not configured.');
        return;
      }
      setState(() => _isLoading = true);
      final auth = EmailAuthController(
        client: client,
        startScreen: EmailFlowScreen.login,
        onAuthenticated: () {},
        onError: (error) {
          if (mounted) setState(() => _loginErrorMessage = error.toString());
        },
      );
      auth.emailController.text = email;
      auth.passwordController.text = _passwordController.text;
      try {
        await auth.login();
        if (!mounted) return;
        setState(() => _isLoading = false);
        Navigator.pushReplacement(
          context,
          FadePageRoute(page: const PatientLocationPermissionScreen()),
        );
      } catch (error) {
        if (mounted) {
          setState(() {
            _isLoading = false;
            _loginErrorMessage = error.toString();
          });
        }
      } finally {
        auth.dispose();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = HealthifyGlassTheme.isDarkMode(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 900;

    final primaryTextColor = HealthifyGlassTheme.getTextPrimary(isDark);
    final secondaryTextColor = HealthifyGlassTheme.getTextSecondary(isDark);
    final mutedTextColor = HealthifyGlassTheme.getTextMuted(isDark);

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
                        // Header Logo
                        Center(
                          child: GlassIconContainer(
                            icon: Icons.healing_rounded,
                            size: 58,
                            iconSize: 32,
                            color: HealthifyGlassTheme.primaryTeal,
                            borderRadius: 18,
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Sign In to Medrix',
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
                          'Access your patient portal, health records & appointments',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 13,
                            color: secondaryTextColor,
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Error Banner
                        if (_loginErrorMessage != null) ...[
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
                                    _loginErrorMessage!,
                                    style: const TextStyle(fontSize: 12.5, color: Colors.redAccent, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],

                        // 1. PHONE NUMBER FIELD
                        Text(
                          'Email Address',
                          style: TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w600,
                            color: primaryTextColor,
                          ),
                        ),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _phoneController,
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

                        // 2. PASSWORD FIELD
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
                              return 'Please enter your password';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 14),

                        // REMEMBER ME & FORGOT PASSWORD
                        Wrap(
                          alignment: WrapAlignment.spaceBetween,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          runSpacing: 8,
                          children: [
                            InkWell(
                              onTap: () => setState(() => _rememberMe = !_rememberMe),
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
                                          ? HealthifyGlassTheme.primaryTeal
                                          : HealthifyGlassTheme.getGlassSurface(isDark),
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(
                                        color: _rememberMe
                                            ? HealthifyGlassTheme.primaryTeal
                                            : HealthifyGlassTheme.getGlassBorder(isDark),
                                      ),
                                    ),
                                    child: _rememberMe
                                        ? const Icon(Icons.check, size: 14, color: Colors.white)
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
                              onTap: () {
                                Navigator.push(
                                  context,
                                  FadePageRoute(page: const PatientForgotPasswordScreen()),
                                );
                              },
                              child: const Text(
                                'Forgot Password?',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: HealthifyGlassTheme.primaryTeal,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 24),

                        // PRIMARY CTA: SIGN IN
                        GlassPrimaryButton(
                          height: 52,
                          isLoading: _isLoading,
                          onPressed: _handleLogin,
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Sign In',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
                                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: mutedTextColor),
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

                        // CREATE ACCOUNT LINK
                        Wrap(
                          alignment: WrapAlignment.center,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Text(
                              "Don't have a patient account? ",
                              style: TextStyle(color: secondaryTextColor, fontSize: 13.5),
                            ),
                            InkWell(
                              onTap: () {
                                Navigator.pushReplacement(
                                  context,
                                  FadePageRoute(page: const PatientSignupScreen()),
                                );
                              },
                              child: const Text(
                                'Create Account',
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

                        const SizedBox(height: 16),

                        // DOCTOR / HOSPITAL SWITCHER LINK
                        Center(
                          child: InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                FadePageRoute(page: const LoginScreen()),
                              );
                            },
                            borderRadius: BorderRadius.circular(20),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 14),
                              decoration: BoxDecoration(
                                color: HealthifyGlassTheme.primaryTeal.withValues(alpha: isDark ? 0.18 : 0.08),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: HealthifyGlassTheme.primaryTeal.withValues(alpha: 0.25),
                                ),
                              ),
                              child: const Wrap(
                                alignment: WrapAlignment.center,
                                crossAxisAlignment: WrapCrossAlignment.center,
                                children: [
                                  Icon(Icons.swap_horiz_rounded, size: 18, color: HealthifyGlassTheme.primaryTeal),
                                  SizedBox(width: 6),
                                  Text(
                                    'Doctor or Hospital Sign In / Sign Up',
                                    style: TextStyle(
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.bold,
                                      color: HealthifyGlassTheme.primaryTeal,
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
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
