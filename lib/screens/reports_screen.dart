import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/expense_provider.dart';
import '../providers/budget_provider.dart';
import '../providers/invoice_provider.dart';
import '../providers/auth_provider.dart';
import '../utils/app_theme.dart';
import '../utils/format_utils.dart';

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
    if (user != null) {
      await Future.wait([
        context.read<ExpenseProvider>().fetchExpenses(user.id),
        context.read<BudgetProvider>().fetchBudgets(user.id),
        context.read<InvoiceProvider>().fetchInvoices(user.id),
      ]);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Báo cáo'),
        elevation: 0,
        backgroundColor: AppColors.surface,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: AppColors.textPrimary),
            onPressed: _loadData,
          ),
        ],
      ),
      body: Consumer3<ExpenseProvider, BudgetProvider, InvoiceProvider>(
        builder: (context, expenseProvider, budgetProvider, invoiceProvider, _) {
          if (expenseProvider.isLoading || budgetProvider.isLoading || invoiceProvider.isLoading) {
            return Center(child: CircularProgressIndicator());
          }

          final totalExpenses = expenseProvider.totalExpenses;
          final totalInvoices = invoiceProvider.totalInvoices;
          final totalBudgets = budgetProvider.budgets.fold(0.0, (sum, budget) => sum + budget.limitAmount);
          final totalSpent = budgetProvider.budgets.fold(0.0, (sum, budget) => sum + budget.spentAmount);

          return RefreshIndicator(
            onRefresh: _loadData,
            child: SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Tổng quan',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildSummaryCard(
                          'Tổng chi tiêu',
                          FormatUtils.formatCurrency(totalExpenses),
                          Icons.trending_down,
                          AppColors.danger,
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: _buildSummaryCard(
                          'Tổng hóa đơn',
                          FormatUtils.formatCurrency(totalInvoices),
                          Icons.receipt_long,
                          AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildSummaryCard(
                          'Ngân sách',
                          FormatUtils.formatCurrency(totalBudgets),
                          Icons.wallet,
                          AppColors.success,
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: _buildSummaryCard(
                          'Đã tiêu',
                          FormatUtils.formatCurrency(totalSpent),
                          Icons.account_balance_wallet,
                          totalSpent > totalBudgets ? AppColors.danger : AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 32),
                  Text(
                    'Chi tiêu theo danh mục',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 16),
                  _buildCategoryExpenses(expenseProvider, totalExpenses),
                  SizedBox(height: 32),
                  Text(
                    'Trạng thái ngân sách',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 16),
                  _buildBudgetStatus(budgetProvider),
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
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
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
                    color: AppColors.textSecondary,
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

  Widget _buildCategoryExpenses(ExpenseProvider expenseProvider, double totalExpenses) {
    // Group expenses by category (this is a simplified version)
    final categoryTotals = <int, double>{};
    for (final expense in expenseProvider.expenses) {
      final categoryId = expense.categoryId ?? 0;
      categoryTotals[categoryId] = (categoryTotals[categoryId] ?? 0) + expense.totalAmount;
    }

    if (categoryTotals.isEmpty) {
      return Container(
        padding: EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Center(
          child: Text(
            'Chưa có dữ liệu chi tiêu',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textTertiary,
            ),
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: ListView.builder(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        itemCount: categoryTotals.length,
        itemBuilder: (context, index) {
          final entry = categoryTotals.entries.elementAt(index);
          final percentage = totalExpenses > 0 ? (entry.value / totalExpenses) * 100 : 0;

          return Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: index < categoryTotals.length - 1
                  ? Border(bottom: BorderSide(color: AppColors.border))
                  : null,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Danh mục ${entry.key}', // In a real app, you'd get category name
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      SizedBox(height: 4),
                      Text(
                        '${percentage.toStringAsFixed(1)}%',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  FormatUtils.formatCurrency(entry.value),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildBudgetStatus(BudgetProvider budgetProvider) {
    if (budgetProvider.budgets.isEmpty) {
      return Container(
        padding: EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Center(
          child: Text(
            'Chưa có ngân sách nào',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textTertiary,
            ),
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: ListView.builder(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        itemCount: budgetProvider.budgets.length,
        itemBuilder: (context, index) {
          final budget = budgetProvider.budgets[index];
          final percentage = budget.percentageUsed;

          return Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: index < budgetProvider.budgets.length - 1
                  ? Border(bottom: BorderSide(color: AppColors.border))
                  : null,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Danh mục ${budget.categoryId}', // In a real app, you'd get category name
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    Text(
                      '${percentage.toStringAsFixed(1)}%',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: percentage > 100 ? AppColors.danger : AppColors.success,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: (percentage / 100).clamp(0, 1),
                    minHeight: 6,
                    backgroundColor: AppColors.surfaceLight,
                    valueColor: AlwaysStoppedAnimation(
                      percentage > 100 ? AppColors.danger : AppColors.success,
                    ),
                  ),
                ),
                SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Đã dùng: ${FormatUtils.formatCurrency(budget.spentAmount)}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    Text(
                      'Ngân sách: ${FormatUtils.formatCurrency(budget.limitAmount)}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}