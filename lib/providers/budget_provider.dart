import 'package:flutter/material.dart';
import '../models/budget.dart';
import '../services/api_service.dart';

class BudgetProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  List<Budget> _budgets = [];
  bool _isLoading = false;
  String? _error;

  List<Budget> get budgets => _budgets;
  bool get isLoading => _isLoading;
  String? get error => _error;

  double get totalBudget {
    return _budgets.fold(0, (sum, budget) => sum + budget.limitAmount);
  }

  double get totalSpent {
    return _budgets.fold(0, (sum, budget) => sum + budget.spentAmount);
  }

  Future<void> fetchBudgets(int userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _budgets = await _apiService.getBudgets(userId);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addBudget({
    required int userId,
    required int categoryId,
    required String monthYear,
    required double limitAmount,
  }) async {
    try {
      final budget = await _apiService.createBudget(
        userId: userId,
        categoryId: categoryId,
        monthYear: monthYear,
        limitAmount: limitAmount,
      );
      _budgets.add(budget);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> createBudget(Budget budget) async {
    try {
      final createdBudget = await _apiService.createBudget(
        userId: budget.userId,
        categoryId: budget.categoryId,
        monthYear: budget.monthYear,
        limitAmount: budget.limitAmount,
      );
      _budgets.add(createdBudget);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> updateBudget(Budget budget) async {
    try {
      final updatedBudget = await _apiService.updateBudget(budget);
      final index = _budgets.indexWhere((b) => b.id == budget.id);
      if (index >= 0) {
        _budgets[index] = updatedBudget;
      }
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> deleteBudget(int id) async {
    try {
      await _apiService.deleteBudget(id);
      _budgets.removeWhere((b) => b.id == id);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  /// Tính lại tất cả ngân sách (recalculate spentAmount)
  /// Dùng khi có nghi ngờ dữ liệu không đồng bộ
  Future<void> recalculateBudgets(int userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _budgets = await _apiService.recalculateBudgets(userId);
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
