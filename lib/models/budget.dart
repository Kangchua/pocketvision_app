class Budget {
  final int id;
  final int userId;
  final int categoryId;
  final String monthYear;
  final double limitAmount;
  final double spentAmount;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Budget({
    required this.id,
    required this.userId,
    required this.categoryId,
    required this.monthYear,
    required this.limitAmount,
    required this.spentAmount,
    this.createdAt,
    this.updatedAt,
  });

  factory Budget.fromJson(Map<String, dynamic> json) {
    return Budget(
      id: json['id'] ?? 0,
      userId: json['userId'] ?? 0,
      categoryId: json['categoryId'] ?? 0,
      monthYear: json['monthYear'] ?? '',
      limitAmount: (json['limitAmount'] ?? 0).toDouble(),
      spentAmount: (json['spentAmount'] ?? 0).toDouble(),
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'categoryId': categoryId,
      'monthYear': monthYear,
      'limitAmount': limitAmount,
      'spentAmount': spentAmount,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  double get remainingAmount => limitAmount - spentAmount;
  double get percentageUsed => (spentAmount / limitAmount * 100).clamp(0, 100);

  Budget copyWith({
    int? id,
    int? userId,
    int? categoryId,
    String? monthYear,
    double? limitAmount,
    double? spentAmount,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Budget(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      categoryId: categoryId ?? this.categoryId,
      monthYear: monthYear ?? this.monthYear,
      limitAmount: limitAmount ?? this.limitAmount,
      spentAmount: spentAmount ?? this.spentAmount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
