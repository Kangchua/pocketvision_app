import 'dart:io';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
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
            print('📄 Data Type: ${e.response?.data?.runtimeType}');
            print('📄 Data: ${e.response?.data}');
            print('📄 Headers: ${e.response?.headers}');
          } else {
            print('⚠️ No response data');
          }
          if (e.error != null) {
            print('🔴 Error object: ${e.error}');
          }
          print('📍 Stack trace: ${e.stackTrace}');
          return handler.next(e);
        },
      ));
    } else {
      // Chỉ thêm Authorization header khi không debug
      _dio.interceptors.add(InterceptorsWrapper(
        onRequest: (options, handler) {
          if (_accessToken != null && _accessToken!.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $_accessToken';
          }
          return handler.next(options);
        },
      ));
    }
  }

  void setTokens(String? accessToken, String? refreshToken) {
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
        final accessToken = data['accessToken'] as String? ?? '';
        final refreshToken = data['refreshToken'] as String? ?? '';
        setTokens(accessToken, refreshToken);
        return {
          'user': User.fromJson(data['user']),
          'accessToken': accessToken,
          'refreshToken': refreshToken,
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
        final accessToken = data['accessToken'] as String? ?? '';
        final refreshToken = data['refreshToken'] as String? ?? '';
        setTokens(accessToken, refreshToken);
        return {
          'user': User.fromJson(data['user']),
          'accessToken': accessToken,
          'refreshToken': refreshToken,
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

  /// Upload avatar image to backend
  /// Returns the avatar URL
  Future<String> uploadAvatar(int userId, int id, File imageFile) async {
    try {
      if (kIsWeb) {
        throw Exception('Upload file không hỗ trợ trên web. Vui lòng sử dụng mobile app.');
      }
      
      // Get file name from path
      final fileName = imageFile.path.split('/').last;
      
      // Đọc bytes từ file
      final bytes = await imageFile.readAsBytes();
      
      final formData = FormData.fromMap({
        'userId': userId,
        'file': MultipartFile.fromBytes(
          bytes,
          filename: fileName,
        ),
      });

      final response = await _dio.post(
        '/users/$id/avatar',
        data: formData,
        options: Options(
          contentType: 'multipart/form-data',
        ),
      );

      // Response format: {"avatarUrl": "uploads/avatars/..."}
      return response.data['avatarUrl'] as String;
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
          'expenseDate': expenseDate.toIso8601String().split('T')[0],
        },
      );
      return Expense.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Expense> updateExpense({
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
      final response = await _dio.put(
        '/expenses/$id',
        data: {
          'userId': userId,
          'categoryId': categoryId,
          'storeName': storeName,
          'totalAmount': totalAmount,
          'paymentMethod': paymentMethod,
          'note': note,
          'expenseDate': expenseDate.toIso8601String().split('T')[0],
        },
      );
      return Expense.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> deleteExpense(int id) async {
    try {
      // Backend trả về plain text "Đã xóa chi tiêu thành công" không phải JSON
      // Nên cần set responseType để chấp nhận plain text
      final response = await _dio.delete(
        '/expenses/$id',
        options: Options(
          responseType: ResponseType.plain, // Chấp nhận plain text thay vì JSON
        ),
      );
      if (ApiConfig.debugMode) {
        print('✅ Delete expense $id: ${response.statusCode}');
        print('📄 Response: ${response.data}');
      }
    } catch (e) {
      // Nếu lỗi là FormatException do cố parse plain text như JSON
      // và status code là 200, thì coi như thành công
      if (e is DioException && 
          e.error is FormatException &&
          e.response?.statusCode == 200) {
        if (ApiConfig.debugMode) {
          print('✅ Delete expense $id: Success (plain text response)');
        }
        return; // Thành công, không throw error
      }
      throw _handleError(e);
    }
  }

  // Category Endpoints
  Future<List<Category>> getCategories(int userId) async {
    try {
      final response = await _dio.get(
        '/categories',
        queryParameters: {'userId': userId},
      );
      final List<dynamic> data = response.data;
      return data.map((json) => Category.fromJson(json)).toList();
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Category> createCategory({
    required int userId,
    required String name,
    String? colorHex,
    String? icon,
  }) async {
    try {
      final response = await _dio.post(
        '/categories',
        data: {
          'userId': userId,
          'name': name,
          'colorHex': colorHex,
          'icon': icon ?? '🏷️',
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

  // Recalculate tất cả budgets (tính lại spentAmount)
  Future<List<Budget>> recalculateBudgets(int userId) async {
    try {
      final response = await _dio.post(
        '/budgets/recalculate',
        queryParameters: {'userId': userId},
      );
      final List<dynamic> data = response.data;
      return data.map((json) => Budget.fromJson(json)).toList();
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

  // LƯU Ý: Backend hiện tại không có endpoint POST /invoices để tạo invoice thủ công
  // Chỉ có POST /invoices/upload để upload và phân tích ảnh
  // Method này có thể không hoạt động nếu backend chưa implement endpoint này
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
      final response = await _dio.put(
        '/invoices/$id',
        queryParameters: {'userId': userId},
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

  Future<void> deleteInvoice(int id, int userId) async {
    try {
      await _dio.delete(
        '/invoices/$id',
        queryParameters: {'userId': userId},
      );
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Convert invoice to expense
  Future<Expense> convertInvoiceToExpense(int invoiceId, int userId) async {
    try {
      final response = await _dio.post(
        '/invoices/$invoiceId/convert',
        queryParameters: {'userId': userId},
      );
      return Expense.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Gọi AI server trực tiếp để phân tích ảnh hóa đơn
  /// Returns raw JSON response from AI server
  Future<Map<String, dynamic>> callAiServer(File imageFile) async {
    try {
      if (kIsWeb) {
        throw Exception('AI analysis không hỗ trợ trên web. Vui lòng sử dụng mobile app.');
      }
      
      // Get file name from path
      final fileName = imageFile.path.split('/').last;
      
      // Đọc bytes từ file
      final bytes = await imageFile.readAsBytes();
      
      // Tạo Dio instance riêng cho AI server (không dùng baseUrl)
      final aiDio = Dio(BaseOptions(
        baseUrl: '',
        connectTimeout: Duration(seconds: 30),
        receiveTimeout: Duration(seconds: 60), // AI processing may take time
        headers: {
          'ngrok-skip-browser-warning': 'true',
        },
      ));

      final formData = FormData.fromMap({
        'image': MultipartFile.fromBytes(
          bytes,
          filename: fileName,
        ),
      });

      // Gọi AI server trực tiếp
      final response = await aiDio.post(
        ApiConfig.aiServerUrl,
        data: formData,
        options: Options(
          contentType: 'multipart/form-data',
        ),
      );

      return response.data as Map<String, dynamic>;
    } catch (e) {
      if (e is DioException) {
        throw Exception('Lỗi kết nối AI server: ${e.message}');
      }
      throw Exception('Lỗi phân tích ảnh: ${e.toString()}');
    }
  }

  /// Parse kết quả từ AI server thành InvoiceData
  Map<String, dynamic> parseAiResponse(Map<String, dynamic> aiResponse) {
    try {
      // AI server trả về format:
      // {
      //   "status": "success",
      //   "data": {
      //     "extraction_result": "```json\n{...}\n```"
      //   }
      // }
      
      if (aiResponse['status'] != 'success') {
        throw Exception('AI server trả về lỗi: ${aiResponse['message'] ?? 'Unknown error'}');
      }

      final data = aiResponse['data'] as Map<String, dynamic>?;
      if (data == null || data['extraction_result'] == null) {
        throw Exception('AI server không trả về dữ liệu trích xuất');
      }

      // Lấy extraction_result và làm sạch (xóa markdown code block)
      String jsonString = data['extraction_result'].toString();
      jsonString = jsonString.replaceAll('```json', '').replaceAll('```', '').trim();

      // Parse JSON string thành Map
      final invoiceData = jsonDecode(jsonString) as Map<String, dynamic>;
      
      return invoiceData;
    } catch (e) {
      throw Exception('Lỗi parse kết quả AI: ${e.toString()}');
    }
  }

  /// Gửi ảnh đến AI server để trích xuất thông tin hóa đơn
  /// Sau đó lưu hóa đơn lên backend
  /// Returns the Invoice object with extracted data
  Future<Invoice> uploadInvoice(int userId, File imageFile) async {
    try {
      if (kIsWeb) {
        throw Exception('Upload file không hỗ trợ trên web. Vui lòng sử dụng mobile app.');
      }
      
      // Bước 1: Gọi AI server trực tiếp để phân tích ảnh
      final aiResponse = await callAiServer(imageFile);
      
      // Bước 2: Parse kết quả từ AI server
      final invoiceData = parseAiResponse(aiResponse);
      
      // Bước 3: Map dữ liệu từ AI sang format của Invoice
      final storeName = invoiceData['Tên người bán'] as String? ?? 'Cửa hàng';
      final totalAmount = (invoiceData['Tổng tiền thanh toán'] as num?)?.toDouble() ?? 0.0;
      final address = invoiceData['Địa chỉ'] as String? ?? '';
      final dateStr = invoiceData['Ngày giao dịch'] as String? ?? '';
      
      // Parse ngày tháng
      DateTime invoiceDate = DateTime.now();
      if (dateStr.isNotEmpty) {
        try {
          // Xử lý format ngày: "13/08/2020" hoặc "16.01.2024 15.14"
          String cleanDate = dateStr.trim().split(' ')[0].replaceAll('.', '/');
          final parts = cleanDate.split('/');
          if (parts.length == 3) {
            invoiceDate = DateTime(
              int.parse(parts[2]),
              int.parse(parts[1]),
              int.parse(parts[0]),
            );
          }
        } catch (e) {
          print('Lỗi parse ngày: $dateStr, dùng ngày hiện tại');
        }
      }
      
      // Parse items
      final List<InvoiceItem> items = [];
      final itemsData = invoiceData['Danh sách món'] as List<dynamic>?;
      if (itemsData != null) {
        for (var itemData in itemsData) {
          final itemMap = itemData as Map<String, dynamic>;
          final itemName = itemMap['Tên món'] as String? ?? 'Sản phẩm';
          final unitPrice = (itemMap['Đơn giá'] as num?)?.toDouble() ?? 0.0;
          final quantity = (itemMap['Số lượng'] as num?)?.toInt() ?? 1;
          
          items.add(InvoiceItem(
            id: 0, // Sẽ được set bởi backend
            invoiceId: 0, // Sẽ được set bởi backend
            itemName: itemName,
            quantity: quantity,
            unitPrice: unitPrice,
            totalPrice: unitPrice * quantity,
          ));
        }
      }
      
      // Bước 4: Upload ảnh lên backend để lưu
      // Backend sẽ tự động gọi AI server và lưu kết quả
      // (App đã gọi AI server trước để có thể hiển thị kết quả ngay)
      final fileName = imageFile.path.split('/').last;
      final bytes = await imageFile.readAsBytes();
      
      final formData = FormData.fromMap({
        'userId': userId,
        'file': MultipartFile.fromBytes(
          bytes,
          filename: fileName,
        ),
      });

      // Gửi lên backend để lưu (backend sẽ tự gọi AI server)
      final response = await _dio.post(
        '/invoices/upload',
        data: formData,
        options: Options(
          contentType: 'multipart/form-data',
          receiveTimeout: Duration(seconds: 60), // AI processing may take time
        ),
      );

      return Invoice.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Income Endpoints
  // LƯU Ý: Backend hiện tại không có IncomeController
  // Các method này sẽ không hoạt động cho đến khi backend implement IncomeController
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
  Future<List<app_notification.AppNotification>> getNotifications(int userId) async {
    try {
      final response = await _dio.get(
        '/notifications',
        queryParameters: {'userId': userId},
      );
      return (response.data as List).map((json) => app_notification.AppNotification.fromJson(json)).toList();
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> markNotificationAsRead(int id) async {
    try {
      await _dio.put('/notifications/$id/read');
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> markAllNotificationsAsRead(int userId) async {
    try {
      await _dio.put(
        '/notifications/read-all',
        queryParameters: {'userId': userId},
      );
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<int> getUnreadNotificationCount(int userId) async {
    try {
      final response = await _dio.get(
        '/notifications/unread-count',
        queryParameters: {'userId': userId},
      );
      return response.data as int;
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
      // Log chi tiết để debug
      if (ApiConfig.debugMode && error.response != null) {
        print('🔴 Error Status: ${error.response?.statusCode}');
        print('🔴 Error Data Type: ${error.response?.data.runtimeType}');
        print('🔴 Error Data: ${error.response?.data}');
      }

      // Xử lý các status code cụ thể
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

      // Xử lý response data - ưu tiên lấy message từ response
      if (error.response?.data != null) {
        // Nếu là Map (JSON object)
        if (error.response!.data is Map) {
          final data = error.response!.data as Map;
          if (data.containsKey('message')) {
            return data['message'].toString();
          }
          // Nếu có key 'error'
          if (data.containsKey('error')) {
            return data['error'].toString();
          }
        }
        
        // Nếu là String (plain text)
        if (error.response!.data is String) {
          return error.response!.data as String;
        }
        
        // Nếu là dynamic type, thử convert sang String
        try {
          final dataStr = error.response!.data.toString();
          if (dataStr.isNotEmpty && dataStr != 'null') {
            return dataStr;
          }
        } catch (e) {
          // Ignore conversion error
        }
      }

      // Xử lý các loại lỗi kết nối
      if (error.type == DioExceptionType.connectionTimeout || 
          error.type == DioExceptionType.receiveTimeout) {
        return 'Kết nối timeout. Vui lòng thử lại.';
      }
      if (error.type == DioExceptionType.connectionError) {
        return 'Không thể kết nối đến server. Vui lòng kiểm tra kết nối mạng.';
      }
      
      // Xử lý DioExceptionType.unknown - thường xảy ra khi response không parse được
      if (error.type == DioExceptionType.unknown) {
        if (error.response != null) {
          // Có response nhưng không parse được - có thể là plain text
          if (error.response!.data != null) {
            if (error.response!.data is String) {
              return error.response!.data as String;
            }
            try {
              final dataStr = error.response!.data.toString();
              if (dataStr.isNotEmpty && dataStr != 'null') {
                return dataStr;
              }
            } catch (e) {
              // Ignore
            }
          }
          // Nếu có status code, trả về message tương ứng
          if (error.response!.statusCode == 400) {
            return 'Dữ liệu không hợp lệ. Vui lòng kiểm tra lại.';
          }
          if (error.response!.statusCode == 404) {
            return 'Không tìm thấy dữ liệu.';
          }
          if (error.response!.statusCode == 500) {
            return 'Lỗi server. Vui lòng thử lại sau.';
          }
        }
        // Nếu không có response, có thể là lỗi network hoặc parse
        return error.message ?? 'Lỗi không xác định. Vui lòng thử lại.';
      }
      
      // Xử lý 400 Bad Request - có thể có message trong response
      if (error.response?.statusCode == 400) {
        if (error.response?.data != null) {
          if (error.response!.data is String) {
            return error.response!.data as String;
          }
          if (error.response!.data is Map) {
            final data = error.response!.data as Map;
            return data['message']?.toString() ?? 
                   data['error']?.toString() ?? 
                   'Dữ liệu không hợp lệ. Vui lòng kiểm tra lại.';
          }
          return error.response!.data.toString();
        }
        return 'Dữ liệu không hợp lệ. Vui lòng kiểm tra lại.';
      }

      // Fallback: trả về message từ DioException hoặc message mặc định
      return error.message ?? 'Lỗi kết nối. Vui lòng thử lại.';
    }
    return error.toString();
  }
}
