import '../../core/network/api_client.dart';
import '../../core/constants/api_constants.dart';
import '../models/user_model.dart';

class ProfileProvider {
  final ApiClient _api;

  ProfileProvider(this._api);

  Future<UserModel> getProfile() async {
    final response = await _api.get(ApiConstants.getProfile);
    final data = response.data;
    // Handle wrapped response: {data: {...}} or direct user object
    if (data is Map<String, dynamic>) {
      if (data.containsKey('data') && data['data'] is Map<String, dynamic>) {
        return UserModel.fromJson(data['data']);
      }
      return UserModel.fromJson(data);
    }
    throw Exception('Invalid profile response format');
  }

  Future<UserModel> createProfile(Map<String, dynamic> data) async {
    final response = await _api.post(ApiConstants.createProfile, data: data);
    final resData = response.data;
    if (resData is Map<String, dynamic>) {
      if (resData.containsKey('data') && resData['data'] is Map<String, dynamic>) {
        return UserModel.fromJson(resData['data']);
      }
      return UserModel.fromJson(resData);
    }
    throw Exception('Invalid create profile response format');
  }

  Future<UserModel> updateProfile(Map<String, dynamic> data) async {
    final response = await _api.put(ApiConstants.updateProfile, data: data);
    final resData = response.data;
    if (resData is Map<String, dynamic>) {
      if (resData.containsKey('data') && resData['data'] is Map<String, dynamic>) {
        return UserModel.fromJson(resData['data']);
      }
      return UserModel.fromJson(resData);
    }
    throw Exception('Invalid update profile response format');
  }
}
