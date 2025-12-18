class Expense {
  final int id;
  final int userId;
  final int categoryId;
  final String? storeName;
  final double totalAmount;
  final String paymentMethod;
  final String note;
  final DateTime expenseDate;
  final DateTime? createdAt;

  Expense({
    required this.id,
    required this.userId,
    required this.categoryId,
    this.storeName,
    required this.totalAmount,
    required this.paymentMethod,
    required this.note,
    required this.expenseDate,
    this.createdAt,
  });

  factory Expense.fromJson(Map<String, dynamic> json) {
    return Expense(
      id: json['id'] ?? 0,
      userId: json['userId'] ?? 0,
      categoryId: json['categoryId'] ?? 0,
      storeName: json['storeName'],
      totalAmount: (json['totalAmount'] ?? 0).toDouble(),
      paymentMethod: json['paymentMethod'] ?? 'OTHER',
      note: json['note'] ?? '',
      expenseDate: DateTime.parse(json['expenseDate'] ?? DateTime.now().toString()),
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'categoryId': categoryId,
      'storeName': storeName,
      'totalAmount': totalAmount,
      'paymentMethod': paymentMethod,
      'note': note,
      'expenseDate': expenseDate.toIso8601String(),
      'createdAt': createdAt?.toIso8601String(),
    };
  }
}
