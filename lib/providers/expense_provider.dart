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
}
