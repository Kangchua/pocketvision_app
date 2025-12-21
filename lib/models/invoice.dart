class Invoice {
  final int id;
  final int userId;
  final int? categoryId;
  final String? storeName;
  final DateTime invoiceDate;
  final double totalAmount;
  final String paymentMethod;
  final String? note;
  final String? imageUrl;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<InvoiceItem> items;

  Invoice({
    required this.id,
    required this.userId,
    this.categoryId,
    this.storeName,
    required this.invoiceDate,
    required this.totalAmount,
    required this.paymentMethod,
    this.note,
    this.imageUrl,
    required this.createdAt,
    required this.updatedAt,
    required this.items,
  });

  factory Invoice.fromJson(Map<String, dynamic> json) {
    return Invoice(
      id: json['id'] ?? 0,
      userId: json['userId'] ?? 0,
      categoryId: json['categoryId'],
      storeName: json['storeName'],
      invoiceDate: json['invoiceDate'] != null 
          ? DateTime.parse(json['invoiceDate'].toString())
          : DateTime.now(),
      totalAmount: (json['totalAmount'] ?? 0.0).toDouble(),
      paymentMethod: json['paymentMethod'] ?? 'CASH',
      note: json['note'],
      imageUrl: json['imageUrl'],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'].toString())
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'].toString())
          : DateTime.now(),
      items: (json['items'] as List<dynamic>?)
          ?.map((item) => InvoiceItem.fromJson(item))
          .toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'categoryId': categoryId,
      'storeName': storeName,
      'invoiceDate': invoiceDate.toIso8601String().split('T')[0],
      'totalAmount': totalAmount,
      'paymentMethod': paymentMethod,
      'note': note,
      'imageUrl': imageUrl,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'items': items.map((item) => item.toJson()).toList(),
    };
  }

  Invoice copyWith({
    int? id,
    int? userId,
    int? categoryId,
    String? storeName,
    DateTime? invoiceDate,
    double? totalAmount,
    String? paymentMethod,
    String? note,
    String? imageUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<InvoiceItem>? items,
  }) {
    return Invoice(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      categoryId: categoryId ?? this.categoryId,
      storeName: storeName ?? this.storeName,
      invoiceDate: invoiceDate ?? this.invoiceDate,
      totalAmount: totalAmount ?? this.totalAmount,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      note: note ?? this.note,
      imageUrl: imageUrl ?? this.imageUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      items: items ?? this.items,
    );
  }
}

class InvoiceItem {
  final int id;
  final int invoiceId;
  final String itemName;
  final int quantity;
  final double unitPrice;
  final double totalPrice;

  InvoiceItem({
    required this.id,
    required this.invoiceId,
    required this.itemName,
    required this.quantity,
    required this.unitPrice,
    required this.totalPrice,
  });

  factory InvoiceItem.fromJson(Map<String, dynamic> json) {
    return InvoiceItem(
      id: json['id'] ?? 0,
      invoiceId: json['invoiceId'] ?? 0,
      itemName: json['itemName'] ?? '',
      quantity: json['quantity'] ?? 1,
      unitPrice: (json['unitPrice'] ?? 0.0).toDouble(),
      totalPrice: (json['totalPrice'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'invoiceId': invoiceId,
      'itemName': itemName,
      'quantity': quantity,
      'unitPrice': unitPrice,
      'totalPrice': totalPrice,
    };
  }

  InvoiceItem copyWith({
    int? id,
    int? invoiceId,
    String? itemName,
    int? quantity,
    double? unitPrice,
    double? totalPrice,
  }) {
    return InvoiceItem(
      id: id ?? this.id,
      invoiceId: invoiceId ?? this.invoiceId,
      itemName: itemName ?? this.itemName,
      quantity: quantity ?? this.quantity,
      unitPrice: unitPrice ?? this.unitPrice,
      totalPrice: totalPrice ?? this.totalPrice,
    );
  }
}