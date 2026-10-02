import 'package:flutter/material.dart';
import '../../../shared/widgets/glass_components.dart';
import '../../models/doctor_profile_models.dart';
import '../../services/doctor_profile_service.dart';

class SecuritySettingsSection extends StatefulWidget {
  final DoctorSecurityModel securityInfo;
  final List<DoctorSecuritySessionModel> sessions;
  final List<DoctorLoginActivityModel> loginActivity;
  final Future<bool> Function(String current, String next) onChangePassword;
  final ValueChanged<String> onSignOutSession;
  final VoidCallback onSignOutOtherSessions;

  const SecuritySettingsSection({
    super.key,
    required this.securityInfo,
    required this.sessions,
    required this.loginActivity,
    required this.onChangePassword,
    required this.onSignOutSession,
    required this.onSignOutOtherSessions,
  });

  @override
  State<SecuritySettingsSection> createState() =>
      _SecuritySettingsSectionState();
}

class _SecuritySettingsSectionState extends State<SecuritySettingsSection> {
  final _passFormKey = GlobalKey<FormState>();
  final _currentPassCtrl = TextEditingController();
  final _newPassCtrl = TextEditingController();
  final _confirmPassCtrl = TextEditingController();

  bool _isChangingPassword = false;
  double _passwordStrength = 0.0;

  @override
  void dispose() {
    _currentPassCtrl.dispose();
    _newPassCtrl.dispose();
    _confirmPassCtrl.dispose();
    super.dispose();
  }

  void _calculateStrength(String val) {
    double strength = 0;
    if (val.length >= 8) strength += 0.3;
    if (RegExp(r'[A-Z]').hasMatch(val)) strength += 0.25;
    if (RegExp(r'[0-9]').hasMatch(val)) strength += 0.25;
    if (RegExp(r'[!@#$%^&*(),.?":{}|<>!]').hasMatch(val)) strength += 0.2;

    setState(() {
      _passwordStrength = strength.clamp(0.0, 1.0);
    });
  }

  Future<void> _handlePasswordSubmit() async {
    if (_passFormKey.currentState?.validate() ?? false) {
      setState(() => _isChangingPassword = true);

      final success = await widget.onChangePassword(
        _currentPassCtrl.text,
        _newPassCtrl.text,
      );

      setState(() => _isChangingPassword = false);

      if (mounted) {
        if (success) {
          _currentPassCtrl.clear();
          _newPassCtrl.clear();
          _confirmPassCtrl.clear();
          setState(() => _passwordStrength = 0.0);

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Password changed successfully.'),
              backgroundColor: HealthifyGlassTheme.primaryTeal,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Unable to change password. Please verify current credentials.'),
              backgroundColor: Colors.redAccent,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = HealthifyGlassTheme.isDarkMode(context);

    return Column(
      children: [
        // 1. Change Password
        GlassCard(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _passFormKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const GlassIconContainer(
                      icon: Icons.key_rounded,
                      size: 40,
                      iconSize: 20,
                      color: HealthifyGlassTheme.primaryTeal,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Change Password',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: HealthifyGlassTheme.getTextPrimary(isDark),
                            ),
                          ),
                          Text(
                            'Last password change: ${widget.securityInfo.lastPasswordChange}',
                            style: TextStyle(
                              fontSize: 12.5,
                              color: HealthifyGlassTheme.getTextSecondary(isDark),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Divider(height: 1, thickness: 1),
                const SizedBox(height: 20),

                // Current Password Field
                TextFormField(
                  controller: _currentPassCtrl,
                  obscureText: true,
                  style: TextStyle(
                    fontSize: 13,
                    color: HealthifyGlassTheme.getTextPrimary(isDark),
                  ),
                  decoration: _buildInputDeco('Current Password', isDark),
                  validator: (val) => val == null || val.isEmpty ? 'Current password required' : null,
                ),
                const SizedBox(height: 14),

                // New Password Field
                TextFormField(
                  controller: _newPassCtrl,
                  obscureText: true,
                  onChanged: _calculateStrength,
                  style: TextStyle(
                    fontSize: 13,
                    color: HealthifyGlassTheme.getTextPrimary(isDark),
                  ),
                  decoration: _buildInputDeco('New Password (min 8 characters)', isDark),
                  validator: (val) {
                    if (val == null || val.length < 8) return 'Password must be at least 8 characters';
                    return null;
                  },
                ),
                if (_newPassCtrl.text.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: LinearProgressIndicator(
                          value: _passwordStrength,
                          backgroundColor: isDark ? Colors.white10 : Colors.black12,
                          color: _passwordStrength < 0.4
                              ? Colors.redAccent
                              : (_passwordStrength < 0.8 ? Colors.amber : const Color(0xFF10B981)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        _passwordStrength < 0.4
                            ? 'Weak'
                            : (_passwordStrength < 0.8 ? 'Medium' : 'Strong'),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: _passwordStrength < 0.4
                              ? Colors.redAccent
                              : (_passwordStrength < 0.8 ? Colors.amber : const Color(0xFF10B981)),
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 14),

                // Confirm Password Field
                TextFormField(
                  controller: _confirmPassCtrl,
                  obscureText: true,
                  style: TextStyle(
                    fontSize: 13,
                    color: HealthifyGlassTheme.getTextPrimary(isDark),
                  ),
                  decoration: _buildInputDeco('Confirm New Password', isDark),
                  validator: (val) {
                    if (val != _newPassCtrl.text) return 'Passwords do not match';
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    GlassPrimaryButton(
                      height: 42,
                      onPressed: _isChangingPassword ? null : _handlePasswordSubmit,
                      child: _isChangingPassword
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : const Row(
                              children: [
                                Icon(Icons.lock_reset_rounded, size: 16, color: Colors.white),
                                SizedBox(width: 6),
                                Text('Change Password', style: TextStyle(fontSize: 13, color: Colors.white)),
                              ],
                            ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 16),

        // 2. Two-Factor Authentication (2FA)
        GlassCard(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const GlassIconContainer(
                    icon: Icons.phonelink_lock_rounded,
                    size: 40,
                    iconSize: 20,
                    color: HealthifyGlassTheme.primaryTeal,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Two-Factor Authentication (2FA)',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: HealthifyGlassTheme.getTextPrimary(isDark),
                          ),
                        ),
                        Text(
                          'Add an extra layer of security to your healthcare workspace.',
                          style: TextStyle(
                            fontSize: 12.5,
                            color: HealthifyGlassTheme.getTextSecondary(isDark),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(height: 1, thickness: 1),
              const SizedBox(height: 16),

              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.04)
                      : Colors.black.withValues(alpha: 0.02),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: HealthifyGlassTheme.getGlassBorder(isDark),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      widget.securityInfo.is2faEnabled
                          ? Icons.check_circle_rounded
                          : Icons.warning_amber_rounded,
                      size: 24,
                      color: widget.securityInfo.is2faEnabled
                          ? const Color(0xFF10B981)
                          : Colors.amber,
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.securityInfo.is2faEnabled ? '2FA Enabled' : '2FA Not Configured',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: HealthifyGlassTheme.getTextPrimary(isDark),
                            ),
                          ),
                          Text(
                            'Supported methods: ${widget.securityInfo.supported2faMethods.join(", ")}',
                            style: TextStyle(
                              fontSize: 12,
                              color: HealthifyGlassTheme.getTextSecondary(isDark),
                            ),
                          ),
                        ],
                      ),
                    ),
                    GlassSecondaryButton(
                      height: 36,
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Two-factor setup prompt initiated. Please scan the QR code in your Authenticator app.'),
                            backgroundColor: HealthifyGlassTheme.primaryTeal,
                          ),
                        );
                      },
                      child: Text(
                        widget.securityInfo.is2faEnabled ? 'Configure' : 'Set Up 2FA',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // 3. Active Sessions
        GlassCard(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const GlassIconContainer(
                    icon: Icons.devices_rounded,
                    size: 40,
                    iconSize: 20,
                    color: HealthifyGlassTheme.primaryTeal,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Active Workspace Sessions',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: HealthifyGlassTheme.getTextPrimary(isDark),
                          ),
                        ),
                        Text(
                          'Devices currently logged into your Medrix Doctor account.',
                          style: TextStyle(
                            fontSize: 12.5,
                            color: HealthifyGlassTheme.getTextSecondary(isDark),
                          ),
                        ),
                      ],
                    ),
                  ),
                  GlassSecondaryButton(
                    height: 36,
                    onPressed: () => _confirmSignOutAllOther(context),
                    child: const Text('Sign Out All Other Sessions', style: TextStyle(fontSize: 11.5, color: Colors.redAccent)),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(height: 1, thickness: 1),
              const SizedBox(height: 16),

              ...widget.sessions.map((ses) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.04)
                          : Colors.black.withValues(alpha: 0.02),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: ses.isCurrent
                            ? HealthifyGlassTheme.primaryTeal.withValues(alpha: 0.4)
                            : HealthifyGlassTheme.getGlassBorder(isDark),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          ses.device.contains('Windows') || ses.device.contains('Mac')
                              ? Icons.laptop_rounded
                              : Icons.smartphone_rounded,
                          size: 22,
                          color: HealthifyGlassTheme.primaryTeal,
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    ses.device,
                                    style: TextStyle(
                                      fontSize: 13.5,
                                      fontWeight: FontWeight.bold,
                                      color: HealthifyGlassTheme.getTextPrimary(isDark),
                                    ),
                                  ),
                                  if (ses.isCurrent) ...[
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: HealthifyGlassTheme.primaryTeal,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Text(
                                        'Current Session',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${ses.browser} • ${ses.locationApprox}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: HealthifyGlassTheme.getTextSecondary(isDark),
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (!ses.isCurrent)
                          IconButton(
                            icon: const Icon(Icons.logout_rounded, size: 18, color: Colors.redAccent),
                            onPressed: () => widget.onSignOutSession(ses.id),
                            tooltip: 'Sign Out Session',
                          ),
                      ],
                    ),
                  ),
                );
              }),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // 4. Recent Login Activity
        GlassCard(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const GlassIconContainer(
                    icon: Icons.history_rounded,
                    size: 40,
                    iconSize: 20,
                    color: HealthifyGlassTheme.primaryTeal,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Recent Login Activity',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: HealthifyGlassTheme.getTextPrimary(isDark),
                          ),
                        ),
                        Text(
                          'Audit log of authentication attempts into your provider profile.',
                          style: TextStyle(
                            fontSize: 12.5,
                            color: HealthifyGlassTheme.getTextSecondary(isDark),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(height: 1, thickness: 1),
              const SizedBox(height: 16),

              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columnSpacing: 24,
                  columns: [
                    DataColumn(label: Text('Timestamp', style: TextStyle(fontWeight: FontWeight.bold, color: HealthifyGlassTheme.getTextPrimary(isDark)))),
                    DataColumn(label: Text('Device / Client', style: TextStyle(fontWeight: FontWeight.bold, color: HealthifyGlassTheme.getTextPrimary(isDark)))),
                    DataColumn(label: Text('Approx Location', style: TextStyle(fontWeight: FontWeight.bold, color: HealthifyGlassTheme.getTextPrimary(isDark)))),
                    DataColumn(label: Text('IP Address', style: TextStyle(fontWeight: FontWeight.bold, color: HealthifyGlassTheme.getTextPrimary(isDark)))),
                    DataColumn(label: Text('Status', style: TextStyle(fontWeight: FontWeight.bold, color: HealthifyGlassTheme.getTextPrimary(isDark)))),
                  ],
                  rows: widget.loginActivity.map((log) {
                    return DataRow(
                      cells: [
                        DataCell(Text(_formatDateTime(log.timestamp), style: TextStyle(fontSize: 12, color: HealthifyGlassTheme.getTextPrimary(isDark)))),
                        DataCell(Text(log.device, style: TextStyle(fontSize: 12, color: HealthifyGlassTheme.getTextSecondary(isDark)))),
                        DataCell(Text(log.locationApprox, style: TextStyle(fontSize: 12, color: HealthifyGlassTheme.getTextSecondary(isDark)))),
                        DataCell(Text(log.ipAddress, style: TextStyle(fontSize: 12, color: HealthifyGlassTheme.getTextMuted(isDark)))),
                        DataCell(
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: log.isSuccessful
                                  ? const Color(0xFF10B981).withValues(alpha: 0.15)
                                  : Colors.red.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              log.isSuccessful ? 'Successful' : 'Failed Attempt',
                              style: TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.bold,
                                color: log.isSuccessful ? const Color(0xFF10B981) : Colors.redAccent,
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  InputDecoration _buildInputDeco(String label, bool isDark) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(fontSize: 13, color: HealthifyGlassTheme.getTextSecondary(isDark)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      filled: true,
      fillColor: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.03),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: HealthifyGlassTheme.getGlassBorder(isDark)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: HealthifyGlassTheme.getGlassBorder(isDark)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: HealthifyGlassTheme.primaryTeal, width: 1.5),
      ),
    );
  }

  void _confirmSignOutAllOther(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogCtx) {
        return AlertDialog(
          title: const Text('Sign Out All Other Sessions?'),
          content: const Text('This will disconnect all other mobile and desktop client sessions. You will remain signed in on this current browser device.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogCtx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
              onPressed: () {
                widget.onSignOutOtherSessions();
                Navigator.pop(dialogCtx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('All other active sessions have been signed out.'),
                    backgroundColor: HealthifyGlassTheme.primaryTeal,
                  ),
                );
              },
              child: const Text('Sign Out Other Sessions', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  String _formatDateTime(DateTime dt) {
    return '${dt.day}/${dt.month}/${dt.year} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }
}
