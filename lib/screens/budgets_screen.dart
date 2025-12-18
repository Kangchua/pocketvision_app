import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/budget_provider.dart';
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

  void _loadBudgets() async {
    final user = context.read<AuthProvider>().user;
    if (user == null) return;

    try {
      await context.read<BudgetProvider>().fetchBudgets(user.id);
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
        ],
      ),
      body: Consumer2<BudgetProvider, CategoryProvider>(
        builder: (context, budgetProvider, categoryProvider, _) {
          if (budgetProvider.isLoading) {
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

          return ListView.builder(
            padding: EdgeInsets.all(20),
            itemCount: budgetProvider.budgets.length,
            itemBuilder: (context, index) {
              final budget = budgetProvider.budgets[index];
              final category = categoryProvider.getCategoryById(budget.categoryId);
              final percentage = budget.percentageUsed;

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
                                  color: (AppColors.categoryColors[budget.categoryId % AppColors.categoryColors.length]).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  _getCategoryIcon(category?.name ?? 'Chi tiêu'),
                                  color: AppColors.categoryColors[budget.categoryId % AppColors.categoryColors.length],
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
                                      'Ngân sách hàng tháng',
                                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                        color: ThemeColors.getTextTertiary(context),
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
            },
          );
        },
      ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.3),
              blurRadius: 12,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AddBudgetScreen(),
              ),
            );
          },
          elevation: 0,
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.black,
          child: Icon(Icons.add, size: 28),
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
