import '../services/api_service.dart';

class UserModel {
  final int id;
  final String name;
  final String email;
  final String userType;
  final String? profileImageUrl;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.userType,
    this.profileImageUrl,
    this.createdAt,
    this.updatedAt,
  });

  /// Compatível com telas que usavam [accountType].
  String get accountType => userType;

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: _parseInt(json['id']),
      name: (json['name'] ?? '').toString(),
      email: (json['email'] ?? '').toString(),
      userType: (json['userType'] ?? 'cliente').toString(),
      profileImageUrl: ApiService.buildImageUrl(json['profileImageUrl']?.toString()),
      createdAt: _parseDateTime(json['createdAt']),
      updatedAt: _parseDateTime(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'userType': userType,
      if (profileImageUrl != null) 'profileImageUrl': profileImageUrl,
      if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
    };
  }

  Map<String, dynamic> toCreateJson({required String password}) {
    return {
      'name': name,
      'email': email,
      'password': password,
      'userType': userType,
    };
  }

  Map<String, dynamic> toUpdateJson({String? password}) {
    final map = <String, dynamic>{
      'name': name,
      'email': email,
      'userType': userType,
    };
    if (password != null && password.isNotEmpty) {
      map['password'] = password;
    }
    return map;
  }

  static int _parseInt(dynamic value) {
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    return DateTime.tryParse(value.toString());
  }
}
