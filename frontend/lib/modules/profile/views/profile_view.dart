import 'package:flutter/material.dart';
import 'dart:io';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/api_constants.dart';
import '../../../app/routes/app_routes.dart';
import '../../../widgets/common_widgets.dart';
import '../controllers/profile_controller.dart';

class ProfileView extends GetView<ProfileController> {
  const ProfileView({super.key});

  void _showMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF162329),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.edit, color: Colors.white),
              title: const Text('Edit Profile',
                  style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(ctx);
                controller.isEditing.value = true;
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.redAccent),
              title: const Text('Logout',
                  style: TextStyle(color: Colors.redAccent)),
              onTap: () async {
                Navigator.pop(ctx);
                final prefs = await SharedPreferences.getInstance();
                await prefs.remove(StorageKeys.accessToken);
                Get.offAllNamed(AppRoutes.landing);
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: Obx(() {
            if (controller.isLoading.value && controller.user.value == null) {
              return const Center(child: CircularProgressIndicator());
            }

            final user = controller.user.value;
            return SingleChildScrollView(
              child: Column(
                children: [
                  // Header
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 6),
                    child: Row(
                      children: [
                        _buildBackButton(),
                        const Spacer(),
                        Text(
                          '@${user?.name?.trim() ?? user?.username ?? 'username'}',
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w600),
                        ),
                        const Spacer(),
                        GestureDetector(
                          onTap: () => Get.toNamed(AppRoutes.chatList),
                          behavior: HitTestBehavior.opaque,
                          child: const Padding(
                            padding: EdgeInsets.all(8),
                            child: Icon(Icons.chat_bubble_outline,
                                color: Colors.white, size: 22),
                          ),
                        ),
                        GestureDetector(
                          onTap: () => _showMenu(context),
                          behavior: HitTestBehavior.opaque,
                          child: const Padding(
                            padding: EdgeInsets.all(8),
                            child:
                                Icon(Icons.more_horiz, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Profile Card
                  _buildProfileCard(user),
                  const SizedBox(height: 24),

                  // About Section
                  _buildAboutSection(user),
                  const SizedBox(height: 18),

                  // Interest Section
                  _buildInterestSection(),
                  const SizedBox(height: 30),
                ],
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildBackButton() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          if (Get.previousRoute.isNotEmpty) {
            Get.back();
          }
        },
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
    );
  }

  Widget _buildProfileCard(dynamic user) {
    final hasData = user?.name != null && user.name!.isNotEmpty;
    final hasLocalImage = controller.selectedImagePath.value.isNotEmpty;
    final hasNetworkImage = user?.profileImage != null && user.profileImage!.isNotEmpty;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      height: 190,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: const Color(0xFF162329),
      ),
      child: Stack(
        children: [
          // Background: local image, network image, or gradient
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: hasLocalImage
                ? Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.file(
                        File(controller.selectedImagePath.value),
                        fit: BoxFit.cover,
                      ),
                      _buildImageGradientOverlay(),
                    ],
                  )
                : hasNetworkImage
                    ? Stack(
                        fit: StackFit.expand,
                        children: [
                          Image.network(
                            user.profileImage!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Container(
                              decoration: const BoxDecoration(
                                gradient: AppColors.profileCardGradient,
                              ),
                            ),
                          ),
                          _buildImageGradientOverlay(),
                        ],
                      )
                    : Container(
                        decoration: const BoxDecoration(
                          gradient: AppColors.profileCardGradient,
                        ),
                      ),
          ),
          // Bottom info
          Positioned(
            left: 13,
            bottom: 14,
            right: 13,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  hasData
                      ? '@${user.name?.trim() ?? user.username}, ${user.displayAge}'
                      : '@${user?.username ?? 'username'},',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w700),
                ),
                if (hasData &&
                    user?.gender != null &&
                    user.gender!.isNotEmpty)
                  Text(user.gender!,
                      style: const TextStyle(
                          color: Colors.white, fontSize: 13)),
                if (hasData &&
                    (user?.horoscope != null || user?.zodiac != null))
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Row(
                      children: [
                        if (user?.horoscope != null)
                          _buildHoroscopeTag(user.horoscope!),
                        if (user?.zodiac != null) ...[
                          const SizedBox(width: 8),
                          _buildZodiacTag(user.zodiac!),
                        ],
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHoroscopeTag(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(100),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.auto_awesome, color: Colors.white, size: 14),
          const SizedBox(width: 4),
          Text(text,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildZodiacTag(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(100),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.pets, color: Colors.white, size: 14),
          const SizedBox(width: 4),
          Text(text,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildImageGradientOverlay() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black.withValues(alpha: 0.76),
            Colors.transparent,
            Colors.black,
          ],
          stops: const [0.0, 0.46, 1.0],
        ),
      ),
    );
  }

  Widget _buildTag(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(100),
      ),
      child: Text(text,
          style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600)),
    );
  }

  Widget _buildAboutSection(dynamic user) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF0E191F),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('About',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w700)),
              Obx(() => GestureDetector(
                    onTap: () {
                      if (controller.isEditing.value) {
                        controller.saveProfile();
                      } else {
                        controller.isEditing.value = true;
                      }
                    },
                    behavior: HitTestBehavior.opaque,
                    child: Padding(
                      padding: const EdgeInsets.all(4),
                      child: controller.isEditing.value
                          ? ShaderMask(
                              shaderCallback: (bounds) =>
                                  AppColors.goldenGradient
                                      .createShader(bounds),
                              child: const Text('Save & Update',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600)),
                            )
                          : const Icon(Icons.edit,
                              color: Colors.white, size: 18),
                    ),
                  )),
            ],
          ),
          const SizedBox(height: 16),
          Obx(() {
            if (controller.isEditing.value) {
              return _buildEditForm();
            }

            // Read from controller directly (not closure parameter)
            // so this Obx reacts to user changes too.
            final currentUser = controller.user.value;
            final hasData =
                currentUser?.name != null && currentUser!.name!.isNotEmpty;
            if (!hasData) {
              return const Text(
                'Add in your your to help others know you better',
                style: TextStyle(color: AppColors.white40, fontSize: 14),
              );
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoRow(
                    'Birthday:',
                    currentUser.birthday != null
                        ? '${_pad(currentUser.birthday!.day)} / ${_pad(currentUser.birthday!.month)} / ${currentUser.birthday!.year} (Age ${currentUser.displayAge})'
                        : '-'),
                _buildInfoRow('Horoscope:', currentUser.horoscope ?? '-'),
                _buildInfoRow('Zodiac:', currentUser.zodiac ?? '-'),
                _buildInfoRow(
                    'Height:',
                    currentUser.height != null
                        ? '${currentUser.height} cm'
                        : '-'),
                _buildInfoRow(
                    'Weight:',
                    currentUser.weight != null
                        ? '${currentUser.weight} kg'
                        : '-'),
              ],
            );
          }),
        ],
      ),
    );
  }

  String _pad(int n) => n.toString().padLeft(2, '0');

  Widget _buildEditForm() {
    return Column(
      children: [
        // Add Image - circular like Figma
        Padding(
          padding: const EdgeInsets.only(bottom: 20),
          child: GestureDetector(
            onTap: () => controller.pickImage(),
            behavior: HitTestBehavior.opaque,
            child: Row(
              children: [
                Obx(() {
                  final hasImage =
                      controller.selectedImagePath.value.isNotEmpty;
                  return Container(
                    width: 58,
                    height: 58,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.08),
                      shape: BoxShape.circle,
                      image: hasImage
                          ? DecorationImage(
                              image: FileImage(File(
                                  controller.selectedImagePath.value)),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    child: !hasImage
                        ? const Icon(Icons.add,
                            color: Color(0xFFD5BE88), size: 24)
                        : null,
                  );
                }),
                const SizedBox(width: 12),
                const Text('Add image',
                    style:
                        TextStyle(color: Colors.white, fontSize: 13)),
              ],
            ),
          ),
        ),
        _buildEditField('Display name:', controller.nameController,
            hint: 'Enter name'),
        _buildGenderDropdown(),
        _buildDateField('Birthday:', controller),
        _buildComputedField('Horoscope:', controller.computedHoroscope),
        _buildComputedField('Zodiac:', controller.computedZodiac),
        _buildEditField('Height:', controller.heightController,
            suffix: 'cm', keyboardType: TextInputType.number),
        _buildEditField('Weight:', controller.weightController,
            suffix: 'kg', keyboardType: TextInputType.number),
        const SizedBox(height: 12),
        Obx(() => GradientButton(
              text: 'Save & Update',
              onPressed: controller.saveProfile,
              isLoading: controller.isLoading.value,
            )),
      ],
    );
  }

  Widget _buildGenderDropdown() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          const SizedBox(
            width: 110,
            child: Text('Gender:',
                style:
                    TextStyle(color: AppColors.white40, fontSize: 13)),
          ),
          Expanded(
            child: Obx(() => Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: AppColors.inputBg,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: controller.selectedGender.value.isEmpty
                          ? null
                          : controller.selectedGender.value,
                      hint: const Align(
                        alignment: Alignment.centerRight,
                        child: Text('Select Gender',
                            style: TextStyle(
                                color: AppColors.white40, fontSize: 13)),
                      ),
                      isExpanded: true,
                      dropdownColor: const Color(0xFF162329),
                      icon: const Icon(Icons.keyboard_arrow_down,
                          color: Colors.white, size: 18),
                      style: const TextStyle(
                          color: Colors.white, fontSize: 13),
                      items: ['Male', 'Female']
                          .map((g) => DropdownMenuItem(
                              value: g,
                              child: Align(
                                  alignment: Alignment.centerRight,
                                  child: Text(g))))
                          .toList(),
                      onChanged: (v) =>
                          controller.selectedGender.value = v ?? '',
                    ),
                  ),
                )),
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
            width: 110,
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
                        computed.value.isEmpty ? '--' : computed.value,
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

  Widget _buildEditField(String label, TextEditingController textController,
      {String? suffix, String? hint, TextInputType? keyboardType}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          SizedBox(
            width: 110,
            child: Text(label,
                style: const TextStyle(
                    color: AppColors.white40, fontSize: 13)),
          ),
          Expanded(
            child: TextField(
              controller: textController,
              keyboardType: keyboardType,
              style:
                  const TextStyle(color: Colors.white, fontSize: 13),
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
                hintText: hint,
                hintStyle: const TextStyle(
                    color: AppColors.white40, fontSize: 13),
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

  Widget _buildDateField(String label, ProfileController ctrl) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          SizedBox(
            width: 110,
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

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Text(label,
              style: const TextStyle(
                  color: AppColors.white40, fontSize: 13)),
          const SizedBox(width: 8),
          Text(value,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildInterestSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF0E191F),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Interest',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w700)),
              GestureDetector(
                onTap: () => Get.toNamed(AppRoutes.interests),
                behavior: HitTestBehavior.opaque,
                child: const Padding(
                  padding: EdgeInsets.all(4),
                  child:
                      Icon(Icons.edit, color: Colors.white, size: 18),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Obx(() {
            if (controller.interests.isEmpty) {
              return const Text(
                'Add in your interest to find a better match',
                style:
                    TextStyle(color: AppColors.white40, fontSize: 14),
              );
            }
            return Wrap(
              spacing: 8,
              runSpacing: 8,
              children: controller.interests
                  .map((i) => _buildTag(i))
                  .toList(),
            );
          }),
        ],
      ),
    );
  }
}
