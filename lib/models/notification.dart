class AppNotification {
  final int id;
  final int userId;
  final String type;  // BUDGET_WARNING, NEW_INVOICE, PAYMENT_REMINDER, GENERAL
  final String message;
  final int? relatedId;
  final bool isRead;
  final DateTime? createdAt;

  AppNotification({
    required this.id,
    required this.userId,
    required this.type,
    required this.message,
    this.relatedId,
    required this.isRead,
    this.createdAt,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id'] ?? 0,
      userId: json['userId'] ?? 0,
      type: json['type'] ?? 'GENERAL',
      message: json['message'] ?? '',
      relatedId: json['relatedId'],
      isRead: json['isRead'] ?? false,
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'type': type,
      'message': message,
      'relatedId': relatedId,
      'isRead': isRead,
      'createdAt': createdAt?.toIso8601String(),
    };
  }
}