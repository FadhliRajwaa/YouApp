import 'package:flutter/material.dart';
import 'dart:io';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../../../widgets/common_widgets.dart';
import '../controllers/profile_controller.dart';

class EditProfileView extends GetView<ProfileController> {
  const EditProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 14),
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
                          onTap: () => Get.back(),
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
                          onTap: controller.saveProfile,
                          borderRadius: BorderRadius.circular(8),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 10, horizontal: 4),
                            child: ShaderMask(
                              shaderCallback: (bounds) =>
                                  AppColors.goldenGradient
                                      .createShader(bounds),
                              child: const Text('Save & Update',
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

                // Profile Image Section
                Center(
                  child: GestureDetector(
                    onTap: () => controller.pickImage(),
                    behavior: HitTestBehavior.opaque,
                    child: Obx(() {
                      final hasImage =
                          controller.selectedImagePath.value.isNotEmpty;
                      return Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          color:
                              AppColors.white.withValues(alpha: 0.08),
                          shape: BoxShape.circle,
                          image: hasImage
                              ? DecorationImage(
                                  image: FileImage(File(controller
                                      .selectedImagePath.value)),
                                  fit: BoxFit.cover,
                                )
                              : null,
                        ),
                        child: !hasImage
                            ? const Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.add,
                                      color: Color(0xFFD5BE88),
                                      size: 28),
                                  SizedBox(height: 4),
                                  Text('Add image',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 12)),
                                ],
                              )
                            : null,
                      );
                    }),
                  ),
                ),
                const SizedBox(height: 30),

                // Form fields
                _buildFormField(
                    'Display name:', controller.nameController),
                _buildGenderDropdown(),
                _buildDateField('Birthday:', controller),
                _buildComputedField(
                    'Horoscope:', controller.computedHoroscope),
                _buildComputedField(
                    'Zodiac:', controller.computedZodiac),
                _buildFormField(
                    'Height:', controller.heightController,
                    suffix: 'cm',
                    keyboardType: TextInputType.number),
                _buildFormField(
                    'Weight:', controller.weightController,
                    suffix: 'kg',
                    keyboardType: TextInputType.number),

                const SizedBox(height: 24),
                Obx(() => GradientButton(
                      text: 'Save & Update',
                      isLoading: controller.isLoading.value,
                      onPressed: controller.saveProfile,
                    )),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFormField(
      String label, TextEditingController? textController,
      {String? suffix, TextInputType? keyboardType}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(label,
                style: const TextStyle(
                    color: AppColors.white40, fontSize: 13)),
          ),
          Expanded(
            child: TextField(
              controller: textController,
              keyboardType: keyboardType,
              style: const TextStyle(
                  color: Colors.white, fontSize: 13),
              textAlign: TextAlign.right,
              decoration: InputDecoration(
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(
                    vertical: 8, horizontal: 12),
                filled: true,
                fillColor: AppColors.inputBg,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                suffixText: suffix,
                suffixStyle: const TextStyle(
                    color: AppColors.white40, fontSize: 13),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComputedField(String label, RxString computed) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(label,
                style: const TextStyle(
                    color: AppColors.white40, fontSize: 13)),
          ),
          Expanded(
            child: Obx(() => Container(
                  padding: const EdgeInsets.symmetric(
                      vertical: 10, horizontal: 12),
                  decoration: BoxDecoration(
                    color: AppColors.inputBg,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                        computed.value.isEmpty
                            ? '--'
                            : computed.value,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w500)),
                  ),
                )),
          ),
        ],
      ),
    );
  }

  Widget _buildGenderDropdown() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          const SizedBox(
            width: 120,
            child: Text('Gender:',
                style: TextStyle(
                    color: AppColors.white40, fontSize: 13)),
          ),
          Expanded(
            child: Obx(() => Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: AppColors.inputBg,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value:
                          controller.selectedGender.value.isEmpty
                              ? null
                              : controller.selectedGender.value,
                      hint: const Align(
                        alignment: Alignment.centerRight,
                        child: Text('Select Gender',
                            style: TextStyle(
                                color: AppColors.white40,
                                fontSize: 13)),
                      ),
                      isExpanded: true,
                      dropdownColor: const Color(0xFF162329),
                      style: const TextStyle(
                          color: Colors.white, fontSize: 13),
                      items: ['Male', 'Female']
                          .map((g) => DropdownMenuItem(
                              value: g,
                              child: Align(
                                  alignment:
                                      Alignment.centerRight,
                                  child: Text(g))))
                          .toList(),
                      onChanged: (v) => controller
                          .selectedGender.value = v ?? '',
                    ),
                  ),
                )),
          ),
        ],
      ),
    );
  }

  Widget _buildDateField(String label, ProfileController ctrl) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(label,
                style: const TextStyle(
                    color: AppColors.white40, fontSize: 13)),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => ctrl.pickBirthday(Get.context!),
              behavior: HitTestBehavior.opaque,
              child: AbsorbPointer(
                child: TextField(
                  controller: ctrl.birthdayController,
                  style: const TextStyle(
                      color: Colors.white, fontSize: 13),
                  textAlign: TextAlign.right,
                  decoration: InputDecoration(
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 8, horizontal: 12),
                    filled: true,
                    fillColor: AppColors.inputBg,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                    hintText: 'DD MM YYYY',
                    hintStyle: const TextStyle(
                        color: AppColors.white40, fontSize: 13),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
