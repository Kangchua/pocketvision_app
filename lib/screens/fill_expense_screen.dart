import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/category_provider.dart';
import '../providers/auth_provider.dart';
import '../utils/app_theme.dart';
import '../utils/format_utils.dart';
import '../utils/theme_colors.dart';

class FillExpenseScreen extends StatefulWidget {
  const FillExpenseScreen({super.key});

  @override
  State<FillExpenseScreen> createState() => _FillExpenseScreenState();
}

class _FillExpenseScreenState extends State<FillExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _storeNameController = TextEditingController();
  final _noteController = TextEditingController();

  int? _selectedCategoryId;
  String? _selectedPaymentMethod;
  DateTime _selectedDate = DateTime.now();

  bool _isFilling = false;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    final user = context.read<AuthProvider>().user;
    if (user != null) {
      final user = context.read<AuthProvider>().user;
      if (user != null) {
        await context.read<CategoryProvider>().fetchCategories(user.id);
      }
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _fillExpense() async {
    if (!_formKey.currentState!.validate()) return;

    final user = context.read<AuthProvider>().user;
    if (user == null) return;

    setState(() {
      _isFilling = true;
    });

    try {
      // Here you would typically call an AI service to fill in missing information
      // For now, we'll simulate this with a delay and some basic logic

      await Future.delayed(Duration(seconds: 2));

      // Simulate AI filling in missing fields
      if (_storeNameController.text.isEmpty) {
        _storeNameController.text = 'Cửa hàng tự động';
      }

      if (_selectedCategoryId == null) {
        // Auto-select a category based on store name or amount
        final categories = context.read<CategoryProvider>().categories;
        if (categories.isNotEmpty) {
          _selectedCategoryId = categories.first.id;
        }
      }

      _selectedPaymentMethod ??= 'Tiền mặt';

      if (_noteController.text.isEmpty) {
        _noteController.text = 'Điền tự động bởi AI';
      }

      setState(() {});

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Đã điền thông tin tự động')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi khi điền thông tin: ${e.toString()}')),
      );
    } finally {
      setState(() {
        _isFilling = false;
      });
    }
  }

  void _saveExpense() async {
    if (!_formKey.currentState!.validate()) return;

    final user = context.read<AuthProvider>().user;
    if (user == null) return;

    // Create expense object and save
    // This would integrate with your expense provider
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Lưu chi tiêu thành công')),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeColors.getBackground(context),
      appBar: AppBar(
        title: Text('Điền chi tiêu thông minh'),
        elevation: 0,
        actions: [
          TextButton(
            onPressed: _saveExpense,
            child: Text(
              'Lưu',
              style: TextStyle(
                color: ThemeColors.getPrimary(context),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // AI Header
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [ThemeColors.getPrimary(context), ThemeColors.getPrimary(context).withOpacity(0.8)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: ThemeColors.getPrimary(context).withOpacity(0.3),
                      blurRadius: 12,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                padding: EdgeInsets.all(24),
                child: Column(
                  children: [
                    Icon(
                      Icons.smart_toy,
                      size: 48,
                      color: Colors.white,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Điền thông tin tự động',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'AI sẽ giúp điền các thông tin còn thiếu dựa trên hóa đơn',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 24),

              // Amount Input
              Container(
                decoration: BoxDecoration(
                  color: ThemeColors.getSurface(context),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: ThemeColors.getBorder(context)),
                ),
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Số tiền',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: ThemeColors.getTextPrimary(context),
                          ),
                        ),
                        if (_amountController.text.isNotEmpty)
                          Icon(Icons.check_circle, color: Colors.green, size: 20),
                      ],
                    ),
                    SizedBox(height: 8),
                    TextFormField(
                      controller: _amountController,
                      keyboardType: TextInputType.numberWithOptions(decimal: true),
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                      decoration: InputDecoration(
                        hintText: 'Nhập số tiền từ hóa đơn',
                        suffixText: 'VND',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: ThemeColors.getBorder(context)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: ThemeColors.getPrimary(context), width: 2),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Vui lòng nhập số tiền';
                        }
                        final amount = double.tryParse(value);
                        if (amount == null || amount <= 0) {
                          return 'Số tiền phải lớn hơn 0';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16),

              // AI Fill Button
              ElevatedButton.icon(
                onPressed: _isFilling ? null : _fillExpense,
                icon: _isFilling
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Icon(Icons.auto_fix_high),
                label: Text(_isFilling ? 'Đang phân tích...' : 'Điền tự động bằng AI'),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 4,
                  shadowColor: ThemeColors.getPrimary(context).withOpacity(0.3),
                ),
              ),
              SizedBox(height: 24),

              // Store Name
              Container(
                decoration: BoxDecoration(
                  color: ThemeColors.getSurface(context),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: ThemeColors.getBorder(context)),
                ),
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Tên cửa hàng',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: ThemeColors.getTextPrimary(context),
                          ),
                        ),
                        if (_storeNameController.text.isNotEmpty)
                          Icon(Icons.check_circle, color: Colors.green, size: 20),
                      ],
                    ),
                    SizedBox(height: 8),
                    TextFormField(
                      controller: _storeNameController,
                      decoration: InputDecoration(
                        hintText: 'Ví dụ: VinMart, Circle K...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: ThemeColors.getBorder(context)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: ThemeColors.getPrimary(context), width: 2),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16),

              // Category Selection
              Container(
                decoration: BoxDecoration(
                  color: ThemeColors.getSurface(context),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: ThemeColors.getBorder(context)),
                ),
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Danh mục',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: ThemeColors.getTextPrimary(context),
                          ),
                        ),
                        if (_selectedCategoryId != null)
                          Icon(Icons.check_circle, color: Colors.green, size: 20),
                      ],
                    ),
                    SizedBox(height: 8),
                    Consumer<CategoryProvider>(
                      builder: (context, categoryProvider, _) {
                        return DropdownButtonFormField<int>(
                          initialValue: _selectedCategoryId,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: ThemeColors.getBorder(context)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: ThemeColors.getPrimary(context), width: 2),
                            ),
                          ),
                          items: categoryProvider.categories.map((category) {
                            return DropdownMenuItem<int>(
                              value: category.id,
                              child: Text(category.name),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedCategoryId = value;
                            });
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16),

              // Payment Method
              Container(
                decoration: BoxDecoration(
                  color: ThemeColors.getSurface(context),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: ThemeColors.getBorder(context)),
                ),
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Phương thức thanh toán',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: ThemeColors.getTextPrimary(context),
                          ),
                        ),
                        if (_selectedPaymentMethod != null)
                          Icon(Icons.check_circle, color: Colors.green, size: 20),
                      ],
                    ),
                    SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      initialValue: _selectedPaymentMethod,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: ThemeColors.getBorder(context)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: ThemeColors.getPrimary(context), width: 2),
                        ),
                      ),
                      items: ['Tiền mặt', 'Thẻ tín dụng', 'Chuyển khoản', 'Ví điện tử']
                          .map((method) => DropdownMenuItem<String>(
                                value: method,
                                child: Text(method),
                              ))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedPaymentMethod = value;
                        });
                      },
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16),

              // Date Selection
              Container(
                decoration: BoxDecoration(
                  color: ThemeColors.getSurface(context),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: ThemeColors.getBorder(context)),
                ),
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Ngày chi tiêu',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: ThemeColors.getTextPrimary(context),
                      ),
                    ),
                    SizedBox(height: 8),
                    InkWell(
                      onTap: () => _selectDate(context),
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                        decoration: BoxDecoration(
                          border: Border.all(color: ThemeColors.getBorder(context)),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              FormatUtils.formatDate(_selectedDate, context),
                              style: TextStyle(
                                fontSize: 16,
                                color: ThemeColors.getTextPrimary(context),
                              ),
                            ),
                            Icon(Icons.calendar_today, color: ThemeColors.getPrimary(context)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16),

              // Note
              Container(
                decoration: BoxDecoration(
                  color: ThemeColors.getSurface(context),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: ThemeColors.getBorder(context)),
                ),
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Ghi chú',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: ThemeColors.getTextPrimary(context),
                          ),
                        ),
                        if (_noteController.text.isNotEmpty)
                          Icon(Icons.check_circle, color: Colors.green, size: 20),
                      ],
                    ),
                    SizedBox(height: 8),
                    TextFormField(
                      controller: _noteController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: 'Thêm ghi chú nếu cần...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: ThemeColors.getBorder(context)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: ThemeColors.getPrimary(context), width: 2),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 24),

              // Progress Indicator
              Container(
                decoration: BoxDecoration(
                  color: ThemeColors.getSurface(context),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: ThemeColors.getBorder(context)),
                ),
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tiến độ điền thông tin',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: ThemeColors.getTextPrimary(context),
                      ),
                    ),
                    SizedBox(height: 12),
                    LinearProgressIndicator(
                      value: _calculateCompletionPercentage(),
                      backgroundColor: ThemeColors.getBorder(context),
                      valueColor: AlwaysStoppedAnimation<Color>(ThemeColors.getPrimary(context)),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '${(_calculateCompletionPercentage() * 100).round()}% hoàn thành',
                      style: TextStyle(
                        fontSize: 12,
                        color: ThemeColors.getTextSecondary(context),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  double _calculateCompletionPercentage() {
    int completed = 0;
    int total = 6;

    if (_amountController.text.isNotEmpty) completed++;
    if (_storeNameController.text.isNotEmpty) completed++;
    if (_selectedCategoryId != null) completed++;
    if (_selectedPaymentMethod != null) completed++;
    if (_noteController.text.isNotEmpty) completed++;
    // Date is always filled

    return completed / total;
  }

  @override
  void dispose() {
    _amountController.dispose();
    _storeNameController.dispose();
    _noteController.dispose();
    super.dispose();
  }
}