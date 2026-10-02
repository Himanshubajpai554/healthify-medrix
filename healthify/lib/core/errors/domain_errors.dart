/// Abstract domain error class and typed domain error variants.
abstract class DomainError implements Exception {
  final String message;
  final String? code;
  final String? details;

  const DomainError({
    required this.message,
    this.code,
    this.details,
  });

  @override
  String toString() => 'DomainError($code): $message${details != null ? ' ($details)' : ''}';
}

class NotFoundError extends DomainError {
  final String entityName;
  final String entityId;

  const NotFoundError({
    required this.entityName,
    required this.entityId,
    String? message,
  }) : super(
          message: message ?? '$entityName with ID $entityId not found.',
          code: 'NOT_FOUND',
          details: 'Entity: $entityName, ID: $entityId',
        );
}

class ValidationError extends DomainError {
  final Map<String, String> fieldErrors;

  const ValidationError({
    required super.message,
    this.fieldErrors = const {},
    super.details,
  }) : super(
          code: 'VALIDATION_ERROR',
        );
}

class PermissionError extends DomainError {
  final String requiredPermission;
  final String role;

  const PermissionError({
    required this.requiredPermission,
    required this.role,
    String? message,
  }) : super(
          message: message ?? 'Role $role does not have permission: $requiredPermission',
          code: 'PERMISSION_DENIED',
        );
}

typedef PermissionDeniedError = PermissionError;

class ConflictError extends DomainError {
  const ConflictError({
    required super.message,
    super.details,
  }) : super(
          code: 'CONFLICT',
        );
}

class UnavailableError extends DomainError {
  const UnavailableError({
    required super.message,
    super.details,
  }) : super(
          code: 'UNAVAILABLE',
        );
}

class RepositoryError extends DomainError {
  const RepositoryError({
    required super.message,
    super.details,
  }) : super(
          code: 'REPOSITORY_ERROR',
        );
}

class UnknownError extends DomainError {
  const UnknownError({
    required super.message,
    super.details,
  }) : super(
          code: 'UNKNOWN_ERROR',
        );
}

class OperationFailedError extends DomainError {
  const OperationFailedError({
    required super.message,
    super.details,
  }) : super(
          code: 'OPERATION_FAILED',
        );
}
