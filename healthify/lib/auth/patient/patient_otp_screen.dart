import 'dart:async';
import 'package:flutter/material.dart';
import 'package:serverpod_auth_idp_flutter/serverpod_auth_idp_flutter.dart';
import '../../core/provider/repository_provider.dart';
import '../../utils/page_transitions.dart';
import '../../shared/widgets/animated_pulse_background.dart';
import '../../shared/widgets/glass_components.dart';
import './patient_profile_setup_screen.dart';

class PatientOtpScreen extends StatefulWidget {
  final String phoneNumber;
  final String fullName;
  final String email;
  final String password;
  final dynamic accountRequestId;
  final bool isPasswordReset;

  const PatientOtpScreen({
    super.key,
    required this.phoneNumber,
    this.fullName = 'Alex Rivera',
    this.email = '',
    this.password = '',
    this.accountRequestId,
    this.isPasswordReset = false,
  });

  @override
  State<PatientOtpScreen> createState() => _PatientOtpScreenState();
}

class _PatientOtpScreenState extends State<PatientOtpScreen> {
  final List<TextEditingController> _controllers = List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  int _resendTimerSeconds = 45;
  late dynamic _activeRequestId;
  Timer? _timer;
  bool _canResend = false;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _activeRequestId = widget.accountRequestId;
    _startResendTimer();
  }

  void _startResendTimer() {
    setState(() {
      _resendTimerSeconds = 45;
      _canResend = false;
      _errorMessage = null;
    });
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendTimerSeconds > 0) {
        setState(() => _resendTimerSeconds--);
      } else {
        setState(() => _canResend = true);
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  String get _otpCode => _controllers.map((c) => c.text).join();

  Future<void> _resendCode() async {
    final client = RepositoryContainer.instance.serverpodClient;
    if (client == null) return;
    try {
      final requestId = widget.isPasswordReset
          ? await client.emailIdp.startPasswordReset(email: widget.email)
          : await client.emailIdp.startRegistration(email: widget.email);
      if (!mounted) return;
      setState(() => _activeRequestId = requestId);
      _startResendTimer();
    } catch (error) {
      if (mounted) setState(() => _errorMessage = error.toString());
    }
  }

  Future<void> _verifyOtp() async {
    final code = _otpCode;
    setState(() => _errorMessage = null);

    if (code.length < 6) {
      setState(() => _errorMessage = 'Please enter all 6 digits of the OTP code.');
      return;
    }

    setState(() => _isLoading = true);
    final client = RepositoryContainer.instance.serverpodClient;
    if (client == null || widget.accountRequestId == null) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Patient account server is not configured. Please try again.';
      });
      return;
    }
    try {
      if (widget.isPasswordReset) {
        final resetToken = await client.emailIdp.verifyPasswordResetCode(
          passwordResetRequestId: _activeRequestId,
          verificationCode: code,
        );
        if (!mounted) return;
        setState(() => _isLoading = false);
        Navigator.pop(context, resetToken);
        return;
      }
      final registrationToken = await client.emailIdp.verifyRegistrationCode(
        accountRequestId: _activeRequestId,
        verificationCode: code,
      );
      await client.emailIdp.finishRegistration(
        registrationToken: registrationToken,
        password: widget.password,
      );
      final auth = EmailAuthController(
        client: client,
        startScreen: EmailFlowScreen.login,
        onAuthenticated: () {},
        onError: (error) => setState(() => _errorMessage = error.toString()),
      );
      auth.emailController.text = widget.email;
      auth.passwordController.text = widget.password;
      await auth.login();
      auth.dispose();
      if (!mounted) return;
      setState(() => _isLoading = false);
      Navigator.pushReplacement(
        context,
        FadePageRoute(
          page: PatientProfileSetupScreen(
            fullName: widget.fullName,
            phoneNumber: widget.phoneNumber,
            email: widget.email,
          ),
        ),
      );
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = error.toString();
      });
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Header Icon
                      Center(
                        child: GlassIconContainer(
                          icon: Icons.mark_email_read_rounded,
                          size: 58,
                          iconSize: 32,
                          color: HealthifyGlassTheme.primaryTeal,
                          borderRadius: 18,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Email Verification',
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
                        'Enter the 6-digit email verification code for\n${widget.email}',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13.5,
                          color: secondaryTextColor,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Change Number Option
                      Center(
                        child: TextButton.icon(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.edit_outlined, size: 14, color: HealthifyGlassTheme.primaryTeal),
                          label: const Text(
                            'Change email address',
                            style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: HealthifyGlassTheme.primaryTeal),
                          ),
                        ),
                      ),

                      const SizedBox(height: 18),

                      // Local development verification-code location.
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: HealthifyGlassTheme.primaryTeal.withValues(alpha: isDark ? 0.18 : 0.08),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: HealthifyGlassTheme.primaryTeal.withValues(alpha: 0.25)),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.info_outline_rounded, size: 15, color: HealthifyGlassTheme.primaryTeal),
                            SizedBox(width: 6),
                            Text(
                              'Local code is printed in the Serverpod terminal',
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: HealthifyGlassTheme.primaryTeal),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Error Banner
                      if (_errorMessage != null) ...[
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.red.withValues(alpha: isDark ? 0.18 : 0.08),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.red.withValues(alpha: 0.35)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.error_outline_rounded, color: Colors.redAccent, size: 20),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  _errorMessage!,
                                  style: const TextStyle(fontSize: 12.5, color: Colors.redAccent, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],

                      // 6-DIGIT OTP INPUT BOXES
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: List.generate(6, (index) {
                          return SizedBox(
                            width: isDesktop ? 48 : 42,
                            height: 52,
                            child: TextFormField(
                              controller: _controllers[index],
                              focusNode: _focusNodes[index],
                              keyboardType: TextInputType.number,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: HealthifyGlassTheme.primaryTeal,
                              ),
                              maxLength: 1,
                              decoration: InputDecoration(
                                counterText: '',
                                contentPadding: EdgeInsets.zero,
                                filled: true,
                                fillColor: isDark
                                    ? Colors.white.withValues(alpha: 0.075)
                                    : Colors.white.withValues(alpha: 0.90),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: HealthifyGlassTheme.getGlassBorder(isDark),
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: HealthifyGlassTheme.getGlassBorder(isDark),
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(
                                    color: HealthifyGlassTheme.primaryTeal,
                                    width: 2,
                                  ),
                                ),
                              ),
                              onChanged: (val) {
                                if (val.isNotEmpty && index < 5) {
                                  _focusNodes[index + 1].requestFocus();
                                } else if (val.isEmpty && index > 0) {
                                  _focusNodes[index - 1].requestFocus();
                                }
                                if (_otpCode.length == 6) {
                                  _verifyOtp();
                                }
                              },
                            ),
                          );
                        }),
                      ),

                      const SizedBox(height: 24),

                      // RESEND TIMER
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Didn't receive code? ",
                            style: TextStyle(color: secondaryTextColor, fontSize: 13),
                          ),
                          _canResend
                              ? InkWell(
                                  onTap: _resendCode,
                                  child: const Text(
                                    'Resend code',
                                    style: TextStyle(
                                      color: HealthifyGlassTheme.primaryTeal,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                )
                              : Text(
                                  'Resend in ${_resendTimerSeconds.toString().padLeft(2, '0')}s',
                                  style: const TextStyle(
                                    color: HealthifyGlassTheme.primaryTeal,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // VERIFY CTA
                      GlassPrimaryButton(
                        height: 52,
                        isLoading: _isLoading,
                        onPressed: _verifyOtp,
                        child: const Text(
                          'Verify & Continue',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
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
    );
  }
}
