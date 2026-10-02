import '../../enums/domain_enums.dart';
import '../../models/prescription_model.dart';
import '../../models/report_model.dart';
import '../../queries/domain_queries.dart';

abstract class PrescriptionRepository {
  Future<List<PrescriptionIndex>> getPrescriptions({PrescriptionQuery query = const PrescriptionQuery()});
  Future<PrescriptionIndex?> getPrescriptionById(String id);
  Future<List<PrescriptionIndex>> getPatientPrescriptions(String patientId);
  Future<List<PrescriptionIndex>> getDoctorPrescriptions(String doctorId);
  Future<List<DocumentActivity>> getPrescriptionHistory(String prescriptionId);
  Future<PharmacyFulfillmentStatus> getFulfillmentStatus(String prescriptionId);
  Future<PrescriptionIndex> createPrescription(PrescriptionIndex prescription);
  Future<PrescriptionIndex> updateFulfillmentStatus(String prescriptionId, PharmacyFulfillmentStatus status);
  Future<void> cancelPrescription(String prescriptionId);

  // Legacy compatibility methods
  Future<List<PrescriptionRecordItem>> getPrescriptionsList();
  Future<List<PrescriptionRecordItem>> getPrescriptionsByPatient(String patientId);
  Future<PrescriptionRecordItem> createPrescriptionRecord(PrescriptionRecordItem prescription);
}
