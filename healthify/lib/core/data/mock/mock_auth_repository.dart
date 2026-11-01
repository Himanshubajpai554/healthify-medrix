import '../repositories/auth_repository.dart';
import '../../enums/domain_enums.dart';
import '../../models/auth_model.dart';

class MockAuthRepository implements AuthRepository {
  AuthSession _currentSession = AuthSession(
    userId: 'ADM-001',
    role: UserRole.hospitalAdmin,
    hospitalId: 'HOSP-101',
    sessionId: 'SES-MOCK-101',
    isAuthenticated: true,
    lastActive: DateTime.now(),
    token: 'mock-jwt-token-healthify-2026',
  );

  @override
  Future<AuthSession> getSession() async {
    await Future.delayed(const Duration(milliseconds: 50));
    return _currentSession;
  }

  @override
  Future<AuthSession> login(String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 200));
    _currentSession = AuthSession(
      userId: 'ADM-001',
      role: UserRole.hospitalAdmin,
      hospitalId: 'HOSP-101',
      sessionId: 'SES-${DateTime.now().millisecondsSinceEpoch}',
      isAuthenticated: true,
      lastActive: DateTime.now(),
      token: 'mock-jwt-token-healthify-${DateTime.now().millisecondsSinceEpoch}',
    );
    return _currentSession;
  }

  @override
  Future<void> logout() async {
    await Future.delayed(const Duration(milliseconds: 100));
    _currentSession = AuthSession.unauthenticated();
  }

  @override
  Future<AuthSession> refreshSession() async {
    await Future.delayed(const Duration(milliseconds: 50));
    _currentSession = _currentSession.copyWith(lastActive: DateTime.now());
    return _currentSession;
  }
}
