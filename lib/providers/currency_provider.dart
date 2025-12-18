import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CurrencyProvider extends ChangeNotifier {
  String _currency = 'VND';

  String get currency => _currency;

  CurrencyProvider() {
    _loadCurrency();
  }

  Future<void> _loadCurrency() async {
    final prefs = await SharedPreferences.getInstance();
    _currency = prefs.getString('currency') ?? 'VND';
    notifyListeners();
  }

  Future<void> setCurrency(String currency) async {
    if (_currency == currency) return;
    
    _currency = currency;
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('currency', currency);
    
    notifyListeners();
  }

  String getCurrencySymbol() {
    switch (_currency) {
      case 'USD':
        return '\$';
      case 'EUR':
        return '€';
      case 'VND':
        return '₫';
      case 'JPY':
        return '¥';
      case 'GBP':
        return '£';
      case 'CNY':
        return '¥';
      default:
        return '₫';
    }
  }

  String getCurrencyName() {
    switch (_currency) {
      case 'USD':
        return 'US Dollar';
      case 'EUR':
        return 'Euro';
      case 'VND':
        return 'Vietnamese Dong';
      case 'JPY':
        return 'Japanese Yen';
      case 'GBP':
        return 'British Pound';
      case 'CNY':
        return 'Chinese Yuan';
      default:
        return 'Vietnamese Dong';
    }
  }
}


