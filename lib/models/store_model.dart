class StoreModel {
  final String id;
  final String? ownerUserId;
  final String? categoryId;
  final String name;
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
    required this.category,
    this.description,
    this.address,
    this.openingHours,
    this.contact,
  });

  factory StoreModel.fromJson(Map<String, dynamic> json) {
    return StoreModel(
      id: json['id'].toString(),
      ownerUserId: json['ownerUserId']?.toString(),
      categoryId: json['categoryId']?.toString(),
      name: (json['name'] ?? '').toString(),
      category: (json['category'] ?? 'Sem categoria').toString(),
      description: json['description']?.toString(),
      address: json['address']?.toString(),
      openingHours: json['openingHours']?.toString(),
      contact: json['contact']?.toString(),
    );
  }
}
