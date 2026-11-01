import 'dart:async';
import '../models/doctor_help_models.dart';

class DoctorHelpService {
  static final DoctorHelpService _instance = DoctorHelpService._internal();

  factory DoctorHelpService() {
    return _instance;
  }

  DoctorHelpService._internal() {
    _initSampleData();
  }

  final List<HelpArticleModel> _articles = [];
  final List<SupportTicketModel> _tickets = [];
  late HospitalAdminContactModel _adminContact;
  final List<SystemServiceStatus> _systemServices = [];
  final List<TroubleshootingGuideModel> _troubleshootingGuides = [];

  void _initSampleData() {
    final now = DateTime.now();

    _articles.addAll([
      HelpArticleModel(
        id: 'ART-101',
        title: 'How to Start a Consultation',
        category: HelpArticleCategory.consultations,
        shortDescription: 'Step-by-step guide to launch patient consultation workspace.',
        contentSteps: [
          'Open the Appointments or Doctor Dashboard screen.',
          'Locate the scheduled patient appointment in your queue.',
          'Review the pre-consultation vitals and medical record summary.',
          'Select [Start Consultation] to launch the clinical consultation workspace.',
          'Record chief complaints, diagnosis notes, clinical observations, and prescriptions.',
          'Review all entered clinical data and tap [Complete Consultation] to finalize.',
        ],
        lastUpdated: now.subtract(const Duration(days: 5)),
        helpfulCount: 142,
        isPopular: true,
      ),
      HelpArticleModel(
        id: 'ART-102',
        title: 'How to Access Patient Medical Records',
        category: HelpArticleCategory.patients,
        shortDescription: 'Searching and reviewing complete patient EHR history.',
        contentSteps: [
          'Navigate to My Patients or Medical Records from the sidebar.',
          'Search for the patient using full name, phone number, or Patient ID (e.g. P-1002).',
          'Tap [View Medical Record] or select the patient row to open the profile workspace.',
          'Use tabs to switch between Overview, Medical History, Lab Reports, Prescriptions, and Consultation Notes.',
        ],
        lastUpdated: now.subtract(const Duration(days: 12)),
        helpfulCount: 98,
        isPopular: true,
      ),
      HelpArticleModel(
        id: 'ART-103',
        title: 'How to Create & Sign a Prescription',
        category: HelpArticleCategory.prescriptions,
        shortDescription: 'Prescribing medications with dosage and refill instructions.',
        contentSteps: [
          'Open the Prescriptions workspace or click [Create Prescription] during a consultation.',
          'Select or confirm the target patient.',
          'Search for required medications in the drug database.',
          'Specify dosage (e.g. 500mg), frequency (e.g. Twice daily), duration, and food timing.',
          'Add allergy check verification and special administration instructions.',
          'Tap [Issue & Sign Prescription] to digitally sign and send to pharmacy.',
        ],
        lastUpdated: now.subtract(const Duration(days: 3)),
        helpfulCount: 185,
        isPopular: true,
      ),
      HelpArticleModel(
        id: 'ART-104',
        title: 'How to Mark a Report as Reviewed',
        category: HelpArticleCategory.reports,
        shortDescription: 'Filtering pending diagnostic reports and adding clinical signatures.',
        contentSteps: [
          'Open the Reports workspace from the main navigation sidebar.',
          'Filter by [Pending Review] status or search by report title/patient ID.',
          'Tap on a report row to view DICOM imaging or lab summary details.',
          'Review lab values against reference ranges and inspect attached PDF documents.',
          'Add physician clinical notes and tap [Mark as Reviewed].',
        ],
        lastUpdated: now.subtract(const Duration(days: 7)),
        helpfulCount: 76,
      ),
      HelpArticleModel(
        id: 'ART-105',
        title: 'How to Update OPD Availability Schedule',
        category: HelpArticleCategory.availability,
        shortDescription: 'Configuring weekly practice hours and availability exceptions.',
        contentSteps: [
          'Open Settings -> Availability & Schedule.',
          'Toggle your real-time status between Available and Offline.',
          'Click [Edit Schedule] to modify OPD time slots for each weekday.',
          'Use [Add Exception] to log leave dates, holidays, or conference periods.',
        ],
        lastUpdated: now.subtract(const Duration(days: 10)),
        helpfulCount: 110,
        isPopular: true,
      ),
      HelpArticleModel(
        id: 'ART-106',
        title: 'How to Manage Patient Follow-ups',
        category: HelpArticleCategory.followups,
        shortDescription: 'Tracking upcoming, due, and overdue follow-up consultations.',
        contentSteps: [
          'Navigate to Patient Follow-ups workspace.',
          'View metric cards for Due Today, Upcoming, and Overdue follow-ups.',
          'Select a follow-up card to view recovery progress notes and original consultation history.',
          'Click [Schedule Follow-up] or [Mark Complete] after contacting the patient.',
        ],
        lastUpdated: now.subtract(const Duration(days: 4)),
        helpfulCount: 64,
      ),
      HelpArticleModel(
        id: 'ART-107',
        title: 'How to Handle Emergency Case Assignments',
        category: HelpArticleCategory.emergency,
        shortDescription: 'Responding to critical ER triage notifications.',
        contentSteps: [
          'When an ER assignment alert arrives, tap [Open Case] or navigate to Emergency Cases.',
          'Review the ER Bay location, chief complaint, and triage priority badge.',
          'Inspect vital signs and STAT lab results in the emergency banner.',
          'Click [Accept & Initiate Care] or reassign to another specialist if off-duty.',
        ],
        lastUpdated: now.subtract(const Duration(days: 2)),
        helpfulCount: 156,
        isPopular: true,
      ),
      HelpArticleModel(
        id: 'ART-108',
        title: 'How to Change Your Password',
        category: HelpArticleCategory.security,
        shortDescription: 'Updating login credentials and workspace security.',
        contentSteps: [
          'Navigate to Settings -> Security & Sessions.',
          'Enter your Current Password in the password form.',
          'Type your New Password (minimum 8 characters with strength validation).',
          'Confirm the new password and tap [Change Password].',
        ],
        lastUpdated: now.subtract(const Duration(days: 15)),
        helpfulCount: 88,
      ),
      HelpArticleModel(
        id: 'ART-109',
        title: 'How to Manage Notification Preferences',
        category: HelpArticleCategory.notifications,
        shortDescription: 'Customizing in-app, push, and email alert channels.',
        contentSteps: [
          'Navigate to Notifications -> Preferences (or Settings -> Notifications).',
          'Toggle alert channels (In-App Alert, Push Mobile, Email Digest) per category.',
          'Click [Save Preferences] to apply changes across device sessions.',
        ],
        lastUpdated: now.subtract(const Duration(days: 8)),
        helpfulCount: 52,
      ),
      HelpArticleModel(
        id: 'ART-110',
        title: 'How to Contact Hospital Administration',
        category: HelpArticleCategory.security,
        shortDescription: 'Reaching IT desk and medical board operations.',
        contentSteps: [
          'Navigate to Help & Support -> Contact Hospital Administrator.',
          'Review the IT & Operations Director contact info and office hours.',
          'Tap [Contact Hospital Admin] to initiate direct communication or submit a support ticket.',
        ],
        lastUpdated: now.subtract(const Duration(days: 20)),
        helpfulCount: 45,
      ),
    ]);

    _tickets.addAll([
      SupportTicketModel(
        id: 'MED-SUP-2026-00842',
        subject: 'Reports page failing to load DICOM study previews',
        category: 'Reports',
        priority: SupportTicketPriority.important,
        status: SupportTicketStatus.inProgress,
        createdDate: now.subtract(const Duration(hours: 5)),
        lastUpdated: now.subtract(const Duration(hours: 1)),
        messages: [
          TicketMessageModel(
            id: 'MSG-01',
            senderName: 'Dr. Arjun Mehta',
            isDoctor: true,
            timestamp: now.subtract(const Duration(hours: 5)),
            messageText:
                'The DICOM imaging viewer on the Reports workspace hangs on loading state when opening 2D Echocardiograms for Patient ID P-1005.',
          ),
          TicketMessageModel(
            id: 'MSG-02',
            senderName: 'Healthify IT Operations (Rajesh Varma)',
            isDoctor: false,
            timestamp: now.subtract(const Duration(hours: 1)),
            messageText:
                'Hello Dr. Mehta, we are investigating PACS server gateway latency in Cardiology Wing. A patch is being deployed shortly.',
          ),
        ],
        attachments: ['screenshot_dicom_error.png'],
      ),
      SupportTicketModel(
        id: 'MED-SUP-2026-00831',
        subject: 'Appointment availability schedule sync delay',
        category: 'Appointments',
        priority: SupportTicketPriority.normal,
        status: SupportTicketStatus.resolved,
        createdDate: now.subtract(const Duration(days: 3)),
        lastUpdated: now.subtract(const Duration(days: 1)),
        messages: [
          TicketMessageModel(
            id: 'MSG-10',
            senderName: 'Dr. Arjun Mehta',
            isDoctor: true,
            timestamp: now.subtract(const Duration(days: 3)),
            messageText:
                'My OPD availability block for Thursday morning was not reflecting on the reception desk booking queue.',
          ),
          TicketMessageModel(
            id: 'MSG-11',
            senderName: 'Healthify Support Specialist',
            isDoctor: false,
            timestamp: now.subtract(const Duration(days: 1)),
            messageText:
                'The appointment cache has been cleared and your Thursday OPD slots are now synchronized across all booking terminals.',
          ),
        ],
      ),
    ]);

    _adminContact = const HospitalAdminContactModel(
      hospitalName: 'Healthify City Hospital & Research Center',
      adminName: 'Mr. Rajesh Varma',
      role: 'IT & Operations Director',
      department: 'Hospital Medical Informatics & Systems Desk',
      phone: '+91 22 6789 4400 (Ext: 4401)',
      email: 'rajesh.varma@healthifycity.org',
      officeHours: 'Mon - Sat: 08:00 AM - 08:00 PM IST',
    );

    _systemServices.addAll([
      const SystemServiceStatus(
        serviceName: 'Authentication & Provider Sign-in',
        status: 'Operational',
        statusDetails: 'All authentication nodes and session engines functioning normally.',
      ),
      const SystemServiceStatus(
        serviceName: 'Appointments & Scheduling Queue',
        status: 'Operational',
        statusDetails: 'Real-time booking and queue synchronization operational.',
      ),
      const SystemServiceStatus(
        serviceName: 'Patient Health Records & EHR API',
        status: 'Operational',
        statusDetails: 'Medical records access and search functioning with 14ms latency.',
      ),
      const SystemServiceStatus(
        serviceName: 'Diagnostic Reports & PACS Gateway',
        status: 'Degraded',
        statusDetails: 'DICOM imaging study previews experiencing minor gateway latency.',
      ),
      const SystemServiceStatus(
        serviceName: 'Notifications & ER Triage Pipeline',
        status: 'Operational',
        statusDetails: 'Real-time alert dispatch running with 0 message backlog.',
      ),
      const SystemServiceStatus(
        serviceName: 'Serverpod Backend Infrastructure',
        status: 'Operational',
        statusDetails: 'Cluster status clean with 99.98% uptime.',
      ),
    ]);

    _troubleshootingGuides.addAll([
      const TroubleshootingGuideModel(
        id: 'TB-01',
        title: 'Application is loading slowly or freezing',
        possibleCauses: [
          'High network latency or temporary hospital Wi-Fi packet drop.',
          'Large DICOM image files downloading concurrently.',
          'Outdated browser cache or active session data.',
        ],
        recommendedSteps: [
          'Verify your connection to the secure Healthify Hospital Wi-Fi network.',
          'Clear local browser cache (Ctrl + Shift + R or Cmd + Shift + R).',
          'Sign out of your workspace session and sign back in.',
        ],
      ),
      const TroubleshootingGuideModel(
        id: 'TB-02',
        title: 'Notifications or ER alerts are not appearing',
        possibleCauses: [
          'Real-time notification channel disabled in workspace preferences.',
          'Browser notification permissions blocked or set to silent.',
          'Availability status set to Offline.',
        ],
        recommendedSteps: [
          'Ensure your header availability toggle is set to Available.',
          'Check browser permission settings to allow notifications from healthify.org.',
          'Go to Settings -> Notifications and verify In-App Alert is enabled.',
        ],
      ),
      const TroubleshootingGuideModel(
        id: 'TB-03',
        title: 'Unable to open or edit a patient medical record',
        possibleCauses: [
          'Patient record is locked by another attending physician during active consultation.',
          'Missing hospital department authorization for target patient MRN.',
        ],
        recommendedSteps: [
          'Check if another doctor is currently editing the consultation record.',
          'Contact Hospital Administrator to verify your department access privileges.',
        ],
      ),
    ]);
  }

  // Getters & Methods
  List<HelpArticleModel> getHelpArticles({
    String searchQuery = '',
    HelpArticleCategory? category,
  }) {
    return _articles.where((item) {
      if (category != null && item.category != category) return false;
      if (searchQuery.isNotEmpty) {
        final q = searchQuery.toLowerCase();
        final matchTitle = item.title.toLowerCase().contains(q);
        final matchDesc = item.shortDescription.toLowerCase().contains(q);
        final matchSteps = item.contentSteps.any((s) => s.toLowerCase().contains(q));
        return matchTitle || matchDesc || matchSteps;
      }
      return true;
    }).toList();
  }

  List<HelpArticleModel> getPopularArticles() {
    return _articles.where((a) => a.isPopular).toList();
  }

  List<SupportTicketModel> getDoctorTickets() {
    return List.unmodifiable(_tickets);
  }

  Future<String> createSupportTicket({
    required String subject,
    required String category,
    required SupportTicketPriority priority,
    required String description,
    List<String> attachments = const [],
  }) async {
    await Future.delayed(const Duration(milliseconds: 400));
    final ticketNum = (843 + _tickets.length).toString().padLeft(5, '0');
    final ticketId = 'MED-SUP-2026-$ticketNum';

    final newTicket = SupportTicketModel(
      id: ticketId,
      subject: subject,
      category: category,
      priority: priority,
      status: SupportTicketStatus.open,
      createdDate: DateTime.now(),
      lastUpdated: DateTime.now(),
      messages: [
        TicketMessageModel(
          id: 'MSG-INIT',
          senderName: 'Dr. Arjun Mehta',
          isDoctor: true,
          timestamp: DateTime.now(),
          messageText: description,
        ),
      ],
      attachments: attachments,
    );

    _tickets.insert(0, newTicket);
    return ticketId;
  }

  Future<void> replyToTicket(String ticketId, String messageText) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final index = _tickets.indexWhere((t) => t.id == ticketId);
    if (index != -1) {
      final updatedMessages = List<TicketMessageModel>.from(_tickets[index].messages)
        ..add(
          TicketMessageModel(
            id: 'MSG-${DateTime.now().millisecondsSinceEpoch}',
            senderName: 'Dr. Arjun Mehta',
            isDoctor: true,
            timestamp: DateTime.now(),
            messageText: messageText,
          ),
        );

      _tickets[index] = _tickets[index].copyWith(
        messages: updatedMessages,
        lastUpdated: DateTime.now(),
        status: SupportTicketStatus.inProgress,
      );
    }
  }

  HospitalAdminContactModel getHospitalAdminContact() => _adminContact;

  List<SystemServiceStatus> getSystemStatus() => List.unmodifiable(_systemServices);

  List<TroubleshootingGuideModel> getTroubleshootingGuides() =>
      List.unmodifiable(_troubleshootingGuides);

  Future<void> submitFeedback(String type, String message) async {
    await Future.delayed(const Duration(milliseconds: 300));
  }
}
