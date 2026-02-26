class ApiConstants {
  // Change this to your backend URL when running locally
  // e.g., 'http://192.168.x.x:3000' for local backend with chat support
  static const String baseUrl = 'http://192.168.100.114:3000';

  static const String register = '/api/register';
  static const String login = '/api/login';
  static const String refresh = '/api/refresh';
  static const String createProfile = '/api/createProfile';
  static const String getProfile = '/api/getProfile';
  static const String updateProfile = '/api/updateProfile';
  static const String searchUsers = '/api/searchUsers';
  static const String sendMessage = '/api/sendMessage';
  static const String viewMessages = '/api/viewMessages';
}

class StorageKeys {
  static const String accessToken = 'access_token';
  static const String refreshToken = 'refresh_token';
  static const String userId = 'user_id';
}
