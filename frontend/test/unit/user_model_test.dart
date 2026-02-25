import 'package:flutter_test/flutter_test.dart';
import 'package:youapp/data/models/user_model.dart';

void main() {
  group('UserModel', () {
    test('fromJson creates model correctly with all fields', () {
      final json = {
        '_id': '123',
        'email': 'test@test.com',
        'username': 'testuser',
        'name': 'Test User',
        'gender': 'Male',
        'birthday': '2000-05-15',
        'height': 175,
        'weight': 70,
        'interests': ['Music', 'Sports'],
        'horoscope': 'Taurus',
        'zodiac': 'Dragon',
        'profileImage': 'image.jpg',
      };

      final user = UserModel.fromJson(json);

      expect(user.id, '123');
      expect(user.email, 'test@test.com');
      expect(user.username, 'testuser');
      expect(user.name, 'Test User');
      expect(user.gender, 'Male');
      expect(user.birthday, DateTime(2000, 5, 15));
      expect(user.height, 175);
      expect(user.weight, 70);
      expect(user.interests, ['Music', 'Sports']);
      expect(user.horoscope, 'Taurus');
      expect(user.zodiac, 'Dragon');
      expect(user.profileImage, 'image.jpg');
    });

    test('fromJson handles null/missing fields', () {
      final json = <String, dynamic>{
        'email': 'test@test.com',
      };

      final user = UserModel.fromJson(json);

      expect(user.id, isNull);
      expect(user.name, isNull);
      expect(user.gender, isNull);
      expect(user.birthday, isNull);
      expect(user.height, isNull);
      expect(user.weight, isNull);
      expect(user.interests, isNull);
      expect(user.horoscope, isNull);
      expect(user.zodiac, isNull);
    });

    test('fromJson uses id fallback when _id is null', () {
      final json = {'id': 'abc456'};
      final user = UserModel.fromJson(json);
      expect(user.id, 'abc456');
    });

    test('toJson produces correct output', () {
      final user = UserModel(
        name: 'Test',
        gender: 'Female',
        birthday: DateTime(1995, 12, 25),
        height: 165,
        weight: 55,
        interests: ['Reading'],
      );

      final json = user.toJson();

      expect(json['name'], 'Test');
      expect(json['gender'], 'Female');
      expect(json['birthday'], '1995-12-25');
      expect(json['height'], 165);
      expect(json['weight'], 55);
      expect(json['interests'], ['Reading']);
    });

    test('toJson omits null fields', () {
      final user = UserModel(name: 'Test');
      final json = user.toJson();

      expect(json.containsKey('name'), true);
      expect(json.containsKey('gender'), false);
      expect(json.containsKey('birthday'), false);
      expect(json.containsKey('height'), false);
    });

    test('displayAge calculates correct age', () {
      final now = DateTime.now();
      final birthday = DateTime(now.year - 25, now.month, now.day);
      final user = UserModel(birthday: birthday);
      expect(user.displayAge, '25');
    });

    test('displayAge returns empty string when no birthday', () {
      final user = UserModel();
      expect(user.displayAge, '');
    });

    test('displayAge handles birthday not yet occurred this year', () {
      final now = DateTime.now();
      // Birthday is next month → age should be one less
      final futureMonth = now.month == 12 ? 1 : now.month + 1;
      final year = now.month == 12 ? now.year - 24 : now.year - 25;
      final birthday = DateTime(year, futureMonth, 1);
      final user = UserModel(birthday: birthday);
      expect(user.displayAge, '24');
    });
  });
}
