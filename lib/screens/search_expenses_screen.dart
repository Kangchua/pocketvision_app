import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/expense_provider.dart';
import '../providers/category_provider.dart';
import '../providers/auth_provider.dart';
import '../models/expense.dart';
import '../models/category.dart';
import '../utils/app_theme.dart';
import '../utils/format_utils.dart';

class SearchExpensesScreen extends StatefulWidget {
  const SearchExpensesScreen({super.key});

  @override
  State<SearchExpensesScreen> createState() => _SearchExpensesScreenState();
}

class _SearchExpensesScreenState extends State<SearchExpensesScreen> {
  final _searchController = TextEditingController();
  List<Expense> _filteredExpenses = [];
  List<Expense> _allExpenses = [];
  String _selectedCategory = 'Tất cả';
  DateTime? _startDate;
  DateTime? _endDate;
  double? _minAmount;
  double? _maxAmount;

  @override
  void initState() {
    super.initState();
    _loadExpenses();
  }

  Future<void> _loadExpenses() async {
    final user = context.read<AuthProvider>().user;
    if (user != null) {
      await context.read<ExpenseProvider>().fetchExpenses(user.id);
      await context.read<CategoryProvider>().fetchCategories();
      _allExpenses = context.read<ExpenseProvider>().expenses;
      _filterExpenses();
    }
  }

  void _filterExpenses() {
    setState(() {
      _filteredExpenses = _allExpenses.where((expense) {
        // Text search
        final searchText = _searchController.text.toLowerCase();
        final matchesSearch = searchText.isEmpty ||
            expense.note.toLowerCase().contains(searchText) == true;

        // Category filter
        final matchesCategory = _selectedCategory == 'Tất cả' ||
            context.read<CategoryProvider>().categories
                .any((cat) => cat.id == expense.categoryId && cat.name == _selectedCategory);

        // Date range filter
        final matchesDateRange = (_startDate == null || expense.expenseDate.isAfter(_startDate!.subtract(Duration(days: 1)))) &&
            (_endDate == null || expense.expenseDate.isBefore(_endDate!.add(Duration(days: 1))));

        // Amount range filter
        final matchesAmount = (_minAmount == null || expense.totalAmount >= _minAmount!) &&
            (_maxAmount == null || expense.totalAmount <= _maxAmount!);

        return matchesSearch && matchesCategory && matchesDateRange && matchesAmount;
      }).toList();

      // Sort by date (newest first)
      _filteredExpenses.sort((a, b) => b.expenseDate.compareTo(a.expenseDate));
    });
  }

  Future<void> _selectDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      initialDateRange: _startDate != null && _endDate != null
          ? DateTimeRange(start: _startDate!, end: _endDate!)
          : null,
    );

    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });
      _filterExpenses();
    }
  }

  void _clearFilters() {
    setState(() {
      _searchController.clear();
      _selectedCategory = 'Tất cả';
      _startDate = null;
      _endDate = null;
      _minAmount = null;
      _maxAmount = null;
    });
    _filterExpenses();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Tìm kiếm chi tiêu'),
        elevation: 0,
        backgroundColor: AppColors.surface,
      ),
      body: Column(
        children: [
          // Search and Filters
          Container(
            color: AppColors.surface,
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                // Search Bar
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Tìm theo tên cửa hàng hoặc ghi chú...',
                    prefixIcon: Icon(Icons.search, color: AppColors.primary),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: AppColors.border),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: AppColors.primary, width: 2),
                    ),
                    filled: true,
                    fillColor: AppColors.background,
                  ),
                  onChanged: (value) => _filterExpenses(),
                ),
                SizedBox(height: 16),

                // Filter Row 1
                _buildFilterDropdown(
                  label: 'Danh mục',
                  value: _selectedCategory,
                  items: ['Tất cả', ...context.watch<CategoryProvider>().categories.map((c) => c.name)],
                  onChanged: (value) {
                    setState(() => _selectedCategory = value!);
                    _filterExpenses();
                  },
                ),
                SizedBox(height: 12),

                // Filter Row 2
                Row(
                  children: [
                    Expanded(
                      child: _buildAmountField(
                        label: 'Từ',
                        value: _minAmount,
                        onChanged: (value) {
                          setState(() => _minAmount = value);
                          _filterExpenses();
                        },
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: _buildAmountField(
                        label: 'Đến',
                        value: _maxAmount,
                        onChanged: (value) {
                          setState(() => _maxAmount = value);
                          _filterExpenses();
                        },
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12),

                // Date Range and Clear
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _selectDateRange,
                        icon: Icon(Icons.date_range),
                        label: Text(
                          _startDate != null && _endDate != null
                              ? '${FormatUtils.formatDate(_startDate!, context)} - ${FormatUtils.formatDate(_endDate!, context)}'
                              : 'Chọn khoảng thời gian',
                        ),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: AppColors.primary),
                          foregroundColor: AppColors.primary,
                          padding: EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                    SizedBox(width: 12),
                    IconButton(
                      onPressed: _clearFilters,
                      icon: Icon(Icons.clear, color: AppColors.danger),
                      tooltip: 'Xóa bộ lọc',
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Results
          Expanded(
            child: _filteredExpenses.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 64,
                          color: AppColors.textSecondary,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Không tìm thấy chi tiêu nào',
                          style: TextStyle(
                            fontSize: 18,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Thử điều chỉnh bộ lọc hoặc từ khóa tìm kiếm',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: EdgeInsets.all(16),
                    itemCount: _filteredExpenses.length,
                    itemBuilder: (context, index) {
                      final expense = _filteredExpenses[index];
                      return _buildExpenseCard(expense);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterDropdown({
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 4),
        SizedBox(
          height: 40,
          child: DropdownButtonFormField<String>(
            initialValue: value,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: AppColors.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: AppColors.primary, width: 2),
              ),
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            items: items.map((item) => DropdownMenuItem(
              value: item,
              child: Text(item, style: TextStyle(fontSize: 14)),
            )).toList(),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

  Widget _buildAmountField({
    required String label,
    required double? value,
    required ValueChanged<double?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 4),
        SizedBox(
          height: 40,
          child: TextFormField(
            initialValue: value?.toString(),
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              hintText: '0',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: AppColors.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: AppColors.primary, width: 2),
              ),
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            onChanged: (text) {
              final amount = double.tryParse(text);
              onChanged(amount);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildExpenseCard(Expense expense) {
    final category = context.read<CategoryProvider>().categories
        .cast<Category?>()
        .firstWhere(
          (cat) => cat?.id == expense.categoryId,
          orElse: () => null,
        );

    return Container(
      margin: EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: EdgeInsets.all(16),
        leading: Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.receipt,
            color: AppColors.primary,
          ),
        ),
        title: Text(
          expense.note.isNotEmpty ? expense.note : 'Chi tiêu',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 4),
            Text(
              FormatUtils.formatDate(expense.expenseDate, context),
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
            if (category != null) ...[
              SizedBox(height: 2),
              Text(
                category.name,
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
            if (expense.note.isNotEmpty) ...[
              SizedBox(height: 2),
              Text(
                expense.note,
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
        trailing: Text(
          FormatUtils.formatCurrency(expense.totalAmount, context),
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.primary,
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}