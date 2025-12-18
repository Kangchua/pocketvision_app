class Income {
  final int id;
  final int userId;
  final int? categoryId;
  final String sourceName;
  final double amount;
  final DateTime incomeDate;
  final String? note;
  final DateTime? createdAt;

  Income({
    required this.id,
    required this.userId,
    this.categoryId,
    required this.sourceName,
    required this.amount,
    required this.incomeDate,
    this.note,
    this.createdAt,
  });

  factory Income.fromJson(Map<String, dynamic> json) {
    return Income(
      id: json['id'] ?? 0,
      userId: json['userId'] ?? 0,
      categoryId: json['categoryId'],
      sourceName: json['sourceName'] ?? '',
      amount: (json['amount'] ?? 0).toDouble(),
      incomeDate: DateTime.parse(json['incomeDate']),
      note: json['note'],
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'categoryId': categoryId,
      'sourceName': sourceName,
      'amount': amount,
      'incomeDate': incomeDate.toIso8601String().split('T')[0],
      'note': note,
      'createdAt': createdAt?.toIso8601String(),
    };
  }
}