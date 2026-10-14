import 'dart:ui';
import 'package:flutter/material.dart';
import '../../core/provider/repository_provider.dart';
import '../../shared/widgets/glass_components.dart';
import '../../theme/app_theme.dart';

/// Modal for hospital staff/administrators to review pending patient account
/// linking claims.
///
/// Under HIPAA and medical record governance, approving a link connects the
/// patient's authenticated user portal to their physical hospital records.
/// Staff MUST verify the requester's identity (e.g. Govt ID / in-person check)
/// before approval is permitted.
class AccountLinkRequestsModal extends StatefulWidget {
  const AccountLinkRequestsModal({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => const AccountLinkRequestsModal(),
    );
  }

  @override
  State<AccountLinkRequestsModal> createState() =>
      _AccountLinkRequestsModalState();
}

class _AccountLinkRequestsModalState extends State<AccountLinkRequestsModal> {
  bool _isLoading = true;
  String _errorMessage = '';
  List<Map<String, dynamic>> _requests = [];
  final Map<String, Map<String, dynamic>?> _patientDetails = {};

  // Per-request identity verification checkboxes & notes
  final Map<String, bool> _idVerified = {};
  final Map<String, bool> _formSigned = {};
  final Map<String, TextEditingController> _notesControllers = {};
  final Set<String> _processingRequestIds = {};

  @override
  void initState() {
    super.initState();
    _loadRequests();
  }

  @override
  void dispose() {
    for (final controller in _notesControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _loadRequests() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    final repo =
        RepositoryContainer.instance.hospitalOperationalRepository;

    if (repo == null) {
      // Demo mode fallback
      setState(() {
        _isLoading = false;
        _requests = [
          {
            'requestId': 'REQ-DEMO-001',
            'patientId': 'PAT-10892',
            'requesterUserIdentifier': 'usr_patient_demo_4812',
            'status': 'pending',
            'createdAt': DateTime.now()
                .subtract(const Duration(hours: 3))
                .toIso8601String(),
          },
        ];
        _patientDetails['PAT-10892'] = {
          'name': 'Rahul Sharma',
          'mrn': 'MRN-2026-8812',
          'phone': '+91 98765 12345',
          'age': 42,
          'gender': 'Male',
        };
      });
      return;
    }

    try {
      final list = await repo.listAccountLinkRequests();
      final details = <String, Map<String, dynamic>?>{};

      // Fetch patient records for each request to display cross-verification info
      for (final req in list) {
        final patientId = '${req['patientId'] ?? ''}'.trim();
        if (patientId.isNotEmpty && !details.containsKey(patientId)) {
          details[patientId] = await repo.get('patients', patientId);
        }
      }

      if (mounted) {
        setState(() {
          _requests = list;
          _patientDetails.addAll(details);
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Failed to load account-link requests: $e';
        });
      }
    }
  }

  Future<void> _handleReview({
    required String requestId,
    required bool approve,
  }) async {
    final repo =
        RepositoryContainer.instance.hospitalOperationalRepository;
    final isLive = repo != null;

    setState(() => _processingRequestIds.add(requestId));

    try {
      if (isLive) {
        await repo.reviewAccountLinkRequest(
          requestId: requestId,
          approve: approve,
        );
      } else {
        // Demo mode simulation
        await Future.delayed(const Duration(milliseconds: 600));
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              approve
                ? '✓ Patient record link approved! Records released to patient account.'
                : 'Account-link claim rejected.',
            ),
            backgroundColor: approve ? Colors.teal : Colors.redAccent,
            behavior: SnackBarBehavior.floating,
          ),
        );

        // Remove from list
        setState(() {
          _requests.removeWhere((r) => r['requestId'] == requestId);
          _processingRequestIds.remove(requestId);
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _processingRequestIds.remove(requestId));
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Action failed: $e'),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = HealthifyGlassTheme.isDark(context);
    final isLive =
        RepositoryContainer.instance.hospitalOperationalRepository != null;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 820, maxHeight: 860),
            decoration: BoxDecoration(
              color: isDark
                  ? const Color(0xFF0F1E1E).withValues(alpha: 0.94)
                  : Colors.white.withValues(alpha: 0.96),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: isDark ? Colors.white12 : Colors.grey.shade200,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.25),
                  blurRadius: 30,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              children: [
                _buildHeader(isDark, isLive),
                Expanded(child: _buildBody(isDark)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(bool isDark, bool isLive) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: isDark ? Colors.white10 : Colors.grey.shade200,
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.teal.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.link_rounded, color: Colors.teal, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text(
                      'Patient Account-Link Review',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 10),
                    if (!isLive)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.orange.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: Colors.orange.withValues(alpha: 0.4),
                          ),
                        ),
                        child: const Text(
                          'DEMO MODE',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.orange,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  'Verify patient identity proofing before approving hospital chart access to app accounts.',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.white60 : AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close_rounded),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(bool isDark) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.teal),
      );
    }

    if (_errorMessage.isNotEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline_rounded,
                  color: Colors.redAccent, size: 40),
              const SizedBox(height: 12),
              Text(
                _errorMessage,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.redAccent),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _loadRequests,
                icon: const Icon(Icons.refresh_rounded, size: 16),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (_requests.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.teal.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_circle_outline_rounded,
                    color: Colors.teal, size: 48),
              ),
              const SizedBox(height: 16),
              const Text(
                'No Pending Account-Link Requests',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              Text(
                'All patient chart link claims have been reviewed and processed.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: isDark ? Colors.white60 : AppTheme.textSecondary,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(20),
      itemCount: _requests.length,
      separatorBuilder: (_, _) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final req = _requests[index];
        final requestId = '${req['requestId'] ?? 'REQ-$index'}';
        return _buildRequestCard(req, requestId, isDark);
      },
    );
  }

  Widget _buildRequestCard(
    Map<String, dynamic> req,
    String requestId,
    bool isDark,
  ) {
    final patientId = '${req['patientId'] ?? ''}';
    final user = '${req['requesterUserIdentifier'] ?? ''}';
    final createdAt = '${req['createdAt'] ?? ''}';
    final patient = _patientDetails[patientId];

    final isProcessing = _processingRequestIds.contains(requestId);
    final idVerified = _idVerified[requestId] ?? false;
    final formSigned = _formSigned[requestId] ?? false;
    final canApprove = idVerified && formSigned && !isProcessing;

    _notesControllers.putIfAbsent(requestId, () => TextEditingController());
    final notesController = _notesControllers[requestId]!;

    return Container(
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.05)
            : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.white12 : Colors.grey.shade200,
        ),
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header of card
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.teal.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Claim ID: $requestId',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.teal,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                'Requested: ${_formatDate(createdAt)}',
                style: TextStyle(
                  fontSize: 11,
                  color: isDark ? Colors.white54 : AppTheme.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Cross-verification summary: Requester Account vs Hospital Patient Chart
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left: App account details
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.black26 : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isDark ? Colors.white10 : Colors.grey.shade200,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '1. App Account (Requester)',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Colors.teal,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'User Identifier: $user',
                        style: const TextStyle(
                          fontSize: 12,
                          fontFamily: 'monospace',
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Claiming Patient ID:',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                      Text(
                        patientId,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Right: Hospital Patient Record in system
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.black26 : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isDark ? Colors.white10 : Colors.grey.shade200,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '2. Hospital Patient Record',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Colors.blueAccent,
                        ),
                      ),
                      const SizedBox(height: 6),
                      if (patient != null) ...[
                        Text(
                          '${patient['name'] ?? 'Unnamed Patient'}',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'MRN: ${patient['mrn'] ?? patient['id'] ?? patientId} • Phone: ${patient['phone'] ?? 'N/A'}',
                          style: const TextStyle(
                            fontSize: 11.5,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                        Text(
                          'Age: ${patient['age'] ?? 'N/A'} • Gender: ${patient['gender'] ?? 'N/A'}',
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ] else ...[
                        Row(
                          children: const [
                            Icon(Icons.warning_amber_rounded,
                                color: Colors.orange, size: 16),
                            SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                'Record not found in hospital directory!',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.orange,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Identity proofing checklist
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.amber.withValues(alpha: isDark ? 0.08 : 0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.amber.withValues(alpha: 0.3),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: const [
                    Icon(Icons.verified_user_rounded,
                        color: Colors.amber, size: 16),
                    SizedBox(width: 6),
                    Text(
                      'Mandatory Identity Proofing (Staff Checklist)',
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                  value: idVerified,
                  onChanged: (val) {
                    setState(() => _idVerified[requestId] = val ?? false);
                  },
                  title: const Text(
                    'Staff verified physical Government Photo ID / Aadhaar / Passport matches this patient.',
                    style: TextStyle(fontSize: 12),
                  ),
                  controlAffinity: ListTileControlAffinity.leading,
                ),
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                  value: formSigned,
                  onChanged: (val) {
                    setState(() => _formSigned[requestId] = val ?? false);
                  },
                  title: const Text(
                    'Signed Medical Records Access Authorization Form received or OTP phone match confirmed.',
                    style: TextStyle(fontSize: 12),
                  ),
                  controlAffinity: ListTileControlAffinity.leading,
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Verification Notes
          TextField(
            controller: notesController,
            decoration: InputDecoration(
              hintText: 'Staff verification notes / reference # (optional)',
              hintStyle: const TextStyle(fontSize: 12),
              isDense: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            ),
          ),

          const SizedBox(height: 16),

          // Action Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              OutlinedButton.icon(
                onPressed: isProcessing
                    ? null
                    : () => _handleReview(
                          requestId: requestId,
                          approve: false,
                        ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.redAccent,
                  side: const BorderSide(color: Colors.redAccent),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                icon: const Icon(Icons.close_rounded, size: 16),
                label: const Text('Reject Claim'),
              ),
              const SizedBox(width: 12),
              ElevatedButton.icon(
                onPressed: canApprove
                    ? () => _handleReview(
                          requestId: requestId,
                          approve: true,
                        )
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor:
                      Colors.grey.withValues(alpha: 0.3),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                icon: isProcessing
                    ? const SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.check_rounded, size: 16),
                label: Text(
                  isProcessing ? 'Processing...' : 'Approve & Link Record',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDate(String iso) {
    if (iso.isEmpty) return 'Recent';
    try {
      final dt = DateTime.parse(iso).toLocal();
      return '${dt.day}/${dt.month}/${dt.year} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return iso;
    }
  }
}
