# 🛡️ Exception Handling Guide - PocketVision App

## 📋 Tổng quan

Tài liệu này mô tả hệ thống xử lý ngoại lệ (exception handling) đã được triển khai trong ứng dụng PocketVision.

---

## 🎯 Mục tiêu

1. **Xử lý lỗi nhất quán** trên toàn bộ ứng dụng
2. **Thông báo lỗi rõ ràng** cho người dùng
3. **Validation đầy đủ** cho tất cả input
4. **Xử lý edge cases** và network errors
5. **Trải nghiệm người dùng tốt** ngay cả khi có lỗi

---

## 📁 Cấu trúc

### **ExceptionHandler Utility Class**

File: `lib/utils/exception_handler.dart`

Class này cung cấp các phương thức tiện ích để:
- Xử lý và chuyển đổi exceptions thành messages dễ hiểu
- Hiển thị error/success/info snackbars
- Validate dữ liệu đầu vào
- Thực hiện safe async operations

---

## 🔧 Các tính năng chính

### **1. Error Message Handling**

```dart
String getErrorMessage(dynamic error)
```

Chuyển đổi các loại exception khác nhau thành messages tiếng Việt dễ hiểu:

- **DioException**: Xử lý các lỗi network (timeout, connection, bad response, etc.)
- **FormatException**: Lỗi định dạng dữ liệu
- **TypeError**: Lỗi kiểu dữ liệu
- **ArgumentError**: Lỗi tham số
- **StateError**: Lỗi trạng thái ứng dụng
- **Generic Exception**: Xử lý các exception khác

### **2. SnackBar Helpers**

#### **Error SnackBar**
```dart
ExceptionHandler.showErrorSnackBar(context, error);
```

Hiển thị error message với:
- Icon lỗi
- Màu đỏ (danger)
- Duration: 4 giây
- Floating behavior

#### **Success SnackBar**
```dart
ExceptionHandler.showSuccessSnackBar(context, 'Thành công!');
```

Hiển thị success message với:
- Icon check
- Màu xanh lá (success)
- Duration: 3 giây

#### **Info SnackBar**
```dart
ExceptionHandler.showInfoSnackBar(context, 'Thông tin');
```

Hiển thị info message với:
- Icon info
- Màu xanh dương (info)
- Duration: 3 giây

### **3. Validation Helpers**

#### **Parse Amount**
```dart
double? amount = ExceptionHandler.parseAmount('100000');
// Returns: 100000.0 or null if invalid
```

#### **Parse Integer**
```dart
int? quantity = ExceptionHandler.parseInteger('5');
// Returns: 5 or null if invalid
```

#### **Validate Email**
```dart
bool isValid = ExceptionHandler.isValidEmail('user@example.com');
// Returns: true or false
```

#### **Validate Phone Number**
```dart
bool isValid = ExceptionHandler.isValidPhoneNumber('0912345678');
// Returns: true or false (Vietnamese format)
```

#### **Validate Month-Year**
```dart
bool isValid = ExceptionHandler.isValidMonthYear('2025-12');
// Returns: true or false (YYYY-MM format)
```

### **4. Safe Async Operations**

```dart
final result = await ExceptionHandler.safeAsync(
  context,
  () => someAsyncOperation(),
  errorMessage: 'Custom error message',
  showError: true,
);
```

Thực hiện async operation với error handling tự động.

---

## 📱 Các màn hình đã được cập nhật

### ✅ **1. Authentication Screens**

#### **Login Screen**
- ✅ Validate email format
- ✅ Validate password length (min 6 characters)
- ✅ Error handling cho login API
- ✅ User-friendly error messages

#### **Register Screen**
- ✅ Validate full name
- ✅ Validate email format
- ✅ Validate password strength
- ✅ Validate password confirmation
- ✅ Error handling cho register API

### ✅ **2. Expense Management**

#### **Expenses Screen**
- ✅ Error handling khi load expenses
- ✅ Error handling khi delete expense
- ✅ Display error messages

#### **Add/Edit Expense Screen**
- ✅ Validate amount (must be > 0)
- ✅ Validate note (required)
- ✅ Validate category (required)
- ✅ Error handling cho create/update API
- ✅ Success messages

### ✅ **3. Budget Management**

#### **Budgets Screen**
- ✅ Error handling khi load budgets
- ✅ Display error messages

#### **Add/Edit Budget Screen**
- ✅ Validate category (required)
- ✅ Validate month-year format (YYYY-MM)
- ✅ Validate amount (must be > 0)
- ✅ Error handling cho create/update/delete API
- ✅ Success messages

### ✅ **4. Invoice Management**

#### **Add/Edit Invoice Screen**
- ✅ Validate items (at least 1 item)
- ✅ Validate item name (required)
- ✅ Validate quantity (must be > 0)
- ✅ Validate unit price (must be > 0)
- ✅ Validate total amount (must be > 0)
- ✅ Error handling cho image picker
- ✅ File size validation (max 10MB)
- ✅ File existence check
- ✅ Error handling cho upload API

### ✅ **5. Category Management**

#### **Categories Screen**
- ✅ Error handling khi load categories
- ✅ Error handling khi delete category
- ✅ Success/error messages

#### **Add Category Dialog**
- ✅ Validate category name
- ✅ Error handling cho create API

### ✅ **6. Profile Management**

#### **Edit Profile Screen**
- ✅ Validate full name (required)
- ✅ Error handling cho update API
- ✅ Success messages

#### **Change Password Screen**
- ✅ Validate current password (required)
- ✅ Validate new password (min 6 characters)
- ✅ Validate password confirmation (must match)
- ✅ Error handling cho change password API
- ✅ Success messages

---

## 🔍 Các loại lỗi được xử lý

### **1. Network Errors**

- **Connection Timeout**: "Kết nối timeout. Vui lòng kiểm tra kết nối mạng và thử lại."
- **Connection Error**: "Không thể kết nối đến server. Vui lòng kiểm tra kết nối mạng."
- **Socket Exception**: "Không thể kết nối đến server. Vui lòng kiểm tra kết nối mạng."

### **2. HTTP Status Codes**

- **401 Unauthorized**: "Phiên đăng nhập đã hết hạn. Vui lòng đăng nhập lại."
- **403 Forbidden**: "Bạn không có quyền thực hiện thao tác này."
- **404 Not Found**: "Không tìm thấy dữ liệu."
- **409 Conflict**: "Dữ liệu đã tồn tại hoặc bị xung đột."
- **422 Unprocessable Entity**: "Dữ liệu không hợp lệ. Vui lòng kiểm tra lại thông tin."
- **500 Internal Server Error**: "Lỗi server. Vui lòng thử lại sau."
- **503 Service Unavailable**: "Server đang bảo trì. Vui lòng thử lại sau."

### **3. Validation Errors**

- **Empty Fields**: "Vui lòng nhập [field name]"
- **Invalid Format**: "Định dạng [field name] không hợp lệ"
- **Invalid Value**: "[Field name] phải [requirement]"
- **Mismatch**: "[Field 1] và [Field 2] không khớp"

### **4. Data Errors**

- **Format Exception**: "Định dạng dữ liệu không hợp lệ. Vui lòng kiểm tra lại."
- **Type Error**: "Lỗi kiểu dữ liệu. Vui lòng thử lại."
- **Null Error**: "Dữ liệu không tồn tại."

---

## 📝 Best Practices

### **1. Luôn sử dụng ExceptionHandler**

```dart
// ❌ Không nên
try {
  await someOperation();
} catch (e) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('Lỗi: $e')),
  );
}

// ✅ Nên làm
try {
  await someOperation();
} catch (e) {
  ExceptionHandler.showErrorSnackBar(context, e);
}
```

### **2. Validate trước khi gọi API**

```dart
// ✅ Validate trước
if (amount == null || amount <= 0) {
  ExceptionHandler.showErrorSnackBar(context, 'Số tiền phải lớn hơn 0');
  return;
}

try {
  await api.createExpense(amount: amount);
} catch (e) {
  ExceptionHandler.showErrorSnackBar(context, e);
}
```

### **3. Kiểm tra mounted trước khi show SnackBar**

```dart
if (mounted) {
  ExceptionHandler.showErrorSnackBar(context, error);
}
```

### **4. Sử dụng parseAmount/parseInteger thay vì parse trực tiếp**

```dart
// ❌ Không nên
final amount = double.parse(text); // Có thể throw FormatException

// ✅ Nên làm
final amount = ExceptionHandler.parseAmount(text);
if (amount == null) {
  ExceptionHandler.showErrorSnackBar(context, 'Số tiền không hợp lệ');
  return;
}
```

### **5. Sử dụng safeAsync cho operations phức tạp**

```dart
final result = await ExceptionHandler.safeAsync(
  context,
  () => complexOperation(),
  showError: true,
);

if (result != null) {
  // Process result
}
```

---

## 🧪 Testing Exception Handling

### **Test Cases**

1. **Network Disconnection**
   - Tắt WiFi/mobile data
   - Thử các thao tác API
   - Kiểm tra error message hiển thị đúng

2. **Invalid Input**
   - Nhập số âm cho amount
   - Nhập email không hợp lệ
   - Nhập password quá ngắn
   - Kiểm tra validation messages

3. **Server Errors**
   - Simulate 500 error
   - Simulate 401 error
   - Simulate 403 error
   - Kiểm tra error messages phù hợp

4. **Edge Cases**
   - Empty strings
   - Null values
   - Very large numbers
   - Special characters
   - Unicode characters

---

## 📚 Tài liệu tham khảo

- [Flutter Error Handling](https://docs.flutter.dev/testing/errors)
- [Dio Exception Types](https://pub.dev/documentation/dio/latest/dio/DioExceptionType.html)
- [Dart Exception Classes](https://dart.dev/guides/libraries/library-tour#exceptions)

---

## 🔄 Cập nhật

**Version**: 1.0.0  
**Last Updated**: 2025-01-XX  
**Maintainer**: Development Team

---

**Chúc bạn code an toàn! 🛡️**


