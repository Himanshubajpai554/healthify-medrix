import 'package:flutter/material.dart';
import '../../../shared/widgets/glass_components.dart';
import '../../models/prescription_models.dart';

class PrescriptionPrintModal extends StatelessWidget {
  final DoctorPrescriptionFullModel prescription;

  const PrescriptionPrintModal({
    super.key,
    required this.prescription,
  });

  static String formatDate(DateTime dt) {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${dt.day.toString().padLeft(2, '0')} ${months[dt.month - 1]} ${dt.year}';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = HealthifyGlassTheme.isDarkMode(context);

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: 720,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: isDark ? HealthifyGlassTheme.darkBackground : Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Controls
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Printable Document Preview',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: HealthifyGlassTheme.getTextPrimary(isDark),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Divider(height: 1),
              const SizedBox(height: 16),

              // Printable Document Sheet Page
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.black12),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Hospital & Doctor Header
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.local_hospital_rounded, size: 40, color: Color(0xFF0D9488)),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'MEDRIX CENTRAL HOSPITAL',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w900,
                                  color: Color(0xFF0D9488),
                                  letterSpacing: 0.8,
                                ),
                              ),
                              Text(
                                '104 Healthcare Boulevard, Medical District • Tel: +91 1800-MEDRIX',
                                style: TextStyle(fontSize: 11, color: Colors.black54),
                              ),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              prescription.doctorName,
                              style: const TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            Text(
                              prescription.doctorQualification,
                              style: const TextStyle(fontSize: 11, color: Colors.black54),
                            ),
                            Text(
                              'Reg: ${prescription.registrationNumber}',
                              style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: Colors.teal),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    const Divider(color: Color(0xFF0D9488), thickness: 2),
                    const SizedBox(height: 14),

                    // Patient Meta Box
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('PATIENT: ${prescription.patientName}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black87)),
                              Text('ID: ${prescription.patientId} • AGE: ${prescription.patientAge}y • GENDER: ${prescription.patientGender}', style: const TextStyle(fontSize: 11.5, color: Colors.black87)),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text('DATE: ${formatDate(prescription.date)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.black87)),
                              Text('BLOOD GROUP: ${prescription.bloodGroup}', style: const TextStyle(fontSize: 11.5, color: Colors.black87)),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Allergy Notice if present
                    if (prescription.allergies.isNotEmpty) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: Colors.red.shade200),
                        ),
                        child: Text(
                          'ALLERGIES NOTED: ${prescription.allergies.join(", ")}',
                          style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: Colors.red.shade800),
                        ),
                      ),
                      const SizedBox(height: 14),
                    ],

                    // Rx symbol & Medicine Table
                    const Row(
                      children: [
                        Text('Rx', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, fontFamily: 'serif', color: Color(0xFF0D9488))),
                        SizedBox(width: 8),
                        Text('MEDICATION ORDER', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 1.0, color: Colors.black54)),
                      ],
                    ),
                    const SizedBox(height: 8),

                    Table(
                      columnWidths: const {
                        0: FlexColumnWidth(2.5),
                        1: FlexColumnWidth(1.2),
                        2: FlexColumnWidth(1.5),
                        3: FlexColumnWidth(1.2),
                        4: FlexColumnWidth(1.2),
                        5: FlexColumnWidth(2.2),
                      },
                      children: [
                        TableRow(
                          decoration: BoxDecoration(color: Colors.grey.shade100),
                          children: const [
                            Padding(padding: EdgeInsets.all(6), child: Text('MEDICINE', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11))),
                            Padding(padding: EdgeInsets.all(6), child: Text('DOSAGE', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11))),
                            Padding(padding: EdgeInsets.all(6), child: Text('FREQUENCY', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11))),
                            Padding(padding: EdgeInsets.all(6), child: Text('ROUTE', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11))),
                            Padding(padding: EdgeInsets.all(6), child: Text('DURATION', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11))),
                            Padding(padding: EdgeInsets.all(6), child: Text('INSTRUCTIONS', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11))),
                          ],
                        ),
                        ...prescription.medicines.map(
                          (m) => TableRow(
                            children: [
                              Padding(padding: const EdgeInsets.all(6), child: Text(m.medicineName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.black87))),
                              Padding(padding: const EdgeInsets.all(6), child: Text(m.dosage, style: const TextStyle(fontSize: 11.5, color: Colors.black87))),
                              Padding(padding: const EdgeInsets.all(6), child: Text(m.frequency, style: const TextStyle(fontSize: 11.5, color: Colors.black87))),
                              Padding(padding: const EdgeInsets.all(6), child: Text(m.route, style: const TextStyle(fontSize: 11.5, color: Colors.black87))),
                              Padding(padding: const EdgeInsets.all(6), child: Text(m.duration, style: const TextStyle(fontSize: 11.5, color: Colors.black87))),
                              Padding(padding: const EdgeInsets.all(6), child: Text(m.instructions, style: const TextStyle(fontSize: 11.5, color: Colors.black87))),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // General Instructions
                    const Text('ADVICE / INSTRUCTIONS:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Colors.black54)),
                    const SizedBox(height: 4),
                    Text(
                      prescription.generalInstructions.isEmpty
                          ? 'Continue prescribed medication as instructed.'
                          : prescription.generalInstructions,
                      style: const TextStyle(fontSize: 12, color: Colors.black87, height: 1.4),
                    ),
                    const SizedBox(height: 30),

                    // Doctor Signature Area
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('Prescription ID: ${prescription.id}', style: const TextStyle(fontSize: 10, color: Colors.black45)),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              width: 140,
                              height: 1,
                              color: Colors.black45,
                            ),
                            const SizedBox(height: 4),
                            Text(prescription.doctorName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.black87)),
                            const Text('Digitally Signed Doctor Sign-off', style: TextStyle(fontSize: 10, color: Colors.black54)),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Close'),
                  ),
                  const SizedBox(width: 12),
                  GlassPrimaryButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Sending document to printer...')),
                      );
                      Navigator.pop(context);
                    },
                    height: 42,
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.print_rounded, size: 18),
                        SizedBox(width: 6),
                        Text('Print Document', style: TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
