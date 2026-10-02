import 'dart:ui';
import 'package:flutter/material.dart';
import '../blood_model.dart';
import '../../../shared/widgets/glass_components.dart';
import '../../../theme/app_theme.dart';

class RecordDonationModal extends StatefulWidget {
  final Function(DonationRecordItem) onDonationRecorded;

  const RecordDonationModal({super.key, required this.onDonationRecorded});

  @override
  State<RecordDonationModal> createState() => _RecordDonationModalState();
}

class _RecordDonationModalState extends State<RecordDonationModal> {
  final _formKey = GlobalKey<FormState>();
  final _unitsController = TextEditingController(text: '1');

  String _bloodGroup = 'O+';
  String _donationType = 'Whole Blood';
  String _screeningStatus = 'Screened';
  final String _storageStatus = 'Stored';

  final List<String> _bloodGroups = ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'];
  final List<String> _types = ['Whole Blood', 'RBC (Apheresis)', 'Plasma', 'Platelets'];

  @override
  void dispose() {
    _unitsController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final newDonorId = 'DNR-${(1000 + (DateTime.now().millisecondsSinceEpoch % 8999))}';
      final newRecord = DonationRecordItem(
        donorId: newDonorId,
        bloodGroup: _bloodGroup,
        donationType: _donationType,
        units: int.tryParse(_unitsController.text.trim()) ?? 1,
        donationDate: 'Today',
        screeningStatus: _screeningStatus,
        storageStatus: _storageStatus,
      );

      widget.onDonationRecorded(newRecord);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = HealthifyGlassTheme.isDarkMode(context);

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      elevation: 0,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
          child: Container(
            width: 500,
            constraints: const BoxConstraints(maxHeight: 600),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: HealthifyGlassTheme.getGlassSurface(isDark, isStrong: true),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: HealthifyGlassTheme.getGlassBorder(isDark), width: 1.2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.08),
                  blurRadius: 30,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const GlassIconContainer(
                            icon: Icons.volunteer_activism_outlined,
                            color: Color(0xFF10B981),
                            size: 38,
                            iconSize: 20,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Record Blood Donation',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : AppTheme.textPrimary,
                            ),
                          ),
                        ],
                      ),
                      IconButton(
                        icon: Icon(Icons.close_rounded, color: isDark ? Colors.white70 : AppTheme.textSecondary),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Divider(height: 1, color: HealthifyGlassTheme.getGlassBorder(isDark)),
                  const SizedBox(height: 16),

                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Blood Group & Donation Type Row
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Donor Blood Group',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: isDark ? Colors.white : AppTheme.textPrimary,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    DropdownButtonFormField<String>(
                                      initialValue: _bloodGroup,
                                      dropdownColor: isDark ? const Color(0xFF0F2928) : Colors.white,
                                      style: TextStyle(color: isDark ? Colors.white : AppTheme.textPrimary),
                                      decoration: GlassTextFieldTheme.getDecoration(
                                        context: context,
                                        hintText: 'Select group',
                                      ),
                                      items: _bloodGroups.map((bg) => DropdownMenuItem(value: bg, child: Text(bg))).toList(),
                                      onChanged: (val) {
                                        if (val != null) setState(() => _bloodGroup = val);
                                      },
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Donation Type',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: isDark ? Colors.white : AppTheme.textPrimary,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    DropdownButtonFormField<String>(
                                      initialValue: _donationType,
                                      dropdownColor: isDark ? const Color(0xFF0F2928) : Colors.white,
                                      style: TextStyle(color: isDark ? Colors.white : AppTheme.textPrimary),
                                      decoration: GlassTextFieldTheme.getDecoration(
                                        context: context,
                                        hintText: 'Select type',
                                      ),
                                      items: _types.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                                      onChanged: (val) {
                                        if (val != null) setState(() => _donationType = val);
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // Quantity & Screening Status Row
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Quantity (Units)',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: isDark ? Colors.white : AppTheme.textPrimary,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    TextFormField(
                                      controller: _unitsController,
                                      keyboardType: TextInputType.number,
                                      style: TextStyle(color: isDark ? Colors.white : AppTheme.textPrimary),
                                      decoration: GlassTextFieldTheme.getDecoration(
                                        context: context,
                                        hintText: 'Enter quantity',
                                      ),
                                      validator: (val) {
                                        if (val == null || val.trim().isEmpty) return 'Enter quantity';
                                        return null;
                                      },
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Screening Status',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: isDark ? Colors.white : AppTheme.textPrimary,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    DropdownButtonFormField<String>(
                                      initialValue: _screeningStatus,
                                      dropdownColor: isDark ? const Color(0xFF0F2928) : Colors.white,
                                      style: TextStyle(color: isDark ? Colors.white : AppTheme.textPrimary),
                                      decoration: GlassTextFieldTheme.getDecoration(
                                        context: context,
                                        hintText: 'Select status',
                                      ),
                                      items: ['Screened', 'Pending Screening', 'Quarantine'].map((st) => DropdownMenuItem(value: st, child: Text(st))).toList(),
                                      onChanged: (val) {
                                        if (val != null) setState(() => _screeningStatus = val);
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // Privacy Notice Box
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: HealthifyGlassTheme.getGlassSurface(isDark),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: HealthifyGlassTheme.getGlassBorder(isDark), width: 1.2),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.privacy_tip_outlined, color: AppTheme.primaryColor, size: 18),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Donor identity is strictly protected under HIPAA/GDPR and will never be exposed to external patients.',
                                    style: TextStyle(
                                      fontSize: 11.5,
                                      color: isDark ? Colors.white70 : AppTheme.textPrimary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Divider(height: 1, color: HealthifyGlassTheme.getGlassBorder(isDark)),
                  const SizedBox(height: 16),

                  // Action Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
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
                          color: const Color(0xFF10B981),
                          onPressed: _submitForm,
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.check, size: 18),
                              SizedBox(width: 6),
                              Text('Record'),
                            ],
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
    );
  }
}