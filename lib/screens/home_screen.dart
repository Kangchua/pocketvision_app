import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/expense_provider.dart';
import '../providers/category_provider.dart';
import '../providers/budget_provider.dart';
import '../providers/notification_provider.dart';
import '../utils/format_utils.dart';
import '../utils/theme_colors.dart';
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
    
    // Đợi một chút để đảm bảo context đã sẵn sàng
    await Future.delayed(Duration(milliseconds: 100));
    
    if (!mounted) return;
    
    final authProvider = context.read<AuthProvider>();
    final user = authProvider.user;

    if (user != null) {
      try {
        // Load dữ liệu song song để tối ưu tốc độ
        await Future.wait([
          context.read<ExpenseProvider>().fetchExpenses(user.id),
          context.read<CategoryProvider>().fetchCategories(user.id),
          context.read<BudgetProvider>().fetchBudgets(user.id),
        ]);
        
        // Load invoices và notifications riêng để không block UI
        // InvoiceProvider sẽ được load trong InvoicesScreen
        
        // Bỏ qua lỗi notification nếu có
        try {
          await context.read<NotificationProvider>().fetchNotifications(user.id);
        } catch (e) {
          // Ignore notification errors
        }
      } catch (e) {
        // Handle errors silently - có thể log ra console trong development
        if (mounted) {
          debugPrint('Error loading data: $e');
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeColors.getBackground(context),
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                gradient: ThemeColors.getPrimaryGradient(context),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.account_balance_wallet_rounded,
                size: 24,
                color: Colors.white,
              ),
            ),
            SizedBox(width: 12),
            Text(
              'Pocket Money',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                letterSpacing: -0.5,
              ),
            ),
          ],
        ),
        centerTitle: true,
        elevation: 0,
        leading: Builder(
          builder: (context) => IconButton(
            icon: Icon(Icons.menu),
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
          color: ThemeColors.getSurface(context),
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              DrawerHeader(
                decoration: BoxDecoration(
                  color: ThemeColors.getSurface(context),
                  border: Border(
                    bottom: BorderSide(
                      color: ThemeColors.getBorder(context),
                      width: 1,
                    ),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: ThemeColors.getPrimary(context),
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
                            color: ThemeColors.getTextPrimary(context),
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
                leading: Icon(Icons.search, color: ThemeColors.getTextPrimary(context)),
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
                leading: Icon(Icons.smart_toy, color: ThemeColors.getTextPrimary(context)),
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
                leading: Icon(Icons.category, color: ThemeColors.getTextPrimary(context)),
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
                leading: Icon(Icons.upload_file, color: ThemeColors.getTextPrimary(context)),
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
                leading: Icon(Icons.edit_note, color: ThemeColors.getTextPrimary(context)),
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
                leading: Icon(Icons.notifications, color: ThemeColors.getTextPrimary(context)),
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
                leading: Icon(Icons.person, color: ThemeColors.getTextPrimary(context)),
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
                leading: Icon(Icons.settings, color: ThemeColors.getTextPrimary(context)),
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
                leading: Icon(Icons.logout, color: ThemeColors.getDanger(context)),
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
        if (user == null) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }

        // Tính toán thống kê như web
        final currentMonth = DateTime.now();
        final monthlyExpenses = expenseProvider.expenses
            .where((e) => e.expenseDate.month == currentMonth.month && e.expenseDate.year == currentMonth.year)
            .fold(0.0, (sum, e) => sum + e.totalAmount);
        final totalBudget = budgetProvider.budgets.fold(0.0, (sum, b) => sum + b.limitAmount);
        final budgetUsed = budgetProvider.budgets.fold(0.0, (sum, b) => sum + b.spentAmount);
        final remainingBudget = totalBudget - budgetUsed;
        final budgetUsagePercentage = totalBudget > 0 ? (budgetUsed / totalBudget * 100).round() : 0;
        
        // Nếu đang loading, hiển thị loading indicator
        if (expenseProvider.isLoading || budgetProvider.isLoading) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header Section như web
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Tổng quan chi tiêu',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: ThemeColors.getPrimary(context),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Số liệu tài chính tháng ${currentMonth.month}/${currentMonth.year} của bạn',
                    style: TextStyle(color: ThemeColors.getTextSecondary(context), fontSize: 14),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: ThemeColors.getPrimaryGradient(context),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: ThemeColors.getElegantShadow(context),
                          ),
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.add, size: 20),
                            label: const Text('Thêm chi tiêu'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const AddExpenseScreen()),
                              );
                            },
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: Icon(Icons.refresh, color: ThemeColors.getPrimary(context)),
                        onPressed: _loadData,
                        style: IconButton.styleFrom(
                          backgroundColor: ThemeColors.getSurfaceLight(context),
                          padding: const EdgeInsets.all(12),
                        ),
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
                    iconColor: ThemeColors.getPrimary(context),
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
                    description: 'Đã dùng: ${FormatUtils.formatCurrency(budgetUsed, context)}',
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
              const SizedBox(height: 32),

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
              const SizedBox(height: 24),
              ..._buildBudgetWarnings(budgetProvider),
              const SizedBox(height: 16),
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
        color: ThemeColors.getSurface(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: ThemeColors.getBorder(context),
          width: 1,
        ),
        boxShadow: ThemeColors.getElegantShadow(context),
      ),
      padding: EdgeInsets.all(20),
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
                  color: ThemeColors.getTextSecondary(context),
                  fontWeight: FontWeight.w500,
                ),
              ),
              Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: iconColor, size: 22),
              ),
            ],
          ),
          SizedBox(height: 12),
          Text(
            FormatUtils.formatCurrency(value, context),
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: valueColor ?? ThemeColors.getPrimary(context),
            ),
          ),
          SizedBox(height: 4),
          Text(
            description,
            style: TextStyle(
              fontSize: 12,
              color: ThemeColors.getTextSecondary(context),
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
          color: ThemeColors.getSurface(context),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: ThemeColors.getBorder(context),
            width: 1,
          ),
          boxShadow: ThemeColors.getElegantShadow(context),
        ),
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        ThemeColors.getPrimary(context).withOpacity(0.2),
                        ThemeColors.getPrimaryGlow(context).withOpacity(0.1),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: ThemeColors.getPrimary(context), size: 22),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: ThemeColors.getTextPrimary(context),
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
                color: ThemeColors.getTextSecondary(context),
                height: 1.4,
              ),
            ),
            SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: Icon(
                Icons.arrow_forward,
                color: ThemeColors.getPrimary(context),
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
          color: ThemeColors.getSurface(context),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: ThemeColors.getBorder(context)),
        ),
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: ThemeColors.getPrimary(context), size: 28),
            SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: ThemeColors.getTextPrimary(context),
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
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: percentage > 100 ? ThemeColors.getDanger(context).withOpacity(0.1) : ThemeColors.getWarning(context).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: percentage > 100 ? ThemeColors.getDanger(context) : ThemeColors.getWarning(context),
                width: 1,
              ),
            ),
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(
                  percentage > 100 ? Icons.warning : Icons.warning_amber,
                  color: percentage > 100 ? ThemeColors.getDanger(context) : ThemeColors.getWarning(context),
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        percentage > 100 ? 'Vượt ngân sách!' : 'Gần đạt giới hạn',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: percentage > 100 ? ThemeColors.getDanger(context) : ThemeColors.getWarning(context),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Danh mục ${budget.categoryId}: ${percentage.toStringAsFixed(1)}% đã sử dụng',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: ThemeColors.getTextSecondary(context),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Flexible(
                  child: Text(
                    '${FormatUtils.formatCurrency(budget.spentAmount, context)} / ${FormatUtils.formatCurrency(budget.limitAmount, context)}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: percentage > 100 ? ThemeColors.getDanger(context) : ThemeColors.getWarning(context),
                    ),
                    textAlign: TextAlign.right,
                    overflow: TextOverflow.ellipsis,
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
