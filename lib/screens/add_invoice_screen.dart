import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../models/invoice.dart';
import '../providers/invoice_provider.dart';
import '../providers/category_provider.dart';
import '../providers/auth_provider.dart';
import '../utils/format_utils.dart';
import '../widgets/custom_text_field.dart';
import '../utils/exception_handler.dart';
import '../utils/theme_colors.dart';

class AddInvoiceScreen extends StatefulWidget {
  final Invoice? invoice;

  const AddInvoiceScreen({super.key, this.invoice});

  @override
  State<AddInvoiceScreen> createState() => _AddInvoiceScreenState();
}

class _AddInvoiceScreenState extends State<AddInvoiceScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _formKey = GlobalKey<FormState>();
  final _storeNameController = TextEditingController();
  final _noteController = TextEditingController();
  DateTime _invoiceDate = DateTime.now();
  int? _selectedCategoryId;
  String _paymentMethod = 'CASH';
  List<InvoiceItem> _items = [];
  bool _isLoading = false;

  // Image upload
  final ImagePicker _picker = ImagePicker();
  XFile? _selectedImage;
  bool _isUploading = false;

  final List<String> _paymentMethods = ['CASH', 'CREDIT_CARD', 'BANK_TRANSFER', 'E_WALLET', 'OTHER'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: widget.invoice == null ? 2 : 1, vsync: this);
    if (widget.invoice != null) {
      _storeNameController.text = widget.invoice!.storeName ?? '';
      _noteController.text = widget.invoice!.note ?? '';
      _invoiceDate = widget.invoice!.invoiceDate;
      _selectedCategoryId = widget.invoice!.categoryId;
      _paymentMethod = widget.invoice!.paymentMethod;
      _items = List.from(widget.invoice!.items);
    } else {
      _addItem(); // Add one empty item for new invoice
    }
  }

  @override
  void dispose() {
    _storeNameController.dispose();
    _noteController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        imageQuality: 80,
        maxWidth: 1200,
        maxHeight: 1200,
      );

      if (image != null) {
        setState(() {
          _selectedImage = image;
        });
      }
    } catch (e) {
      if (mounted) {
        ExceptionHandler.showErrorSnackBar(
          context,
          'Lỗi khi chọn ảnh: ${ExceptionHandler.getErrorMessage(e)}',
        );
      }
    }
  }

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: ThemeColors.getSurface(context),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.camera_alt, color: ThemeColors.getPrimary(context)),
              title: const Text('Chụp ảnh'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: Icon(Icons.photo_library, color: ThemeColors.getPrimary(context)),
              title: const Text('Chọn từ thư viện'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _uploadInvoiceImage() async {
    if (_selectedImage == null) {
      ExceptionHandler.showErrorSnackBar(context, 'Vui lòng chọn ảnh hóa đơn');
      return;
    }

    final user = context.read<AuthProvider>().user;
    if (user == null) {
      ExceptionHandler.showErrorSnackBar(context, 'Chưa đăng nhập');
      return;
    }

    // Check file exists
    final file = File(_selectedImage!.path);
    if (!await file.exists()) {
      ExceptionHandler.showErrorSnackBar(context, 'File ảnh không tồn tại');
      return;
    }

    // Check file size (max 10MB)
    final fileSize = await file.length();
    if (fileSize > 10 * 1024 * 1024) {
      ExceptionHandler.showErrorSnackBar(context, 'Kích thước file quá lớn (tối đa 10MB)');
      return;
    }

    setState(() => _isUploading = true);

    try {
      await context.read<InvoiceProvider>().uploadInvoice(
        user.id,
        file,
      );

      if (mounted) {
        Navigator.pop(context);
        ExceptionHandler.showSuccessSnackBar(context, 'Upload hóa đơn thành công');
      }
    } catch (e) {
      if (mounted) {
        ExceptionHandler.showErrorSnackBar(context, e);
      }
    } finally {
      if (mounted) {
        setState(() => _isUploading = false);
      }
    }
  }

  void _addItem() {
    setState(() {
      _items.add(InvoiceItem(
        id: DateTime.now().millisecondsSinceEpoch, // Temporary ID
        invoiceId: 0,
        itemName: '',
        quantity: 1,
        unitPrice: 0,
        totalPrice: 0,
      ));
    });
  }

  void _removeItem(int index) {
    if (_items.length > 1) {
      setState(() {
        _items.removeAt(index);
      });
    }
  }

  void _updateItem(int index, InvoiceItem item) {
    setState(() {
      _items[index] = item.copyWith(
        totalPrice: item.quantity * item.unitPrice,
      );
    });
  }

  double get _totalAmount {
    return _items.fold(0, (sum, item) => sum + item.totalPrice);
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _invoiceDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _invoiceDate) {
      setState(() {
        _invoiceDate = picked;
      });
    }
  }

  void _saveInvoice() async {
    if (!_formKey.currentState!.validate()) return;

    // Validate items
    if (_items.isEmpty) {
      ExceptionHandler.showErrorSnackBar(context, 'Vui lòng thêm ít nhất một mặt hàng');
      return;
    }

    for (var i = 0; i < _items.length; i++) {
      final item = _items[i];
      if (item.itemName.trim().isEmpty) {
        ExceptionHandler.showErrorSnackBar(context, 'Tên mặt hàng thứ ${i + 1} không được để trống');
        return;
      }
      if (item.quantity <= 0) {
        ExceptionHandler.showErrorSnackBar(context, 'Số lượng mặt hàng thứ ${i + 1} phải lớn hơn 0');
        return;
      }
      if (item.unitPrice <= 0) {
        ExceptionHandler.showErrorSnackBar(context, 'Đơn giá mặt hàng thứ ${i + 1} phải lớn hơn 0');
        return;
      }
    }

    if (_totalAmount <= 0) {
      ExceptionHandler.showErrorSnackBar(context, 'Tổng tiền phải lớn hơn 0');
      return;
    }

    final user = context.read<AuthProvider>().user;
    if (user == null) {
      ExceptionHandler.showErrorSnackBar(context, 'Chưa đăng nhập');
      return;
    }

    setState(() => _isLoading = true);

    try {
      if (widget.invoice != null) {
        // Update existing invoice
        await context.read<InvoiceProvider>().updateInvoice(
          id: widget.invoice!.id,
          userId: user.id,
          categoryId: _selectedCategoryId,
          storeName: _storeNameController.text.trim().isNotEmpty 
              ? _storeNameController.text.trim() 
              : null,
          invoiceDate: _invoiceDate,
          totalAmount: _totalAmount,
          paymentMethod: _paymentMethod,
          note: _noteController.text.trim().isNotEmpty 
              ? _noteController.text.trim() 
              : null,
          items: _items,
        );
      } else {
        // Create new invoice
        await context.read<InvoiceProvider>().createInvoice(
          userId: user.id,
          categoryId: _selectedCategoryId,
          storeName: _storeNameController.text.trim().isNotEmpty 
              ? _storeNameController.text.trim() 
              : null,
          invoiceDate: _invoiceDate,
          totalAmount: _totalAmount,
          paymentMethod: _paymentMethod,
          note: _noteController.text.trim().isNotEmpty 
              ? _noteController.text.trim() 
              : null,
          items: _items,
        );
      }

      if (mounted) {
        Navigator.pop(context);
        ExceptionHandler.showSuccessSnackBar(
          context,
          widget.invoice != null 
              ? 'Cập nhật hóa đơn thành công' 
              : 'Thêm hóa đơn thành công',
        );
      }
    } catch (e) {
      if (mounted) {
        ExceptionHandler.showErrorSnackBar(context, e);
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _deleteInvoice() async {
    if (widget.invoice == null) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Xóa hóa đơn?'),
        content: Text('Bạn có chắc chắn muốn xóa hóa đơn này?'),
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

    if (confirm == true) {
      final user = context.read<AuthProvider>().user;
      if (user == null) {
        if (mounted) {
          ExceptionHandler.showErrorSnackBar(context, 'Chưa đăng nhập');
        }
        return;
      }
      
      try {
        await context.read<InvoiceProvider>().deleteInvoice(widget.invoice!.id, user.id);
        if (mounted) {
          Navigator.pop(context);
          ExceptionHandler.showSuccessSnackBar(context, 'Xóa hóa đơn thành công');
        }
      } catch (e) {
        if (mounted) {
          ExceptionHandler.showErrorSnackBar(context, e);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeColors.getBackground(context),
      appBar: AppBar(
        title: Text(widget.invoice != null ? 'Cập nhật hóa đơn' : 'Thêm hóa đơn'),
        elevation: 0,
        actions: widget.invoice != null ? [
          IconButton(
            icon: Icon(Icons.delete, color: ThemeColors.getDanger(context)),
            onPressed: _deleteInvoice,
          ),
        ] : null,
        bottom: widget.invoice == null ? TabBar(
          controller: _tabController,
          labelColor: ThemeColors.getPrimary(context),
          unselectedLabelColor: ThemeColors.getTextSecondary(context),
          indicatorColor: ThemeColors.getPrimary(context),
          tabs: const [
            Tab(icon: Icon(Icons.edit), text: 'Nhập thủ công'),
            Tab(icon: Icon(Icons.camera_alt), text: 'Chụp ảnh'),
          ],
        ) : null,
      ),
      body: widget.invoice == null
          ? TabBarView(
              controller: _tabController,
              children: [
                _buildManualInputTab(),
                _buildImageUploadTab(),
              ],
            )
          : _buildManualInputTab(),
    );
  }

  Widget _buildManualInputTab() {
    return Consumer<CategoryProvider>(
      builder: (context, categoryProvider, _) {
        final categories = categoryProvider.categories;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                  Text(
                    'Thông tin cơ bản',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 16),
                  CustomTextField(
                    controller: _storeNameController,
                    hintText: 'Tên cửa hàng (tùy chọn)',
                    validator: (value) => null, // Optional field
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Danh mục',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: ThemeColors.getSurface(context),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: ThemeColors.getBorder(context)),
                    ),
                    child: DropdownButtonFormField<int>(
                      initialValue: _selectedCategoryId,
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        border: InputBorder.none,
                        hintText: 'Chọn danh mục (tùy chọn)',
                      ),
                      items: categories.map((category) {
                        return DropdownMenuItem(
                          value: category.id,
                          child: Text(category.name),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() => _selectedCategoryId = value);
                      },
                    ),
                  ),
                  SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Ngày hóa đơn',
                              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(height: 8),
                            GestureDetector(
                              onTap: () => _selectDate(context),
                              child: Container(
                                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                decoration: BoxDecoration(
                                  color: ThemeColors.getSurface(context),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: ThemeColors.getBorder(context)),
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.calendar_today, color: ThemeColors.getTextSecondary(context)),
                                    SizedBox(width: 8),
                                    Text(
                                      FormatUtils.formatDate(_invoiceDate, context),
                                      style: Theme.of(context).textTheme.bodyMedium,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Thanh toán',
                              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(height: 8),
                            Container(
                              decoration: BoxDecoration(
                                color: ThemeColors.getSurface(context),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: ThemeColors.getBorder(context)),
                              ),
                              child: DropdownButtonFormField<String>(
                                initialValue: _paymentMethod,
                                decoration: InputDecoration(
                                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                  border: InputBorder.none,
                                ),
                                items: _paymentMethods.map((method) {
                                  return DropdownMenuItem(
                                    value: method,
                                    child: Text(_getPaymentMethodText(method)),
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  setState(() => _paymentMethod = value!);
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Chi tiết mặt hàng',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      TextButton.icon(
                        onPressed: _addItem,
                        icon: Icon(Icons.add, size: 18),
                        label: Text('Thêm'),
                        style: TextButton.styleFrom(
                          foregroundColor: ThemeColors.getPrimary(context),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  ..._items.asMap().entries.map((entry) {
                    final index = entry.key;
                    final item = entry.value;
                    return _buildItemWidget(index, item);
                  }),
                  SizedBox(height: 24),
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: ThemeColors.getSurfaceLight(context),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Tổng cộng',
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          FormatUtils.formatCurrency(_totalAmount, context),
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: ThemeColors.getPrimary(context),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 16),
                  CustomTextField(
                    controller: _noteController,
                    hintText: 'Ghi chú (tùy chọn)',
                    maxLines: 3,
                    validator: (value) => null, // Optional field
                  ),
                  SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _saveInvoice,
                          style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isLoading
                          ? SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation(Colors.white),
                              ),
                            )
                          : Text(
                              widget.invoice != null ? 'Cập nhật' : 'Thêm hóa đơn',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
  }

  Widget _buildImageUploadTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header Card
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [ThemeColors.getPrimary(context), ThemeColors.getPrimary(context).withOpacity(0.8)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: ThemeColors.getPrimary(context).withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const Icon(
                  Icons.receipt_long,
                  size: 48,
                  color: Colors.white,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Chụp ảnh Hóa đơn',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Chụp ảnh hoặc chọn từ thư viện để upload hóa đơn của bạn. Hệ thống sẽ tự động trích xuất thông tin.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Image Preview or Selection
          if (_selectedImage != null)
            Container(
              decoration: BoxDecoration(
                color: ThemeColors.getSurface(context),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: ThemeColors.getBorder(context)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                    child: Image.file(
                      File(_selectedImage!.path),
                      height: 300,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton.icon(
                          onPressed: _showImageSourceDialog,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Thay đổi'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: ThemeColors.getSurface(context),
                            foregroundColor: ThemeColors.getPrimary(context),
                            side: BorderSide(color: ThemeColors.getPrimary(context)),
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: () => setState(() => _selectedImage = null),
                          icon: const Icon(Icons.delete),
                          label: const Text('Xóa'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: ThemeColors.getDanger(context),
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            )
          else
            Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => _pickImage(ImageSource.camera),
                        child: Container(
                          height: 140,
                          decoration: BoxDecoration(
                            color: ThemeColors.getSurface(context),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: ThemeColors.getPrimary(context),
                              width: 2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: ThemeColors.getPrimary(context).withOpacity(0.1),
                                blurRadius: 8,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: ThemeColors.getPrimary(context).withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.camera_alt,
                                  size: 40,
                                  color: ThemeColors.getPrimary(context),
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Chụp ảnh',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: ThemeColors.getTextPrimary(context),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Mở camera',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: ThemeColors.getTextSecondary(context),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => _pickImage(ImageSource.gallery),
                        child: Container(
                          height: 140,
                          decoration: BoxDecoration(
                            color: ThemeColors.getSurface(context),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: ThemeColors.getBorder(context),
                              width: 2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 8,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: ThemeColors.getTextSecondary(context).withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.photo_library,
                                  size: 40,
                                  color: ThemeColors.getTextSecondary(context),
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Thư viện',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: ThemeColors.getTextPrimary(context),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Chọn ảnh',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: ThemeColors.getTextSecondary(context),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),

          const SizedBox(height: 24),

          // Instructions
          Container(
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
                  children: [
                    Icon(Icons.info_outline, color: ThemeColors.getPrimary(context)),
                    const SizedBox(width: 8),
                    Text(
                      'Hướng dẫn',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: ThemeColors.getTextPrimary(context),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildInstructionItem('1. Chụp ảnh rõ nét hóa đơn'),
                _buildInstructionItem('2. Đảm bảo đủ ánh sáng'),
                _buildInstructionItem('3. Căn chỉnh hóa đơn trong khung hình'),
                _buildInstructionItem('4. Hệ thống sẽ tự động trích xuất thông tin'),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Upload Button
          if (_selectedImage != null)
            ElevatedButton(
              onPressed: _isUploading ? null : _uploadInvoiceImage,
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 4,
                shadowColor: ThemeColors.getPrimary(context).withOpacity(0.3),
              ),
              child: _isUploading
                  ? const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
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
                        Text('Đang upload và phân tích...'),
                      ],
                    )
                  : const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.cloud_upload),
                        SizedBox(width: 8),
                        Text(
                          'Upload Hóa đơn',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
            ),
        ],
      ),
    );
  }

  Widget _buildInstructionItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 4,
            decoration: BoxDecoration(
              color: ThemeColors.getPrimary(context),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14,
                color: ThemeColors.getTextSecondary(context),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemWidget(int index, InvoiceItem item) {
    final itemNameController = TextEditingController(text: item.itemName);
    final quantityController = TextEditingController(text: item.quantity.toString());
    final unitPriceController = TextEditingController(text: item.unitPrice.toString());

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ThemeColors.getSurface(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: ThemeColors.getBorder(context)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                flex: 3,
                child: TextFormField(
                  controller: itemNameController,
                  decoration: InputDecoration(
                    hintText: 'Tên mặt hàng',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: ThemeColors.getBorder(context)),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  ),
                  textDirection: TextDirection.ltr,
                  textInputAction: TextInputAction.next,
                  onChanged: (value) {
                    _updateItem(index, item.copyWith(itemName: value));
                  },
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: () => _removeItem(index),
                icon: Icon(Icons.delete, color: ThemeColors.getDanger(context)),
                padding: const EdgeInsets.all(8),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: quantityController,
                  decoration: InputDecoration(
                    hintText: 'Số lượng',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: ThemeColors.getBorder(context)),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  ),
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.next,
                  textDirection: TextDirection.ltr,
                  onChanged: (value) {
                    final quantity = int.tryParse(value) ?? 1;
                    _updateItem(index, item.copyWith(quantity: quantity));
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 2,
                child: TextFormField(
                  controller: unitPriceController,
                  decoration: InputDecoration(
                    hintText: 'Đơn giá',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: ThemeColors.getBorder(context)),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  ),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  textInputAction: TextInputAction.done,
                  textDirection: TextDirection.ltr,
                  onChanged: (value) {
                    final unitPrice = double.tryParse(value) ?? 0;
                    _updateItem(index, item.copyWith(unitPrice: unitPrice));
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  decoration: BoxDecoration(
                    color: ThemeColors.getSurfaceLight(context),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    FormatUtils.formatCurrency(item.totalPrice, context),
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: ThemeColors.getTextSecondary(context),
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
        ],
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
}