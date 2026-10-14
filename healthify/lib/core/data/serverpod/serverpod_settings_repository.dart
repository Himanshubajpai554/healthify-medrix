import '../../models/settings_model.dart';
import '../repositories/settings_repository.dart';
import 'hospital_operational_repository.dart';

/// Persists hospital configuration and administrator preferences in the
/// tenant-scoped `settings` operational collection.
class ServerpodSettingsRepository implements SettingsRepository {
  ServerpodSettingsRepository(this.records);
  final HospitalOperationalRepository records;

  Future<Map<String, dynamic>> _get(String category, [String? key]) async =>
      await records.get('settings', key ?? category) ?? <String, dynamic>{};
  Future<void> _put(String category, Map<String, dynamic> value, [String? key]) async =>
      records.save('settings', key ?? category, {'id': key ?? category, 'category': category,
        ...value, 'updatedAt': DateTime.now().toUtc().toIso8601String()});
  String _s(Map<String, dynamic> m, String k, String fallback) => m[k] is String ? m[k] as String : fallback;
  bool _b(Map<String, dynamic> m, String k, bool fallback) => m[k] is bool ? m[k] as bool : fallback;
  int _i(Map<String, dynamic> m, String k, int fallback) => m[k] is num ? (m[k] as num).toInt() : fallback;
  double _d(Map<String, dynamic> m, String k, double fallback) => m[k] is num ? (m[k] as num).toDouble() : fallback;

  @override
  Future<HospitalSettings> getHospitalSettings(String hospitalId) async {
    final m = await _get('hospital'); final d = HospitalSettings(hospitalId: records.hospitalKey);
    final profile = m.isEmpty
        ? await records.client.hospital.getProfile(records.hospitalKey)
        : null;
    return HospitalSettings(
      hospitalId: records.hospitalKey,
      displayName: _s(m, 'displayName', profile?.displayName ?? d.displayName),
      legalName: _s(m, 'legalName', profile?.legalName ?? d.legalName),
      hospitalType: _s(m, 'hospitalType', profile?.hospitalType ?? d.hospitalType),
      licenseId: _s(m, 'licenseId', profile?.registrationLicenseId ?? d.licenseId),
      taxId: _s(m, 'taxId', profile?.taxId ?? d.taxId),
      email: _s(m, 'email', profile?.email ?? d.email),
      phone: _s(m, 'phone', profile?.receptionPhone ?? d.phone),
      emergencyHelpline: _s(m, 'emergencyHelpline', profile?.emergencyHelpline ?? d.emergencyHelpline),
      website: _s(m, 'website', profile?.website ?? d.website),
      address: _s(m, 'address', profile?.address ?? d.address),
      city: _s(m, 'city', profile?.city ?? d.city),
      state: _s(m, 'state', profile?.state ?? d.state),
      country: _s(m, 'country', profile?.country ?? d.country),
      postalCode: _s(m, 'postalCode', d.postalCode),
      timezone: _s(m, 'timezone', d.timezone),
      operatingMode: _s(m, 'operatingMode', profile?.operatingStatus ?? d.operatingMode),
    );
  }
  @override
  Future<void> updateHospitalSettings(HospitalSettings x) => _put('hospital', {'displayName':x.displayName,'legalName':x.legalName,'hospitalType':x.hospitalType,'licenseId':x.licenseId,'taxId':x.taxId,'email':x.email,'phone':x.phone,'emergencyHelpline':x.emergencyHelpline,'website':x.website,'address':x.address,'city':x.city,'state':x.state,'country':x.country,'postalCode':x.postalCode,'timezone':x.timezone,'operatingMode':x.operatingMode});

  @override
  Future<OperationalSettings> getOperationalSettings(String hospitalId) async { final m=await _get('operational'); final d=OperationalSettings(); return OperationalSettings(defaultAppointmentDuration:_i(m,'defaultAppointmentDuration',d.defaultAppointmentDuration),appointmentBufferMinutes:_i(m,'appointmentBufferMinutes',d.appointmentBufferMinutes),allowWalkIns:_b(m,'allowWalkIns',d.allowWalkIns),allowOnlineAppointments:_b(m,'allowOnlineAppointments',d.allowOnlineAppointments),maxAdvanceBookingDays:_i(m,'maxAdvanceBookingDays',d.maxAdvanceBookingDays),noShowThreshold:_i(m,'noShowThreshold',d.noShowThreshold),queueDisplayEnabled:_b(m,'queueDisplayEnabled',d.queueDisplayEnabled)); }
  @override
  Future<void> updateOperationalSettings(OperationalSettings x) => _put('operational', {'defaultAppointmentDuration':x.defaultAppointmentDuration,'appointmentBufferMinutes':x.appointmentBufferMinutes,'allowWalkIns':x.allowWalkIns,'allowOnlineAppointments':x.allowOnlineAppointments,'maxAdvanceBookingDays':x.maxAdvanceBookingDays,'noShowThreshold':x.noShowThreshold,'queueDisplayEnabled':x.queueDisplayEnabled});

  @override
  Future<EmergencySettings> getEmergencySettings(String hospitalId) async { final m=await _get('emergency'); final d=EmergencySettings(); return EmergencySettings(emergencyServicesEnabled:_b(m,'emergencyServicesEnabled',d.emergencyServicesEnabled),is24HourEmergency:_b(m,'is24HourEmergency',d.is24HourEmergency),triageEnabled:_b(m,'triageEnabled',d.triageEnabled),emergencyQueueEnabled:_b(m,'emergencyQueueEnabled',d.emergencyQueueEnabled),ambulanceServiceEnabled:_b(m,'ambulanceServiceEnabled',d.ambulanceServiceEnabled),traumaLevel:_s(m,'traumaLevel',d.traumaLevel),criticalAlertEnabled:_b(m,'criticalAlertEnabled',d.criticalAlertEnabled)); }
  @override
  Future<void> updateEmergencySettings(EmergencySettings x) => _put('emergency', {'emergencyServicesEnabled':x.emergencyServicesEnabled,'is24HourEmergency':x.is24HourEmergency,'triageEnabled':x.triageEnabled,'emergencyQueueEnabled':x.emergencyQueueEnabled,'ambulanceServiceEnabled':x.ambulanceServiceEnabled,'traumaLevel':x.traumaLevel,'criticalAlertEnabled':x.criticalAlertEnabled});

  @override
  Future<BedManagementSettings> getBedManagementSettings(String hospitalId) async { final m=await _get('bedManagement'); final d=BedManagementSettings(); return BedManagementSettings(allowReservations:_b(m,'allowReservations',d.allowReservations),sanitizationRequired:_b(m,'sanitizationRequired',d.sanitizationRequired),maintenanceTracking:_b(m,'maintenanceTracking',d.maintenanceTracking),occupancyAlerts:_b(m,'occupancyAlerts',d.occupancyAlerts),capacityWarningThreshold:_d(m,'capacityWarningThreshold',d.capacityWarningThreshold),criticalCapacityThreshold:_d(m,'criticalCapacityThreshold',d.criticalCapacityThreshold),icuCapacityAlerts:_b(m,'icuCapacityAlerts',d.icuCapacityAlerts),icuCriticalThreshold:_d(m,'icuCriticalThreshold',d.icuCriticalThreshold)); }
  @override
  Future<void> updateBedManagementSettings(BedManagementSettings x) => _put('bedManagement', {'allowReservations':x.allowReservations,'sanitizationRequired':x.sanitizationRequired,'maintenanceTracking':x.maintenanceTracking,'occupancyAlerts':x.occupancyAlerts,'capacityWarningThreshold':x.capacityWarningThreshold,'criticalCapacityThreshold':x.criticalCapacityThreshold,'icuCapacityAlerts':x.icuCapacityAlerts,'icuCriticalThreshold':x.icuCriticalThreshold});

  @override
  Future<BloodBankSettings> getBloodBankSettings(String hospitalId) async { final m=await _get('bloodBank'); final d=BloodBankSettings(); return BloodBankSettings(expiryWarningDays:_i(m,'expiryWarningDays',d.expiryWarningDays),criticalStockThreshold:_i(m,'criticalStockThreshold',d.criticalStockThreshold),reservationEnabled:_b(m,'reservationEnabled',d.reservationEnabled),quarantineEnabled:_b(m,'quarantineEnabled',d.quarantineEnabled),patientAvailabilityEnabled:_b(m,'patientAvailabilityEnabled',d.patientAvailabilityEnabled)); }
  @override
  Future<void> updateBloodBankSettings(BloodBankSettings x) => _put('bloodBank', {'expiryWarningDays':x.expiryWarningDays,'criticalStockThreshold':x.criticalStockThreshold,'reservationEnabled':x.reservationEnabled,'quarantineEnabled':x.quarantineEnabled,'patientAvailabilityEnabled':x.patientAvailabilityEnabled});

  @override
  Future<NotificationSystemSettings> getNotificationSystemSettings(String hospitalId) async { final m=await _get('notification'); final d=NotificationSystemSettings(); return NotificationSystemSettings(inAppEnabled:_b(m,'inAppEnabled',d.inAppEnabled),pushEnabled:_b(m,'pushEnabled',d.pushEnabled),emailEnabled:_b(m,'emailEnabled',d.emailEnabled),smsEnabled:_b(m,'smsEnabled',d.smsEnabled),criticalAlertsEnabled:_b(m,'criticalAlertsEnabled',d.criticalAlertsEnabled),notificationRetentionDays:_i(m,'notificationRetentionDays',d.notificationRetentionDays)); }
  @override
  Future<void> updateNotificationSystemSettings(NotificationSystemSettings x) => _put('notification', {'inAppEnabled':x.inAppEnabled,'pushEnabled':x.pushEnabled,'emailEnabled':x.emailEnabled,'smsEnabled':x.smsEnabled,'criticalAlertsEnabled':x.criticalAlertsEnabled,'notificationRetentionDays':x.notificationRetentionDays});

  @override
  Future<AISettings> getAISettings(String hospitalId) async { final m=await _get('ai'); final d=AISettings(); return AISettings(aiInsightsEnabled:_b(m,'aiInsightsEnabled',d.aiInsightsEnabled),forecastingEnabled:_b(m,'forecastingEnabled',d.forecastingEnabled),emergencyRecommendationEnabled:_b(m,'emergencyRecommendationEnabled',d.emergencyRecommendationEnabled),confidenceThreshold:_d(m,'confidenceThreshold',d.confidenceThreshold),showModelVersion:_b(m,'showModelVersion',d.showModelVersion),showForecastLimitations:_b(m,'showForecastLimitations',d.showForecastLimitations)); }
  @override
  Future<void> updateAISettings(AISettings x) => _put('ai', {'aiInsightsEnabled':x.aiInsightsEnabled,'forecastingEnabled':x.forecastingEnabled,'emergencyRecommendationEnabled':x.emergencyRecommendationEnabled,'confidenceThreshold':x.confidenceThreshold,'showModelVersion':x.showModelVersion,'showForecastLimitations':x.showForecastLimitations});

  @override
  Future<SecuritySettings> getSecuritySettings(String hospitalId) async { final m=await _get('security'); final d=SecuritySettings(); return SecuritySettings(sessionTimeoutMinutes:_i(m,'sessionTimeoutMinutes',d.sessionTimeoutMinutes),auditLoggingEnabled:_b(m,'auditLoggingEnabled',d.auditLoggingEnabled),sensitiveAccessLoggingEnabled:_b(m,'sensitiveAccessLoggingEnabled',d.sensitiveAccessLoggingEnabled),breakGlassEnabled:_b(m,'breakGlassEnabled',d.breakGlassEnabled),requireAcknowledgementForCriticalAlerts:_b(m,'requireAcknowledgementForCriticalAlerts',d.requireAcknowledgementForCriticalAlerts)); }
  @override
  Future<void> updateSecuritySettings(SecuritySettings x) => _put('security', {'sessionTimeoutMinutes':x.sessionTimeoutMinutes,'auditLoggingEnabled':x.auditLoggingEnabled,'sensitiveAccessLoggingEnabled':x.sensitiveAccessLoggingEnabled,'breakGlassEnabled':x.breakGlassEnabled,'requireAcknowledgementForCriticalAlerts':x.requireAcknowledgementForCriticalAlerts});

  @override
  Future<UserPreferences> getUserPreferences(String userId) async { final m=await _get('userPreferences','userPreferences:$userId'); final d=UserPreferences(userId:userId); return UserPreferences(userId:userId,language:_s(m,'language',d.language),timezone:_s(m,'timezone',d.timezone),compactMode:_b(m,'compactMode',d.compactMode),defaultLandingPage:_s(m,'defaultLandingPage',d.defaultLandingPage),notificationsEnabled:_b(m,'notificationsEnabled',d.notificationsEnabled),soundEnabled:_b(m,'soundEnabled',d.soundEnabled),reducedMotion:_b(m,'reducedMotion',d.reducedMotion)); }
  @override
  Future<void> updateUserPreferences(UserPreferences x) => _put('userPreferences', {'userId':x.userId,'language':x.language,'timezone':x.timezone,'compactMode':x.compactMode,'defaultLandingPage':x.defaultLandingPage,'notificationsEnabled':x.notificationsEnabled,'soundEnabled':x.soundEnabled,'reducedMotion':x.reducedMotion}, 'userPreferences:${x.userId}');
  @override
  Future<AppearanceSettings> getAppearanceSettings(String userId) async { final m=await _get('appearance','appearance:$userId'); final data=m.isEmpty?await _get('appearance','appearance:current'):m; final d=AppearanceSettings(); return AppearanceSettings(themeMode:_s(data,'themeMode',d.themeMode),density:_s(data,'density',d.density),sidebarCollapsed:_b(data,'sidebarCollapsed',d.sidebarCollapsed),animationsEnabled:_b(data,'animationsEnabled',d.animationsEnabled)); }
  @override
  Future<void> updateAppearanceSettings(AppearanceSettings x) => _put('appearance', {'themeMode':x.themeMode,'density':x.density,'sidebarCollapsed':x.sidebarCollapsed,'animationsEnabled':x.animationsEnabled}, 'appearance:current');
  @override
  Future<SystemInformation> getSystemInformation() async => const SystemInformation(appName:'Healthify', environment:'Serverpod', architectureVersion:'Serverpod operational records v1');
  @override
  Future<List<ConfigurationChange>> getConfigurationHistory(String hospitalId) async {
    final rows=await records.list('settings',limit:500); return rows.where((r)=>r['category']=='configurationChange').map((r)=>ConfigurationChange(id:'${r['id']}',hospitalId:records.hospitalKey,category:'${r['categoryName'] ?? ''}',setting:'${r['setting'] ?? ''}',previousValue:'${r['previousValue'] ?? ''}',newValue:'${r['newValue'] ?? ''}',changedBy:'${r['changedBy'] ?? ''}',changedAt:DateTime.tryParse('${r['changedAt']}') ?? DateTime.now().toUtc())).toList(growable:false);
  }
  @override
  Future<void> recordConfigurationChange(ConfigurationChange x) => _put('configurationChange', {'categoryName':x.category,'setting':x.setting,'previousValue':x.previousValue,'newValue':x.newValue,'changedBy':x.changedBy,'changedAt':x.changedAt.toIso8601String()}, 'configurationChange:${x.id}');
}
