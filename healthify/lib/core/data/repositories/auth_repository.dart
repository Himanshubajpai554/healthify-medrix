import '../../models/auth_model.dart';

/// Abstract contract for Authentication & Session management
abstract class AuthRepository {
  Future<AuthSession> getSession();
  Future<AuthSession> login(String email, String password);
  Future<void> logout();
  Future<AuthSession> refreshSession();
}
