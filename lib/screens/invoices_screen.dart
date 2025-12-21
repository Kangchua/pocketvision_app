import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/invoice.dart';
import '../providers/invoice_provider.dart';
import '../providers/expense_provider.dart';
import '../providers/budget_provider.dart';
import '../providers/category_provider.dart';
import '../providers/auth_provider.dart';
import '../utils/exception_handler.dart';
import '../utils/format_utils.dart';
import '../utils/theme_colors.dart';
import 'add_invoice_screen.dart';

class InvoicesScreen extends StatefulWidget {
  const InvoicesScreen({super.key});

  @override
  State<InvoicesScreen> createState() => _InvoicesScreenState();
}

class _InvoicesScreenState extends State<InvoicesScreen> {
  @override
  void initState() {
    super.initState();
    _loadInvoices();
  }

  Future<void> _loadInvoices() async {
    final user = context.read<AuthProvider>().user;
    if (user != null) {
      try {
        await context.read<InvoiceProvider>().fetchInvoices(user.id);
        final error = context.read<InvoiceProvider>().error;
        if (error != null && mounted) {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Lỗi: $error'),
                backgroundColor: ThemeColors.getDanger(context),
                duration: Duration(seconds: 4),
              ),
            );
          }
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Lỗi: $e'),
                backgroundColor: ThemeColors.getDanger(context),
                duration: Duration(seconds: 4),
              ),
            );
          }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeColors.getBackground(context),
      appBar: AppBar(
        title: Text('Hóa đơn'),
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _loadInvoices,
          ),
        ],
      ),
      body: Consumer2<InvoiceProvider, CategoryProvider>(
        builder: (context, invoiceProvider, categoryProvider, _) {
          if (invoiceProvider.isLoading) {
            return Center(child: CircularProgressIndicator());
          }

          if (invoiceProvider.invoices.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.receipt_long,
                      size: 64, color: ThemeColors.getTextLight(context)),
                  SizedBox(height: 16),
                  Text(
                    'Chưa có hóa đơn nào',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: ThemeColors.getTextTertiary(context),
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _loadInvoices,
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: invoiceProvider.invoices.length,
              cacheExtent: 500,
              itemBuilder: (context, index) {
                final invoice = invoiceProvider.invoices[index];
                final category =
                    invoice.categoryId != null ? categoryProvider.getCategoryById(invoice.categoryId!) : null;

                return GestureDetector(
                  key: ValueKey('invoice_${invoice.id}'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AddInvoiceScreen(invoice: invoice),
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                invoice.storeName ?? 'Hóa đơn',
                                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Text(
                              FormatUtils.formatCurrency(invoice.totalAmount, context),
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: ThemeColors.getPrimary(context),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(
                              Icons.store,
                              size: 16,
                              color: ThemeColors.getTextSecondary(context),
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                category?.name ?? 'Không phân loại',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: ThemeColors.getTextSecondary(context),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.calendar_today,
                              size: 16,
                              color: ThemeColors.getTextSecondary(context),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              FormatUtils.formatDate(invoice.invoiceDate, context),
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: ThemeColors.getTextSecondary(context),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Icon(
                              Icons.payment,
                              size: 16,
                              color: ThemeColors.getTextSecondary(context),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _getPaymentMethodText(invoice.paymentMethod),
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: ThemeColors.getTextSecondary(context),
                              ),
                            ),
                          ],
                        ),
                        if (invoice.note != null && invoice.note!.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Text(
                            invoice.note!,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: ThemeColors.getTextTertiary(context),
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                        const SizedBox(height: 12),
                        // Button chuyển đổi thành chi tiêu
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: () => _convertToExpense(invoice),
                            icon: Icon(Icons.swap_horiz, size: 18),
                            label: Text('Cập nhật chi tiêu'),
                            style: OutlinedButton.styleFrom(
                              padding: EdgeInsets.symmetric(vertical: 8),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              side: BorderSide(color: ThemeColors.getPrimary(context)),
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
        },
      ),
      floatingActionButton: FloatingActionButton(
        key: const ValueKey('add_invoice_fab'),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddInvoiceScreen(),
            ),
          );
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  String _getPaymentMethodText(String method) {
    switch (method) {
      case 'CASH':
        return 'Tiền mặt';
      case 'CREDIT_CARD':
        return 'Thẻ tín dụng';
      case 'BANK_TRANSFER':
        return 'Chuyển khoản';
      case 'E_WALLET':
        return 'Ví điện tử';
      default:
        return 'Khác';
    }
  }

  /// Chuyển đổi hóa đơn thành chi tiêu
  Future<void> _convertToExpense(Invoice invoice) async {
    final user = context.read<AuthProvider>().user;
    if (user == null) {
      ExceptionHandler.showErrorSnackBar(context, 'Chưa đăng nhập');
      return;
    }

    // Xác nhận
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Cập nhật chi tiêu?'),
        content: Text(
          'Bạn có muốn cập nhật chi tiêu từ hóa đơn "${invoice.storeName ?? 'Hóa đơn'}"?\n\n'
          'Thông tin từ hóa đơn sẽ được chuyển thành chi tiêu.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Cập nhật', style: TextStyle(color: ThemeColors.getPrimary(context))),
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
                child: Text('Đang cập nhật chi tiêu...'),
              ),
            ],
          ),
          duration: Duration(seconds: 10),
        ),
      );

      // Gọi API để convert invoice to expense
      await context.read<ExpenseProvider>().updateExpenseFromInvoice(
        invoice.id,
        user.id,
      );

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
        ExceptionHandler.showSuccessSnackBar(
          context,
          '✅ Đã cập nhật chi tiêu từ hóa đơn thành công!',
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ExceptionHandler.showErrorSnackBar(context, e);
      }
    }
  }
}