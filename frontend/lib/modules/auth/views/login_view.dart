import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/routes/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../widgets/common_widgets.dart';
import '../controllers/auth_controller.dart';

class LoginView extends GetView<AuthController> {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    // Listen to text changes for enabling/disabling button
    controller.emailController.addListener(() => controller.update());
    controller.passwordController.addListener(() => controller.update());

    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 23),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 40),
                // Back button
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => Get.back(),
                    borderRadius: BorderRadius.circular(8),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 4),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.chevron_left, color: Colors.white, size: 24),
                          SizedBox(width: 2),
                          Text('Back',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700)),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 60),
                // Title
                const Text(
                  'Login',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 25),
                // Email/Username field
                AppTextField(
                  controller: controller.emailController,
                  hintText: 'Enter Username/Email',
                ),
                const SizedBox(height: 15),
                // Password field
                Obx(() => AppTextField(
                      controller: controller.passwordController,
                      hintText: 'Enter Password',
                      obscureText: controller.obscurePassword.value,
                      suffixIcon: IconButton(
                        icon: ShaderMask(
                          shaderCallback: (bounds) =>
                              AppColors.goldenGradient.createShader(bounds),
                          child: Icon(
                            controller.obscurePassword.value
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                        onPressed: () => controller.obscurePassword.toggle(),
                      ),
                    )),
                const SizedBox(height: 25),
                // Login button - disabled when fields empty
                GetBuilder<AuthController>(
                  builder: (ctrl) {
                    final isEnabled = ctrl.emailController.text.isNotEmpty &&
                        ctrl.passwordController.text.isNotEmpty;
                    return Obx(() => GradientButton(
                          text: 'Login',
                          isLoading: ctrl.isLoading.value,
                          isEnabled: isEnabled,
                          onPressed: ctrl.login,
                        ));
                  },
                ),
                const SizedBox(height: 50),
                // Register link
                Center(
                  child: GestureDetector(
                    onTap: () => Get.toNamed(AppRoutes.register),
                    child: RichText(
                      text: const TextSpan(
                        text: 'No account? ',
                        style: TextStyle(color: Colors.white, fontSize: 13),
                        children: [
                          TextSpan(
                            text: 'Register here',
                            style: TextStyle(
                              decoration: TextDecoration.underline,
                              color: Color(0xFFD5BE88),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
