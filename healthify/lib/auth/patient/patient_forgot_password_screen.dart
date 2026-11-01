import 'package:flutter/material.dart';
import '../../core/provider/repository_provider.dart';
import '../../utils/page_transitions.dart';
import '../../shared/widgets/animated_pulse_background.dart';
import '../../shared/widgets/glass_components.dart';
import './patient_login_screen.dart';
import './patient_otp_screen.dart';

class PatientForgotPasswordScreen extends StatefulWidget {
  const PatientForgotPasswordScreen({super.key});

  @override
  State<PatientForgotPasswordScreen> createState() => _PatientForgotPasswordScreenState();
}

class _PatientForgotPasswordScreenState extends State<PatientForgotPasswordScreen> {
  int _currentStep = 0; // 0: Email, 1: New Password, 2: Success

  final _formKeyPhone = GlobalKey<FormState>();
  final _formKeyPassword = GlobalKey<FormState>();

  final _phoneController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isPasswordVisible = false;
  bool _isLoading = false;
  String? _finishResetToken;

  @override
  void dispose() {
    _phoneController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _sendOtp() async {
    if (_formKeyPhone.currentState!.validate()) {
      final email = _phoneController.text.trim().toLowerCase();
      final client = RepositoryContainer.instance.serverpodClient;
      if (client == null) {
        _showError('Patient account server is not configured.');
        return;
      }
      try {
        setState(() => _isLoading = true);
        final requestId = await client.emailIdp.startPasswordReset(email: email);
        if (!mounted) return;
        final verified = await Navigator.push<String>(
          context,
          FadePageRoute(
            page: PatientOtpScreen(
              phoneNumber: email,
              email: email,
              accountRequestId: requestId,
              isPasswordReset: true,
            ),
          ),
        );

      if (verified != null && mounted) {
        _finishResetToken = verified;
        setState(() {
          _currentStep = 1; // Move to New Password step
        });
      }
      } catch (error) {
        _showError(error.toString());
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _resetPassword() async {
    if (_formKeyPassword.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        final client = RepositoryContainer.instance.serverpodClient;
        final token = _finishResetToken;
        if (client == null || token == null) {
          throw StateError('Verify the email code before resetting the password.');
        }
        await client.emailIdp.finishPasswordReset(
          finishPasswordResetToken: token,
          newPassword: _newPasswordController.text,
        );
        if (!mounted) return;
        setState(() {
          _isLoading = false;
          _currentStep = 2; // Success step
        });
      } catch (error) {
        if (mounted) {
          setState(() => _isLoading = false);
          _showError(error.toString());
        }
      }
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = HealthifyGlassTheme.isDarkMode(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 900;

    final primaryTextColor = HealthifyGlassTheme.getTextPrimary(isDark);

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
                constraints: BoxConstraints(maxWidth: isDesktop ? 480 : 420),
                child: GlassCard(
                  borderRadius: 24,
                  hasTealGlow: true,
                  padding: EdgeInsets.all(isDesktop ? 32.0 : 24.0),
                  child: _buildStepContent(isDark),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStepContent(bool isDark) {
    switch (_currentStep) {
      case 0:
        return _buildPhoneStep(isDark);
      case 1:
        return _buildNewPasswordStep(isDark);
      case 2:
        return _buildSuccessStep(isDark);
      default:
        return _buildPhoneStep(isDark);
    }
  }

  Widget _buildPhoneStep(bool isDark) {
    final primaryTextColor = HealthifyGlassTheme.getTextPrimary(isDark);
    final secondaryTextColor = HealthifyGlassTheme.getTextSecondary(isDark);

    return Form(
      key: _formKeyPhone,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Center(
            child: GlassIconContainer(
              icon: Icons.lock_reset_rounded,
              size: 58,
              iconSize: 32,
              color: HealthifyGlassTheme.primaryTeal,
              borderRadius: 18,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Reset Password',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: HealthifyGlassTheme.primaryTeal,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Enter your registered email. Use the 6-digit verification code printed in the Serverpod terminal.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: secondaryTextColor, height: 1.4),
          ),
          const SizedBox(height: 24),

          Text(
            'Registered Email Address',
            style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600, color: primaryTextColor),
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
              if (value == null || value.trim().isEmpty) {
                return 'Please enter your email address';
              }
              if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(value.trim())) {
                return 'Please enter a valid email address';
              }
              return null;
            },
          ),
          const SizedBox(height: 24),

          GlassPrimaryButton(
            height: 50,
            onPressed: _sendOtp,
            child: const Text(
              'Send Verification OTP',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNewPasswordStep(bool isDark) {
    final primaryTextColor = HealthifyGlassTheme.getTextPrimary(isDark);
    final secondaryTextColor = HealthifyGlassTheme.getTextSecondary(isDark);

    return Form(
      key: _formKeyPassword,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Center(
            child: GlassIconContainer(
              icon: Icons.shield_outlined,
              size: 58,
              iconSize: 32,
              color: HealthifyGlassTheme.primaryTeal,
              borderRadius: 18,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Create New Password',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: HealthifyGlassTheme.primaryTeal,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Your phone number has been verified. Create a new strong password for your account.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: secondaryTextColor),
          ),
          const SizedBox(height: 24),

          // New Password
          Text(
            'New Password',
            style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600, color: primaryTextColor),
          ),
          const SizedBox(height: 6),
          TextFormField(
            controller: _newPasswordController,
            obscureText: !_isPasswordVisible,
            style: TextStyle(color: primaryTextColor),
            decoration: GlassTextFieldTheme.getDecoration(
              context: context,
              hintText: 'Enter new password',
              prefixIcon: const Icon(Icons.lock_outline_rounded),
              suffixIcon: IconButton(
                icon: Icon(
                  _isPasswordVisible ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                  color: secondaryTextColor,
                ),
                onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a new password';
              }
              if (value.length < 6) {
                return 'Password must be at least 6 characters';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          // Confirm Password
          Text(
            'Confirm New Password',
            style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600, color: primaryTextColor),
          ),
          const SizedBox(height: 6),
          TextFormField(
            controller: _confirmPasswordController,
            obscureText: !_isPasswordVisible,
            style: TextStyle(color: primaryTextColor),
            decoration: GlassTextFieldTheme.getDecoration(
              context: context,
              hintText: 'Re-enter new password',
              prefixIcon: const Icon(Icons.lock_reset_rounded),
            ),
            validator: (value) {
              if (value != _newPasswordController.text) {
                return 'Passwords do not match';
              }
              return null;
            },
          ),
          const SizedBox(height: 24),

          GlassPrimaryButton(
            height: 50,
            isLoading: _isLoading,
            onPressed: _resetPassword,
            child: const Text(
              'Save New Password',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessStep(bool isDark) {
    final secondaryTextColor = HealthifyGlassTheme.getTextSecondary(isDark);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Center(
          child: GlassIconContainer(
            icon: Icons.check_circle_rounded,
            size: 64,
            iconSize: 40,
            color: const Color(0xFF10B981),
            borderRadius: 20,
          ),
        ),
        const SizedBox(height: 18),
        const Text(
          'Password Reset Successful!',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Color(0xFF10B981)),
        ),
        const SizedBox(height: 8),
        Text(
          'Your password has been updated securely. You can now sign in to Healthify using your new password.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 13.5, color: secondaryTextColor, height: 1.4),
        ),
        const SizedBox(height: 28),

        GlassPrimaryButton(
          height: 50,
          onPressed: () {
            Navigator.pushAndRemoveUntil(
              context,
              FadePageRoute(page: const PatientLoginScreen()),
              (route) => false,
            );
          },
          child: const Text('Back to Sign In', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }
}
