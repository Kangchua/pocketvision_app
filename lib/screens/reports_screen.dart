import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/expense_provider.dart';
import '../providers/budget_provider.dart';
import '../providers/invoice_provider.dart';
import '../providers/category_provider.dart';
import '../providers/auth_provider.dart';
import '../utils/app_theme.dart';
import '../utils/format_utils.dart';
import '../utils/exception_handler.dart';
import '../utils/theme_colors.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final user = context.read<AuthProvider>().user;
    if (user == null) return;

    try {
      await Future.wait([
        context.read<ExpenseProvider>().fetchExpenses(user.id),
        context.read<BudgetProvider>().fetchBudgets(user.id),
        context.read<InvoiceProvider>().fetchInvoices(user.id),
        context.read<CategoryProvider>().fetchCategories(),
      ]);
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
        title: Text('Báo cáo'),
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _loadData,
          ),
        ],
      ),
      body: Consumer4<ExpenseProvider, BudgetProvider, InvoiceProvider, CategoryProvider>(
        builder: (context, expenseProvider, budgetProvider, invoiceProvider, categoryProvider, _) {
          if (expenseProvider.isLoading || budgetProvider.isLoading || invoiceProvider.isLoading || categoryProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final totalExpenses = expenseProvider.totalExpenses;
          final totalInvoices = invoiceProvider.totalInvoices;
          final totalBudgets = budgetProvider.budgets.fold(0.0, (sum, budget) => sum + budget.limitAmount);
          final totalSpent = budgetProvider.budgets.fold(0.0, (sum, budget) => sum + budget.spentAmount);

          return RefreshIndicator(
            onRefresh: _loadData,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Tổng quan
                  Text(
                    'Tổng quan',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildSummaryCard(
                          'Tổng chi tiêu',
                          FormatUtils.formatCurrency(totalExpenses, context),
                          Icons.trending_down,
                          AppColors.danger,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildSummaryCard(
                          'Tổng hóa đơn',
                          FormatUtils.formatCurrency(totalInvoices, context),
                          Icons.receipt_long,
                          AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildSummaryCard(
                          'Ngân sách',
                          FormatUtils.formatCurrency(totalBudgets, context),
                          Icons.wallet,
                          AppColors.success,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildSummaryCard(
                          'Đã tiêu',
                          FormatUtils.formatCurrency(totalSpent, context),
                          Icons.account_balance_wallet,
                          totalSpent > totalBudgets ? AppColors.danger : AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  
                  // Biểu đồ Pie Chart - Chi tiêu theo danh mục
                  Text(
                    'Chi tiêu theo danh mục',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildCategoryExpensesChart(expenseProvider, categoryProvider, totalExpenses),
                  const SizedBox(height: 16),
                  _buildCategoryExpensesList(expenseProvider, categoryProvider, totalExpenses),
                  const SizedBox(height: 32),
                  
                  // Biểu đồ Bar Chart - Trạng thái ngân sách
                  Text(
                    'Trạng thái ngân sách',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildBudgetStatusChart(budgetProvider, categoryProvider),
                  const SizedBox(height: 16),
                  _buildBudgetStatus(budgetProvider, categoryProvider),
                  const SizedBox(height: 32),
                  
                  // Biểu đồ Line Chart - Xu hướng chi tiêu theo thời gian
                  Text(
                    'Xu hướng chi tiêu',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildExpenseTrendChart(expenseProvider),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSummaryCard(String title, String value, IconData icon, Color color) {
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

  Widget _buildCategoryExpensesChart(ExpenseProvider expenseProvider, CategoryProvider categoryProvider, double totalExpenses) {
    // Group expenses by category
    final categoryTotals = <int, double>{};
    for (final expense in expenseProvider.expenses) {
      final categoryId = expense.categoryId;
      categoryTotals[categoryId] = (categoryTotals[categoryId] ?? 0) + expense.totalAmount;
    }

    if (categoryTotals.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Center(
          child: Text(
            'Chưa có dữ liệu chi tiêu',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: ThemeColors.getTextTertiary(context),
            ),
          ),
        ),
      );
    }

    // Prepare data for pie chart
    final sortedEntries = categoryTotals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    final pieChartData = sortedEntries.asMap().entries.map((entry) {
      final amount = entry.value.value;
      final color = AppColors.categoryColors[entry.key % AppColors.categoryColors.length];
      
      return PieChartSectionData(
        value: amount,
        title: '${(amount / totalExpenses * 100).toStringAsFixed(1)}%',
        color: color,
        radius: 60,
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      );
    }).toList();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ThemeColors.getSurface(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: ThemeColors.getBorder(context)),
      ),
      child: Column(
        children: [
          // Pie Chart
          SizedBox(
            height: 220,
            child: PieChart(
              PieChartData(
                sections: pieChartData,
                sectionsSpace: 2,
                centerSpaceRadius: 60,
                pieTouchData: PieTouchData(
                  touchCallback: (FlTouchEvent event, pieTouchResponse) {
                    // Handle touch if needed
                  },
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Legend
          Wrap(
            spacing: 12,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: sortedEntries.take(6).map((entry) {
              final categoryId = entry.key;
              final amount = entry.value;
              final category = categoryProvider.getCategoryById(categoryId);
              final entryIndex = sortedEntries.indexOf(entry);
              final color = AppColors.categoryColors[entryIndex % AppColors.categoryColors.length];
              
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: color.withOpacity(0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          category?.name ?? 'Danh mục $categoryId',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          '${(amount / totalExpenses * 100).toStringAsFixed(1)}%',
                          style: TextStyle(
                            fontSize: 11,
                            color: ThemeColors.getTextSecondary(context),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryExpensesList(ExpenseProvider expenseProvider, CategoryProvider categoryProvider, double totalExpenses) {
    // Group expenses by category
    final categoryTotals = <int, double>{};
    for (final expense in expenseProvider.expenses) {
      final categoryId = expense.categoryId;
      categoryTotals[categoryId] = (categoryTotals[categoryId] ?? 0) + expense.totalAmount;
    }

    if (categoryTotals.isEmpty) {
      return const SizedBox.shrink();
    }

    final sortedEntries = categoryTotals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Container(
      decoration: BoxDecoration(
        color: ThemeColors.getSurface(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: ThemeColors.getBorder(context)),
      ),
      child: ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: sortedEntries.length,
        itemBuilder: (context, index) {
          final entry = sortedEntries[index];
          final category = categoryProvider.getCategoryById(entry.key);
          final percentage = totalExpenses > 0 ? (entry.value / totalExpenses) * 100 : 0;
          final color = AppColors.categoryColors[index % AppColors.categoryColors.length];

          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: index < sortedEntries.length - 1
                  ? const Border(bottom: BorderSide(color: AppColors.border))
                  : null,
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    _getCategoryIcon(category?.icon ?? 'category'),
                    color: color,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        category?.name ?? 'Danh mục ${entry.key}',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(2),
                              child: LinearProgressIndicator(
                                value: percentage / 100,
                                minHeight: 4,
                                backgroundColor: AppColors.surfaceLight,
                                valueColor: AlwaysStoppedAnimation(color),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${percentage.toStringAsFixed(1)}%',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: ThemeColors.getTextSecondary(context),
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  FormatUtils.formatCurrency(entry.value, context),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  IconData _getCategoryIcon(String iconName) {
    switch (iconName) {
      case 'shopping_cart':
        return Icons.shopping_cart;
      case 'restaurant':
        return Icons.restaurant;
      case 'local_gas_station':
        return Icons.local_gas_station;
      case 'home':
        return Icons.home;
      case 'school':
        return Icons.school;
      case 'medical_services':
        return Icons.medical_services;
      case 'flight':
        return Icons.flight;
      case 'directions_car':
        return Icons.directions_car;
      case 'local_movies':
        return Icons.local_movies;
      case 'sports_soccer':
        return Icons.sports_soccer;
      default:
        return Icons.category;
    }
  }

  Widget _buildBudgetStatusChart(BudgetProvider budgetProvider, CategoryProvider categoryProvider) {
    if (budgetProvider.budgets.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
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

    // Prepare data for bar chart
    final barGroups = budgetProvider.budgets.asMap().entries.map((entry) {
      final index = entry.key;
      final budget = entry.value;
      final percentage = budget.percentageUsed.clamp(0.0, 100.0);
      final color = percentage > 100 
          ? AppColors.danger 
          : percentage > 80 
              ? AppColors.warning 
              : AppColors.success;
      
      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: percentage,
            color: color,
            width: 20,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
          ),
        ],
      );
    }).toList();

    final maxPercentage = budgetProvider.budgets
        .map((b) => b.percentageUsed)
        .fold(0.0, (max, p) => p > max ? p : max)
        .ceilToDouble()
        .clamp(100.0, 200.0);

    return Container(
      height: 200,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ThemeColors.getSurface(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: ThemeColors.getBorder(context)),
      ),
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: maxPercentage,
          barTouchData: BarTouchData(
            enabled: true,
            touchTooltipData: BarTouchTooltipData(
              tooltipBgColor: AppColors.surface,
              tooltipRoundedRadius: 8,
            ),
          ),
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  if (value.toInt() >= budgetProvider.budgets.length) {
                    return const Text('');
                  }
                  final budget = budgetProvider.budgets[value.toInt()];
                  final category = categoryProvider.getCategoryById(budget.categoryId);
                  final name = category?.name ?? 'DM${budget.categoryId}';
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      name.length > 6 ? '${name.substring(0, 6)}...' : name,
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
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
          ),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: 25,
            getDrawingHorizontalLine: (value) {
              return FlLine(
                color: AppColors.border,
                strokeWidth: 1,
              );
            },
          ),
          borderData: FlBorderData(
            show: true,
            border: Border.all(color: AppColors.border),
          ),
          barGroups: barGroups,
        ),
      ),
    );
  }

  Widget _buildBudgetStatus(BudgetProvider budgetProvider, CategoryProvider categoryProvider) {
    if (budgetProvider.budgets.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      decoration: BoxDecoration(
        color: ThemeColors.getSurface(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: ThemeColors.getBorder(context)),
      ),
      child: ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: budgetProvider.budgets.length,
        itemBuilder: (context, index) {
          final budget = budgetProvider.budgets[index];
          final category = categoryProvider.getCategoryById(budget.categoryId);
          final percentage = budget.percentageUsed;
          final color = AppColors.categoryColors[index % AppColors.categoryColors.length];

          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: index < budgetProvider.budgets.length - 1
                  ? const Border(bottom: BorderSide(color: AppColors.border))
                  : null,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        _getCategoryIcon(category?.icon ?? 'category'),
                        color: color,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            category?.name ?? 'Danh mục ${budget.categoryId}',
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${FormatUtils.formatCurrency(budget.spentAmount, context)} / ${FormatUtils.formatCurrency(budget.limitAmount, context)}',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: ThemeColors.getTextSecondary(context),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: percentage > 100
                            ? AppColors.danger.withOpacity(0.1)
                            : percentage > 80
                                ? AppColors.warning.withOpacity(0.1)
                                : AppColors.success.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${percentage.toStringAsFixed(1)}%',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: percentage > 100 
                              ? AppColors.danger 
                              : percentage > 80 
                                  ? AppColors.warning 
                                  : AppColors.success,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: (percentage / 100).clamp(0, 1),
                    minHeight: 8,
                    backgroundColor: AppColors.surfaceLight,
                    valueColor: AlwaysStoppedAnimation(
                      percentage > 100 
                          ? AppColors.danger 
                          : percentage > 80 
                              ? AppColors.warning 
                              : AppColors.success,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildExpenseTrendChart(ExpenseProvider expenseProvider) {
    // Group expenses by month
    final monthlyExpenses = <String, double>{};
    final now = DateTime.now();
    
    // Get last 6 months
    for (int i = 5; i >= 0; i--) {
      final date = DateTime(now.year, now.month - i, 1);
      final key = '${date.month}/${date.year}';
      monthlyExpenses[key] = 0.0;
    }

    // Calculate expenses per month
    for (final expense in expenseProvider.expenses) {
      final key = '${expense.expenseDate.month}/${expense.expenseDate.year}';
      if (monthlyExpenses.containsKey(key)) {
        monthlyExpenses[key] = (monthlyExpenses[key] ?? 0) + expense.totalAmount;
      }
    }

    if (monthlyExpenses.values.every((v) => v == 0)) {
      return Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Center(
          child: Text(
            'Chưa có dữ liệu chi tiêu',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: ThemeColors.getTextTertiary(context),
            ),
          ),
        ),
      );
    }

    final maxValue = monthlyExpenses.values.fold(0.0, (max, v) => v > max ? v : max);
    final spots = monthlyExpenses.entries.toList().asMap().entries.map((entry) {
      return FlSpot(entry.key.toDouble(), entry.value.value);
    }).toList();

    return Container(
      height: 200,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ThemeColors.getSurface(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: ThemeColors.getBorder(context)),
      ),
      child: LineChart(
        LineChartData(
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: maxValue > 0 ? maxValue / 4 : 100000,
            getDrawingHorizontalLine: (value) {
              return FlLine(
                color: AppColors.border,
                strokeWidth: 1,
              );
            },
          ),
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index >= monthlyExpenses.length) {
                    return const Text('');
                  }
                  final key = monthlyExpenses.keys.elementAt(index);
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      key,
                      style: TextStyle(
                        fontSize: 10,
                        color: ThemeColors.getTextSecondary(context),
                      ),
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
                  if (value <= 0) return const Text('');
                  return Text(
                    '${(value / 1000).toStringAsFixed(0)}k',
                    style: TextStyle(
                      fontSize: 10,
                      color: ThemeColors.getTextSecondary(context),
                    ),
                  );
                },
                reservedSize: 40,
              ),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
          ),
          borderData: FlBorderData(
            show: true,
            border: Border.all(color: AppColors.border),
          ),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              color: AppColors.primary,
              barWidth: 3,
              isStrokeCapRound: true,
              dotData: const FlDotData(show: true),
              belowBarData: BarAreaData(
                show: true,
                color: AppColors.primary.withOpacity(0.1),
              ),
            ),
          ],
          minY: 0,
          maxY: maxValue > 0 ? maxValue * 1.2 : 100000,
        ),
      ),
    );
  }
}