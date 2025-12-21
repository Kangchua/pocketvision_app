import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/budget.dart';
import '../providers/budget_provider.dart';
import '../providers/category_provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/custom_text_field.dart';
import '../utils/exception_handler.dart';
import '../utils/theme_colors.dart';

class AddBudgetScreen extends StatefulWidget {
  final Budget? budget;

  const AddBudgetScreen({super.key, this.budget});

  @override
  State<AddBudgetScreen> createState() => _AddBudgetScreenState();
}

class _AddBudgetScreenState extends State<AddBudgetScreen> {
  final _formKey = GlobalKey<FormState>();
  final _budgetController = TextEditingController();
  final _monthYearController = TextEditingController();
  int? _selectedCategoryId;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.budget != null) {
      _budgetController.text = widget.budget!.limitAmount.toString();
      _monthYearController.text = widget.budget!.monthYear;
      _selectedCategoryId = widget.budget!.categoryId;
    } else {
      // Default to current month-year
      final now = DateTime.now();
      _monthYearController.text = '${now.year}-${now.month.toString().padLeft(2, '0')}';
    }
  }

  @override
  void dispose() {
    _budgetController.dispose();
    _monthYearController.dispose();
    super.dispose();
  }

  void _saveBudget() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedCategoryId == null) {
      ExceptionHandler.showErrorSnackBar(context, 'Vui lòng chọn danh mục');
      return;
    }

    // Validate month-year format
    final monthYear = _monthYearController.text.trim();
    if (!ExceptionHandler.isValidMonthYear(monthYear)) {
      ExceptionHandler.showErrorSnackBar(context, 'Định dạng tháng/năm không hợp lệ (YYYY-MM)');
      return;
    }

    // Validate amount
    final limitAmount = ExceptionHandler.parseAmount(_budgetController.text);
    if (limitAmount == null || limitAmount <= 0) {
      ExceptionHandler.showErrorSnackBar(context, 'Số tiền ngân sách phải lớn hơn 0');
      return;
    }

    final user = context.read<AuthProvider>().user;
    if (user == null) {
      ExceptionHandler.showErrorSnackBar(context, 'Chưa đăng nhập');
      return;
    }

    setState(() => _isLoading = true);

    try {
      if (widget.budget != null) {
        // Update existing budget
        final updatedBudget = widget.budget!.copyWith(
          limitAmount: limitAmount,
          monthYear: monthYear,
          categoryId: _selectedCategoryId!,
        );
        await context.read<BudgetProvider>().updateBudget(updatedBudget);
      } else {
        // Create new budget
        final newBudget = Budget(
          id: 0, // Will be set by backend
          userId: user.id,
          categoryId: _selectedCategoryId!,
          monthYear: monthYear,
          limitAmount: limitAmount,
          spentAmount: 0,
        );
        await context.read<BudgetProvider>().createBudget(newBudget);
      }

      if (mounted) {
        Navigator.pop(context);
        ExceptionHandler.showSuccessSnackBar(
          context,
          widget.budget != null 
              ? 'Cập nhật ngân sách thành công' 
              : 'Thêm ngân sách thành công',
        );
      }
    } catch (e) {
      if (mounted) {
        ExceptionHandler.showErrorSnackBar(context, e);
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _deleteBudget() async {
    if (widget.budget == null) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Xóa ngân sách?'),
        content: Text('Bạn có chắc chắn muốn xóa ngân sách này?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Xóa', style: TextStyle(color: ThemeColors.getDanger(context))),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await context.read<BudgetProvider>().deleteBudget(widget.budget!.id);
        if (mounted) {
          Navigator.pop(context);
          ExceptionHandler.showSuccessSnackBar(context, 'Xóa ngân sách thành công');
        }
      } catch (e) {
        if (mounted) {
          ExceptionHandler.showErrorSnackBar(context, e);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeColors.getBackground(context),
      appBar: AppBar(
        title: Text(widget.budget != null ? 'Cập nhật ngân sách' : 'Thêm ngân sách'),
        elevation: 0,
        actions: widget.budget != null ? [
          IconButton(
            icon: Icon(Icons.delete, color: ThemeColors.getDanger(context)),
            onPressed: _deleteBudget,
          ),
        ] : null,
      ),
      body: Consumer<CategoryProvider>(
        builder: (context, categoryProvider, _) {
          final categories = categoryProvider.categories;

          return SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Danh mục',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: ThemeColors.getSurface(context),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: ThemeColors.getBorder(context)),
                    ),
                    child: DropdownButtonFormField<int>(
                      initialValue: _selectedCategoryId,
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        border: InputBorder.none,
                        hintText: 'Chọn danh mục',
                      ),
                      items: categories.map((category) {
                        return DropdownMenuItem(
                          value: category.id,
                          child: Text(category.name),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() => _selectedCategoryId = value);
                      },
                      validator: (value) {
                        if (value == null) return 'Vui lòng chọn danh mục';
                        return null;
                      },
                    ),
                  ),
                  SizedBox(height: 24),
                  Text(
                    'Tháng/Năm',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 8),
                  CustomTextField(
                    controller: _monthYearController,
                    hintText: 'YYYY-MM (ví dụ: 2025-12)',
                    keyboardType: TextInputType.text,
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Vui lòng nhập tháng/năm';
                      final regex = RegExp(r'^\d{4}-\d{2}$');
                      if (!regex.hasMatch(value)) return 'Định dạng phải là YYYY-MM';
                      return null;
                    },
                  ),
                  SizedBox(height: 24),
                  Text(
                    'Số tiền ngân sách',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 8),
                  CustomTextField(
                    controller: _budgetController,
                    hintText: 'Nhập số tiền',
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Vui lòng nhập số tiền';
                      final amount = double.tryParse(value);
                      if (amount == null || amount <= 0) return 'Số tiền phải lớn hơn 0';
                      return null;
                    },
                  ),
                  SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _saveBudget,
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isLoading
                          ? SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation(Colors.white),
                              ),
                            )
                          : Text(
                              widget.budget != null ? 'Cập nhật' : 'Thêm ngân sách',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
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