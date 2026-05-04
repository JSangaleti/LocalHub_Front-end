class UserModel {
  final String id;
  final String name;
  final String email;
  final String accountType;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.accountType,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'].toString(),
      name: (json['name'] ?? '').toString(),
      email: (json['email'] ?? '').toString(),
      accountType: (json['userType'] ?? 'cliente').toString(),
    );
  }
}
