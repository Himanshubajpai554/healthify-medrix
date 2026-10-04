import 'dart:ui';
import 'package:flutter/material.dart';
import '../blood_model.dart';
import '../../../shared/widgets/glass_components.dart';
import '../../../theme/app_theme.dart';

class CreateBloodRequestModal extends StatefulWidget {
  final Function(BloodRequestItem) onRequestCreated;

  const CreateBloodRequestModal({super.key, required this.onRequestCreated});

  @override
  State<CreateBloodRequestModal> createState() => _CreateBloodRequestModalState();
}

class _CreateBloodRequestModalState extends State<CreateBloodRequestModal> {
  final _formKey = GlobalKey<FormState>();
  final _unitsController = TextEditingController(text: '4');

  String _bloodGroup = 'O-';
  String _department = 'Emergency';
  RequestPriority _priority = RequestPriority.critical;

  final List<String> _bloodGroups = ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'];
  final List<String> _departments = ['Emergency', 'ICU', 'Surgery', 'Maternity', 'Trauma', 'Other'];

  @override
  void dispose() {
    _unitsController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final newReqId = 'BR-${(1000 + (DateTime.now().millisecondsSinceEpoch % 8999))}';
      final newRequest = BloodRequestItem(
        requestId: newReqId,
        bloodGroup: _bloodGroup,
        requiredUnits: int.tryParse(_unitsController.text.trim()) ?? 2,
        allocatedUnits: 0,
        department: _department,
        priority: _priority,
        status: RequestStatus.pending,
      );

      widget.onRequestCreated(newRequest);
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
            constraints: const BoxConstraints(maxHeight: 580),
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
                      Expanded(
                        child: Row(
                          children: [
                            const GlassIconContainer(
                              icon: Icons.add_alert_outlined,
                              color: Color(0xFFD97706),
                              size: 38,
                              iconSize: 20,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Create Department Blood Request',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? Colors.white : AppTheme.textPrimary,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
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
                          // Department & Blood Group Row
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Requesting Department',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: isDark ? Colors.white : AppTheme.textPrimary,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    DropdownButtonFormField<String>(
                                      isExpanded: true,
                                      initialValue: _department,
                                      dropdownColor: isDark ? const Color(0xFF0F2928) : Colors.white,
                                      style: TextStyle(color: isDark ? Colors.white : AppTheme.textPrimary),
                                      decoration: GlassTextFieldTheme.getDecoration(
                                        context: context,
                                        hintText: 'Select dept',
                                      ),
                                      items: _departments.map((d) => DropdownMenuItem(value: d, child: Text(d))).toList(),
                                      onChanged: (val) {
                                        if (val != null) setState(() => _department = val);
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
                                      'Blood Group Required',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: isDark ? Colors.white : AppTheme.textPrimary,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    DropdownButtonFormField<String>(
                                      isExpanded: true,
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
                            ],
                          ),
                          const SizedBox(height: 16),

                          // Required Units & Priority Row
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Required Units',
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
                                        hintText: 'Enter units',
                                      ),
                                      validator: (val) {
                                        if (val == null || val.trim().isEmpty) return 'Enter units';
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
                                      'Clinical Priority',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: isDark ? Colors.white : AppTheme.textPrimary,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    DropdownButtonFormField<RequestPriority>(
                                      isExpanded: true,
                                      initialValue: _priority,
                                      dropdownColor: isDark ? const Color(0xFF0F2928) : Colors.white,
                                      style: TextStyle(color: isDark ? Colors.white : AppTheme.textPrimary),
                                      decoration: GlassTextFieldTheme.getDecoration(
                                        context: context,
                                        hintText: 'Select priority',
                                      ),
                                      items: const [
                                        DropdownMenuItem(value: RequestPriority.critical, child: Text('Critical (Immediate)')),
                                        DropdownMenuItem(value: RequestPriority.urgent, child: Text('Urgent (<2 hrs)')),
                                        DropdownMenuItem(value: RequestPriority.normal, child: Text('Normal Roster')),
                                      ],
                                      onChanged: (val) {
                                        if (val != null) setState(() => _priority = val);
                                      },
                                    ),
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
                          color: const Color(0xFFD97706),
                          onPressed: _submitForm,
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.send_rounded, size: 18),
                              SizedBox(width: 6),
                              Text('Dispatch'),
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