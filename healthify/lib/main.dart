import 'package:flutter/material.dart';
import 'package:healthify_server_client/healthify_server_client.dart';
import 'package:serverpod_auth_idp_flutter/serverpod_auth_idp_flutter.dart';
import 'package:serverpod_flutter/serverpod_flutter.dart';
import './core/core.dart';
import './auth/doctor/doctor_signup_screen.dart';
import './auth/login/login_screen.dart';
import './auth/patient/patient_forgot_password_screen.dart';
import './auth/patient/patient_location_permission_screen.dart';
import './auth/patient/patient_login_screen.dart';
import './auth/patient/patient_otp_screen.dart';
import './auth/patient/patient_profile_setup_screen.dart';
import './auth/patient/patient_signup_screen.dart';
import './auth/patient/patient_welcome_screen.dart';
import './auth/signup/signup_screen.dart';
import './doctor/appointments/doctor_appointments_screen.dart';
import './doctor/consultation/doctor_consultation_screen.dart';
import './doctor/dashboard/doctor_dashboard_screen.dart';
import './doctor/emergency/doctor_emergency_cases_screen.dart';
import './doctor/followups/doctor_followups_screen.dart';
import './doctor/analytics/doctor_analytics_screen.dart';
import './doctor/patients/doctor_patient_profile_screen.dart';
import './doctor/patients/my_patients_screen.dart';
import './doctor/reports/doctor_reports_screen.dart';
import './doctor/prescriptions/doctor_prescriptions_screen.dart';
import './doctor/notifications/doctor_notifications_screen.dart';
import './doctor/settings/doctor_profile_settings_screen.dart';
import './doctor/help/doctor_help_support_screen.dart';
import './hospital/dashboard/main_dashboard_screen.dart';
import './patient/dashboard/patient_dashboard_screen.dart';
import './theme/app_theme.dart';

final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier<ThemeMode>(
  ThemeMode.light,
);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  const serverpodUrl = String.fromEnvironment(
    'SERVERPOD_URL',
    defaultValue: 'http://localhost:8080/',
  );
  final client = Client(serverpodUrl)
    ..connectivityMonitor = FlutterConnectivityMonitor()
    ..authSessionManager = FlutterAuthSessionManager();
  await client.auth.initialize();
  RepositoryContainer.instance = RepositoryContainer.withServerpod(client);
  runApp(const HealthifyHospitalApp());
}

class HealthifyHospitalApp extends StatelessWidget {
  const HealthifyHospitalApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (context, currentMode, child) {
        return RepositoryScope(
          container: RepositoryContainer.instance,
          child: MaterialApp(
            title: 'HEALTHIFY - Healthcare Platform',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.theme,
            darkTheme: AppTheme.darkTheme,
            themeMode: currentMode,
            initialRoute: '/',
            routes: {
            '/': (context) => const PatientWelcomeScreen(),
            '/patient-welcome': (context) => const PatientWelcomeScreen(),
            '/patient-login': (context) => const PatientLoginScreen(),
            '/patient-signup': (context) => const PatientSignupScreen(),
            '/patient-forgot-password': (context) =>
                const PatientForgotPasswordScreen(),
            '/patient-otp': (context) =>
                const PatientOtpScreen(phoneNumber: '+91 98765 43210'),
            '/patient-profile-setup': (context) =>
                const PatientProfileSetupScreen(),
            '/patient-location': (context) =>
                const PatientLocationPermissionScreen(),
            '/patient': (context) => const PatientDashboardScreen(),
            '/doctor': (context) => const DoctorDashboardScreen(),
            '/doctor-dashboard': (context) => const DoctorDashboardScreen(),
            '/doctor-appointments': (context) => const DoctorAppointmentsScreen(),
            '/doctor-patients': (context) => const MyPatientsScreen(),
            '/doctor-patient-profile': (context) => const DoctorPatientProfileScreen(),
            '/doctor-consultation': (context) => const DoctorConsultationScreen(),
            '/doctor-reports': (context) => const DoctorReportsScreen(),
            '/doctor-prescriptions': (context) => const DoctorPrescriptionsScreen(),
            '/doctor-emergency': (context) => const DoctorEmergencyCasesScreen(),
            '/doctor-emergency-cases': (context) => const DoctorEmergencyCasesScreen(),
            '/doctor-followups': (context) => const DoctorFollowUpsScreen(),
            '/doctor-patient-followups': (context) => const DoctorFollowUpsScreen(),
            '/doctor-analytics': (context) => const DoctorAnalyticsScreen(),
            '/doctor-notifications': (context) => const DoctorNotificationsScreen(),
            '/doctor-settings': (context) => const DoctorProfileSettingsScreen(),
            '/doctor-profile-settings': (context) => const DoctorProfileSettingsScreen(),
            '/doctor-help': (context) => const DoctorHelpSupportScreen(),
            '/doctor-support': (context) => const DoctorHelpSupportScreen(),
            '/hospital': (context) => const MainDashboardScreen(),
            '/portal-select': (context) => const LoginScreen(),
            '/doctor-signup': (context) => const DoctorSignupScreen(),
            '/hospital-signup': (context) => const HospitalSignupScreen(),
          },
        ),
        );
      },
    );
  }
}
