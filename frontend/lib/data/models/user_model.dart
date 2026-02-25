class UserModel {
  final String? id;
  final String? email;
  final String? username;
  final String? name;
  final String? gender;
  final DateTime? birthday;
  final int? height;
  final int? weight;
  final List<String>? interests;
  final String? horoscope;
  final String? zodiac;
  final String? profileImage;

  UserModel({
    this.id,
    this.email,
    this.username,
    this.name,
    this.gender,
    this.birthday,
    this.height,
    this.weight,
    this.interests,
    this.horoscope,
    this.zodiac,
    this.profileImage,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['_id'] ?? json['id'],
      email: json['email'],
      username: json['username'],
      name: json['name'],
      gender: json['gender'],
      birthday: json['birthday'] != null ? DateTime.tryParse(json['birthday']) : null,
      height: json['height'],
      weight: json['weight'],
      interests: json['interests'] != null
          ? List<String>.from(json['interests'])
          : null,
      horoscope: json['horoscope'],
      zodiac: json['zodiac'],
      profileImage: json['profileImage'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (name != null) 'name': name,
      if (gender != null) 'gender': gender,
      if (birthday != null) 'birthday': birthday!.toIso8601String().split('T')[0],
      if (height != null) 'height': height,
      if (weight != null) 'weight': weight,
      if (interests != null) 'interests': interests,
    };
  }

  String get displayAge {
    if (birthday == null) return '';
    final now = DateTime.now();
    int age = now.year - birthday!.year;
    if (now.month < birthday!.month ||
        (now.month == birthday!.month && now.day < birthday!.day)) {
      age--;
    }
    return '$age';
  }
}
