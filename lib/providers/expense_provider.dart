import 'package:flutter/material.dart';
import '../models/expense.dart';
import '../services/api_service.dart';

class ExpenseProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  List<Expense> _expenses = [];
  bool _isLoading = false;
  String? _error;

  List<Expense> get expenses => _expenses;
  bool get isLoading => _isLoading;
  String? get error => _error;

  double get totalExpenses {
    return _expenses.fold(0, (sum, expense) => sum + expense.totalAmount);
  }

  Future<void> fetchExpenses(int userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _expenses = await _apiService.getExpenses(userId);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addExpense({
    required int userId,
    required int categoryId,
    String? storeName,
    required double totalAmount,
    required String paymentMethod,
    required String note,
    required DateTime expenseDate,
  }) async {
    try {
      final expense = await _apiService.createExpense(
        userId: userId,
        categoryId: categoryId,
        storeName: storeName,
        totalAmount: totalAmount,
        paymentMethod: paymentMethod,
        note: note,
        expenseDate: expenseDate,
      );
      _expenses.add(expense);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> updateExpense({
    required int id,
    required int userId,
    required int categoryId,
    String? storeName,
    required double totalAmount,
    required String paymentMethod,
    required String note,
    required DateTime expenseDate,
  }) async {
    try {
      final updatedExpense = await _apiService.updateExpense(
        id: id,
        userId: userId,
        categoryId: categoryId,
        storeName: storeName,
        totalAmount: totalAmount,
        paymentMethod: paymentMethod,
        note: note,
        expenseDate: expenseDate,
      );
      final index = _expenses.indexWhere((e) => e.id == id);
      if (index >= 0) {
        _expenses[index] = updatedExpense;
      }
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> deleteExpense(int id) async {
    try {
      await _apiService.deleteExpense(id);
      _expenses.removeWhere((e) => e.id == id);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  List<Expense> getExpensesByCategory(int categoryId) {
    return _expenses.where((e) => e.categoryId == categoryId).toList();
  }

  List<Expense> getExpensesByMonth(DateTime month) {
    return _expenses.where((e) =>
        e.expenseDate.year == month.year &&
        e.expenseDate.month == month.month).toList();
  }

  /// Lấy chi tiêu theo tuần (từ thứ 2 đến chủ nhật)
  List<Expense> getExpensesByWeek(DateTime date) {
    // Tính ngày đầu tuần (Thứ 2)
    final weekday = date.weekday; // 1 = Monday, 7 = Sunday
    final startOfWeek = date.subtract(Duration(days: weekday - 1));
    final endOfWeek = startOfWeek.add(Duration(days: 6));
    
    return _expenses.where((e) {
      return e.expenseDate.isAfter(startOfWeek.subtract(Duration(days: 1))) &&
             e.expenseDate.isBefore(endOfWeek.add(Duration(days: 1)));
    }).toList();
  }

  /// Lấy chi tiêu theo năm
  List<Expense> getExpensesByYear(int year) {
    return _expenses.where((e) => e.expenseDate.year == year).toList();
  }

  /// Lấy chi tiêu theo khoảng thời gian
  List<Expense> getExpensesByDateRange(DateTime startDate, DateTime endDate) {
    return _expenses.where((e) {
      return e.expenseDate.isAfter(startDate.subtract(Duration(days: 1))) &&
             e.expenseDate.isBefore(endDate.add(Duration(days: 1)));
    }).toList();
  }

  /// Tính tổng chi tiêu theo tuần
  double getTotalExpensesByWeek(DateTime date) {
    return getExpensesByWeek(date).fold(0.0, (sum, e) => sum + e.totalAmount);
  }

  /// Tính tổng chi tiêu theo tháng
  double getTotalExpensesByMonth(DateTime month) {
    return getExpensesByMonth(month).fold(0.0, (sum, e) => sum + e.totalAmount);
  }

  /// Tính tổng chi tiêu theo năm
  double getTotalExpensesByYear(int year) {
    return getExpensesByYear(year).fold(0.0, (sum, e) => sum + e.totalAmount);
  }

  /// Cập nhật chi tiêu từ hóa đơn
  /// Nếu expense đã tồn tại thì update, nếu chưa thì add mới
  Future<void> updateExpenseFromInvoice(int invoiceId, int userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Gọi API để convert invoice to expense
      final expense = await _apiService.convertInvoiceToExpense(invoiceId, userId);
      
      // Kiểm tra xem expense đã tồn tại chưa (dựa vào id)
      final existingIndex = _expenses.indexWhere((e) => e.id == expense.id);
      
      if (existingIndex >= 0) {
        // Update existing expense
        _expenses[existingIndex] = expense;
      } else {
        // Add new expense
        _expenses.add(expense);
      }
      
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
