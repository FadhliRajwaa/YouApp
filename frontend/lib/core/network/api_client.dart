import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart' hide Response;
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/api_constants.dart';
import '../../app/routes/app_routes.dart';

class ApiClient {
  late Dio _dio;

  ApiClient() {
    _dio = Dio(BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      headers: {'Content-Type': 'application/json'},
    ));

    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final prefs = await SharedPreferences.getInstance();
        final token = prefs.getString(StorageKeys.accessToken);
        if (token != null) {
          // Send both headers for compatibility with external API and our backend
          options.headers['x-access-token'] = token;
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
        debugPrint('[API] Error data: ${error.response?.data}');

        if (error.response?.statusCode == 401) {
          final prefs = await SharedPreferences.getInstance();
          await _logout(prefs);
        }

        handler.next(error);
      },
    ));
  }

  Future<void> _logout(SharedPreferences prefs) async {
    await prefs.remove(StorageKeys.accessToken);
    await prefs.remove(StorageKeys.refreshToken);
    await prefs.remove(StorageKeys.userId);
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
