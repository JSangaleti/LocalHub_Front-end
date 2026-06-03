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
    };
  }

  Map<String, dynamic> toCreateJson() {
    return {
      'ownerUserId': ownerUserId,
      'categoryId': categoryId,
      'name': name,
      if (cnpj != null && cnpj!.isNotEmpty) 'cnpj': cnpj,
      if (description != null && description!.isNotEmpty) 'description': description,
      if (address != null && address!.isNotEmpty) 'address': address,
      if (openingHours != null && openingHours!.isNotEmpty) 'openingHours': openingHours,
      if (contact != null && contact!.isNotEmpty) 'contact': contact,
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
}
