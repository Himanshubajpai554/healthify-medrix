import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../shared/widgets/glass_components.dart';
import '../../theme/app_theme.dart';
import '../models/patient_portal_models.dart';

class ShareReportModal extends StatefulWidget {
  final MedicalReport report;
  final Function(MedicalReport updatedReport) onReportUpdated;

  const ShareReportModal({
    super.key,
    required this.report,
    required this.onReportUpdated,
  });

  static void show(
    BuildContext context, {
    required MedicalReport report,
    required Function(MedicalReport updatedReport) onReportUpdated,
  }) {
    showHealthifyGlassBottomSheet(
      context: context,
      builder: (context) => ShareReportModal(
        report: report,
        onReportUpdated: onReportUpdated,
      ),
    );
  }

  @override
  State<ShareReportModal> createState() => _ShareReportModalState();
}

class _ShareReportModalState extends State<ShareReportModal> {
  late MedicalReport _currentReport;
  String _selectedExpiration = '24 Hours';
  final _recipientController = TextEditingController(text: 'Dr. Sarah Jenkins');
  bool _isLinkGenerated = false;
  String _generatedLink = '';

  final List<String> _expirationOptions = ['24 Hours', '48 Hours', '7 Days', '30 Days'];

  @override
  void initState() {
    super.initState();
    _currentReport = widget.report;
  }

  @override
  void dispose() {
    _recipientController.dispose();
    super.dispose();
  }

  void _generateSecureLink() {
    final expiryHours = _selectedExpiration == '24 Hours'
        ? 24
        : _selectedExpiration == '48 Hours'
            ? 48
            : _selectedExpiration == '7 Days'
                ? 168
                : 720;

    final newLink = SharedReportLink(
      id: 'LNK-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
      sharedWith: _recipientController.text.trim().isEmpty ? 'Attending Doctor' : _recipientController.text.trim(),
      createdAt: DateTime.now(),
      expiresAt: DateTime.now().add(Duration(hours: expiryHours)),
      isRevoked: false,
    );

    final updatedLinks = List<SharedReportLink>.from(_currentReport.sharedLinks)..add(newLink);

    final updatedReport = _currentReport.copyWith(sharedLinks: updatedLinks);

    setState(() {
      _currentReport = updatedReport;
      _isLinkGenerated = true;
      _generatedLink = 'https://medrix.health/v/${newLink.id}';
    });

    widget.onReportUpdated(updatedReport);
  }

  void _revokeAccess(String linkId) {
    final updatedLinks = _currentReport.sharedLinks.map((link) {
      if (link.id == linkId) {
        return SharedReportLink(
          id: link.id,
          sharedWith: link.sharedWith,
          createdAt: link.createdAt,
          expiresAt: link.expiresAt,
          isRevoked: true,
        );
      }
      return link;
    }).toList();

    final updatedReport = _currentReport.copyWith(sharedLinks: updatedLinks);

    setState(() {
      _currentReport = updatedReport;
    });

    widget.onReportUpdated(updatedReport);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('🔒 Shared access revoked immediately.'),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkCardColor : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        top: 24,
        left: 24,
        right: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Modal Handle & Header
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? Colors.white24 : Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.blue.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.shield_outlined, color: Colors.blue, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Secure Share & Access',
                        style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _currentReport.title,
                        style: const TextStyle(fontSize: 12.5, color: AppTheme.textSecondary, fontWeight: FontWeight.w500),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Privacy Assurance Card
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.teal.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.teal.withValues(alpha: 0.2)),
              ),
              child: Row(
                children: const [
                  Icon(Icons.lock_outline_rounded, color: Colors.teal, size: 18),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Your medical records are encrypted. Shared links self-expire automatically.',
                      style: TextStyle(fontSize: 12, color: Colors.teal, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),
            const Text(
              'Generate Temporary Access Link',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            // Recipient Field
            TextField(
              controller: _recipientController,
              decoration: InputDecoration(
                labelText: 'Recipient Name or Hospital',
                hintText: 'e.g. Dr. Sarah Jenkins or City Care Hospital',
                prefixIcon: const Icon(Icons.person_outline_rounded, color: Colors.blue),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 12),

            // Expiration Dropdown
            DropdownButtonFormField<String>(
              initialValue: _selectedExpiration,
              items: _expirationOptions
                  .map((exp) => DropdownMenuItem(value: exp, child: Text('Link Expires in $exp')))
                  .toList(),
              onChanged: (val) {
                if (val != null) setState(() => _selectedExpiration = val);
              },
              decoration: InputDecoration(
                labelText: 'Link Expiration Window',
                prefixIcon: const Icon(Icons.timer_outlined, color: Colors.orange),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 16),

            // Generate Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _generateSecureLink,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                icon: const Icon(Icons.link_rounded),
                label: const Text('Generate Secure Temporary Link', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),

            // Generated Link Card
            if (_isLinkGenerated) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppTheme.backgroundColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.teal.withValues(alpha: 0.4)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: const [
                        Icon(Icons.check_circle_rounded, color: Colors.teal, size: 18),
                        SizedBox(width: 8),
                        Text('Link Generated & Encrypted', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.teal)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    SelectableText(
                      _generatedLink,
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.blue),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        ElevatedButton.icon(
                          onPressed: () {
                            Clipboard.setData(ClipboardData(text: _generatedLink));
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Link copied to clipboard!'),
                                backgroundColor: Colors.teal,
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue.shade700,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          icon: const Icon(Icons.copy_rounded, size: 16),
                          label: const Text('Copy Link', style: TextStyle(fontSize: 12)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],

            // Active Shared Links List Section
            if (_currentReport.sharedLinks.isNotEmpty) ...[
              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 12),
              const Text(
                'Active & Past Shared Access',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              ..._currentReport.sharedLinks.map((link) => _buildSharedLinkTile(link)),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSharedLinkTile(SharedReportLink link) {
    final now = DateTime.now();
    final isExpired = now.isAfter(link.expiresAt);
    final isActive = !link.isRevoked && !isExpired;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isActive ? Colors.teal.withValues(alpha: 0.3) : AppTheme.borderLight,
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: isActive ? Colors.teal.withValues(alpha: 0.15) : Colors.grey.withValues(alpha: 0.15),
            child: Icon(
              isActive ? Icons.person_outline_rounded : Icons.link_off_rounded,
              color: isActive ? Colors.teal : Colors.grey,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Shared with ${link.sharedWith}',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5),
                ),
                const SizedBox(height: 2),
                Text(
                  link.isRevoked
                      ? 'Access Revoked'
                      : isExpired
                          ? 'Expired on ${_formatDate(link.expiresAt)}'
                          : 'Expires: ${_formatDate(link.expiresAt)}',
                  style: TextStyle(
                    fontSize: 11.5,
                    color: link.isRevoked
                        ? Colors.redAccent
                        : isExpired
                            ? Colors.orange
                            : Colors.teal,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          if (isActive) ...[
            TextButton.icon(
              onPressed: () => _revokeAccess(link.id),
              style: TextButton.styleFrom(foregroundColor: Colors.redAccent),
              icon: const Icon(Icons.block_rounded, size: 16),
              label: const Text('Revoke', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            ),
          ] else ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                link.isRevoked ? 'Revoked' : 'Expired',
                style: const TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}