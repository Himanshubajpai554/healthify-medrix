import '../data/repositories/report_repository.dart';
import '../models/report_model.dart';
import '../queries/domain_queries.dart';

class ReportService {
  final ReportRepository reportRepository;

  ReportService({required this.reportRepository});

  Future<List<DiagnosticReport>> getReports({ReportQuery query = const ReportQuery()}) async {
    return await reportRepository.getReports(query: query);
  }

  Future<DiagnosticReport?> getReportById(String id) async {
    return await reportRepository.getReportById(id);
  }

  Future<DiagnosticReport> uploadReport(DiagnosticReport report) async {
    return await reportRepository.uploadReport(report);
  }

  Future<DiagnosticReport> verifyReport(String reportId, String doctorId) async {
    return await reportRepository.verifyReport(reportId, doctorId);
  }

  Future<DiagnosticReport> rejectReport(String reportId, String doctorId, String reason) async {
    return await reportRepository.rejectReport(reportId, doctorId, reason);
  }

  Future<DiagnosticReport> releaseReportToPatient(String reportId) async {
    return await reportRepository.releaseReportToPatient(reportId);
  }

  Future<List<DiagnosticReport>> getPatientReports(String patientId, {bool releasedOnly = true}) async {
    return await reportRepository.getPatientReports(patientId, releasedOnly: releasedOnly);
  }

  Future<List<DiagnosticReport>> getCriticalReports() async {
    return await reportRepository.getCriticalReports();
  }

  Future<List<DocumentActivity>> getReportActivity(String reportId) async {
    return await reportRepository.getReportActivity(reportId);
  }
}
