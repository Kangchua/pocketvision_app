import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/budget.dart';
import '../providers/budget_provider.dart';
import '../providers/expense_provider.dart';
import '../providers/category_provider.dart';
import '../providers/auth_provider.dart';
import '../utils/app_theme.dart';
import '../utils/format_utils.dart';
import '../utils/theme_colors.dart';
import 'add_budget_screen.dart';

class BudgetsScreen extends StatefulWidget {
  const BudgetsScreen({super.key});

  @override
  State<BudgetsScreen> createState() => _BudgetsScreenState();
}

class _BudgetsScreenState extends State<BudgetsScreen> {
  @override
  void initState() {
    super.initState();
    _loadBudgets();
  }

  Future<void> _loadBudgets() async {
    final user = context.read<AuthProvider>().user;
    if (user == null) return;

    try {
      await Future.wait([
        context.read<BudgetProvider>().fetchBudgets(user.id),
        context.read<ExpenseProvider>().fetchExpenses(user.id),
      ]);
      final error = context.read<BudgetProvider>().error;
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

  Future<void> _recalculateBudgets() async {
    final user = context.read<AuthProvider>().user;
    if (user == null) return;

    // Xác nhận
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Tính lại ngân sách?'),
        content: Text(
          'Bạn có muốn tính lại số tiền đã chi cho tất cả ngân sách?\n\n'
          'Hành động này sẽ đảm bảo dữ liệu ngân sách được đồng bộ với chi tiêu.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Tính lại', style: TextStyle(color: ThemeColors.getPrimary(context))),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      // Hiển thị loading
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Text('Đang tính lại ngân sách...'),
              ),
            ],
          ),
          duration: Duration(seconds: 10),
        ),
      );

      // Recalculate budgets
      await context.read<BudgetProvider>().recalculateBudgets(user.id);

      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ Đã tính lại ngân sách thành công!'),
            backgroundColor: ThemeColors.getSuccess(context),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi: ${e.toString()}'),
            backgroundColor: ThemeColors.getDanger(context),
            duration: Duration(seconds: 4),
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
        title: Text('Ngân sách'),
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _loadBudgets,
            tooltip: 'Làm mới',
          ),
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert),
            onSelected: (value) {
              if (value == 'recalculate') {
                _recalculateBudgets();
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'recalculate',
                child: Row(
                  children: [
                    Icon(Icons.calculate, size: 20),
                    SizedBox(width: 8),
                    Text('Tính lại ngân sách'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Consumer3<BudgetProvider, ExpenseProvider, CategoryProvider>(
        builder: (context, budgetProvider, expenseProvider, categoryProvider, _) {
          if (budgetProvider.isLoading || expenseProvider.isLoading) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 48,
                    height: 48,
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      valueColor: AlwaysStoppedAnimation<Color>(ThemeColors.getPrimary(context)),
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Đang tải...',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: ThemeColors.getTextSecondary(context),
                    ),
                  ),
                ],
              ),
            );
          }

          // Tính tổng ngân sách và đã tiêu
          final totalBudgets = budgetProvider.budgets.fold(0.0, (sum, budget) => sum + budget.limitAmount);
          final totalSpent = budgetProvider.budgets.fold(0.0, (sum, budget) => sum + budget.spentAmount);
          final remainingBudget = totalBudgets - totalSpent;

          if (budgetProvider.budgets.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: ThemeColors.getSurface(context),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: ThemeColors.getPrimary(context).withOpacity(0.1),
                          blurRadius: 20,
                          offset: Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.account_balance_wallet,
                      size: 64,
                      color: ThemeColors.getTextLight(context),
                    ),
                  ),
                  SizedBox(height: 24),
                  Text(
                    'Chưa có ngân sách nào',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: ThemeColors.getTextSecondary(context),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Tạo ngân sách đầu tiên để bắt đầu quản lý chi tiêu',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: ThemeColors.getTextTertiary(context),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _loadBudgets,
            child: SingleChildScrollView(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Tổng quan ngân sách
                  Text(
                    'Tổng quan ngân sách',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildSummaryCard(
                          context,
                          'Tổng ngân sách',
                          FormatUtils.formatCurrency(totalBudgets, context),
                          Icons.wallet,
                          AppColors.success,
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: _buildSummaryCard(
                          context,
                          'Đã tiêu',
                          FormatUtils.formatCurrency(totalSpent, context),
                          Icons.account_balance_wallet,
                          totalSpent > totalBudgets ? AppColors.danger : AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12),
                  _buildSummaryCard(
                    context,
                    'Còn lại',
                    FormatUtils.formatCurrency(remainingBudget, context),
                    Icons.savings,
                    remainingBudget < 0 ? AppColors.danger : AppColors.success,
                  ),
                  SizedBox(height: 32),

                  // Biểu đồ trạng thái ngân sách
                  Text(
                    'Trạng thái ngân sách',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 16),
                  _buildBudgetStatusChart(budgetProvider, categoryProvider),
                  SizedBox(height: 32),

                  // Danh sách ngân sách chi tiết
                  Text(
                    'Chi tiết ngân sách',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 16),
                  ...budgetProvider.budgets.asMap().entries.map((entry) {
                    final index = entry.key;
                    final budget = entry.value;
                    return _buildBudgetCard(context, budget, index, categoryProvider);
                  }),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSummaryCard(BuildContext context, String title, String value, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ThemeColors.getSurface(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: ThemeColors.getBorder(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 24),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: ThemeColors.getTextSecondary(context),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBudgetStatusChart(BudgetProvider budgetProvider, CategoryProvider categoryProvider) {
    if (budgetProvider.budgets.isEmpty) {
      return Container(
        padding: EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: ThemeColors.getSurface(context),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: ThemeColors.getBorder(context)),
        ),
        child: Center(
          child: Text(
            'Chưa có ngân sách nào',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: ThemeColors.getTextTertiary(context),
            ),
          ),
        ),
      );
    }

    final barGroups = budgetProvider.budgets.asMap().entries.map((entry) {
      final index = entry.key;
      final budget = entry.value;
      final percentage = budget.percentageUsed.clamp(0.0, 100.0);
      
      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: percentage,
            color: percentage > 100
                ? ThemeColors.getDanger(context)
                : percentage > 80
                    ? ThemeColors.getWarning(context)
                    : ThemeColors.getSuccess(context),
            width: 20,
            borderRadius: BorderRadius.vertical(top: Radius.circular(4)),
          ),
        ],
      );
    }).toList();

    final maxPercentage = budgetProvider.budgets
        .map((b) => b.percentageUsed)
        .fold(0.0, (a, b) => a > b ? a : b);

    return Container(
      height: 250,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ThemeColors.getSurface(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: ThemeColors.getBorder(context)),
      ),
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: maxPercentage > 100 ? maxPercentage * 1.2 : 100,
          barTouchData: BarTouchData(
            enabled: true,
            touchTooltipData: BarTouchTooltipData(
              tooltipBgColor: ThemeColors.getSurface(context),
              tooltipRoundedRadius: 8,
              tooltipPadding: EdgeInsets.all(8),
              tooltipMargin: 8,
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                final budget = budgetProvider.budgets[group.x.toInt()];
                final category = categoryProvider.getCategoryById(budget.categoryId);
                return BarTooltipItem(
                  '${category?.name ?? 'Danh mục'}\n${budget.percentageUsed.toStringAsFixed(1)}%',
                  TextStyle(
                    color: ThemeColors.getTextPrimary(context),
                    fontWeight: FontWeight.w600,
                  ),
                );
              },
            ),
          ),
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  if (value.toInt() >= budgetProvider.budgets.length) {
                    return Text('');
                  }
                  final budget = budgetProvider.budgets[value.toInt()];
                  final category = categoryProvider.getCategoryById(budget.categoryId);
                  final name = category?.name ?? 'DM${budget.categoryId}';
                  return Padding(
                    padding: EdgeInsets.only(top: 8),
                    child: Text(
                      name.length > 8 ? '${name.substring(0, 8)}...' : name,
                      style: TextStyle(
                        fontSize: 10,
                        color: ThemeColors.getTextSecondary(context),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  );
                },
                reservedSize: 40,
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  return Text(
                    '${value.toInt()}%',
                    style: TextStyle(
                      fontSize: 10,
                      color: ThemeColors.getTextSecondary(context),
                    ),
                  );
                },
                reservedSize: 40,
              ),
            ),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            getDrawingHorizontalLine: (value) {
              return FlLine(
                color: ThemeColors.getBorder(context).withOpacity(0.2),
                strokeWidth: 1,
              );
            },
          ),
          borderData: FlBorderData(show: false),
          barGroups: barGroups,
        ),
      ),
    );
  }

  Widget _buildBudgetCard(BuildContext context, Budget budget, int index, CategoryProvider categoryProvider) {
    final category = categoryProvider.getCategoryById(budget.categoryId);
    final percentage = budget.percentageUsed;
    final color = AppColors.categoryColors[budget.categoryId % AppColors.categoryColors.length];

    return Container(
      margin: EdgeInsets.only(bottom: 16),
      child: Card(
        elevation: 4,
        shadowColor: ThemeColors.getPrimary(context).withOpacity(0.1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AddBudgetScreen(budget: budget),
              ),
            );
          },
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with category and percentage
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        _getCategoryIcon(category?.name ?? 'Chi tiêu'),
                        color: color,
                        size: 24,
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            category?.name ?? 'Chi tiêu',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            '${FormatUtils.formatCurrency(budget.spentAmount, context)} / ${FormatUtils.formatCurrency(budget.limitAmount, context)}',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: ThemeColors.getTextSecondary(context),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: percentage > 100
                            ? ThemeColors.getDanger(context).withOpacity(0.1)
                            : percentage > 80
                                ? ThemeColors.getWarning(context).withOpacity(0.1)
                                : ThemeColors.getSuccess(context).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${percentage.toStringAsFixed(1)}%',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: percentage > 100
                              ? ThemeColors.getDanger(context)
                              : percentage > 80
                                  ? ThemeColors.getWarning(context)
                                  : ThemeColors.getSuccess(context),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),

                // Progress bar
                Container(
                  height: 12,
                  decoration: BoxDecoration(
                    color: ThemeColors.getSurfaceLight(context),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: (percentage / 100).clamp(0, 1),
                      backgroundColor: Colors.transparent,
                      valueColor: AlwaysStoppedAnimation(
                        percentage > 100
                            ? ThemeColors.getDanger(context)
                            : percentage > 80
                                ? ThemeColors.getWarning(context)
                                : ThemeColors.getSuccess(context),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 16),

                // Amount details
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Đã chi',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: ThemeColors.getTextTertiary(context),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            FormatUtils.formatCurrency(budget.spentAmount, context),
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: ThemeColors.getTextPrimary(context),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      height: 40,
                      width: 1,
                      color: ThemeColors.getBorder(context),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'Ngân sách',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: ThemeColors.getTextTertiary(context),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            FormatUtils.formatCurrency(budget.limitAmount, context),
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: ThemeColors.getTextPrimary(context),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }


  IconData _getCategoryIcon(String categoryName) {
    switch (categoryName.toLowerCase()) {
      case 'ăn uống':
        return Icons.restaurant;
      case 'di chuyển':
        return Icons.directions_car;
      case 'mua sắm':
        return Icons.shopping_bag;
      case 'giải trí':
        return Icons.movie;
      case 'sức khỏe':
        return Icons.health_and_safety;
      case 'giáo dục':
        return Icons.school;
      case 'nhà ở':
        return Icons.home;
      case 'tiền điện':
        return Icons.electrical_services;
      case 'tiền nước':
        return Icons.water_drop;
      case 'internet':
        return Icons.wifi;
      default:
        return Icons.category;
    }
  }
}
