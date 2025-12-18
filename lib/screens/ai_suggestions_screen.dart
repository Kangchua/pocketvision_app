import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/expense_provider.dart';
import '../providers/budget_provider.dart';
import '../providers/auth_provider.dart';
import '../utils/app_theme.dart';
import '../utils/format_utils.dart';

class AISuggestionsScreen extends StatefulWidget {
  const AISuggestionsScreen({super.key});

  @override
  State<AISuggestionsScreen> createState() => _AISuggestionsScreenState();
}

class _AISuggestionsScreenState extends State<AISuggestionsScreen> {
  List<String> _suggestions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _generateSuggestions();
  }

  void _generateSuggestions() async {
    final authProvider = context.read<AuthProvider>();
    final expenseProvider = context.read<ExpenseProvider>();
    final budgetProvider = context.read<BudgetProvider>();

    final user = authProvider.user;
    if (user == null) return;

    // Simulate AI processing
    await Future.delayed(Duration(seconds: 2));

    final suggestions = <String>[];

    // Analyze spending patterns
    final currentMonth = DateTime.now();
    final monthlyExpenses = expenseProvider.expenses
        .where((e) => e.expenseDate.month == currentMonth.month && e.expenseDate.year == currentMonth.year)
        .toList();

    final totalSpent = monthlyExpenses.fold<double>(0.0, (sum, e) => sum + e.totalAmount);
    final totalBudget = budgetProvider.budgets.fold(0.0, (sum, b) => sum + b.limitAmount);

    // Budget analysis
    if (totalBudget > 0) {
      final budgetUsage = (totalSpent / totalBudget) * 100;
      if (budgetUsage > 90) {
        suggestions.add('Bạn đã sử dụng ${budgetUsage.toStringAsFixed(1)}% ngân sách tháng này. Hãy cân nhắc giảm chi tiêu không cần thiết.');
      } else if (budgetUsage < 50) {
        suggestions.add('Bạn đang quản lý ngân sách rất tốt! Chỉ sử dụng ${budgetUsage.toStringAsFixed(1)}% ngân sách tháng này.');
      }
    }

    // Category analysis
    final categorySpending = <int, double>{};
    for (final expense in monthlyExpenses) {
      categorySpending[expense.categoryId] = (categorySpending[expense.categoryId] ?? 0) + expense.totalAmount;
    }

    final topCategory = categorySpending.entries
        .reduce((a, b) => a.value > b.value ? a : b);

    suggestions.add('Danh mục chi tiêu nhiều nhất tháng này là ${topCategory.key} với ${FormatUtils.formatCurrency(topCategory.value, context)}.');

    // Trend analysis
    final lastMonth = DateTime(currentMonth.year, currentMonth.month - 1);
    final lastMonthExpenses = expenseProvider.expenses
        .where((e) => e.expenseDate.month == lastMonth.month && e.expenseDate.year == lastMonth.year)
        .fold(0.0, (sum, e) => sum + e.totalAmount);

    if (lastMonthExpenses > 0) {
      final change = ((totalSpent - lastMonthExpenses) / lastMonthExpenses) * 100;
      if (change > 20) {
        suggestions.add('Chi tiêu tháng này tăng ${change.toStringAsFixed(1)}% so với tháng trước. Hãy xem xét lại các khoản chi.');
      } else if (change < -10) {
        suggestions.add('Tuyệt vời! Chi tiêu tháng này giảm ${change.abs().toStringAsFixed(1)}% so với tháng trước.');
      }
    }

    // Savings suggestions
    if (totalBudget > 0 && totalSpent < totalBudget) {
      final remaining = totalBudget - totalSpent;
      suggestions.add('Bạn còn ${FormatUtils.formatCurrency(remaining, context)} trong ngân sách tháng này. Có thể tiết kiệm hoặc đầu tư số tiền này.');
    }

    // Frequency analysis
    final dailySpending = monthlyExpenses.isNotEmpty ? totalSpent / DateTime.now().day : 0.0;
    if (dailySpending > 100000) { // More than 100k per day
      suggestions.add('Chi tiêu trung bình ${FormatUtils.formatCurrency(dailySpending, context)}/ngày. Hãy lập kế hoạch chi tiêu hợp lý hơn.');
    }

    // Default suggestions if not enough data
    if (suggestions.isEmpty) {
      suggestions.addAll([
        'Hãy thiết lập ngân sách cho các danh mục chi tiêu để theo dõi tốt hơn.',
        'Ghi chép đầy đủ các khoản chi tiêu để có cái nhìn tổng quan về tài chính.',
        'Xem xét các khoản chi tiêu có thể cắt giảm để tiết kiệm.',
        'Đặt mục tiêu tiết kiệm hàng tháng để xây dựng quỹ dự phòng.',
      ]);
    }

    if (mounted) {
      setState(() {
        _suggestions = suggestions;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Gợi ý AI'),
        elevation: 0,
        backgroundColor: AppColors.surface,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: AppColors.primary),
            onPressed: () {
              setState(() {
                _isLoading = true;
                _suggestions = [];
              });
              _generateSuggestions();
            },
          ),
        ],
      ),
      body: _isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.smart_toy,
                      size: 48,
                      color: AppColors.primary,
                    ),
                  ),
                  SizedBox(height: 24),
                  Text(
                    'Đang phân tích dữ liệu...',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'AI đang học hỏi thói quen chi tiêu của bạn',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  SizedBox(height: 24),
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppColors.primary, AppColors.primary.withOpacity(0.8)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.3),
                          blurRadius: 12,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    padding: EdgeInsets.all(24),
                    child: Column(
                      children: [
                        Icon(
                          Icons.lightbulb,
                          size: 48,
                          color: Colors.white,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Gợi ý thông minh',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Dựa trên phân tích chi tiêu của bạn',
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

                  // Suggestions List
                  ..._suggestions.map((suggestion) => Padding(
                        padding: EdgeInsets.only(bottom: 16),
                        child: Container(
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
                          padding: EdgeInsets.all(16),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  Icons.smart_toy,
                                  color: AppColors.primary,
                                  size: 20,
                                ),
                              ),
                              SizedBox(width: 16),
                              Expanded(
                                child: Text(
                                  suggestion,
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: AppColors.textPrimary,
                                    height: 1.5,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )),

                  // Additional Tips
                  SizedBox(height: 24),
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.border),
                    ),
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.tips_and_updates, color: AppColors.primary),
                            SizedBox(width: 8),
                            Text(
                              'Mẹo quản lý tài chính',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 16),
                        _buildTipItem('Theo dõi chi tiêu hàng ngày'),
                        _buildTipItem('Đặt mục tiêu tiết kiệm rõ ràng'),
                        _buildTipItem('Phân tích báo cáo chi tiêu định kỳ'),
                        _buildTipItem('Tìm kiếm ưu đãi và giảm giá'),
                        _buildTipItem('Đầu tư số tiền tiết kiệm được'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildTipItem(String tip) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              tip,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}