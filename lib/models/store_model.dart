import '../services/api_service.dart';

class StoreModel {
  final int id;
  final int? ownerUserId;
  final int? categoryId;
  final String name;
  final String? cnpj;
  final String category;
  final String? description;
  final String? address;
  final String? openingHours;
  final String? contact;
  final String? profileImageUrl;
  final bool isActive;

  const StoreModel({
    required this.id,
    this.ownerUserId,
    this.categoryId,
    required this.name,
    this.cnpj,
    this.category = 'Sem categoria',
    this.description,
    this.address,
    this.openingHours,
    this.contact,
    this.profileImageUrl,
    this.isActive = true,
  });

  factory StoreModel.fromJson(Map<String, dynamic> json) {
    return StoreModel(
      id: _parseInt(json['id']),
      ownerUserId: _parseNullableInt(json['ownerUserId']),
      categoryId: _parseNullableInt(json['categoryId']),
      name: (json['name'] ?? '').toString(),
      cnpj: json['cnpj']?.toString(),
      category: (json['category'] ?? 'Sem categoria').toString(),
      description: json['description']?.toString(),
      address: json['address']?.toString(),
      openingHours: json['openingHours']?.toString(),
      contact: json['contact']?.toString(),
      profileImageUrl: ApiService.buildImageUrl(json['profileImageUrl']?.toString()),
      isActive: _parseBool(json['isActive'], defaultValue: true),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      if (ownerUserId != null) 'ownerUserId': ownerUserId,
      if (categoryId != null) 'categoryId': categoryId,
      'name': name,
      if (cnpj != null && cnpj!.isNotEmpty) 'cnpj': cnpj,
      if (description != null) 'description': description,
      if (address != null) 'address': address,
      if (openingHours != null) 'openingHours': openingHours,
      if (contact != null) 'contact': contact,
      if (profileImageUrl != null) 'profileImageUrl': profileImageUrl,
      'isActive': isActive,
    };
  }

  Map<String, dynamic> toCreateJson() {
    return {
      'ownerUserId': ownerUserId,
      'categoryId': categoryId,
      'name': name,
      if (cnpj != null && cnpj!.isNotEmpty) 'cnpj': cnpj,
      if (description != null && description!.isNotEmpty)
        'description': description,
      if (address != null && address!.isNotEmpty) 'address': address,
      if (openingHours != null && openingHours!.isNotEmpty)
        'openingHours': openingHours,
      if (contact != null && contact!.isNotEmpty) 'contact': contact,
      if (profileImageUrl != null && profileImageUrl!.isNotEmpty)
        'profileImageUrl': profileImageUrl,
    };
  }

  Map<String, dynamic> toUpdateJson() => toCreateJson();

  static int _parseInt(dynamic value) {
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static int? _parseNullableInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    return int.tryParse(value.toString());
  }

  static bool _parseBool(dynamic value, {bool defaultValue = false}) {
    if (value == null) return defaultValue;
    if (value is bool) return value;
    return value.toString().toLowerCase() == 'true' || value.toString() == '1';
  }
}
