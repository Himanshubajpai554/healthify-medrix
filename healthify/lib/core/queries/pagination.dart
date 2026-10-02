/// Pagination parameters supporting both page-based and cursor-based pagination.
class PaginationParams {
  final int page;
  final int pageSize;
  final String? cursor;
  final String? sortField;
  final bool sortAscending;

  const PaginationParams({
    this.page = 1,
    this.pageSize = 20,
    this.cursor,
    this.sortField,
    this.sortAscending = true,
  });

  int get offset => (page - 1) * pageSize;
}

/// Generic paginated result wrapper.
class PaginatedResult<T> {
  final List<T> items;
  final int totalCount;
  final int page;
  final int pageSize;
  final String? nextCursor;

  const PaginatedResult({
    required this.items,
    required this.totalCount,
    required this.page,
    required this.pageSize,
    this.nextCursor,
  });

  int get totalPages => (totalCount / pageSize).ceil();
  bool get hasNextPage => page < totalPages || nextCursor != null;
  bool get hasPreviousPage => page > 1;

  factory PaginatedResult.empty({int page = 1, int pageSize = 20}) {
    return PaginatedResult<T>(
      items: const [],
      totalCount: 0,
      page: page,
      pageSize: pageSize,
    );
  }
}
