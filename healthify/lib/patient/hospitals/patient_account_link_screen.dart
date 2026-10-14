import 'package:flutter/material.dart';

import '../../core/provider/repository_provider.dart';
import '../../core/queries/domain_queries.dart' as queries;

class PatientAccountLinkScreen extends StatefulWidget {
  const PatientAccountLinkScreen({super.key});

  @override
  State<PatientAccountLinkScreen> createState() =>
      _PatientAccountLinkScreenState();
}

class _PatientAccountLinkScreenState extends State<PatientAccountLinkScreen> {
  static const _teal = Color(0xFF0D9488);
  final _patientId = TextEditingController();
  List<Map<String, dynamic>> _hospitals = const [];
  List<Map<String, dynamic>> _requests = const [];
  List<Map<String, dynamic>> _links = const [];
  String? _hospitalKey;
  bool _loading = true;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _patientId.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final results = await Future.wait([
        RepositoryContainer.instance.patientDiscoveryRepository.searchHospitals(
          const queries.HospitalSearchQuery(pageSize: 100),
        ),
        RepositoryContainer.instance.patientPortalRepository!
            .listHospitalAccountLinks(),
        RepositoryContainer.instance.patientPortalRepository!
            .listHospitalAccountLinkRequests(),
      ]);
      if (!mounted) return;
      setState(() {
        _hospitals = (results[0] as List)
            .map((hospital) => {'id': hospital.id, 'name': hospital.name})
            .toList();
        _links = results[1] as List<Map<String, dynamic>>;
        _requests = results[2] as List<Map<String, dynamic>>;
        _hospitalKey ??= _hospitals.isEmpty
            ? null
            : '${_hospitals.first['id']}';
        _loading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Account links could not be loaded: $error')),
      );
    }
  }

  Future<void> _requestLink() async {
    final hospitalKey = _hospitalKey;
    final patientId = _patientId.text.trim();
    if (hospitalKey == null || patientId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Choose a hospital and enter your hospital patient ID.',
          ),
        ),
      );
      return;
    }
    setState(() => _submitting = true);
    try {
      final status = await RepositoryContainer.instance.patientPortalRepository!
          .requestHospitalAccountLink(
            hospitalKey: hospitalKey,
            patientId: patientId,
          );
      if (!mounted) return;
      _patientId.clear();
      await _load();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            status == 'linked'
                ? 'This hospital record is already linked to your account.'
                : 'Request sent. The hospital must verify and approve it.',
          ),
        ),
      );
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not send the link request: $error')),
        );
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  Future<void> _revoke(Map<String, dynamic> link) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Unlink hospital record?'),
        content: const Text(
          'The hospital will no longer be able to share records to this account. Existing hospital-shared reports and prescriptions will be removed from your portal.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Unlink'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await RepositoryContainer.instance.patientPortalRepository!
          .revokeHospitalAccountLink(
            hospitalKey: '${link['hospitalKey']}',
            patientId: '${link['patientId']}',
          );
      await _load();
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not unlink this hospital: $error')),
        );
      }
    }
  }

  String _hospitalName(String key) =>
      _hospitals
          .where((hospital) => hospital['id'] == key)
          .map((hospital) => '${hospital['name']}')
          .firstOrNull ??
      key;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Hospital account links')),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: _teal))
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                const Text(
                  'Connect a hospital record to your Healthify account. The hospital verifies each request before any reports or prescriptions are shared.',
                  style: TextStyle(height: 1.5),
                ),
                const SizedBox(height: 20),
                DropdownButtonFormField<String>(
                  initialValue: _hospitalKey,
                  decoration: const InputDecoration(
                    labelText: 'Hospital',
                    border: OutlineInputBorder(),
                  ),
                  items: _hospitals
                      .map(
                        (hospital) => DropdownMenuItem(
                          value: '${hospital['id']}',
                          child: Text(
                            '${hospital['name']}',
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (value) => setState(() => _hospitalKey = value),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _patientId,
                  textCapitalization: TextCapitalization.characters,
                  decoration: const InputDecoration(
                    labelText: 'Hospital patient ID / MRN',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.badge_outlined),
                  ),
                ),
                const SizedBox(height: 12),
                FilledButton.icon(
                  onPressed: _submitting || _hospitals.isEmpty
                      ? null
                      : _requestLink,
                  icon: _submitting
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.link),
                  label: const Text('Request account link'),
                  style: FilledButton.styleFrom(backgroundColor: _teal),
                ),
                const SizedBox(height: 28),
                Text(
                  'Approved links',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                if (_links.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Text('No hospital accounts are linked yet.'),
                  ),
                ..._links.map(
                  (link) => Card(
                    child: ListTile(
                      leading: const Icon(
                        Icons.verified_user_outlined,
                        color: _teal,
                      ),
                      title: Text(_hospitalName('${link['hospitalKey']}')),
                      subtitle: Text('Patient ID: ${link['patientId']}'),
                      trailing: TextButton(
                        onPressed: () => _revoke(link),
                        child: const Text('Unlink'),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text('Requests', style: Theme.of(context).textTheme.titleLarge),
                if (_requests.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Text('No account-link requests.'),
                  ),
                ..._requests.map(
                  (request) => Card(
                    child: ListTile(
                      leading: Icon(
                        request['status'] == 'approved'
                            ? Icons.check_circle_outline
                            : request['status'] == 'rejected'
                            ? Icons.cancel_outlined
                            : Icons.hourglass_top,
                        color: _teal,
                      ),
                      title: Text(_hospitalName('${request['hospitalKey']}')),
                      subtitle: Text(
                        'Patient ID: ${request['patientId']} • ${request['status']}',
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
