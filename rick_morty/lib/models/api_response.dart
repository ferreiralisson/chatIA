class ApiInfo {
  final int count;
  final int pages;
  final String? next;
  final String? prev;

  ApiInfo({
    required this.count,
    required this.pages,
    this.next,
    this.prev,
  });

  factory ApiInfo.fromJson(Map<String, dynamic> json) {
    return ApiInfo(
      count: json['count'] as int,
      pages: json['pages'] as int,
      next: json['next'] as String?,
      prev: json['prev'] as String?,
    );
  }
}

class ApiResponse<T> {
  final ApiInfo info;
  final List<T> results;

  ApiResponse({required this.info, required this.results});
}
