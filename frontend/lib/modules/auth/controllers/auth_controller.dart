import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../../core/network/api_client.dart';
import '../../../core/constants/api_constants.dart';
import '../../../data/providers/auth_provider.dart';
import '../../../app/routes/app_routes.dart';

class AuthController extends GetxController {
  final emailController = TextEditingController();
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  final isLoading = false.obs;
  final obscurePassword = true.obs;
  final obscureConfirmPassword = true.obs;

  late final AuthProvider _authProvider;

  @override
  void onInit() {
    super.onInit();
    _authProvider = AuthProvider(ApiClient());
  }

  @override
  void onClose() {
    emailController.dispose();
    usernameController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }

  Future<void> login() async {
    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      Get.snackbar('Error', 'Please fill in all fields',
          backgroundColor: Colors.red.withValues(alpha: 0.8), colorText: Colors.white);
      return;
    }

    isLoading.value = true;
    try {
      final input = emailController.text.trim().toLowerCase();
      final result = await _authProvider.login(
        input,
        passwordController.text,
      );

      final message = result['message']?.toString() ?? '';
      final token = result['access_token'];
      if (token != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(StorageKeys.accessToken, token);

        // Extract userId from JWT payload or response
        final userId = result['userId']?.toString() ?? _extractUserIdFromJwt(token);
        if (userId.isNotEmpty) {
          await prefs.setString(StorageKeys.userId, userId);
        }

        // Store refresh_token if available (our backend provides it)
        final refreshToken = result['refresh_token'];
        if (refreshToken != null) {
          await prefs.setString(StorageKeys.refreshToken, refreshToken);
        }

        Get.offAllNamed(AppRoutes.profile);
      } else {
        Get.snackbar('Error', message.isNotEmpty ? message : 'Login failed',
            backgroundColor: Colors.red.withValues(alpha: 0.8), colorText: Colors.white);
      }
    } catch (e) {
      String errorMsg = 'Invalid credentials';
      if (e is DioException && e.response?.data != null) {
        final data = e.response!.data;
        if (data is Map && data['message'] != null) {
          errorMsg = data['message'] is List
              ? (data['message'] as List).join(', ')
              : data['message'].toString();
        }
      }
      Get.snackbar('Error', errorMsg,
          backgroundColor: Colors.red.withValues(alpha: 0.8), colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> register() async {
    if (emailController.text.isEmpty ||
        usernameController.text.isEmpty ||
        passwordController.text.isEmpty) {
      Get.snackbar('Error', 'Please fill in all fields',
          backgroundColor: Colors.red.withValues(alpha: 0.8), colorText: Colors.white);
      return;
    }

    if (passwordController.text != confirmPasswordController.text) {
      Get.snackbar('Error', 'Passwords do not match',
          backgroundColor: Colors.red.withValues(alpha: 0.8), colorText: Colors.white);
      return;
    }

    isLoading.value = true;
    try {
      final result = await _authProvider.register(
        emailController.text.trim(),
        usernameController.text.trim(),
        passwordController.text,
      );

      final message = result['message']?.toString() ?? '';

      if (message.toLowerCase().contains('already exists')) {
        Get.snackbar('Error', 'User already exists. Please login instead.',
            backgroundColor: Colors.red.withValues(alpha: 0.8), colorText: Colors.white);
        return;
      }

      Get.snackbar('Success', 'Account created! Please login.',
          backgroundColor: Colors.green.withValues(alpha: 0.8), colorText: Colors.white);
      Get.offNamed(AppRoutes.login);
    } catch (e) {
      String errorMsg = 'Registration failed. Try again.';
      if (e is DioException && e.response?.data != null) {
        final data = e.response!.data;
        if (data is Map && data['message'] != null) {
          errorMsg = data['message'] is List
              ? (data['message'] as List).join(', ')
              : data['message'].toString();
        }
      }
      Get.snackbar('Error', errorMsg,
          backgroundColor: Colors.red.withValues(alpha: 0.8), colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }

  /// Decode JWT payload to extract user ID (works without verification)
  String _extractUserIdFromJwt(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return '';
      // Pad base64 string if needed
      String payload = parts[1];
      payload = base64Url.normalize(payload);
      final decoded = utf8.decode(base64Url.decode(payload));
      final Map<String, dynamic> data = json.decode(decoded);
      // External API uses 'id', our backend uses 'sub'
      return (data['sub'] ?? data['id'] ?? '').toString();
    } catch (_) {
      return '';
    }
  }
}
