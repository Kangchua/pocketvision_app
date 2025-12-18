import 'dart:io';
import 'package:dio/dio.dart';
import '../models/user.dart';
import '../models/expense.dart';
import '../models/category.dart';
import '../models/budget.dart';
import '../models/invoice.dart';
import '../models/income.dart';
import '../models/notification.dart' as app_notification;
import '../config/api_config.dart';

class ApiService {
  // Base URL được cấu hình trong api_config.dart
  // Để chạy trên iPhone, mở file lib/config/api_config.dart và thay đổi serverIp
  static String get baseUrl => ApiConfig.baseUrl;
  late Dio _dio;

  String? _accessToken;
  String? _refreshToken;

  // Singleton pattern
  static final ApiService _instance = ApiService._internal();

  factory ApiService() {
    return _instance;
  }

  ApiService._internal() {
    _dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: Duration(seconds: ApiConfig.connectTimeout),
      receiveTimeout: Duration(seconds: ApiConfig.receiveTimeout),
      contentType: 'application/json',
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
    ));

    if (ApiConfig.debugMode) {
      _dio.interceptors.add(InterceptorsWrapper(
        onRequest: (options, handler) {
          if (_accessToken != null) {
            options.headers['Authorization'] = 'Bearer $_accessToken';
          }
          print('🌐 API Request: ${options.method} ${options.uri}');
          print('📤 Headers: ${options.headers}');
          if (options.data != null) {
            print('📦 Data: ${options.data}');
          }
          return handler.next(options);
        },
        onResponse: (response, handler) {
          print('✅ API Response: ${response.statusCode} ${response.requestOptions.uri}');
          return handler.next(response);
        },
        onError: (DioException e, handler) {
          print('❌ API Error: ${e.type} - ${e.message}');
          if (e.response != null) {
            print('📊 Status: ${e.response?.statusCode}');
            print('📄 Data: ${e.response?.data}');
          }
          return handler.next(e);
        },
      ));
    } else {
      // Chỉ thêm Authorization header khi không debug
      _dio.interceptors.add(InterceptorsWrapper(
        onRequest: (options, handler) {
          if (_accessToken != null) {
            options.headers['Authorization'] = 'Bearer $_accessToken';
          }
          return handler.next(options);
        },
      ));
    }
  }

  void setTokens(String accessToken, String refreshToken) {
    _accessToken = accessToken;
    _refreshToken = refreshToken;
  }

  void logout() {
    _accessToken = null;
    _refreshToken = null;
  }

  // Auth Endpoints
  Future<Map<String, dynamic>> register({
    required String fullName,
    required String email,
    required String password,
    required String confirmPassword,
  }) async {
    try {
      final response = await _dio.post(
        '/auth/register',
        data: {
          'fullName': fullName,
          'email': email,
          'password': password,
          'confirmPassword': confirmPassword,
        },
      );
      final data = response.data;
      if (data['user'] != null) {
        setTokens(data['accessToken'], data['refreshToken']);
        return {
          'user': User.fromJson(data['user']),
          'accessToken': data['accessToken'],
          'refreshToken': data['refreshToken'],
        };
      } else {
        throw Exception('Invalid response');
      }
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dio.post(
        '/auth/login',
        data: {
          'email': email,
          'password': password,
        },
      );
      final data = response.data;
      if (data['user'] != null) {
        setTokens(data['accessToken'], data['refreshToken']);
        return {
          'user': User.fromJson(data['user']),
          'accessToken': data['accessToken'],
          'refreshToken': data['refreshToken'],
        };
      } else {
        throw Exception('Invalid response');
      }
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Test connectivity endpoint (no auth required)
  Future<String> testConnection() async {
    try {
      final response = await _dio.get('/auth/test');
      return response.data.toString();
    } catch (e) {
      throw _handleError(e);
    }
  }

  // User Endpoints
  Future<User> getCurrentUser() async {
    try {
      // Lấy user từ token hoặc từ endpoint nếu có
      // Tạm thời trả về user từ auth, có thể thêm endpoint riêng sau
      throw Exception('Use AuthProvider.user instead');
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<User> getUserById(int id) async {
    try {
      final response = await _dio.get('/users/$id');
      return User.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<User> updateUser({
    required int id,
    String? fullName,
    String? avatarUrl,
  }) async {
    try {
      final response = await _dio.put(
        '/users/$id',
        data: {
          if (fullName != null) 'fullName': fullName,
          if (avatarUrl != null) 'avatarUrl': avatarUrl,
        },
      );
      return User.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> changePassword({
    required int id,
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      await _dio.put(
        '/users/$id/password',
        data: {
          'currentPassword': currentPassword,
          'newPassword': newPassword,
        },
      );
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Expense Endpoints
  Future<List<Expense>> getExpenses(int userId) async {
    try {
      final response = await _dio.get(
        '/expenses',
        queryParameters: {'userId': userId},
      );
      final List<dynamic> data = response.data;
      return data.map((json) => Expense.fromJson(json)).toList();
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Expense> getExpenseById(int id) async {
    try {
      final response = await _dio.get('/expenses/$id');
      return Expense.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Expense> createExpense({
    required int userId,
    required int categoryId,
    String? storeName,
    required double totalAmount,
    required String paymentMethod,
    required String note,
    required DateTime expenseDate,
  }) async {
    try {
      final response = await _dio.post(
        '/expenses',
        data: {
          'userId': userId,
          'categoryId': categoryId,
          'storeName': storeName,
          'totalAmount': totalAmount,
          'paymentMethod': paymentMethod,
          'note': note,
          'expenseDate': expenseDate.toIso8601String(),
        },
      );
      return Expense.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Expense> updateExpense({
    required int id,
    required int categoryId,
    String? storeName,
    required double totalAmount,
    required String paymentMethod,
    required String note,
    required DateTime expenseDate,
  }) async {
    try {
      final response = await _dio.put(
        '/expenses/$id',
        data: {
          'categoryId': categoryId,
          'storeName': storeName,
          'totalAmount': totalAmount,
          'paymentMethod': paymentMethod,
          'note': note,
          'expenseDate': expenseDate.toIso8601String(),
        },
      );
      return Expense.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> deleteExpense(int id) async {
    try {
      await _dio.delete('/expenses/$id');
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Category Endpoints
  Future<List<Category>> getCategories() async {
    try {
      final response = await _dio.get('/categories');
      final List<dynamic> data = response.data;
      return data.map((json) => Category.fromJson(json)).toList();
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Category> createCategory({
    required String name,
    String? colorHex,
    String? icon,
  }) async {
    try {
      final response = await _dio.post(
        '/categories',
        data: {
          'name': name,
          'colorHex': colorHex,
          'icon': icon,
        },
      );
      return Category.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> deleteCategory(int id) async {
    try {
      await _dio.delete('/categories/$id');
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Budget Endpoints
  Future<List<Budget>> getBudgets(int userId) async {
    try {
      final response = await _dio.get(
        '/budgets',
        queryParameters: {'userId': userId},
      );
      final List<dynamic> data = response.data;
      return data.map((json) => Budget.fromJson(json)).toList();
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Budget> createBudget({
    required int userId,
    required int categoryId,
    required String monthYear,
    required double limitAmount,
  }) async {
    try {
      final response = await _dio.post(
        '/budgets',
        data: {
          'userId': userId,
          'categoryId': categoryId,
          'monthYear': monthYear,
          'limitAmount': limitAmount,
        },
      );
      return Budget.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Budget> updateBudget(Budget budget) async {
    try {
      final response = await _dio.put(
        '/budgets/${budget.id}',
        data: {
          'categoryId': budget.categoryId,
          'monthYear': budget.monthYear,
          'limitAmount': budget.limitAmount,
        },
      );
      return Budget.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> deleteBudget(int id) async {
    try {
      await _dio.delete('/budgets/$id');
    } catch (e) {
      throw _handleError(e);
    }
  }

  // ==================== INVOICE METHODS ====================

  Future<List<Invoice>> getInvoices(int userId) async {
    try {
      final response = await _dio.get(
        '/invoices',
        queryParameters: {'userId': userId},
      );
      final List<dynamic> data = response.data;
      return data.map((json) => Invoice.fromJson(json)).toList();
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Invoice> createInvoice({
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
      final response = await _dio.post(
        '/invoices',
        data: {
          'userId': userId,
          'categoryId': categoryId,
          'storeName': storeName,
          'invoiceDate': invoiceDate.toIso8601String().split('T')[0],
          'totalAmount': totalAmount,
          'paymentMethod': paymentMethod,
          'note': note,
          'imageUrl': imageUrl,
          'items': items.map((item) => item.toJson()).toList(),
        },
      );
      return Invoice.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Invoice> updateInvoice({
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
      final response = await _dio.put(
        '/invoices/$id',
        data: {
          'categoryId': categoryId,
          'storeName': storeName,
          'invoiceDate': invoiceDate.toIso8601String().split('T')[0],
          'totalAmount': totalAmount,
          'paymentMethod': paymentMethod,
          'note': note,
          'imageUrl': imageUrl,
          'items': items.map((item) => item.toJson()).toList(),
        },
      );
      return Invoice.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> deleteInvoice(int id) async {
    try {
      await _dio.delete('/invoices/$id');
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Gửi ảnh đến AI server để trích xuất thông tin hóa đơn
  Future<Map<String, dynamic>> extractInvoiceFromImage(File imageFile) async {
    try {
      final aiServerUrl = 'http://192.168.100.117:8000/extract_invoice';
      
      final formData = FormData.fromMap({
        'image': await MultipartFile.fromFile(
          imageFile.path,
          filename: 'invoice.jpg',
        ),
      });

      final dio = Dio(BaseOptions(
        connectTimeout: Duration(seconds: 30),
        receiveTimeout: Duration(seconds: 30),
      ));

      final response = await dio.post(
        aiServerUrl,
        data: formData,
        options: Options(
          contentType: 'multipart/form-data',
          headers: {
            'Accept': 'application/json',
          },
        ),
      );

      if (response.data is Map) {
        return response.data as Map<String, dynamic>;
      }
      return {};
    } catch (e) {
      print('AI Server Error: $e');
      // Không throw error, chỉ log để không block upload
      return {};
    }
  }

  Future<Invoice> uploadInvoice(int userId, String imagePath) async {
    try {
      final formData = FormData.fromMap({
        'userId': userId,
        'image': await MultipartFile.fromFile(imagePath, filename: 'invoice.jpg'),
      });

      final response = await _dio.post(
        '/invoices/upload',
        data: formData,
        options: Options(contentType: 'multipart/form-data'),
      );

      return Invoice.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Income Endpoints
  Future<List<Income>> getIncomes() async {
    try {
      final response = await _dio.get('/incomes');
      return (response.data as List).map((json) => Income.fromJson(json)).toList();
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Income> createIncome({
    int? categoryId,
    required String sourceName,
    required double amount,
    required DateTime incomeDate,
    String? note,
  }) async {
    try {
      final response = await _dio.post(
        '/incomes',
        data: {
          'categoryId': categoryId,
          'sourceName': sourceName,
          'amount': amount,
          'incomeDate': incomeDate.toIso8601String().split('T')[0],
          'note': note,
        },
      );
      return Income.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Income> updateIncome(Income income) async {
    try {
      final response = await _dio.put(
        '/incomes/${income.id}',
        data: income.toJson(),
      );
      return Income.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> deleteIncome(int id) async {
    try {
      await _dio.delete('/incomes/$id');
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Notification Endpoints
  Future<List<app_notification.AppNotification>> getNotifications() async {
    try {
      final response = await _dio.get('/notifications');
      return (response.data as List).map((json) => app_notification.AppNotification.fromJson(json)).toList();
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> markNotificationAsRead(int id) async {
    try {
      await _dio.patch('/notifications/$id/read');
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> markAllNotificationsAsRead() async {
    try {
      await _dio.patch('/notifications/read-all');
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> deleteNotification(int id) async {
    try {
      await _dio.delete('/notifications/$id');
    } catch (e) {
      throw _handleError(e);
    }
  }

  String _handleError(dynamic error) {
    if (error is DioException) {
      if (error.response?.statusCode == 401) {
        return 'Không được phép. Vui lòng đăng nhập lại.';
      }
      if (error.response?.statusCode == 403) {
        return 'Không có quyền truy cập. Vui lòng kiểm tra lại quyền của bạn.';
      }
      if (error.response?.statusCode == 404) {
        return 'Không tìm thấy.';
      }
      if (error.response?.statusCode == 500) {
        return 'Lỗi server. Vui lòng thử lại sau.';
      }
      if (error.response?.data is Map) {
        final message = error.response?.data['message'];
        if (message != null) {
          return message.toString();
        }
      }
      if (error.response?.data is String) {
        return error.response!.data as String;
      }
      if (error.type == DioExceptionType.connectionTimeout || 
          error.type == DioExceptionType.receiveTimeout) {
        return 'Kết nối timeout. Vui lòng thử lại.';
      }
      if (error.type == DioExceptionType.connectionError) {
        return 'Không thể kết nối đến server. Vui lòng kiểm tra kết nối mạng.';
      }
      return error.message ?? 'Lỗi kết nối';
    }
    return error.toString();
  }
}
