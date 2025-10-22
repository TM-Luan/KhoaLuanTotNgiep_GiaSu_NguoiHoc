class ApiConfig {
  static const String baseUrl = 'http://10.0.2.2:8000/api/';
  static const int timeout = 10000;

  static Map<String, String> getHeaders({String? token}) {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }
}
