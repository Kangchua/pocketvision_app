import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/expense_provider.dart';
import '../providers/category_provider.dart';
import '../providers/budget_provider.dart';
import '../providers/notification_provider.dart';
import '../utils/app_theme.dart';
import '../utils/format_utils.dart';
import 'expenses_screen.dart';
import 'budgets_screen.dart';
import 'invoices_screen.dart';
import 'reports_screen.dart';
import 'notifications_screen.dart';
import 'profile_screen.dart';
import 'add_expense_screen.dart';
import 'settings_screen.dart';
import 'categories_screen.dart';
import 'search_expenses_screen.dart';
import 'ai_suggestions_screen.dart';
import 'upload_invoice_screen.dart';
import 'fill_expense_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    // Sử dụng addPostFrameCallback để tránh setState trong build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  void _loadData() async {
    if (!mounted) return;
    final authProvider = context.read<AuthProvider>();
    final user = authProvider.user;

    if (user != null) {
      try {
        await context.read<ExpenseProvider>().fetchExpenses(user.id);
        await context.read<CategoryProvider>().fetchCategories();
        await context.read<BudgetProvider>().fetchBudgets(user.id);
        // Bỏ qua lỗi notification nếu có
        try {
          await context.read<NotificationProvider>().fetchNotifications();
        } catch (e) {
          // Ignore notification errors
        }
      } catch (e) {
        // Handle errors silently
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('PocketVision'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: AppColors.surface,
        leading: Builder(
          builder: (context) => IconButton(
            icon: Icon(Icons.menu, color: AppColors.textPrimary),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: [
          _buildDashboard(),
          const ExpensesScreen(),
          const BudgetsScreen(),
          const InvoicesScreen(),
          const ReportsScreen(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Trang chủ',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt),
            label: 'Chi tiêu',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.trending_down),
            label: 'Ngân sách',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long),
            label: 'Hóa đơn',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: 'Báo cáo',
          ),
        ],
      ),
      drawer: Drawer(
        child: Container(
          color: AppColors.surface,
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              DrawerHeader(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  border: Border(
                    bottom: BorderSide(
                      color: AppColors.border,
                      width: 1,
                    ),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: AppColors.primary,
                      child: Icon(
                        Icons.person,
                        size: 30,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 12),
                    Consumer<AuthProvider>(
                      builder: (context, authProvider, _) {
                        final user = authProvider.user;
                        return Text(
                          user?.fullName ?? 'Người dùng',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              ListTile(
                leading: Icon(Icons.search, color: AppColors.textPrimary),
                title: Text('Tìm kiếm chi tiêu'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => SearchExpensesScreen()),
                  );
                },
              ),
              ListTile(
                leading: Icon(Icons.smart_toy, color: AppColors.textPrimary),
                title: Text('Gợi ý AI'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => AISuggestionsScreen()),
                  );
                },
              ),
              ListTile(
                leading: Icon(Icons.category, color: AppColors.textPrimary),
                title: Text('Danh mục'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => CategoriesScreen()),
                  );
                },
              ),
              ListTile(
                leading: Icon(Icons.upload_file, color: AppColors.textPrimary),
                title: Text('Upload hóa đơn'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => UploadInvoiceScreen()),
                  );
                },
              ),
              ListTile(
                leading: Icon(Icons.edit_note, color: AppColors.textPrimary),
                title: Text('Điền chi tiêu'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => FillExpenseScreen()),
                  );
                },
              ),
              Divider(),
              ListTile(
                leading: Icon(Icons.notifications, color: AppColors.textPrimary),
                title: Text('Thông báo'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => NotificationsScreen()),
                  );
                },
              ),
              ListTile(
                leading: Icon(Icons.person, color: AppColors.textPrimary),
                title: Text('Tài khoản'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ProfileScreen()),
                  );
                },
              ),
              ListTile(
                leading: Icon(Icons.settings, color: AppColors.textPrimary),
                title: Text('Cài đặt'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => SettingsScreen()),
                  );
                },
              ),
              Divider(),
              ListTile(
                leading: Icon(Icons.logout, color: AppColors.danger),
                title: Text('Đăng xuất'),
                onTap: () {
                  context.read<AuthProvider>().logout();
                  Navigator.pushReplacementNamed(context, '/login');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDashboard() {
    return Consumer3<AuthProvider, ExpenseProvider, BudgetProvider>(
      builder: (context, authProvider, expenseProvider, budgetProvider, _) {
        final user = authProvider.user;
        if (user == null) return SizedBox.shrink();

        // Tính toán thống kê như web
        final currentMonth = DateTime.now();
        final monthlyExpenses = expenseProvider.expenses
            .where((e) => e.expenseDate.month == currentMonth.month && e.expenseDate.year == currentMonth.year)
            .fold(0.0, (sum, e) => sum + e.totalAmount);
        final totalBudget = budgetProvider.budgets.fold(0.0, (sum, b) => sum + b.limitAmount);
        final budgetUsed = budgetProvider.budgets.fold(0.0, (sum, b) => sum + b.spentAmount);
        final remainingBudget = totalBudget - budgetUsed;
        final budgetUsagePercentage = totalBudget > 0 ? (budgetUsed / totalBudget * 100).round() : 0;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header Section như web
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Tổng quan chi tiêu',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          foreground: Paint()
                            ..shader = LinearGradient(
                              colors: [AppColors.primary, AppColors.primary.withOpacity(0.6)],
                            ).createShader(Rect.fromLTWH(0, 0, 200, 70)),
                        ),
                      ),
                      Text(
                        'Số liệu tài chính tháng ${currentMonth.month}/${currentMonth.year} của bạn',
                        style: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.refresh, color: AppColors.primary),
                        onPressed: _loadData,
                      ),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.add),
                        label: const Text('Thêm chi tiêu'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          elevation: 4,
                          shadowColor: AppColors.primary.withOpacity(0.3),
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const AddExpenseScreen()),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Stats Grid như web
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                children: [
                  _buildStatCard(
                    title: 'Tổng chi tiêu',
                    value: expenseProvider.totalExpenses,
                    description: 'Tích lũy từ trước đến nay',
                    icon: Icons.trending_down,
                    iconColor: AppColors.primary,
                  ),
                  _buildStatCard(
                    title: 'Chi tiêu tháng này',
                    value: monthlyExpenses,
                    description: 'Tháng ${currentMonth.month}',
                    icon: Icons.credit_card,
                    iconColor: Colors.purple,
                    valueColor: Colors.purple,
                  ),
                  _buildStatCard(
                    title: 'Ngân sách tháng',
                    value: totalBudget,
                    description: 'Đã dùng: ${FormatUtils.formatCurrency(budgetUsed)}',
                    icon: Icons.savings,
                    iconColor: Colors.blue,
                    valueColor: Colors.blue,
                  ),
                  _buildStatCard(
                    title: 'Ngân sách còn lại',
                    value: remainingBudget,
                    description: totalBudget > 0 ? '$budgetUsagePercentage% đã sử dụng' : 'Chưa thiết lập ngân sách',
                    icon: Icons.account_balance_wallet,
                    iconColor: remainingBudget < 0 ? Colors.red : Colors.green,
                    valueColor: remainingBudget < 0 ? Colors.red : Colors.green,
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Quick Actions như web
              Text(
                'Truy cập nhanh',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 16),
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                children: [
                  _buildQuickActionCard(
                    icon: Icons.add,
                    title: 'Thêm giao dịch',
                    description: 'Ghi lại ngay khoản chi tiêu mới để theo dõi dòng tiền chính xác nhất.',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => AddExpenseScreen()),
                      );
                    },
                  ),
                  _buildQuickActionCard(
                    icon: Icons.savings,
                    title: 'Quản lý ngân sách',
                    description: 'Đặt giới hạn chi tiêu cho từng danh mục để tránh vung tay quá trán.',
                    onTap: () {
                      setState(() => _currentIndex = 2);
                    },
                  ),
                  _buildQuickActionCard(
                    icon: Icons.bar_chart,
                    title: 'Báo cáo chi tiết',
                    description: 'Xem biểu đồ trực quan về thói quen chi tiêu của bạn qua các tháng.',
                    onTap: () {
                      setState(() => _currentIndex = 4);
                    },
                  ),
                  _buildQuickActionCard(
                    icon: Icons.receipt_long,
                    title: 'Quản lý hóa đơn',
                    description: 'Upload và quản lý các hóa đơn của bạn một cách dễ dàng.',
                    onTap: () {
                      setState(() => _currentIndex = 3);
                    },
                  ),
                ],
              ),

              // Budget Warnings
              ..._buildBudgetWarnings(budgetProvider),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatCard({
    required String title,
    required double value,
    required String description,
    required IconData icon,
    required Color iconColor,
    Color? valueColor,
  }) {
    return Container(
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
            ],
          ),
          SizedBox(height: 12),
          Text(
            FormatUtils.formatCurrency(value),
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: valueColor ?? AppColors.primary,
            ),
          ),
          SizedBox(height: 4),
          Text(
            description,
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionCard({
    required IconData icon,
    required String title,
    required String description,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: AppColors.primary, size: 20),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Text(
              description,
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
                height: 1.4,
              ),
            ),
            SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: Icon(
                Icons.arrow_forward,
                color: AppColors.primary,
                size: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: AppColors.primary, size: 28),
            SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildBudgetWarnings(BudgetProvider budgetProvider) {
    final warnings = <Widget>[];

    for (final budget in budgetProvider.budgets) {
      final percentage = budget.percentageUsed;

      if (percentage >= 80) { // Warning threshold
        warnings.add(
          Container(
            margin: EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: percentage > 100 ? AppColors.danger.withOpacity(0.1) : AppColors.warning.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: percentage > 100 ? AppColors.danger : AppColors.warning,
                width: 1,
              ),
            ),
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(
                  percentage > 100 ? Icons.warning : Icons.warning_amber,
                  color: percentage > 100 ? AppColors.danger : AppColors.warning,
                  size: 24,
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        percentage > 100 ? 'Vượt ngân sách!' : 'Gần đạt giới hạn',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: percentage > 100 ? AppColors.danger : AppColors.warning,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Danh mục ${budget.categoryId}: ${percentage.toStringAsFixed(1)}% đã sử dụng',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  '${FormatUtils.formatCurrency(budget.spentAmount)} / ${FormatUtils.formatCurrency(budget.limitAmount)}',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: percentage > 100 ? AppColors.danger : AppColors.warning,
                  ),
                ),
              ],
            ),
          ),
        );
      }
    }

    return warnings;
  }
}
