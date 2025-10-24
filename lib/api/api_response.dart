class ApiResponse<T> {
  final bool success;
  final String message;
  final T? data;
  final String? error;
  final int statusCode;

  ApiResponse({
    required this.success,
    required this.message,
    this.data,
    this.error,
    required this.statusCode,
  });

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>)? fromJsonT,
  ) {
    return ApiResponse<T>(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data:
          fromJsonT != null && json['data'] != null
              ? fromJsonT(json['data'])
              : null,
      error: json['error'],
      statusCode: 200,
    );
  }

  bool get isSuccess => success && statusCode >= 200 && statusCode < 300;
}
