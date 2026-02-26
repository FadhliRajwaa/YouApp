import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';
import '../../../data/models/user_model.dart';
import '../../../data/providers/profile_provider.dart';

class ProfileController extends GetxController {
  final isLoading = false.obs;
  final isEditing = false.obs;
  final user = Rxn<UserModel>();

  final nameController = TextEditingController();
  final birthdayController = TextEditingController();
  final heightController = TextEditingController();
  final weightController = TextEditingController();
  final interestController = TextEditingController();

  final selectedGender = ''.obs;
  final interests = <String>[].obs;
  final selectedBirthday = Rxn<DateTime>();
  final selectedImagePath = ''.obs;
  final computedHoroscope = ''.obs;
  final computedZodiac = ''.obs;

  late final ProfileProvider _profileProvider;
  final _imagePicker = ImagePicker();

  @override
  void onInit() {
    super.onInit();
    _profileProvider = ProfileProvider(ApiClient());
    loadProfile();
  }

  @override
  void onClose() {
    nameController.dispose();
    birthdayController.dispose();
    heightController.dispose();
    weightController.dispose();
    interestController.dispose();
    super.onClose();
  }

  Future<void> loadProfile() async {
    isLoading.value = true;
    try {
      final profile = await _profileProvider.getProfile();
      user.value = profile;
      _populateFields(profile);
    } on DioException catch (e) {
      debugPrint('Load profile error: $e');
    } catch (e) {
      debugPrint('Load profile error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void _populateFields(UserModel profile) {
    nameController.text = profile.name?.trim() ?? '';
    selectedGender.value = profile.gender ?? '';
    if (profile.birthday != null) {
      selectedBirthday.value = profile.birthday;
      birthdayController.text =
          DateFormat('dd MM yyyy').format(profile.birthday!);
      _computeHoroscopeZodiac(profile.birthday!);
    }
    heightController.text = profile.height?.toString() ?? '';
    weightController.text = profile.weight?.toString() ?? '';
    interests.value = profile.interests ?? [];
  }

  void _computeHoroscopeZodiac(DateTime date) {
    computedHoroscope.value = _getHoroscope(date.month, date.day);
    computedZodiac.value = _getChineseZodiac(date.year);
  }

  String _getHoroscope(int month, int day) {
    if ((month == 3 && day >= 21) || (month == 4 && day <= 19)) return 'Aries';
    if ((month == 4 && day >= 20) || (month == 5 && day <= 20)) return 'Taurus';
    if ((month == 5 && day >= 21) || (month == 6 && day <= 21)) return 'Gemini';
    if ((month == 6 && day >= 22) || (month == 7 && day <= 22)) return 'Cancer';
    if ((month == 7 && day >= 23) || (month == 8 && day <= 22)) return 'Leo';
    if ((month == 8 && day >= 23) || (month == 9 && day <= 22)) return 'Virgo';
    if ((month == 9 && day >= 23) || (month == 10 && day <= 23)) return 'Libra';
    if ((month == 10 && day >= 24) || (month == 11 && day <= 21)) {
      return 'Scorpio';
    }
    if ((month == 11 && day >= 22) || (month == 12 && day <= 21)) {
      return 'Sagittarius';
    }
    if ((month == 12 && day >= 22) || (month == 1 && day <= 19)) {
      return 'Capricorn';
    }
    if ((month == 1 && day >= 20) || (month == 2 && day <= 18)) {
      return 'Aquarius';
    }
    return 'Pisces';
  }

  String _getChineseZodiac(int year) {
    const zodiacs = [
      'Rat', 'Ox', 'Tiger', 'Rabbit', 'Dragon', 'Snake',
      'Horse', 'Goat', 'Monkey', 'Rooster', 'Dog', 'Pig',
    ];
    final offset = year - 1900;
    return zodiacs[((offset % 12) + 12) % 12];
  }

  Future<void> pickBirthday(BuildContext context) async {
    final date = await showDatePicker(
      context: context,
      initialDate: selectedBirthday.value ?? DateTime(2000),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFF62CDCB),
              surface: Color(0xFF162329),
            ),
          ),
          child: child!,
        );
      },
    );

    if (date != null) {
      selectedBirthday.value = date;
      birthdayController.text = DateFormat('dd MM yyyy').format(date);
      _computeHoroscopeZodiac(date);
    }
  }

  void addInterest(String interest) {
    if (interest.isNotEmpty && !interests.contains(interest)) {
      interests.add(interest);
      interestController.clear();
    }
  }

  void removeInterest(String interest) {
    interests.remove(interest);
  }

  Future<void> pickImage() async {
    final source = await Get.bottomSheet<ImageSource>(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Color(0xFF162329),
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
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
              leading: const Icon(Icons.camera_alt, color: Colors.white),
              title: const Text('Camera',
                  style: TextStyle(color: Colors.white)),
              onTap: () => Get.back(result: ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library, color: Colors.white),
              title: const Text('Gallery',
                  style: TextStyle(color: Colors.white)),
              onTap: () => Get.back(result: ImageSource.gallery),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );

    if (source == null) return;

    final picked = await _imagePicker.pickImage(
      source: source,
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 85,
    );

    if (picked != null) {
      selectedImagePath.value = picked.path;
    }
  }

  Future<void> saveProfile() async {
    // Guard: prevent concurrent saves
    if (isLoading.value) return;

    isLoading.value = true;
    try {
      final data = <String, dynamic>{
        'name': nameController.text.trim().isEmpty ? null : nameController.text.trim(),
        'gender': selectedGender.value.isNotEmpty ? selectedGender.value : null,
        'birthday':
            selectedBirthday.value?.toIso8601String().split('T')[0],
        'height': int.tryParse(heightController.text),
        'weight': int.tryParse(weightController.text),
        'interests': interests.isEmpty ? null : interests.toList(),
      };
      // Remove null values to avoid sending empty fields
      data.removeWhere((key, value) => value == null);

      // Try update first; if 500/404, fallback to create
      UserModel profile;
      try {
        profile = await _profileProvider.updateProfile(data);
      } on DioException catch (e) {
        if (e.response?.statusCode == 500 || e.response?.statusCode == 404) {
          profile = await _profileProvider.createProfile(data);
        } else {
          rethrow;
        }
      }

      // Build profile from LOCAL data (text controllers) merged with
      // API response for identity/computed fields. This avoids stale data
      // if the external API response hasn't caught up yet.
      final savedProfile = UserModel(
        id: profile.id ?? user.value?.id,
        email: profile.email ?? user.value?.email,
        username: profile.username ?? user.value?.username,
        name: nameController.text.trim(),
        gender: selectedGender.value.isNotEmpty
            ? selectedGender.value
            : profile.gender,
        birthday: selectedBirthday.value,
        height: int.tryParse(heightController.text),
        weight: int.tryParse(weightController.text),
        interests: interests.toList(),
        horoscope: computedHoroscope.value.isNotEmpty
            ? computedHoroscope.value
            : profile.horoscope,
        zodiac: computedZodiac.value.isNotEmpty
            ? computedZodiac.value
            : profile.zodiac,
        profileImage: profile.profileImage ?? user.value?.profileImage,
      );

      // Update reactive state — don't call _populateFields here because
      // text controllers already hold the correct values the user typed.
      user.value = savedProfile;
      isEditing.value = false;

      Get.snackbar('Success', 'Profile updated!',
          backgroundColor: Colors.green.withValues(alpha: 0.8),
          colorText: Colors.white);
    } on DioException catch (e) {
      final statusCode = e.response?.statusCode;
      final errorMsg =
          e.response?.data?['message'] ?? e.message ?? 'Network error';
      debugPrint('Save profile DioError: $statusCode - $errorMsg');
      debugPrint('Response data: ${e.response?.data}');

      if (statusCode == 500) {
        Get.snackbar(
            'Session Expired', 'Please login again to save profile.',
            backgroundColor: Colors.orange.withValues(alpha: 0.9),
            colorText: Colors.white,
            duration: const Duration(seconds: 4));
      } else {
        Get.snackbar('Error', errorMsg.toString(),
            backgroundColor: Colors.red.withValues(alpha: 0.8),
            colorText: Colors.white);
      }
    } catch (e) {
      debugPrint('Save profile error: $e');
      Get.snackbar('Error', 'Failed to save profile',
          backgroundColor: Colors.red.withValues(alpha: 0.8),
          colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }
}
