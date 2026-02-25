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
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {'Content-Type': 'application/json'},
    ));

    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final prefs = await SharedPreferences.getInstance();
        final token = prefs.getString(StorageKeys.accessToken);
        if (token != null) {
          options.headers['x-access-token'] = token;
        }
        debugPrint('[API] ${options.method} ${options.baseUrl}${options.path}');
        debugPrint('[API] Data: ${options.data}');
        handler.next(options);
      },
      onResponse: (response, handler) {
        debugPrint('[API] Response ${response.statusCode}: ${response.data}');
        handler.next(response);
      },
      onError: (error, handler) async {
        debugPrint('[API] Error ${error.response?.statusCode}: ${error.response?.data}');
        debugPrint('[API] Message: ${error.message}');
        // Redirect to login on 401 Unauthorized
        // External API returns 500 for expired tokens on auth-required endpoints
        if (error.response?.statusCode == 401) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.remove(StorageKeys.accessToken);
          Get.offAllNamed(AppRoutes.login);
        }
        handler.next(error);
      },
    ));
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
