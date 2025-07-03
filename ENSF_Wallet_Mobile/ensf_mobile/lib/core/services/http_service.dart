import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:io';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/api_models.dart';

/// 🌐 HTTP Service
/// Handles all HTTP communications with the backend API
/// Includes error handling, logging, and token management
class HttpService {
  static final HttpService _instance = HttpService._internal();
  factory HttpService() => _instance;
  HttpService._internal();

  final http.Client _client = http.Client();
  String? _authToken;
  String? _refreshToken;

  /// Set authentication tokens
  void setTokens(String authToken, String refreshToken) {
    _authToken = authToken;
    _refreshToken = refreshToken;
  }

  /// Clear authentication tokens
  void clearTokens() {
    _authToken = null;
    _refreshToken = null;
  }

  /// Check if user is authenticated
  bool get isAuthenticated => _authToken != null;

  /// GET Request
  Future<ApiResponse<T>> get<T>(
    String endpoint, {
    Map<String, String>? queryParams,
    bool requiresAuth = true,
  }) async {
    try {
      final uri = _buildUri(endpoint, queryParams);
      final headers = _buildHeaders(requiresAuth);

      developer.log('🔍 GET Request: $uri', name: 'HttpService');

      final response = await _client
          .get(uri, headers: headers)
          .timeout(HttpSettings.receiveTimeout);
      developer.log('response: ${response.toString()}', name: 'HttpService');
      return _handleResponse<T>(response);
    } catch (e) {
      return _handleError<T>(e);
    }
  }

  /// POST Request
  Future<ApiResponse<T>> post<T>(
    String endpoint, {
    Map<String, dynamic>? body,
    Map<String, String>? queryParams,
    bool requiresAuth = true,
  }) async {
    try {
      final uri = _buildUri(endpoint, queryParams);
      final headers = _buildHeaders(requiresAuth);

      developer.log('📤 POST Request: $uri', name: 'HttpService');
      if (body != null) {
        developer.log('📦 Request Body: ${json.encode(body)}', name: 'HttpService');
      }

      final response = await _client
          .post(
            uri,
            headers: headers,
            body: body != null ? json.encode(body) : null,
          )
          .timeout(HttpSettings.sendTimeout);
      developer.log('📬 Response: ${response.statusCode} - ${response.body}', name: 'HttpService');
      developer.log(response.toString(), name: 'HttpService');
      return _handleResponse<T>(response);
    } catch (e) {
      developer.log('❌ Error: $e', name: 'HttpService');
      return _handleError<T>(e);
    }
  }

  Future<ApiResponse<T>> postMultipart<T>(
    String endpoint, {
    Map<String, dynamic>? fields,
    List<Map<String, dynamic>>? files, // [{fieldName, file}, ...]
    Map<String, String>? queryParams,
    bool requiresAuth = true,
  }) async {
    try {
      final uri = _buildUri(endpoint, queryParams);
      final request = http.MultipartRequest('POST', uri);

      // Add headers (without Content-Type as it's set automatically for multipart)
      if (requiresAuth && _authToken != null) {
        request.headers.addAll({
          'Authorization': 'Bearer $_authToken',
        });
      }

      // Add form fields
      if (fields != null) {
        fields.forEach((key, value) {
          request.fields[key] = value.toString();
        });
      }

      // Add files
      if (files != null) {
        for (var fileInfo in files) {
          final File file = fileInfo['file'] as File;
          final String fieldName = fileInfo['fieldName'] as String;
          
          final multipartFile = await http.MultipartFile.fromPath(
            fieldName,
            file.path,
            filename: file.path.split('/').last,
          );
          request.files.add(multipartFile);
        }
      }

      developer.log('📤 MULTIPART POST Request: $uri', name: 'HttpService');
      developer.log('📦 Fields: $fields', name: 'HttpService');
      developer.log('📁 Files: ${files?.length ?? 0} files', name: 'HttpService');

      final streamedResponse = await request.send()
          .timeout(HttpSettings.sendTimeout);

      final response = await http.Response.fromStream(streamedResponse);
      
      developer.log('📬 Response: ${response.statusCode} - ${response.body}', name: 'HttpService');
      
      return _handleResponse<T>(response);
    } catch (e) {
      developer.log('❌ Multipart Error: $e', name: 'HttpService');
      return _handleError<T>(e);
    }
  }
   Future<ApiResponse<T>> post2<T>(
    String uri,
    {
    Map<String, dynamic>? body,
    Map<String, String>? queryParams,
    bool requiresAuth = true,
  }) async {
    try {
      final uriObj = Uri.parse(uri);
      final headers = _buildHeaders(requiresAuth);

      developer.log('📤 POST Request: $uriObj', name: 'HttpService');
      if (body != null) {
        developer.log('📦 Request Body: ${json.encode(body)}', name: 'HttpService');
      }

      final response = await _client
          .post(
            uriObj,
            headers: headers,
            body: body != null ? json.encode(body) : null,
          )
          .timeout(HttpSettings.sendTimeout);
      developer.log('📬 Response: ${response.statusCode} - ${response.body}', name: 'HttpService');
      return _handleResponse<T>(response);
    } catch (e) {
      developer.log('❌ Error: $e', name: 'HttpService');
      return _handleError<T>(e);
    }
  }

  /// PUT Request
  Future<ApiResponse<T>> put<T>(
    String endpoint, {
    Map<String, dynamic>? body,
    Map<String, String>? queryParams,
    bool requiresAuth = true,
  }) async {
    try {
      final uri = _buildUri(endpoint, queryParams);
      final headers = _buildHeaders(requiresAuth);

      developer.log('📝 PUT Request: $uri', name: 'HttpService');

      final response = await _client
          .put(
            uri,
            headers: headers,
            body: body != null ? json.encode(body) : null,
          )
          .timeout(HttpSettings.sendTimeout);

      return _handleResponse<T>(response);
    } catch (e) {
      return _handleError<T>(e);
    }
  }

  /// DELETE Request
  Future<ApiResponse<T>> delete<T>(
    String endpoint, {
    Map<String, String>? queryParams,
    bool requiresAuth = true,
  }) async {
    try {
      final uri = _buildUri(endpoint, queryParams);
      final headers = _buildHeaders(requiresAuth);

      developer.log('🗑️ DELETE Request: $uri', name: 'HttpService');

      final response = await _client
          .delete(uri, headers: headers)
          .timeout(HttpSettings.receiveTimeout);

      return _handleResponse<T>(response);
    } catch (e) {
      return _handleError<T>(e);
    }
  }

 /// Build URI with automatic service detection
  Uri _buildUri(String endpoint, [Map<String, String>? queryParams]) {
    String baseUrl;
    
    // Determine service based on endpoint
    if (endpoint.startsWith('/api/v1/cartes')) {
      baseUrl = ApiConfig.getServiceUrl('cards');
    } else if (endpoint.startsWith('/api/v1/agence')) {
      baseUrl = ApiConfig.getServiceUrl('agence');
    } else if (endpoint.startsWith('/api/withdrawals') || endpoint.startsWith('/api/deposit')) {
      baseUrl = ApiConfig.getServiceUrl('money');
    } else {
      baseUrl = ApiConfig.getServiceUrl('user');
    }
    
    final uri = Uri.parse('$baseUrl$endpoint');
    
    if (queryParams != null && queryParams.isNotEmpty) {
      return uri.replace(queryParameters: {
        ...uri.queryParameters,
        ...queryParams,
      });
    }
    
    return uri;
  }

  /// Build headers for request
  Map<String, String> _buildHeaders(bool requiresAuth) {
    if (requiresAuth && _authToken != null) {
      return HttpSettings.getAuthHeaders(_authToken!);
    }
    return HttpSettings.defaultHeaders;
  }

  /// Handle HTTP response
  ApiResponse<T> _handleResponse<T>(http.Response response) {
    developer.log(
      '📡 Response: ${response.statusCode} - ${response.body}', 
      name: 'HttpService'
    );

    try {
      final Map<String, dynamic> responseData = json.decode(response.body);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        //developer.log('✅ Success Response: ${responseData}', name: 'HttpService');
        return ApiResponse<T>.success(responseData);
      } else {
        final error = ApiError.fromJson(responseData);
        return ApiResponse<T>.error(error, response.statusCode);
      }
    } catch (e) {
      // Handle non-JSON responses
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return ApiResponse<T>.success({'message': response.body});
      } else {
        final error = ApiError(
          error: 'HTTP_ERROR',
          message: _getHttpErrorMessage(response.statusCode),
          timestamp: DateTime.now(),
          path: 'unknown',
          statusCode: response.statusCode,
        );
        return ApiResponse<T>.error(error, response.statusCode);
      }
    }
  }

  /// Handle request errors (network, timeout, etc.)
  ApiResponse<T> _handleError<T>(dynamic error) {
    developer.log('❌ Request Error: $error', name: 'HttpService');

    String message;
    if (error.toString().contains('TimeoutException')) {
      message = ErrorMessages.timeoutError;
    } else if (error.toString().contains('SocketException')) {
      message = ErrorMessages.networkError;
    } else {
      message = ErrorMessages.unknownError;
    }

    final apiError = ApiError(
      error: 'REQUEST_ERROR',
      message: message,
      timestamp: DateTime.now(),
      path: 'unknown',
    );

    return ApiResponse<T>.error(apiError);
  }

  /// Get human-readable HTTP error message
  String _getHttpErrorMessage(int statusCode) {
    switch (statusCode) {
      case 401:
        return ErrorMessages.unauthorizedError;
      case 400:
        return ErrorMessages.validationError;
      case 500:
        return ErrorMessages.serverError;
      default:
        return ErrorMessages.unknownError;
    }
  }

  /// Dispose HTTP client
  void dispose() {
    _client.close();
  }
}

/// 📋 API Response Wrapper
/// Standardizes all API responses with success/error states
class ApiResponse<T> {
  final bool isSuccess;
  final Map<String, dynamic>? data;
  final ApiError? error;
  final int? statusCode;

  ApiResponse._({
    required this.isSuccess,
    this.data,
    this.error,
    this.statusCode,
  });

  /// Create success response
  factory ApiResponse.success(Map<String, dynamic> data) {
    return ApiResponse._(
      isSuccess: true,
      data: data,
    );
  }

  /// Create error response
  factory ApiResponse.error(ApiError error, [int? statusCode]) {
    return ApiResponse._(
      isSuccess: false,
      error: error,
      statusCode: statusCode,
    );
  }

  /// Get data with type casting
  T? getData<T>() {
    if (isSuccess && data != null) {
      return data as T?;
    }
    return null;
  }

  /// Get error message
  String get errorMessage => error?.message ?? 'Unknown error';

  /// Check if error is authentication related
  bool get isAuthError => statusCode == 401;

  /// Check if error is validation related
  bool get isValidationError => statusCode == 400;

  /// Check if error is server related
  bool get isServerError => statusCode != null && statusCode! >= 500;
}