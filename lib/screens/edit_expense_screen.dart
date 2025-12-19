import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/expense_provider.dart';
import '../providers/category_provider.dart';
import '../providers/auth_provider.dart';
import '../models/expense.dart';
import '../utils/format_utils.dart';
import '../utils/theme_colors.dart';
import '../utils/exception_handler.dart';

class EditExpenseScreen extends StatefulWidget {
  final Expense expense;

  const EditExpenseScreen({super.key, required this.expense});

  @override
  State<EditExpenseScreen> createState() => _EditExpenseScreenState();
}

class _EditExpenseScreenState extends State<EditExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _amountController;
  late TextEditingController _noteController;
  late TextEditingController _storeNameController;
  late DateTime _selectedDate;
  int? _selectedCategoryId;
  String? _selectedPaymentMethod;

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController(text: widget.expense.totalAmount.toString());
    _noteController = TextEditingController(text: widget.expense.note);
    _storeNameController = TextEditingController(text: widget.expense.storeName ?? '');
    _selectedDate = widget.expense.expenseDate;
    _selectedCategoryId = widget.expense.categoryId;
    _selectedPaymentMethod = widget.expense.paymentMethod;
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    _storeNameController.dispose();
    super.dispose();
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

  void _saveExpense() async {
    if (!_formKey.currentState!.validate()) return;

    final user = context.read<AuthProvider>().user;
    if (user == null) return;

    if (_selectedCategoryId == null) {
      ExceptionHandler.showErrorSnackBar(context, 'Vui lòng chọn danh mục');
      return;
    }

    if (_selectedPaymentMethod == null) {
      ExceptionHandler.showErrorSnackBar(context, 'Vui lòng chọn phương thức thanh toán');
      return;
    }

    try {
      await context.read<ExpenseProvider>().updateExpense(
        id: widget.expense.id,
        userId: widget.expense.userId,
        categoryId: _selectedCategoryId!,
        storeName: _storeNameController.text.trim().isEmpty 
            ? null 
            : _storeNameController.text.trim(),
        totalAmount: double.parse(_amountController.text),
        paymentMethod: _selectedPaymentMethod!,
        note: _noteController.text.trim().isEmpty ? '' : _noteController.text.trim(),
        expenseDate: _selectedDate,
      );
      if (mounted) {
        ExceptionHandler.showSuccessSnackBar(context, 'Cập nhật chi tiêu thành công');
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ExceptionHandler.showErrorSnackBar(context, e);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeColors.getBackground(context),
      appBar: AppBar(
        title: Text('Chỉnh sửa chi tiêu'),
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
      body: Consumer<CategoryProvider>(
        builder: (context, categoryProvider, _) {
          return SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
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
                        Text(
                          'Số tiền',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: ThemeColors.getTextPrimary(context),
                          ),
                        ),
                        SizedBox(height: 8),
                        TextFormField(
                          controller: _amountController,
                          keyboardType: TextInputType.numberWithOptions(decimal: true),
                          style: TextStyle(
                            fontSize: 18, 
                            fontWeight: FontWeight.w600,
                            color: ThemeColors.getTextPrimary(context),
                          ),
                          decoration: InputDecoration(
                            hintText: '0',
                            suffixText: 'VND',
                            hintStyle: TextStyle(color: ThemeColors.getTextTertiary(context)),
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
                        Text(
                          'Danh mục',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: ThemeColors.getTextPrimary(context),
                          ),
                        ),
                        SizedBox(height: 8),
                        DropdownButtonFormField<int>(
                          initialValue: _selectedCategoryId,
                          dropdownColor: ThemeColors.getSurface(context),
                          style: TextStyle(color: ThemeColors.getTextPrimary(context)),
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
                              child: Text(
                                category.name,
                                style: TextStyle(color: ThemeColors.getTextPrimary(context)),
                              ),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedCategoryId = value;
                            });
                          },
                          validator: (value) {
                            if (value == null) {
                              return 'Vui lòng chọn danh mục';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 16),

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
                        Text(
                          'Tên cửa hàng (tùy chọn)',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: ThemeColors.getTextPrimary(context),
                          ),
                        ),
                        SizedBox(height: 8),
                        TextFormField(
                          controller: _storeNameController,
                          style: TextStyle(color: ThemeColors.getTextPrimary(context)),
                          decoration: InputDecoration(
                            hintText: 'Nhập tên cửa hàng',
                            hintStyle: TextStyle(color: ThemeColors.getTextTertiary(context)),
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
                        Text(
                          'Phương thức thanh toán',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: ThemeColors.getTextPrimary(context),
                          ),
                        ),
                        SizedBox(height: 8),
                        DropdownButtonFormField<String>(
                          initialValue: _selectedPaymentMethod,
                          dropdownColor: ThemeColors.getSurface(context),
                          style: TextStyle(color: ThemeColors.getTextPrimary(context)),
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
                          items: [
                            DropdownMenuItem(
                              value: 'CASH', 
                              child: Text('Tiền mặt', style: TextStyle(color: ThemeColors.getTextPrimary(context))),
                            ),
                            DropdownMenuItem(
                              value: 'CREDIT_CARD', 
                              child: Text('Thẻ tín dụng', style: TextStyle(color: ThemeColors.getTextPrimary(context))),
                            ),
                            DropdownMenuItem(
                              value: 'BANK_TRANSFER', 
                              child: Text('Chuyển khoản', style: TextStyle(color: ThemeColors.getTextPrimary(context))),
                            ),
                            DropdownMenuItem(
                              value: 'E_WALLET', 
                              child: Text('Ví điện tử', style: TextStyle(color: ThemeColors.getTextPrimary(context))),
                            ),
                            DropdownMenuItem(
                              value: 'OTHER', 
                              child: Text('Khác', style: TextStyle(color: ThemeColors.getTextPrimary(context))),
                            ),
                          ],
                          onChanged: (value) {
                            setState(() {
                              _selectedPaymentMethod = value;
                            });
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Vui lòng chọn phương thức thanh toán';
                            }
                            return null;
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
                        Text(
                          'Ghi chú',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: ThemeColors.getTextPrimary(context),
                          ),
                        ),
                        SizedBox(height: 8),
                        TextFormField(
                          controller: _noteController,
                          maxLines: 3,
                          style: TextStyle(color: ThemeColors.getTextPrimary(context)),
                          decoration: InputDecoration(
                            hintText: 'Nhập ghi chú (tùy chọn)',
                            hintStyle: TextStyle(color: ThemeColors.getTextTertiary(context)),
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

                  // Save Button
                  ElevatedButton(
                    onPressed: _saveExpense,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ThemeColors.getPrimary(context),
                      foregroundColor: Theme.of(context).brightness == Brightness.dark 
                          ? Colors.white 
                          : Colors.black,
                      padding: EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 4,
                      shadowColor: ThemeColors.getPrimary(context).withOpacity(0.3),
                    ),
                    child: Text(
                      'Cập nhật chi tiêu',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}