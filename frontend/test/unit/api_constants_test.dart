import 'package:flutter_test/flutter_test.dart';
import 'package:youapp/core/constants/api_constants.dart';

void main() {
  group('ApiConstants', () {
    test('baseUrl is correct', () {
      expect(ApiConstants.baseUrl, 'http://techtest.youapp.ai');
    });

    test('all endpoints start with /api/', () {
      expect(ApiConstants.register, startsWith('/api/'));
      expect(ApiConstants.login, startsWith('/api/'));
      expect(ApiConstants.createProfile, startsWith('/api/'));
      expect(ApiConstants.getProfile, startsWith('/api/'));
      expect(ApiConstants.updateProfile, startsWith('/api/'));
      expect(ApiConstants.sendMessage, startsWith('/api/'));
      expect(ApiConstants.viewMessages, startsWith('/api/'));
    });
  });

  group('StorageKeys', () {
    test('access token key is defined', () {
      expect(StorageKeys.accessToken, 'access_token');
    });

    test('user id key is defined', () {
      expect(StorageKeys.userId, 'user_id');
    });
  });
}
