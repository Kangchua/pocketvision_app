import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/expense.dart';
import '../providers/expense_provider.dart';
import '../providers/category_provider.dart';
import '../providers/auth_provider.dart';
import '../utils/app_theme.dart';
import '../utils/format_utils.dart';

class AddExpenseScreen extends StatefulWidget {
  final Expense? expense;

  const AddExpenseScreen({super.key, this.expense});

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  late TextEditingController _amountController;
  late TextEditingController _noteController;
  late TextEditingController _storeNameController;
  late DateTime _selectedDate;
  int? _selectedCategoryId;
  String? _selectedPaymentMethod;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _amountController =
        TextEditingController(text: widget.expense?.totalAmount.toString() ?? '');
    _noteController = TextEditingController(text: widget.expense?.note ?? '');
    _storeNameController = TextEditingController(text: widget.expense?.storeName ?? '');
    _selectedDate = widget.expense?.expenseDate ?? DateTime.now();
    _selectedCategoryId = widget.expense?.categoryId;
    _selectedPaymentMethod = widget.expense?.paymentMethod ?? 'CASH';
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    _storeNameController.dispose();
    super.dispose();
  }

  void _saveExpense() async {
    if (_amountController.text.isEmpty ||
        _noteController.text.isEmpty ||
        _selectedCategoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Vui lòng nhập đầy đủ thông tin')),
      );
      return;
    }

    final user = context.read<AuthProvider>().user;
    if (user == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final amount = double.parse(_amountController.text);

      if (widget.expense != null) {
        await context.read<ExpenseProvider>().updateExpense(
          id: widget.expense!.id,
          categoryId: _selectedCategoryId!,
          storeName: _storeNameController.text,
          totalAmount: amount,
          paymentMethod: _selectedPaymentMethod!,
          note: _noteController.text,
          expenseDate: _selectedDate,
        );
      } else {
        await context.read<ExpenseProvider>().addExpense(
          userId: user.id,
          categoryId: _selectedCategoryId!,
          storeName: _storeNameController.text,
          totalAmount: amount,
          paymentMethod: _selectedPaymentMethod!,
          note: _noteController.text,
          expenseDate: _selectedDate,
        );
      }

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.expense != null
                ? 'Cập nhật chi tiêu thành công'
                : 'Thêm chi tiêu thành công'),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: $e')),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _deleteExpense() async {
    if (widget.expense == null) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Xóa chi tiêu?'),
        content: Text('Bạn có chắc chắn muốn xóa chi tiêu này?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Xóa', style: TextStyle(color: AppColors.danger)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await context.read<ExpenseProvider>().deleteExpense(widget.expense!.id);
        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Xóa chi tiêu thành công')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Lỗi: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(widget.expense != null ? 'Cập nhật chi tiêu' : 'Thêm chi tiêu'),
        elevation: 0,
        backgroundColor: AppColors.surface,
        actions: [
          if (widget.expense != null)
            IconButton(
              icon: Icon(Icons.delete, color: AppColors.danger),
              onPressed: _deleteExpense,
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Amount
            TextField(
              controller: _amountController,
              decoration: InputDecoration(
                labelText: 'Số tiền',
                prefixIcon: Icon(Icons.attach_money),
                suffixText: 'VNĐ',
              ),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 16),

            // Note
            TextField(
              controller: _noteController,
              decoration: InputDecoration(
                labelText: 'Ghi chú',
                prefixIcon: Icon(Icons.note),
              ),
              maxLines: 3,
            ),
            SizedBox(height: 16),

            // Store Name
            TextField(
              controller: _storeNameController,
              decoration: InputDecoration(
                labelText: 'Tên cửa hàng (tùy chọn)',
                prefixIcon: Icon(Icons.store),
              ),
            ),
            SizedBox(height: 16),

            // Payment Method
            DropdownButtonFormField<String>(
              value: _selectedPaymentMethod,
              decoration: InputDecoration(
                labelText: 'Phương thức thanh toán',
                prefixIcon: Icon(Icons.payment),
              ),
              items: [
                DropdownMenuItem(value: 'CASH', child: Text('Tiền mặt')),
                DropdownMenuItem(value: 'CREDIT_CARD', child: Text('Thẻ tín dụng')),
                DropdownMenuItem(value: 'BANK_TRANSFER', child: Text('Chuyển khoản')),
                DropdownMenuItem(value: 'E_WALLET', child: Text('Ví điện tử')),
                DropdownMenuItem(value: 'OTHER', child: Text('Khác')),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedPaymentMethod = value;
                });
              },
            ),
            SizedBox(height: 16),

            // Date
            GestureDetector(
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: _selectedDate,
                  firstDate: DateTime(2020),
                  lastDate: DateTime.now(),
                );
                if (date != null) {
                  setState(() {
                    _selectedDate = date;
                  });
                }
              },
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.border),
                ),
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                child: Row(
                  children: [
                    Icon(Icons.calendar_today, color: AppColors.textTertiary),
                    SizedBox(width: 12),
                    Text(
                      FormatUtils.formatDate(_selectedDate),
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16),

            // Category
            Consumer<CategoryProvider>(
              builder: (context, categoryProvider, _) {
                return DropdownButtonFormField<int>(
                  initialValue: _selectedCategoryId,
                  decoration: InputDecoration(
                    labelText: 'Danh mục',
                    prefixIcon: Icon(Icons.category),
                  ),
                  items: categoryProvider.categories
                      .map((category) => DropdownMenuItem(
                    value: category.id,
                    child: Text(category.name),
                  ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedCategoryId = value;
                    });
                  },
                );
              },
            ),
            SizedBox(height: 24),

            // Save Button
            ElevatedButton(
              onPressed: _isLoading ? null : _saveExpense,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: _isLoading
                  ? SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation(Colors.white),
                  strokeWidth: 2,
                ),
              )
                  : Text(
                widget.expense != null ? 'Cập nhật' : 'Thêm chi tiêu',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
