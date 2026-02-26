import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart' hide Response;
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/api_constants.dart';
import '../../app/routes/app_routes.dart';

class ApiClient {
  late Dio _dio;
  bool _isRefreshing = false;

  ApiClient() {
    _dio = Dio(BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {'Content-Type': 'application/json'},
    ));

    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final prefs = await SharedPreferences.getInstance();
        final token = prefs.getString(StorageKeys.accessToken);
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        debugPrint('[API] ${options.method} ${options.baseUrl}${options.path}');
        handler.next(options);
      },
      onResponse: (response, handler) {
        debugPrint('[API] Response ${response.statusCode}');
        handler.next(response);
      },
      onError: (error, handler) async {
        debugPrint('[API] Error ${error.response?.statusCode}: ${error.message}');

        // Auto-refresh on 401
        if (error.response?.statusCode == 401 && !_isRefreshing) {
          _isRefreshing = true;
          try {
            final prefs = await SharedPreferences.getInstance();
            final refreshToken = prefs.getString(StorageKeys.refreshToken);

            if (refreshToken != null) {
              // Try to refresh the access token
              final refreshDio = Dio(BaseOptions(
                baseUrl: ApiConstants.baseUrl,
                headers: {'Content-Type': 'application/json'},
              ));
              final response = await refreshDio.post(
                ApiConstants.refresh,
                data: {'refresh_token': refreshToken},
              );

              final newAccessToken = response.data['access_token'];
              if (newAccessToken != null) {
                await prefs.setString(StorageKeys.accessToken, newAccessToken);

                // Retry the original request with new token
                error.requestOptions.headers['Authorization'] =
                    'Bearer $newAccessToken';
                final retryResponse = await _dio.fetch(error.requestOptions);
                _isRefreshing = false;
                return handler.resolve(retryResponse);
              }
            }

            // No refresh token or refresh failed - logout
            await _logout(prefs);
          } catch (e) {
            debugPrint('[API] Refresh failed: $e');
            final prefs = await SharedPreferences.getInstance();
            await _logout(prefs);
          }
          _isRefreshing = false;
        }

        handler.next(error);
      },
    ));
  }

  Future<void> _logout(SharedPreferences prefs) async {
    await prefs.remove(StorageKeys.accessToken);
    await prefs.remove(StorageKeys.refreshToken);
    Get.offAllNamed(AppRoutes.login);
  }

  Future<Response> get(String path, {Map<String, dynamic>? queryParams}) {
    return _dio.get(path, queryParameters: queryParams);
  }

  Future<Response> post(String path, {dynamic data}) {
    return _dio.post(path, data: data);
  }

  Future<Response> put(String path, {dynamic data}) {
    return _dio.put(path, data: data);
  }
}
