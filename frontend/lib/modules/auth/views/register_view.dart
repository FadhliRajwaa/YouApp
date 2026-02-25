import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/routes/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../widgets/common_widgets.dart';
import '../controllers/auth_controller.dart';

class RegisterView extends GetView<AuthController> {
  const RegisterView({super.key});

  @override
  Widget build(BuildContext context) {
    controller.emailController.addListener(() => controller.update());
    controller.usernameController.addListener(() => controller.update());
    controller.passwordController.addListener(() => controller.update());
    controller.confirmPasswordController.addListener(() => controller.update());

    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 23),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 40),
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
                const Text(
                  'Register',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 25),
                AppTextField(
                  controller: controller.emailController,
                  hintText: 'Enter Email',
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 15),
                AppTextField(
                  controller: controller.usernameController,
                  hintText: 'Create Username',
                ),
                const SizedBox(height: 15),
                Obx(() => AppTextField(
                      controller: controller.passwordController,
                      hintText: 'Create Password',
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
                const SizedBox(height: 15),
                Obx(() => AppTextField(
                      controller: controller.confirmPasswordController,
                      hintText: 'Confirm Password',
                      obscureText: controller.obscureConfirmPassword.value,
                      suffixIcon: IconButton(
                        icon: ShaderMask(
                          shaderCallback: (bounds) =>
                              AppColors.goldenGradient.createShader(bounds),
                          child: Icon(
                            controller.obscureConfirmPassword.value
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                        onPressed: () =>
                            controller.obscureConfirmPassword.toggle(),
                      ),
                    )),
                const SizedBox(height: 25),
                // Register button - disabled when fields empty
                GetBuilder<AuthController>(
                  builder: (ctrl) {
                    final isEnabled =
                        ctrl.emailController.text.isNotEmpty &&
                            ctrl.usernameController.text.isNotEmpty &&
                            ctrl.passwordController.text.isNotEmpty &&
                            ctrl.confirmPasswordController.text.isNotEmpty;
                    return Obx(() => GradientButton(
                          text: 'Register',
                          isLoading: ctrl.isLoading.value,
                          isEnabled: isEnabled,
                          onPressed: ctrl.register,
                        ));
                  },
                ),
                const SizedBox(height: 50),
                Center(
                  child: GestureDetector(
                    onTap: () => Get.toNamed(AppRoutes.login),
                    child: RichText(
                      text: const TextSpan(
                        text: 'Have an account? ',
                        style: TextStyle(color: Colors.white, fontSize: 13),
                        children: [
                          TextSpan(
                            text: 'Login here',
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
