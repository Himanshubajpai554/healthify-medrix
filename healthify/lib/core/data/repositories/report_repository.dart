import '../../models/report_model.dart';
import '../../queries/domain_queries.dart';

abstract class ReportRepository {
  Future<List<DiagnosticReport>> getReports({ReportQuery query = const ReportQuery()});
  Future<DiagnosticReport?> getReportById(String id);
  Future<DiagnosticReport> uploadReport(DiagnosticReport report);
  Future<DiagnosticReport> updateReportMetadata(String reportId, Map<String, dynamic> metadata);
  Future<DiagnosticReport> verifyReport(String reportId, String doctorId);
  Future<DiagnosticReport> rejectReport(String reportId, String doctorId, String reason);
  Future<DiagnosticReport> releaseReportToPatient(String reportId);
  Future<List<DiagnosticReport>> getPatientReports(String patientId, {bool releasedOnly = true});
  Future<List<DiagnosticReport>> getCriticalReports();
  Future<List<DocumentActivity>> getReportActivity(String reportId);

  // Legacy compatibility methods
  Future<List<DiagnosticReportItem>> getReportsList();
  Future<List<DiagnosticReportItem>> getReportsByPatient(String patientId);
  Future<DiagnosticReportItem> uploadReportItem(DiagnosticReportItem report);
  Future<void> updateReportStatus(String reportId, DiagnosticReportStatus status);
}
