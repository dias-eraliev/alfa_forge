import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiClient {
  static const String baseUrl = 'http://localhost:3000'; // Измените на ваш URL
  static ApiClient? _instance;
  late http.Client _client;
  String? _accessToken;
  String? _refreshToken;

  ApiClient._internal() {
    _client = http.Client();
  }

  static ApiClient get instance {
    _instance ??= ApiClient._internal();
    return _instance!;
  }

  // Инициализация токенов из SharedPreferences
  Future<void> initialize() async {
    print('🎫🎫🎫 ApiClient INITIALIZE START 🎫🎫🎫');
    final prefs = await SharedPreferences.getInstance();
    _accessToken = prefs.getString('access_token');
    _refreshToken = prefs.getString('refresh_token');
    
    print('🎫 Access token: ${_accessToken != null ? "EXISTS (${_accessToken!.substring(0, 20)}...)" : "NULL"}');
    print('🎫 Refresh token: ${_refreshToken != null ? "EXISTS" : "NULL"}');
    print('🎫 isAuthenticated: $isAuthenticated');
    print('🎫🎫🎫 ApiClient INITIALIZE END 🎫🎫🎫');
  }

  // Сохранение токенов
  Future<void> saveTokens(String accessToken, String refreshToken) async {
    _accessToken = accessToken;
    _refreshToken = refreshToken;
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('access_token', accessToken);
    await prefs.setString('refresh_token', refreshToken);
  }

  // Очистка токенов
  Future<void> clearTokens() async {
    _accessToken = null;
    _refreshToken = null;
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('access_token');
    await prefs.remove('refresh_token');
  }

  // Проверка авторизации
  bool get isAuthenticated => _accessToken != null;

  // Заголовки для запросов
  Map<String, String> get _headers {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    
    if (_accessToken != null) {
      headers['Authorization'] = 'Bearer $_accessToken';
    }
    
    return headers;
  }

  // GET запрос
  Future<ApiResponse<T>> get<T>(
    String endpoint, {
    Map<String, String>? queryParams,
    T Function(Map<String, dynamic>)? fromJson,
  }) async {
    try {
      final uri = _buildUri(endpoint, queryParams);
      final response = await _client.get(uri, headers: _headers);
      return _handleResponse<T>(response, fromJson);
    } catch (e) {
      return ApiResponse.error('Ошибка сети: $e');
    }
  }

  // POST запрос
  Future<ApiResponse<T>> post<T>(
    String endpoint, {
    Map<String, dynamic>? body,
    T Function(Map<String, dynamic>)? fromJson,
  }) async {
    try {
      final uri = _buildUri(endpoint);
      final response = await _client.post(
        uri,
        headers: _headers,
        body: body != null ? jsonEncode(body) : null,
      );
      return _handleResponse<T>(response, fromJson);
    } catch (e) {
      return ApiResponse.error('Ошибка сети: $e');
    }
  }

  // PUT запрос
  Future<ApiResponse<T>> put<T>(
    String endpoint, {
    Map<String, dynamic>? body,
    T Function(Map<String, dynamic>)? fromJson,
  }) async {
    try {
      final uri = _buildUri(endpoint);
      final response = await _client.put(
        uri,
        headers: _headers,
        body: body != null ? jsonEncode(body) : null,
      );
      return _handleResponse<T>(response, fromJson);
    } catch (e) {
      return ApiResponse.error('Ошибка сети: $e');
    }
  }

  // PATCH запрос
  Future<ApiResponse<T>> patch<T>(
    String endpoint, {
    Map<String, dynamic>? body,
    T Function(Map<String, dynamic>)? fromJson,
  }) async {
    try {
      final uri = _buildUri(endpoint);
      final response = await _client.patch(
        uri,
        headers: _headers,
        body: body != null ? jsonEncode(body) : null,
      );
      return _handleResponse<T>(response, fromJson);
    } catch (e) {
      return ApiResponse.error('Ошибка сети: $e');
    }
  }

  // DELETE запрос
  Future<ApiResponse<T>> delete<T>(
    String endpoint, {
    T Function(Map<String, dynamic>)? fromJson,
  }) async {
    try {
      final uri = _buildUri(endpoint);
      final response = await _client.delete(uri, headers: _headers);
      return _handleResponse<T>(response, fromJson);
    } catch (e) {
      return ApiResponse.error('Ошибка сети: $e');
    }
  }

  // Построение URI
  Uri _buildUri(String endpoint, [Map<String, String>? queryParams]) {
    final uri = Uri.parse('$baseUrl$endpoint');
    if (queryParams != null && queryParams.isNotEmpty) {
      return uri.replace(queryParameters: queryParams);
    }
    return uri;
  }

  // Обработка ответа
  Future<ApiResponse<T>> _handleResponse<T>(
    http.Response response,
    T Function(Map<String, dynamic>)? fromJson,
  ) async {
    final statusCode = response.statusCode;
    
    // Попытка обновить токен при ошибке 401
    if (statusCode == 401 && _refreshToken != null) {
      final refreshed = await _refreshAccessToken();
      if (refreshed) {
        // Повторить запрос с новым токеном
        // TODO: Реализовать повторный запрос
      }
    }

    try {
      print('🚀 API Response Status: $statusCode');
      print('🚀 API Response Body: ${response.body}');
      
      final jsonData = jsonDecode(response.body) as Map<String, dynamic>;
      print('🚀 Parsed JSON: $jsonData');
      
      if (statusCode >= 200 && statusCode < 300) {
        if (fromJson != null) {
          print('🚀 Calling fromJson with: $jsonData');
          final data = fromJson(jsonData);
          print('🚀 fromJson result: $data');
          return ApiResponse.success(data);
        } else {
          return ApiResponse.success(jsonData as T);
        }
      } else {
        final message = jsonData['message'] ?? 'Неизвестная ошибка';
        return ApiResponse.error(message);
      }
    } catch (e, stackTrace) {
      print('🚀🚀🚀 API PARSE ERROR 🚀🚀🚀');
      print('Error: $e');
      print('StackTrace: $stackTrace');
      print('Response Body: ${response.body}');
      print('Status Code: $statusCode');
      print('🚀🚀🚀 END ERROR 🚀🚀🚀');
      return ApiResponse.error('Ошибка парсинга: $e');
    }
  }

  // Обновление access token
  Future<bool> _refreshAccessToken() async {
    if (_refreshToken == null) return false;
    
    try {
      final response = await _client.post(
        Uri.parse('$baseUrl/auth/refresh'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'refreshToken': _refreshToken}),
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final newAccessToken = data['accessToken'] as String;
        final newRefreshToken = data['refreshToken'] as String?;
        
        await saveTokens(newAccessToken, newRefreshToken ?? _refreshToken!);
        return true;
      }
    } catch (e) {
      // Ошибка обновления токена
    }
    
    return false;
  }

  void dispose() {
    _client.close();
  }
}

// Класс для обработки ответов API
class ApiResponse<T> {
  final T? data;
  final String? error;
  final bool isSuccess;

  ApiResponse.success(this.data)
      : error = null,
        isSuccess = true;

  ApiResponse.error(this.error)
      : data = null,
        isSuccess = false;
}
