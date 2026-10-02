import '../enums/domain_enums.dart';

/// Frontend session state representation (decoupled from Serverpod auth session)
class AuthSession {
  final String userId;
  final UserRole role;
  final String hospitalId;
  final String sessionId;
  final bool isAuthenticated;
  final DateTime lastActive;
  final String? token;

  const AuthSession({
    required this.userId,
    required this.role,
    required this.hospitalId,
    required this.sessionId,
    required this.isAuthenticated,
    required this.lastActive,
    this.token,
  });

  factory AuthSession.unauthenticated() => AuthSession(
        userId: '',
        role: UserRole.patient,
        hospitalId: '',
        sessionId: '',
        isAuthenticated: false,
        lastActive: DateTime.now(),
      );

  AuthSession copyWith({
    String? userId,
    UserRole? role,
    String? hospitalId,
    String? sessionId,
    bool? isAuthenticated,
    DateTime? lastActive,
    String? token,
  }) {
    return AuthSession(
      userId: userId ?? this.userId,
      role: role ?? this.role,
      hospitalId: hospitalId ?? this.hospitalId,
      sessionId: sessionId ?? this.sessionId,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      lastActive: lastActive ?? this.lastActive,
      token: token ?? this.token,
    );
  }
}
