import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../../../widgets/common_widgets.dart';
import '../controllers/profile_controller.dart';

class InterestsView extends GetView<ProfileController> {
  const InterestsView({super.key});

  @override
  Widget build(BuildContext context) {
    final focusNode = FocusNode();

    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    children: [
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            focusNode.unfocus();
                            Get.back();
                          },
                          borderRadius: BorderRadius.circular(8),
                          child: const Padding(
                            padding: EdgeInsets.symmetric(
                                vertical: 10, horizontal: 4),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.chevron_left,
                                    color: Colors.white, size: 24),
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
                      const Spacer(),
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            final pending =
                                controller.interestController.text.trim();
                            if (pending.isNotEmpty) {
                              controller.addInterest(pending);
                            }
                            focusNode.unfocus();
                            Get.back();
                            // Save in background after navigating back
                            controller.saveProfile();
                          },
                          borderRadius: BorderRadius.circular(8),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 10, horizontal: 4),
                            child: ShaderMask(
                              shaderCallback: (bounds) =>
                                  AppColors.goldenGradient
                                      .createShader(bounds),
                              child: const Text('Save',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600)),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 56),

                // Golden subtitle
                ShaderMask(
                  shaderCallback: (bounds) =>
                      AppColors.goldenGradient.createShader(bounds),
                  child: const Text(
                    'Tell everyone about yourself',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w700),
                  ),
                ),
                const SizedBox(height: 12),

                // Title
                const Text(
                  'What interest you?',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 28),

                // Interest Input Box
                Expanded(
                  child: SingleChildScrollView(
                    child: Container(
                      width: double.infinity,
                      constraints: const BoxConstraints(minHeight: 80),
                      padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0D1D23),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Interest chips
                          Obx(() {
                            if (controller.interests.isEmpty) {
                              return const SizedBox.shrink();
                            }
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: Wrap(
                                spacing: 8,
                                runSpacing: 10,
                                children: controller.interests
                                    .map((interest) =>
                                        _buildChip(interest))
                                    .toList(),
                              ),
                            );
                          }),

                          // Text input field
                          TextField(
                            controller: controller.interestController,
                            focusNode: focusNode,
                            textInputAction: TextInputAction.done,
                            style: const TextStyle(
                                color: Colors.white, fontSize: 14),
                            decoration: InputDecoration(
                              isDense: true,
                              contentPadding: const EdgeInsets.symmetric(
                                  vertical: 12, horizontal: 0),
                              border: InputBorder.none,
                              hintText: 'Add interest...',
                              hintStyle: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.33),
                                  fontSize: 14),
                            ),
                            onSubmitted: (value) {
                              if (value.trim().isNotEmpty) {
                                controller.addInterest(value.trim());
                              }
                              focusNode.requestFocus();
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildChip(String interest) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(100),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(interest,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500)),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () => controller.removeInterest(interest),
            behavior: HitTestBehavior.opaque,
            child: const Padding(
              padding: EdgeInsets.all(2),
              child: Icon(Icons.close, color: Colors.white, size: 14),
            ),
          ),
        ],
      ),
    );
  }
}
