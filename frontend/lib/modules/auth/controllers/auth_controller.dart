import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
      // External API only authenticates by email field;
      // send same input for both to satisfy required DTO fields.
      final input = emailController.text.trim();
      final result = await _authProvider.login(
        input,
        input,
        passwordController.text,
      );

      final token = result['access_token'];
      if (token != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(StorageKeys.accessToken, token);
        Get.offAllNamed(AppRoutes.profile);
      }
    } catch (e) {
      Get.snackbar('Error', 'Invalid credentials',
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
      await _authProvider.register(
        emailController.text.trim(),
        usernameController.text.trim(),
        passwordController.text,
      );

      Get.snackbar('Success', 'Account created! Please login.',
          backgroundColor: Colors.green.withValues(alpha: 0.8), colorText: Colors.white);
      Get.offNamed(AppRoutes.login);
    } catch (e) {
      Get.snackbar('Error', 'Registration failed. Try again.',
          backgroundColor: Colors.red.withValues(alpha: 0.8), colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }
}
