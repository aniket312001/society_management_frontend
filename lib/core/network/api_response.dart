// core/network/api_response.dart
class ApiResponse<T> {
  final bool success;
  final T? data;
  final String? message;
  final String? field;

  ApiResponse({required this.success, this.data, this.message, this.field});

  factory ApiResponse.fromJson(
    Map<String, dynamic> json, {
    T Function(dynamic)? fromJsonT,
  }) {
    return ApiResponse<T>(
      success: json['success'] ?? false,
      message: json['message'],
      field: json['field'],
      data: json['data'] != null && fromJsonT != null
          ? fromJsonT(json['data'])
          : json['data'],
    );
  }
}
