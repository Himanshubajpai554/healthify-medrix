import 'dart:ui';

import 'package:flutter/material.dart';
import '../../shared/widgets/animated_pulse_background.dart';
import '../../theme/app_theme.dart';
import '../models/patient_portal_models.dart';
import './share_report_modal.dart';

class PatientReportDetailScreen extends StatefulWidget {
final MedicalReport report;
final Function(MedicalReport updatedReport)? onReportUpdated;
final Future<void> Function(String reportId)? onDownloadReport;

const PatientReportDetailScreen({
super.key,
required this.report,
this.onReportUpdated,
this.onDownloadReport,
});

@override
State<PatientReportDetailScreen> createState() => _PatientReportDetailScreenState();
}

class _PatientReportDetailScreenState extends State<PatientReportDetailScreen> with SingleTickerProviderStateMixin {
late MedicalReport _report;
late TabController _tabController;
bool _isDownloading = false;
double _zoomLevel = 1.0;


// ─────────────────────────────────────────────────────────────
// HEALTHIFY GLASS THEME — LIGHT + DARK
// ─────────────────────────────────────────────────────────────

static const Color _primary = Color(0xFF0D9488);
static const Color _primaryDark = Color(0xFF0F766E);

Color _surface(bool isDark) =>
isDark
? Colors.white.withValues(alpha: 0.045)
    : Colors.white.withValues(alpha: 0.72);

Color _surfaceStrong(bool isDark) =>
isDark
? Colors.white.withValues(alpha: 0.075)
    : Colors.white.withValues(alpha: 0.90);

Color _border(bool isDark) =>
isDark
? Colors.white.withValues(alpha: 0.085)
    : Colors.white.withValues(alpha: 0.88);

Color _primaryText(bool isDark) =>
isDark ? Colors.white : AppTheme.textPrimary;

Color _secondaryText(bool isDark) =>
isDark
? Colors.white.withValues(alpha: 0.55)
    : AppTheme.textSecondary;

Widget _glassCard({
required bool isDark,
required Widget child,
EdgeInsetsGeometry padding = const EdgeInsets.all(16),
double radius = 22,
Color? accent,
}) {
return ClipRRect(
borderRadius: BorderRadius.circular(radius),
child: BackdropFilter(
filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
child: Container(
padding: padding,
decoration: BoxDecoration(
color: _surface(isDark),
borderRadius: BorderRadius.circular(radius),
border: Border.all(
color: accent != null
? accent.withValues(alpha: isDark ? 0.22 : 0.18)
    : _border(isDark),
),
boxShadow: [
BoxShadow(
color: Colors.black.withValues(
alpha: isDark ? 0.17 : 0.035,
),
blurRadius: 26,
offset: const Offset(0, 10),
),
if (accent != null)
BoxShadow(
color: accent.withValues(
alpha: isDark ? 0.055 : 0.035,
),
blurRadius: 22,
offset: const Offset(0, 5),
),
],
),
child: child,
),
),
);
}



  @override
void initState() {
super.initState();
_report = widget.report;
// Tabs: Document View, Structured Summary, Security & Audit
_tabController = TabController(length: 3, vsync: this);
}

@override
void dispose() {
_tabController.dispose();
super.dispose();
}

Future<void> _triggerDownload() async {
if (!_report.hasAttachedFile || widget.onDownloadReport == null) {
ScaffoldMessenger.of(context).showSnackBar(
const SnackBar(content: Text('This report has no downloadable file.')),
);
return;
}
setState(() => _isDownloading = true);
try {
await widget.onDownloadReport!(_report.id);
} finally {
if (mounted) setState(() => _isDownloading = false);
}
}

void _openShareModal() {
ShareReportModal.show(
context,
report: _report,
onReportUpdated: (updated) {
setState(() => _report = updated);
if (widget.onReportUpdated != null) {
widget.onReportUpdated!(updated);
}
},
);
}

@override
Widget build(BuildContext context) {
final isDark = Theme.of(context).brightness == Brightness.dark;

return Scaffold(
backgroundColor: isDark ? const Color(0xFF061817) : const Color(0xFFF3FAF9),
appBar: AppBar(
backgroundColor: isDark
? const Color(0xFF061817).withValues(alpha: 0.86)
    : Colors.white.withValues(alpha: 0.78),
surfaceTintColor: Colors.transparent,
elevation: 0,
scrolledUnderElevation: 0,
leading: IconButton(
icon: const Icon(Icons.arrow_back_rounded),
onPressed: () => Navigator.pop(context),
),
title: Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
Text(
_report.title,
style: TextStyle(
fontSize: 16,
fontWeight: FontWeight.bold,
color: _primaryText(isDark),
),
overflow: TextOverflow.ellipsis,
),
Text(
'${_report.category} • ${_formatDate(_report.date)}',
style: TextStyle(
fontSize: 11.5,
color: _secondaryText(isDark),
),
),
],
),
actions: [
IconButton(
icon: Icon(Icons.share_outlined, color: _primary),
onPressed: _openShareModal,
tooltip: 'Share Secure Link',
),
IconButton(
icon: Icon(Icons.download_rounded, color: _primary),
onPressed: _isDownloading || !_report.hasAttachedFile ? null : _triggerDownload,
tooltip: 'Download report file',
),
PopupMenuButton<String>(
onSelected: (val) {
if (val == 'share') _openShareModal();
if (val == 'download') _triggerDownload();
if (val == 'print') {
ScaffoldMessenger.of(context).showSnackBar(
const SnackBar(content: Text('Sending document to printer...'), behavior: SnackBarBehavior.floating),
);
}
},
itemBuilder: (context) => const [
PopupMenuItem(value: 'share', child: Row(children: [Icon(Icons.share_outlined, size: 18), SizedBox(width: 10), Text('Share Report')])),
PopupMenuItem(value: 'download', child: Row(children: [Icon(Icons.download_rounded, size: 18), SizedBox(width: 10), Text('Download report file')])),
PopupMenuItem(value: 'print', child: Row(children: [Icon(Icons.print_outlined, size: 18), SizedBox(width: 10), Text('Print Document')])),
],
),
],
bottom: TabBar(
controller: _tabController,
labelColor: isDark ? const Color(0xFF5EEAD4) : _primaryDark,
unselectedLabelColor: _secondaryText(isDark),
indicatorColor: _primary,
dividerColor: _border(isDark),
tabs: const [
Tab(text: '📄 Document View'),
Tab(text: '📊 Structured Summary'),
Tab(text: '🔒 Access & Audit'),
],
),
),
body: AnimatedPulseBackground(
  child: TabBarView(
    controller: _tabController,
    children: [
      _buildDocumentViewerTab(isDark),
      _buildStructuredSummaryTab(isDark),
      _buildAccessAuditTab(isDark),
    ],
  ),
),
bottomNavigationBar: ClipRRect(
borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
child: BackdropFilter(
filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
child: Container(
padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
decoration: BoxDecoration(
color: _surfaceStrong(isDark),
border: Border(
top: BorderSide(color: _border(isDark)),
),
),

child: Row(
children: [
Expanded(
child: OutlinedButton.icon(
onPressed: _openShareModal,
style: OutlinedButton.styleFrom(
foregroundColor: Colors.teal,
side: const BorderSide(color: Colors.teal),
padding: const EdgeInsets.symmetric(vertical: 12),
shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
),
icon: const Icon(Icons.share_outlined, size: 18),
label: const Text('Share Record', style: TextStyle(fontWeight: FontWeight.bold)),
),
),
const SizedBox(width: 12),
Expanded(
child: ElevatedButton.icon(
onPressed: _isDownloading || !_report.hasAttachedFile ? null : _triggerDownload,
style: ElevatedButton.styleFrom(
backgroundColor: Colors.teal,
foregroundColor: Colors.white,
padding: const EdgeInsets.symmetric(vertical: 12),
shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
),
icon: _isDownloading
? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
    : const Icon(Icons.download_rounded, size: 18),
label: Text(_isDownloading ? 'Saving...' : 'Download file', style: const TextStyle(fontWeight: FontWeight.bold)),
),
),
],
),
),
),
),
);
}

// 1. Document Viewer Tab
Widget _buildDocumentViewerTab(bool isDark) {
return SingleChildScrollView(
padding: const EdgeInsets.all(16),
child: Column(
children: [
// Document Controls Bar (Zoom, Page counter, Format badge)
Container(
padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
decoration: BoxDecoration(
color: AppTheme.cardColor,
borderRadius: BorderRadius.circular(12),
border: Border.all(color: AppTheme.borderLight),
),
child: Row(
mainAxisAlignment: MainAxisAlignment.spaceBetween,
children: [
Row(
children: [
Container(
padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
decoration: BoxDecoration(
color: Colors.red.withValues(alpha: 0.15),
borderRadius: BorderRadius.circular(6),
),
child: Text(
_report.fileFormat,
style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Colors.red),
),
),
const SizedBox(width: 8),
Text(_report.fileSize, style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
],
),
Row(
children: [
IconButton(
icon: const Icon(Icons.zoom_out_rounded, size: 20),
onPressed: _zoomLevel > 0.8 ? () => setState(() => _zoomLevel -= 0.1) : null,
),
Text('${(_zoomLevel * 100).toInt()}%', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
IconButton(
icon: const Icon(Icons.zoom_in_rounded, size: 20),
onPressed: _zoomLevel < 1.4 ? () => setState(() => _zoomLevel += 0.1) : null,
),
],
),
const Text('Page 1 of 1', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
],
),
),
const SizedBox(height: 16),

// High-Fidelity Simulated Clinical Document Paper Card
Transform.scale(
scale: _zoomLevel,
child: Container(
width: double.infinity,
padding: const EdgeInsets.all(24),
decoration: BoxDecoration(
color: isDark ? const Color(0xFF102321) : Colors.white, // Clinical paper aesthetic
borderRadius: BorderRadius.circular(8),
boxShadow: [
BoxShadow(
color: Colors.black.withValues(alpha: 0.08),
blurRadius: 16,
offset: const Offset(0, 4),
),
],
),
child: Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
// Hospital Clinical Header Banner
Row(
mainAxisAlignment: MainAxisAlignment.spaceBetween,
crossAxisAlignment: CrossAxisAlignment.start,
children: [
Expanded(
child: Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
Row(
children: [
Container(
padding: const EdgeInsets.all(6),
decoration: BoxDecoration(
color: Colors.teal.shade800,
borderRadius: BorderRadius.circular(6),
),
child: const Icon(Icons.local_hospital_rounded, color: Colors.white, size: 18),
),
const SizedBox(width: 8),
Expanded(
child: Text(
_report.hospitalName.toUpperCase(),
style: TextStyle(
fontSize: 15,
fontWeight: FontWeight.bold,
color: isDark ? const Color(0xFF5EEAD4) : Colors.teal.shade900,
letterSpacing: 0.5,
),
maxLines: 1,
overflow: TextOverflow.ellipsis,
),
),
],
),
const SizedBox(height: 4),
Text(
'Department of Diagnostics & Pathology',
style: TextStyle(fontSize: 11, color: isDark ? Colors.white.withValues(alpha: 0.62) : Colors.grey.shade700, fontWeight: FontWeight.w500),
maxLines: 1,
overflow: TextOverflow.ellipsis,
),
Text(
'NABH & CAP Accredited Clinical Laboratory',
style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
maxLines: 1,
overflow: TextOverflow.ellipsis,
),
],
),
),
const SizedBox(width: 8),
Container(
padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
decoration: BoxDecoration(
border: Border.all(color: Colors.teal.shade700),
borderRadius: BorderRadius.circular(6),
),
child: Text(
'OFFICIAL RECORD',
style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.teal.shade900),
),
),
],
),
const SizedBox(height: 12),
Divider(color: Colors.teal.shade800, thickness: 2),
const SizedBox(height: 12),

// Patient & Report Metadata Grid Box
Container(
padding: const EdgeInsets.all(12),
decoration: BoxDecoration(
color: Colors.grey.shade100,
borderRadius: BorderRadius.circular(6),
border: Border.all(color: Colors.grey.shade300),
),
child: Column(
children: [
Row(
children: [
Expanded(child: _buildDocMetaItem('PATIENT NAME', 'Alex Rivera', isBold: true)),
Expanded(child: _buildDocMetaItem('AGE / GENDER', '32 Yrs / Male')),
Expanded(child: _buildDocMetaItem('PATIENT ID', 'PAT-8842')),
],
),
const SizedBox(height: 8),
Row(
children: [
Expanded(child: _buildDocMetaItem('ORDERING DOCTOR', _report.doctorName)),
Expanded(child: _buildDocMetaItem('REPORT DATE', _formatDate(_report.date))),
Expanded(child: _buildDocMetaItem('DOCUMENT ID', _report.id)),
],
),
],
),
),

const SizedBox(height: 20),

// Document Title & Summary Body
Text(
_report.title,
style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.grey.shade900),
),
const SizedBox(height: 8),
Text(
_report.summary,
style: TextStyle(fontSize: 13.5, color: Colors.grey.shade800, height: 1.5),
),

const SizedBox(height: 20),

// Simulated Laboratory Parameters Table (if available)
if (_report.parameters.isNotEmpty) ...[
Text(
'CLINICAL TEST RESULTS',
style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: isDark ? const Color(0xFF5EEAD4) : Colors.teal.shade900, letterSpacing: 0.5),
),
const SizedBox(height: 8),
Table(
border: TableBorder.all(color: isDark ? Colors.white.withValues(alpha: 0.12) : Colors.grey.shade300),
columnWidths: const {
0: FlexColumnWidth(2.5),
1: FlexColumnWidth(1.5),
2: FlexColumnWidth(2.0),
},
children: [
TableRow(
decoration: BoxDecoration(color: isDark ? _primary.withValues(alpha: 0.12) : Colors.teal.shade50),
children: [
_buildTableCell('Test Parameter', isHeader: true),
_buildTableCell('Result Value', isHeader: true),
_buildTableCell('Reference Range', isHeader: true),
],
),
..._report.parameters.map((param) => TableRow(
children: [
_buildTableCell(param.name),
_buildTableCell(
'${param.value} ${param.unit}',
textColor: param.isNormal ? Colors.black : Colors.orange.shade900,
isBold: !param.isNormal,
),
_buildTableCell(param.normalRange.isEmpty ? '—' : param.normalRange),
],
)),
],
),
const SizedBox(height: 20),
],

// Digital Signature & Watermark Footer
Row(
mainAxisAlignment: MainAxisAlignment.spaceBetween,
children: [
Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
Icon(Icons.verified_rounded, color: isDark ? const Color(0xFF5EEAD4) : Colors.teal.shade700, size: 28),
const SizedBox(height: 4),
Text(
'Digitally Signed by Medrix Vault',
style: TextStyle(fontSize: 10, color: isDark ? Colors.white.withValues(alpha: 0.48) : Colors.grey.shade600, fontWeight: FontWeight.w600),
),
],
),
Column(
crossAxisAlignment: CrossAxisAlignment.end,
children: [
Text(
'Approved by:',
style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
),
const SizedBox(height: 2),
Text(
_report.doctorName,
style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.teal.shade900),
),
Text(
'Consultant Pathologist',
style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
),
],
),
],
),
],
),
),
),
const SizedBox(height: 24),
],
),
);
}

// 2. Structured Summary Tab
Widget _buildStructuredSummaryTab(bool isDark) {
return SingleChildScrollView(
padding: const EdgeInsets.all(20),
child: Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
// Medical Disclaimer Banner
_glassCard(
isDark: isDark,
accent: Colors.blue,
padding: const EdgeInsets.all(14),
radius: 16,
child: Row(
children: [
Icon(Icons.info_outline_rounded, color: Colors.blue, size: 20),
SizedBox(width: 12),
Expanded(
child: Text(
'Values outside reference range do not imply a medical diagnosis. The original report document remains the authoritative source. Consult your attending physician.',
style: TextStyle(fontSize: 12, color: AppTheme.textSecondary, height: 1.4),
),
),
],
),
),

const SizedBox(height: 20),
Text(
'Structured Results for ${_report.title}',
style: TextStyle(
fontSize: 16,
fontWeight: FontWeight.bold,
color: _primaryText(isDark),
),
),
const SizedBox(height: 12),

if (_report.parameters.isEmpty) ...[
_glassCard(
isDark: isDark,
radius: 18,
padding: const EdgeInsets.all(24),
child: Center(
child: Column(
children: const [
Icon(Icons.article_outlined, color: AppTheme.textMuted, size: 40),
SizedBox(height: 10),
Text(
'No tabular values detected in this record',
style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
),
SizedBox(height: 4),
Text(
'Please view the "Document View" tab to read full clinical notes.',
style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
),
],
),
),
),
] else ...[
..._report.parameters.map((param) => _buildParameterCard(param)),
],
],
),
);
}

// 3. Access & Security Audit Tab
Widget _buildAccessAuditTab(bool isDark) {
return SingleChildScrollView(
padding: const EdgeInsets.all(20),
child: Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
// Security Status Card
_glassCard(
isDark: isDark,
accent: _primary,
radius: 18,
child: Row(
children: [
Container(
padding: const EdgeInsets.all(12),
decoration: BoxDecoration(
color: Colors.teal.withValues(alpha: 0.15),
shape: BoxShape.circle,
),
child: const Icon(Icons.shield_outlined, color: Colors.teal, size: 24),
),
const SizedBox(width: 14),
Expanded(
child: Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
Text(
'End-to-End Encrypted',
style: TextStyle(
fontWeight: FontWeight.bold,
fontSize: 15,
color: _primaryText(isDark),
),
),
const SizedBox(height: 2),
Text(
'Stored securely under Medrix Health Vault with HIPAA & GDPR compliance standards.',
style: TextStyle(
fontSize: 12,
color: _secondaryText(isDark),
),
),
],
),
),
],
),
),

const SizedBox(height: 24),
Text('Document Access History', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: _primaryText(isDark))),
const SizedBox(height: 12),

if (_report.accessLogs.isEmpty) ...[
Text('No access history logged yet.', style: TextStyle(color: _secondaryText(isDark))),
] else ...[
..._report.accessLogs.map((log) => Container(
margin: const EdgeInsets.only(bottom: 10),
padding: const EdgeInsets.all(14),
decoration: BoxDecoration(
color: _surface(isDark),
borderRadius: BorderRadius.circular(16),
border: Border.all(color: _border(isDark)),
boxShadow: [
BoxShadow(
color: Colors.black.withValues(
alpha: isDark ? 0.10 : 0.025,
),
blurRadius: 18,
offset: const Offset(0, 7),
),
],
),
child: Row(
children: [
const CircleAvatar(
radius: 18,
backgroundColor: Colors.teal,
child: Icon(Icons.visibility_rounded, color: Colors.white, size: 18),
),
const SizedBox(width: 12),
Expanded(
child: Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
Text(
'${log.viewerName} (${log.viewerRole})',
style: TextStyle(
fontWeight: FontWeight.bold,
fontSize: 13.5,
color: _primaryText(isDark),
),
),
const SizedBox(height: 2),
Text(
log.action,
style: TextStyle(
fontSize: 12,
color: _secondaryText(isDark),
),
),
],
),
),
Text(
_formatDate(log.timestamp),
style: TextStyle(
fontSize: 11,
color: _secondaryText(isDark),
fontWeight: FontWeight.w600,
),
),
],
),
)),
],
],
),
);
}

Widget _buildParameterCard(ReportParameter param) {
final isDark = Theme.of(context).brightness == Brightness.dark;
return Container(
margin: const EdgeInsets.only(bottom: 12),
padding: const EdgeInsets.all(16),
decoration: BoxDecoration(
color: _surface(isDark),
borderRadius: BorderRadius.circular(18),
border: Border.all(
color: param.isNormal
? _border(isDark)
    : Colors.orange.withValues(alpha: 0.5),
),
boxShadow: [
BoxShadow(
color: Colors.black.withValues(
alpha: isDark ? 0.10 : 0.025,
),
blurRadius: 18,
offset: const Offset(0, 7),
),
],
),
child: Row(
mainAxisAlignment: MainAxisAlignment.spaceBetween,
children: [
Expanded(
child: Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
Text(
param.name,
style: TextStyle(
fontWeight: FontWeight.bold,
fontSize: 15,
color: _primaryText(isDark),
),
),
const SizedBox(height: 4),
Text(
'Normal range: ${param.normalRange.isEmpty ? 'N/A' : param.normalRange}',
style: TextStyle(
fontSize: 12,
color: _secondaryText(isDark),
),
),
],
),
),
Column(
crossAxisAlignment: CrossAxisAlignment.end,
children: [
Text(
'${param.value} ${param.unit}',
style: TextStyle(
fontSize: 16,
fontWeight: FontWeight.bold,
color: param.isNormal ? _primaryText(isDark) : Colors.orange.shade800,
),
),
const SizedBox(height: 4),
Container(
padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
decoration: BoxDecoration(
color: param.isNormal ? Colors.teal.withValues(alpha: 0.12) : Colors.orange.withValues(alpha: 0.15),
borderRadius: BorderRadius.circular(6),
),
child: Text(
param.isNormal ? 'Normal range' : 'Outside reference range',
style: TextStyle(
fontSize: 11,
fontWeight: FontWeight.bold,
color: param.isNormal ? Colors.teal : Colors.orange.shade900,
),
),
),
],
),
],
),
);
}

Widget _buildDocMetaItem(String label, String value, {bool isBold = false, bool isDark = false}) {
return Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
Text(label, style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.grey.shade600)),
const SizedBox(height: 2),
Text(
value,
style: TextStyle(fontSize: 11, fontWeight: isBold ? FontWeight.bold : FontWeight.w500, color: isDark ? Colors.white : Colors.grey.shade900),
overflow: TextOverflow.ellipsis,
),
],
);
}

Widget _buildTableCell(String text, {bool isHeader = false, Color? textColor, bool isBold = false}) {
return Padding(
padding: const EdgeInsets.all(8.0),
child: Text(
text,
style: TextStyle(
fontSize: isHeader ? 10.5 : 11,
fontWeight: isHeader || isBold ? FontWeight.bold : FontWeight.normal,
color: textColor ?? (isHeader ? Colors.teal.shade900 : Colors.black),
),
),
);
}

String _formatDate(DateTime date) {
const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
return '${date.day} ${months[date.month - 1]} ${date.year}';
}
}
