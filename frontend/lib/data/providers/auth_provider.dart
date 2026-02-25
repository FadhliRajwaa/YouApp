import '../../core/network/api_client.dart';
import '../../core/constants/api_constants.dart';

class AuthProvider {
  final ApiClient _api;

  AuthProvider(this._api);

  Future<Map<String, dynamic>> register(String email, String username, String password) async {
    final response = await _api.post(ApiConstants.register, data: {
      'email': email,
      'username': username,
      'password': password,
    });
    return response.data;
  }

  Future<Map<String, dynamic>> login(String email, String username, String password) async {
    final response = await _api.post(ApiConstants.login, data: {
      'email': email,
      'username': username,
      'password': password,
    });
    return response.data;
  }
}
