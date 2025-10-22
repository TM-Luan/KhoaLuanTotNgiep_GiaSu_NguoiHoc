class ApiResponse<T> {
  final T? data;
  final String? message;
  final bool success;

  ApiResponse({this.data, this.message, this.success = true});

  factory ApiResponse.success(T data) => ApiResponse(data: data, success: true);
  factory ApiResponse.error(String message) =>
      ApiResponse(message: message, success: false);
}
