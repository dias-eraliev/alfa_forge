import 'dart:convert';
import 'habit_model.dart';

class OnboardingData {
  // Профильные данные
  final String? fullName;
  final String? email;
  final String? phone;
  final String? city;
  
  // Имя пользователя
  final String? username;
  
  // Пароль (вводится в онбординге, используется при регистрации)
  final String? password;
  
  // Привычки
  final List<HabitModel> selectedHabits;
  final bool isCompleted;

  const OnboardingData({
    this.fullName,
    this.email,
    this.phone,
    this.city,
    this.username,
    this.password,
    this.selectedHabits = const [],
    this.isCompleted = false,
  });

  OnboardingData copyWith({
    String? fullName,
    String? email,
    String? phone,
    String? city,
    String? username,
    String? password,
    List<HabitModel>? selectedHabits,
    bool? isCompleted,
  }) {
    return OnboardingData(
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      city: city ?? this.city,
      username: username ?? this.username,
      password: password ?? this.password,
      selectedHabits: selectedHabits ?? this.selectedHabits,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fullName': fullName,
      'email': email,
      'phone': phone,
      'city': city,
      'username': username,
      'password': password,
      'selectedHabits': selectedHabits.map((habit) => habit.toJson()).toList(),
      'isCompleted': isCompleted,
    };
  }

  factory OnboardingData.fromJson(Map<String, dynamic> json) {
    return OnboardingData(
      fullName: json['fullName'] as String?,
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      city: json['city'] as String?,
      username: json['username'] as String?,
      password: json['password'] as String?,
      selectedHabits: (json['selectedHabits'] as List<dynamic>?)
              ?.map((item) => HabitModel.fromJson(item as Map<String, dynamic>))
              .toList() ??
          [],
      isCompleted: json['isCompleted'] as bool? ?? false,
    );
  }

  String toJsonString() => jsonEncode(toJson());

  factory OnboardingData.fromJsonString(String jsonString) {
    return OnboardingData.fromJson(jsonDecode(jsonString) as Map<String, dynamic>);
  }

  bool get isValid {
    return fullName != null && 
           fullName!.isNotEmpty &&
           email != null &&
           email!.isNotEmpty &&
           username != null && 
           username!.isNotEmpty && 
           password != null &&
           password!.isNotEmpty &&
           selectedHabits.isNotEmpty;
  }

  @override
  String toString() {
    return 'OnboardingData{fullName: $fullName, email: $email, username: $username, selectedHabits: ${selectedHabits.length}, isCompleted: $isCompleted}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OnboardingData &&
          runtimeType == other.runtimeType &&
          fullName == other.fullName &&
          email == other.email &&
          phone == other.phone &&
          city == other.city &&
          username == other.username &&
          password == other.password &&
          _listEquals(selectedHabits, other.selectedHabits) &&
          isCompleted == other.isCompleted;

  @override
  int get hashCode =>
      fullName.hashCode ^
      email.hashCode ^
      phone.hashCode ^
      city.hashCode ^
      username.hashCode ^
  password.hashCode ^
      selectedHabits.hashCode ^
      isCompleted.hashCode;

  bool _listEquals<T>(List<T> list1, List<T> list2) {
    if (list1.length != list2.length) return false;
    for (int i = 0; i < list1.length; i++) {
      if (list1[i] != list2[i]) return false;
    }
    return true;
  }
}
