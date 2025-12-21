import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'app_theme.dart';

/// Utility class để xử lý exceptions và hiển thị error messages cho người dùng
class ExceptionHandler {
  /// Xử lý exception và trả về message phù hợp cho người dùng
  static String getErrorMessage(dynamic error) {
    if (error is DioException) {
      return _handleDioException(error);
    } else if (error is FormatException) {
      return 'Định dạng dữ liệu không hợp lệ. Vui lòng kiểm tra lại.';
    } else if (error is TypeError) {
      return 'Lỗi kiểu dữ liệu. Vui lòng thử lại.';
    } else if (error is ArgumentError) {
      return 'Thông tin không hợp lệ: ${error.message}';
    } else if (error is StateError) {
      return 'Lỗi trạng thái ứng dụng. Vui lòng thử lại.';
    } else if (error is Exception) {
      final message = error.toString();
      if (message.contains('SocketException') || message.contains('Failed host lookup')) {
        return 'Không thể kết nối đến server. Vui lòng kiểm tra kết nối mạng.';
      }
      if (message.contains('TimeoutException')) {
        return 'Kết nối timeout. Vui lòng thử lại.';
      }
      if (message.contains('FormatException')) {
        return 'Định dạng dữ liệu không hợp lệ.';
      }
      // Loại bỏ "Exception: " prefix nếu có
      return message.replaceFirst(RegExp(r'^Exception:\s*'), '');
    }
    return error.toString();
  }

  /// Xử lý DioException cụ thể
  static String _handleDioException(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.sendTimeout:
        return 'Kết nối timeout. Vui lòng kiểm tra kết nối mạng và thử lại.';
      
      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        if (statusCode == 401) {
          return 'Phiên đăng nhập đã hết hạn. Vui lòng đăng nhập lại.';
        } else if (statusCode == 403) {
          return 'Bạn không có quyền thực hiện thao tác này.';
        } else if (statusCode == 404) {
          return 'Không tìm thấy dữ liệu.';
        } else if (statusCode == 409) {
          return 'Dữ liệu đã tồn tại hoặc bị xung đột.';
        } else if (statusCode == 422) {
          return 'Dữ liệu không hợp lệ. Vui lòng kiểm tra lại thông tin.';
        } else if (statusCode == 500) {
          return 'Lỗi server. Vui lòng thử lại sau.';
        } else if (statusCode == 503) {
          return 'Server đang bảo trì. Vui lòng thử lại sau.';
        } else {
          // Lấy message từ response nếu có
          final responseData = error.response?.data;
          if (responseData is Map && responseData['message'] != null) {
            return responseData['message'].toString();
          }
          return 'Lỗi server (${statusCode ?? 'unknown'}). Vui lòng thử lại.';
        }
      
      case DioExceptionType.cancel:
        return 'Yêu cầu đã bị hủy.';
      
      case DioExceptionType.connectionError:
        return 'Không thể kết nối đến server. Vui lòng kiểm tra kết nối mạng.';
      
      case DioExceptionType.badCertificate:
        return 'Lỗi chứng chỉ bảo mật. Vui lòng liên hệ hỗ trợ.';
      
      case DioExceptionType.unknown:
        final message = error.message;
        if (message != null && message.isNotEmpty) {
          if (message.contains('SocketException') || message.contains('Failed host lookup')) {
            return 'Không thể kết nối đến server. Vui lòng kiểm tra kết nối mạng.';
          }
          if (message.contains('TimeoutException')) {
            return 'Kết nối timeout. Vui lòng thử lại.';
          }
        }
        return 'Đã xảy ra lỗi. Vui lòng thử lại.';
    }
  }

  /// Hiển thị error snackbar với message phù hợp
  static void showErrorSnackBar(BuildContext context, dynamic error, {Duration? duration}) {
    if (!context.mounted) return;
    
    final message = getErrorMessage(error);
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(fontSize: 14),
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.danger,
        duration: duration ?? const Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  /// Hiển thị success snackbar
  static void showSuccessSnackBar(BuildContext context, String message, {Duration? duration}) {
    if (!context.mounted) return;
    
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_outline, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(fontSize: 14),
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.success,
        duration: duration ?? const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  /// Hiển thị info snackbar
  static void showInfoSnackBar(BuildContext context, String message, {Duration? duration}) {
    if (!context.mounted) return;
    
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.info_outline, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(fontSize: 14),
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.info,
        duration: duration ?? const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  /// Validate và parse số tiền
  static double? parseAmount(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null;
    }
    try {
      final amount = double.parse(value.trim().replaceAll(',', ''));
      if (amount < 0) {
        return null;
      }
      return amount;
    } catch (e) {
      return null;
    }
  }

  /// Validate và parse số nguyên
  static int? parseInteger(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null;
    }
    try {
      final number = int.parse(value.trim());
      if (number < 0) {
        return null;
      }
      return number;
    } catch (e) {
      return null;
    }
  }

  /// Validate email
  static bool isValidEmail(String email) {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(email);
  }

  /// Validate phone number (Vietnamese format)
  static bool isValidPhoneNumber(String phone) {
    final phoneRegex = RegExp(r'^(0|\+84)[1-9][0-9]{8,9}$');
    return phoneRegex.hasMatch(phone.replaceAll(' ', ''));
  }

  /// Validate date format (YYYY-MM)
  static bool isValidMonthYear(String monthYear) {
    final regex = RegExp(r'^\d{4}-\d{2}$');
    if (!regex.hasMatch(monthYear)) {
      return false;
    }
    try {
      final parts = monthYear.split('-');
      final year = int.parse(parts[0]);
      final month = int.parse(parts[1]);
      if (month < 1 || month > 12) {
        return false;
      }
      if (year < 2000 || year > 2100) {
        return false;
      }
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Safe async operation với error handling
  static Future<T?> safeAsync<T>(
    BuildContext context,
    Future<T> Function() operation, {
    String? errorMessage,
    bool showError = true,
  }) async {
    try {
      return await operation();
    } catch (e) {
      if (showError && context.mounted) {
        showErrorSnackBar(
          context,
          errorMessage ?? e,
        );
      }
      return null;
    }
  }
}

