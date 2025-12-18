import 'package:flutter/material.dart';
import '../models/invoice.dart';
import '../services/api_service.dart';

class InvoiceProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  List<Invoice> _invoices = [];
  bool _isLoading = false;
  String? _error;

  List<Invoice> get invoices => _invoices;
  bool get isLoading => _isLoading;
  String? get error => _error;

  double get totalInvoices {
    return _invoices.fold(0, (sum, invoice) => sum + invoice.totalAmount);
  }

  Future<void> fetchInvoices(int userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _invoices = await _apiService.getInvoices(userId);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> createInvoice({
    required int userId,
    int? categoryId,
    String? storeName,
    required DateTime invoiceDate,
    required double totalAmount,
    required String paymentMethod,
    String? note,
    String? imageUrl,
    required List<InvoiceItem> items,
  }) async {
    try {
      final invoice = await _apiService.createInvoice(
        userId: userId,
        categoryId: categoryId,
        storeName: storeName,
        invoiceDate: invoiceDate,
        totalAmount: totalAmount,
        paymentMethod: paymentMethod,
        note: note,
        imageUrl: imageUrl,
        items: items,
      );
      _invoices.add(invoice);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> updateInvoice({
    required int id,
    int? categoryId,
    String? storeName,
    required DateTime invoiceDate,
    required double totalAmount,
    required String paymentMethod,
    String? note,
    String? imageUrl,
    required List<InvoiceItem> items,
  }) async {
    try {
      final updatedInvoice = await _apiService.updateInvoice(
        id: id,
        categoryId: categoryId,
        storeName: storeName,
        invoiceDate: invoiceDate,
        totalAmount: totalAmount,
        paymentMethod: paymentMethod,
        note: note,
        imageUrl: imageUrl,
        items: items,
      );
      final index = _invoices.indexWhere((i) => i.id == id);
      if (index >= 0) {
        _invoices[index] = updatedInvoice;
      }
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> deleteInvoice(int id) async {
    try {
      await _apiService.deleteInvoice(id);
      _invoices.removeWhere((i) => i.id == id);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> uploadInvoice(int userId, dynamic imageFile) async {
    try {
      final invoice = await _apiService.uploadInvoice(userId, imageFile.path);
      _invoices.add(invoice);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  List<Invoice> getInvoicesByCategory(int categoryId) {
    return _invoices.where((i) => i.categoryId == categoryId).toList();
  }

  List<Invoice> getInvoicesByMonth(DateTime month) {
    return _invoices.where((i) =>
        i.invoiceDate.year == month.year &&
        i.invoiceDate.month == month.month).toList();
  }
}