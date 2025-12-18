class Category {
  final int id;
  final String name;
  final String? icon;
  final String? colorHex;
  final DateTime? createdAt;
  final int userId;

  Category({
    required this.id,
    required this.name,
    this.icon,
    this.colorHex,
    this.createdAt,
    required this.userId,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      icon: json['icon'],
      colorHex: json['colorHex'],
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      userId: json['userId'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'icon': icon,
      'colorHex': colorHex,
      'createdAt': createdAt?.toIso8601String(),
      'userId': userId,
    };
  }
}
