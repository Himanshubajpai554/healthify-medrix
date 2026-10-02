enum UiStatus {
  initial,
  loading,
  empty,
  error,
  success,
  refreshing,
  actionInProgress,
}

class UiState<T> {
  final UiStatus status;
  final T? data;
  final String? errorMessage;
  final String? actionMessage;

  const UiState._({
    required this.status,
    this.data,
    this.errorMessage,
    this.actionMessage,
  });

  factory UiState.initial() => const UiState._(status: UiStatus.initial);

  factory UiState.loading() => const UiState._(status: UiStatus.loading);

  factory UiState.empty() => const UiState._(status: UiStatus.empty);

  factory UiState.error(String message) => UiState._(
        status: UiStatus.error,
        errorMessage: message,
      );

  factory UiState.success(T data) => UiState._(
        status: UiStatus.success,
        data: data,
      );

  factory UiState.refreshing(T data) => UiState._(
        status: UiStatus.refreshing,
        data: data,
      );

  factory UiState.actionInProgress(T? data, {String? message}) => UiState._(
        status: UiStatus.actionInProgress,
        data: data,
        actionMessage: message,
      );

  bool get isInitial => status == UiStatus.initial;
  bool get isLoading => status == UiStatus.loading;
  bool get isEmpty => status == UiStatus.empty;
  bool get isError => status == UiStatus.error;
  bool get isSuccess => status == UiStatus.success;
  bool get isRefreshing => status == UiStatus.refreshing;
  bool get isActionInProgress => status == UiStatus.actionInProgress;
}
