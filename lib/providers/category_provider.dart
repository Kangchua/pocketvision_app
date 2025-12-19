import 'package:flutter/material.dart';
import '../models/category.dart';
import '../services/api_service.dart';

class CategoryProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  List<Category> _categories = [];
  bool _isLoading = false;
  String? _error;

  List<Category> get categories => _categories;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchCategories(int userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _categories = await _apiService.getCategories(userId);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addCategory({
    required int userId,
    required String name,
    String? colorHex,
    String? icon,
  }) async {
    try {
      final category = await _apiService.createCategory(
        userId: userId,
        name: name,
        colorHex: colorHex,
        icon: icon,
      );
      _categories.add(category);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Category? getCategoryById(int id) {
    try {
      return _categories.firstWhere((c) => c.id == id);
    } catch (e) {
      return null;
    }
  }

  Future<void> deleteCategory(int id) async {
    try {
      await _apiService.deleteCategory(id);
      _categories.removeWhere((c) => c.id == id);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }
}
