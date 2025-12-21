import 'package:flutter/material.dart';
import '../models/income.dart';
import '../services/api_service.dart';

class IncomeProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  List<Income> _incomes = [];
  bool _isLoading = false;
  String? _error;

  List<Income> get incomes => _incomes;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchIncomes() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _incomes = await _apiService.getIncomes();
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addIncome({
    required int? categoryId,
    required String sourceName,
    required double amount,
    required DateTime incomeDate,
    String? note,
  }) async {
    try {
      final income = await _apiService.createIncome(
        categoryId: categoryId,
        sourceName: sourceName,
        amount: amount,
        incomeDate: incomeDate,
        note: note,
      );
      _incomes.add(income);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> updateIncome(Income income) async {
    try {
      final updatedIncome = await _apiService.updateIncome(income);
      final index = _incomes.indexWhere((i) => i.id == income.id);
      if (index != -1) {
        _incomes[index] = updatedIncome;
        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> deleteIncome(int id) async {
    try {
      await _apiService.deleteIncome(id);
      _incomes.removeWhere((i) => i.id == id);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Income? getIncomeById(int id) {
    try {
      return _incomes.firstWhere((i) => i.id == id);
    } catch (e) {
      return null;
    }
  }
}