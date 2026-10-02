import '../enums/domain_enums.dart';
import '../data/repositories/prescription_repository.dart';
import '../models/prescription_model.dart';
import '../models/report_model.dart';
import '../queries/domain_queries.dart';

class PrescriptionService {
  final PrescriptionRepository prescriptionRepository;

  PrescriptionService({required this.prescriptionRepository});

  Future<List<PrescriptionIndex>> getPrescriptions({PrescriptionQuery query = const PrescriptionQuery()}) async {
    return await prescriptionRepository.getPrescriptions(query: query);
  }

  Future<PrescriptionIndex?> getPrescriptionById(String id) async {
    return await prescriptionRepository.getPrescriptionById(id);
  }

  Future<List<PrescriptionIndex>> getPatientPrescriptions(String patientId) async {
    return await prescriptionRepository.getPatientPrescriptions(patientId);
  }

  Future<List<PrescriptionIndex>> getDoctorPrescriptions(String doctorId) async {
    return await prescriptionRepository.getDoctorPrescriptions(doctorId);
  }

  Future<List<DocumentActivity>> getPrescriptionHistory(String prescriptionId) async {
    return await prescriptionRepository.getPrescriptionHistory(prescriptionId);
  }

  Future<PharmacyFulfillmentStatus> getFulfillmentStatus(String prescriptionId) async {
    return await prescriptionRepository.getFulfillmentStatus(prescriptionId);
  }

  Future<PrescriptionIndex> createPrescription(PrescriptionIndex prescription) async {
    return await prescriptionRepository.createPrescription(prescription);
  }

  Future<PrescriptionIndex> updateFulfillmentStatus(String prescriptionId, PharmacyFulfillmentStatus status) async {
    return await prescriptionRepository.updateFulfillmentStatus(prescriptionId, status);
  }

  Future<void> cancelPrescription(String prescriptionId) async {
    await prescriptionRepository.cancelPrescription(prescriptionId);
  }
}
