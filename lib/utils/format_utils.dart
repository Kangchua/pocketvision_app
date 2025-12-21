import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import '../providers/currency_provider.dart';
import '../providers/language_provider.dart';

class FormatUtils {
  static String formatCurrency(double amount, BuildContext? context) {
    String currency = 'VND';
    String locale = 'vi_VN';
    String symbol = '₫';
    int decimalDigits = 0;

    if (context != null) {
      try {
        final currencyProvider = context.read<CurrencyProvider>();
        final languageProvider = context.read<LanguageProvider>();
        currency = currencyProvider.currency;
        locale = languageProvider.locale.toString();
        symbol = currencyProvider.getCurrencySymbol();
        
        // Set decimal digits based on currency
        switch (currency) {
          case 'USD':
          case 'EUR':
          case 'GBP':
            decimalDigits = 2;
            break;
          case 'VND':
          case 'JPY':
          case 'CNY':
          default:
            decimalDigits = 0;
            break;
        }
      } catch (e) {
        // Fallback to defaults if providers not available
      }
    }

    final formatter = NumberFormat.currency(
      locale: locale,
      symbol: symbol,
      decimalDigits: decimalDigits,
    );
    return formatter.format(amount);
  }

  static String formatDate(DateTime date, BuildContext? context) {
    String locale = 'vi_VN';
    if (context != null) {
      try {
        final languageProvider = context.read<LanguageProvider>();
        locale = languageProvider.locale.toString();
      } catch (e) {
        // Fallback to default
      }
    }
    return DateFormat('dd/MM/yyyy', locale).format(date);
  }

  static String formatDateShort(DateTime date, BuildContext? context) {
    String locale = 'vi_VN';
    if (context != null) {
      try {
        final languageProvider = context.read<LanguageProvider>();
        locale = languageProvider.locale.toString();
      } catch (e) {
        // Fallback to default
      }
    }
    return DateFormat('dd/MM', locale).format(date);
  }

  static String formatDateTime(DateTime dateTime, BuildContext? context) {
    String locale = 'vi_VN';
    if (context != null) {
      try {
        final languageProvider = context.read<LanguageProvider>();
        locale = languageProvider.locale.toString();
      } catch (e) {
        // Fallback to default
      }
    }
    return DateFormat('dd/MM/yyyy HH:mm', locale).format(dateTime);
  }

  static String formatMonth(DateTime date, BuildContext? context) {
    String locale = 'vi_VN';
    if (context != null) {
      try {
        final languageProvider = context.read<LanguageProvider>();
        locale = languageProvider.locale.toString();
      } catch (e) {
        // Fallback to default
      }
    }
    return DateFormat('MMMM yyyy', locale).format(date);
  }

  static String formatTimeAgo(DateTime dateTime, BuildContext? context) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    String locale = 'vi';
    if (context != null) {
      try {
        final languageProvider = context.read<LanguageProvider>();
        locale = languageProvider.language;
      } catch (e) {
        // Fallback to default
      }
    }

    if (locale == 'en') {
      if (difference.inSeconds < 60) {
        return 'Just now';
      } else if (difference.inMinutes < 60) {
        return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
      } else if (difference.inHours < 24) {
        return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
      } else if (difference.inDays < 7) {
        return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
      } else {
        return formatDate(dateTime, context);
      }
    } else {
      if (difference.inSeconds < 60) {
        return 'Vừa xong';
      } else if (difference.inMinutes < 60) {
        return '${difference.inMinutes} phút trước';
      } else if (difference.inHours < 24) {
        return '${difference.inHours} giờ trước';
      } else if (difference.inDays < 7) {
        return '${difference.inDays} ngày trước';
      } else {
        return formatDate(dateTime, context);
      }
    }
  }
}
