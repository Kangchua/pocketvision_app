import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/expense.dart';
import '../providers/expense_provider.dart';
import '../providers/budget_provider.dart';
import '../providers/category_provider.dart';
import '../providers/auth_provider.dart';
import '../utils/app_theme.dart';
import '../utils/format_utils.dart';
import '../utils/exception_handler.dart';
import '../utils/theme_colors.dart';
import 'add_expense_screen.dart';

class ExpensesScreen extends StatefulWidget {
  const ExpensesScreen({super.key});

  @override
  State<ExpensesScreen> createState() => _ExpensesScreenState();
}

class _ExpensesScreenState extends State<ExpensesScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadExpenses();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadExpenses() async {
    final user = context.read<AuthProvider>().user;
    if (user == null) return;

    try {
      await context.read<ExpenseProvider>().fetchExpenses(user.id);
      final error = context.read<ExpenseProvider>().error;
      if (error != null && mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi: $error'),
            backgroundColor: ThemeColors.getDanger(context),
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi tải dữ liệu: $e'),
            backgroundColor: ThemeColors.getDanger(context),
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeColors.getBackground(context),
      appBar: AppBar(
        title: Text('Chi tiêu'),
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _loadExpenses,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: ThemeColors.getPrimary(context),
          unselectedLabelColor: ThemeColors.getTextSecondary(context),
          indicatorColor: ThemeColors.getPrimary(context),
          tabs: const [
            Tab(text: 'Tất cả'),
            Tab(text: 'Tuần'),
            Tab(text: 'Tháng'),
            Tab(text: 'Năm'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildExpensesList('Tất cả'),
          _buildExpensesList('Tuần'),
          _buildExpensesList('Tháng'),
          _buildExpensesList('Năm'),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        key: const ValueKey('add_expense_fab'),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddExpenseScreen(),
            ),
          );
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildExpensesList(String period) {
    return Consumer2<ExpenseProvider, CategoryProvider>(
      builder: (context, expenseProvider, categoryProvider, _) {
        if (expenseProvider.isLoading) {
          return Center(child: CircularProgressIndicator());
        }

        // Lọc expenses theo period
        List<Expense> filteredExpenses = [];
        double totalAmount = 0.0;
        String periodLabel = '';

        switch (period) {
          case 'Tất cả':
            filteredExpenses = expenseProvider.expenses;
            totalAmount = expenseProvider.totalExpenses;
            periodLabel = 'Tất cả chi tiêu';
            break;
          case 'Tuần':
            filteredExpenses = expenseProvider.getExpensesByWeek(_selectedDate);
            totalAmount = expenseProvider.getTotalExpensesByWeek(_selectedDate);
            final weekday = _selectedDate.weekday;
            final startOfWeek = _selectedDate.subtract(Duration(days: weekday - 1));
            final endOfWeek = startOfWeek.add(Duration(days: 6));
            periodLabel = 'Tuần này (${FormatUtils.formatDate(startOfWeek, context)} - ${FormatUtils.formatDate(endOfWeek, context)})';
            break;
          case 'Tháng':
            filteredExpenses = expenseProvider.getExpensesByMonth(_selectedDate);
            totalAmount = expenseProvider.getTotalExpensesByMonth(_selectedDate);
            periodLabel = 'Tháng ${_selectedDate.month}/${_selectedDate.year}';
            break;
          case 'Năm':
            filteredExpenses = expenseProvider.getExpensesByYear(_selectedDate.year);
            totalAmount = expenseProvider.getTotalExpensesByYear(_selectedDate.year);
            periodLabel = 'Năm ${_selectedDate.year}';
            break;
        }

        // Sắp xếp theo ngày (mới nhất trước)
        filteredExpenses.sort((a, b) => b.expenseDate.compareTo(a.expenseDate));

        return RefreshIndicator(
          onRefresh: _loadExpenses,
          child: Column(
            children: [
              // Header với tổng chi tiêu và period selector - LUÔN HIỂN THỊ
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: ThemeColors.getSurface(context),
                  border: Border(
                    bottom: BorderSide(color: ThemeColors.getBorder(context)),
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                periodLabel,
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: ThemeColors.getTextSecondary(context),
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                FormatUtils.formatCurrency(totalAmount, context),
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w700,
                                  color: ThemeColors.getDanger(context),
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Nút chọn thời gian - LUÔN HIỂN THỊ khi không phải tab "Tất cả"
                        if (period != 'Tất cả')
                          IconButton(
                            icon: Icon(Icons.calendar_today),
                            onPressed: () => _selectPeriodDate(period),
                            tooltip: 'Chọn thời gian',
                          ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Text(
                      '${filteredExpenses.length} chi tiêu',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: ThemeColors.getTextTertiary(context),
                      ),
                    ),
                  ],
                ),
              ),
              // Danh sách chi tiêu hoặc empty state
              Expanded(
                child: filteredExpenses.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.receipt_long,
                                size: 64, color: ThemeColors.getTextLight(context)),
                            SizedBox(height: 16),
                            Text(
                              'Chưa có chi tiêu nào',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: ThemeColors.getTextTertiary(context),
                              ),
                            ),
                            if (period != 'Tất cả') ...[
                              SizedBox(height: 8),
                              Text(
                                periodLabel,
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: ThemeColors.getTextTertiary(context),
                                ),
                              ),
                              SizedBox(height: 16),
                              TextButton.icon(
                                onPressed: () => _selectPeriodDate(period),
                                icon: Icon(Icons.calendar_today),
                                label: Text('Chọn thời gian khác'),
                                style: TextButton.styleFrom(
                                  foregroundColor: ThemeColors.getPrimary(context),
                                ),
                              ),
                            ],
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: filteredExpenses.length,
                        cacheExtent: 500,
                        itemBuilder: (context, index) {
                          final expense = filteredExpenses[index];
                    final category = categoryProvider.getCategoryById(expense.categoryId);

                    return Dismissible(
                      key: Key(expense.id.toString()),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: EdgeInsets.only(right: 20),
                        decoration: BoxDecoration(
                          color: ThemeColors.getDanger(context),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.delete,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                      confirmDismiss: (direction) async {
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
                                child: Text('Xóa', style: TextStyle(color: ThemeColors.getDanger(context))),
                              ),
                            ],
                          ),
                        );
                        return confirm == true;
                      },
                      onDismissed: (direction) async {
                        final user = context.read<AuthProvider>().user;
                        if (user == null) return;

                        try {
                          await context.read<ExpenseProvider>().deleteExpense(expense.id);
                          
                          // Refresh budgets để cập nhật spentAmount
                          if (mounted) {
                            try {
                              await context.read<BudgetProvider>().fetchBudgets(user.id);
                            } catch (e) {
                              // Ignore budget refresh errors
                            }
                          }

                          if (mounted) {
                            ScaffoldMessenger.of(context).hideCurrentSnackBar();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text('Xóa chi tiêu thành công'),
                                backgroundColor: ThemeColors.getSuccess(context),
                                duration: const Duration(seconds: 2),
                              ),
                            );
                          }
                        } catch (e) {
                          if (mounted) {
                            ScaffoldMessenger.of(context).hideCurrentSnackBar();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Lỗi: ${ExceptionHandler.getErrorMessage(e)}'),
                                backgroundColor: ThemeColors.getDanger(context),
                                duration: const Duration(seconds: 4),
                              ),
                            );
                          }
                        }
                      },
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AddExpenseScreen(expense: expense),
                            ),
                          );
                        },
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: ThemeColors.getSurface(context),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: ThemeColors.getBorder(context)),
                          ),
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: AppColors.surfaceLight,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Center(
                                  child: Icon(
                                    Icons.receipt,
                                    color: AppColors.primary,
                                    size: 24,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      expense.note.isNotEmpty
                                          ? expense.note
                                          : (category?.name ?? 'Chi tiêu'),
                                      style: Theme.of(context).textTheme.titleSmall,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      FormatUtils.formatDate(expense.expenseDate, context),
                                      style: Theme.of(context).textTheme.bodySmall,
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                FormatUtils.formatCurrency(expense.totalAmount, context),
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: ThemeColors.getDanger(context),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _selectPeriodDate(String period) async {
    switch (period) {
      case 'Tuần':
        // Chọn tuần: Chọn tháng/năm trước, sau đó chọn tuần trong tháng
        final monthYear = await _selectMonthYear();
        if (monthYear != null) {
          final week = await _selectWeekInMonth(monthYear['year']!, monthYear['month']!);
          if (week != null) {
            setState(() {
              _selectedDate = week;
            });
          }
        }
        return;
      case 'Tháng':
        // Chọn tháng/năm
        final monthYear = await _selectMonthYear();
        if (monthYear != null) {
          setState(() {
            _selectedDate = DateTime(monthYear['year']!, monthYear['month']!, 1);
          });
        }
        return;
      case 'Năm':
        // Chọn năm
        final year = await showDialog<int>(
          context: context,
          builder: (context) {
            final currentYear = DateTime.now().year;
            final years = List.generate(10, (i) => currentYear - i);
            return AlertDialog(
              title: Text('Chọn năm'),
              content: Container(
                width: double.maxFinite,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: years.length,
                  itemBuilder: (context, index) {
                    final year = years[index];
                    return ListTile(
                      title: Text(year.toString()),
                      onTap: () => Navigator.pop(context, year),
                    );
                  },
                ),
              ),
            );
          },
        );
        if (year != null) {
          setState(() {
            _selectedDate = DateTime(year, 1, 1);
          });
        }
        return;
    }

  }

  /// Chọn tháng và năm
  Future<Map<String, int>?> _selectMonthYear() async {
    int? selectedYear;
    int? selectedMonth;

    // Bước 1: Chọn năm
    final year = await showDialog<int>(
      context: context,
      builder: (context) {
        final currentYear = DateTime.now().year;
        final years = List.generate(10, (i) => currentYear - i);
        return AlertDialog(
          title: Text('Chọn năm'),
          content: Container(
            width: double.maxFinite,
            height: 300,
            child: ListView.builder(
              itemCount: years.length,
              itemBuilder: (context, index) {
                final year = years[index];
                return ListTile(
                  title: Text(year.toString()),
                  onTap: () => Navigator.pop(context, year),
                );
              },
            ),
          ),
        );
      },
    );

    if (year == null) return null;
    selectedYear = year;

    // Bước 2: Chọn tháng (1-12)
    final month = await showDialog<int>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Chọn tháng'),
          content: Container(
            width: double.maxFinite,
            height: 400,
            child: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: 12,
              itemBuilder: (context, index) {
                final month = index + 1;
                final monthNames = [
                  'Tháng 1', 'Tháng 2', 'Tháng 3', 'Tháng 4',
                  'Tháng 5', 'Tháng 6', 'Tháng 7', 'Tháng 8',
                  'Tháng 9', 'Tháng 10', 'Tháng 11', 'Tháng 12'
                ];
                return InkWell(
                  onTap: () => Navigator.pop(context, month),
                  child: Container(
                    decoration: BoxDecoration(
                      color: ThemeColors.getSurface(context),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: ThemeColors.getBorder(context)),
                    ),
                    child: Center(
                      child: Text(
                        monthNames[index],
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: ThemeColors.getTextPrimary(context),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );

    if (month == null) return null;
    selectedMonth = month;

    return {'year': selectedYear, 'month': selectedMonth};
  }

  /// Chọn tuần trong tháng
  Future<DateTime?> _selectWeekInMonth(int year, int month) async {
    // Tính các tuần trong tháng
    final firstDayOfMonth = DateTime(year, month, 1);
    final lastDayOfMonth = DateTime(year, month + 1, 0);
    
    // Tìm thứ 2 đầu tiên của tháng (hoặc thứ 2 trước đó nếu tháng bắt đầu không phải thứ 2)
    int firstDayWeekday = firstDayOfMonth.weekday; // 1 = Monday, 7 = Sunday
    DateTime startOfFirstWeek = firstDayOfMonth.subtract(Duration(days: firstDayWeekday - 1));
    
    // Tìm thứ 2 cuối cùng của tháng
    int lastDayWeekday = lastDayOfMonth.weekday;
    DateTime endOfLastWeek = lastDayOfMonth.add(Duration(days: 7 - lastDayWeekday));
    
    // Tạo danh sách các tuần
    List<Map<String, DateTime>> weeks = [];
    DateTime currentWeekStart = startOfFirstWeek;
    
    while (currentWeekStart.isBefore(endOfLastWeek) || currentWeekStart.isAtSameMomentAs(endOfLastWeek)) {
      DateTime weekEnd = currentWeekStart.add(Duration(days: 6));
      
      // Chỉ thêm tuần nếu nó có ít nhất 1 ngày trong tháng
      if (weekEnd.isAfter(firstDayOfMonth.subtract(Duration(days: 1))) && 
          currentWeekStart.isBefore(lastDayOfMonth.add(Duration(days: 1)))) {
        weeks.add({
          'start': currentWeekStart,
          'end': weekEnd,
        });
      }
      
      currentWeekStart = currentWeekStart.add(Duration(days: 7));
    }

    // Hiển thị dialog chọn tuần
    final selectedWeek = await showDialog<Map<String, DateTime>>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Chọn tuần - Tháng $month/$year'),
          content: Container(
            width: double.maxFinite,
            height: 400,
            child: ListView.builder(
              itemCount: weeks.length,
              itemBuilder: (context, index) {
                final week = weeks[index];
                final start = week['start']!;
                final end = week['end']!;
                
                // Format ngày
                final startStr = '${start.day}/${start.month}';
                final endStr = '${end.day}/${end.month}';
                
                return ListTile(
                  title: Text('Tuần ${index + 1}'),
                  subtitle: Text('$startStr - $endStr'),
                  onTap: () => Navigator.pop(context, week),
                );
              },
            ),
          ),
        );
      },
    );

    if (selectedWeek != null) {
      // Trả về ngày đầu tuần (thứ 2)
      return selectedWeek['start'];
    }
    
    return null;
  }
}
