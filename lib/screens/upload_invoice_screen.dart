import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../providers/invoice_provider.dart';
import '../providers/auth_provider.dart';
import '../utils/theme_colors.dart';
import '../utils/exception_handler.dart';
import 'camera_screen.dart';

class UploadInvoiceScreen extends StatefulWidget {
  const UploadInvoiceScreen({super.key});

  @override
  State<UploadInvoiceScreen> createState() => _UploadInvoiceScreenState();
}

class _UploadInvoiceScreenState extends State<UploadInvoiceScreen> {
  final ImagePicker _picker = ImagePicker();
  XFile? _selectedImage;
  bool _isUploading = false;

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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi khi chọn ảnh: ${e.toString()}')),
        );
      }
    }
  }

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: ThemeColors.getSurface(context),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.camera_alt, color: ThemeColors.getPrimary(context)),
              title: Text('Chụp ảnh'),
              onTap: () {
                Navigator.pop(context);
                _openCamera();
              },
            ),
            ListTile(
              leading: Icon(Icons.photo_library, color: ThemeColors.getPrimary(context)),
              title: Text('Chọn từ thư viện'),
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

  Future<void> _openCamera() async {
    final result = await Navigator.push<File>(
      context,
      MaterialPageRoute(
        builder: (context) => const CameraScreen(),
      ),
    );

    if (result != null) {
      setState(() {
        _selectedImage = XFile(result.path);
      });
    }
  }

  Future<void> _uploadInvoice() async {
    if (_selectedImage == null) return;

    final user = context.read<AuthProvider>().user;
    if (user == null) return;

    setState(() {
      _isUploading = true;
    });

    try {
      final imageFile = File(_selectedImage!.path);
      
      // Hiển thị loading message
      if (mounted) {
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
                  child: Text('Đang phân tích hóa đơn bằng AI...'),
                ),
              ],
            ),
            duration: Duration(seconds: 30), // AI processing may take time
          ),
        );
      }

      // Upload hóa đơn lên backend
      // Backend sẽ tự động gọi AI server để trích xuất thông tin
      final invoice = await context.read<InvoiceProvider>().uploadInvoice(
        user.id,
        imageFile,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        
        // Hiển thị thông tin đã trích xuất
        final storeName = invoice.storeName ?? 'Cửa hàng';
        final totalAmount = invoice.totalAmount;
        
        ExceptionHandler.showSuccessSnackBar(
          context,
          '✅ Phân tích thành công!\nĐã trích xuất hóa đơn từ "$storeName" với tổng tiền ${totalAmount.toStringAsFixed(0)}đ',
        );
        
        // Quay lại màn hình trước (hoặc có thể điều hướng đến màn hình chi tiết invoice)
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ExceptionHandler.showErrorSnackBar(context, e);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUploading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeColors.getBackground(context),
      appBar: AppBar(
        title: Text('Upload Hóa đơn'),
        elevation: 0,
        actions: [
          if (_selectedImage != null && !_isUploading)
            TextButton(
              onPressed: _uploadInvoice,
              child: Text(
                'Upload',
                style: TextStyle(
                  color: ThemeColors.getPrimary(context),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
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
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              padding: EdgeInsets.all(24),
              child: Column(
                children: [
                  Icon(
                    Icons.receipt_long,
                    size: 48,
                    color: Colors.white,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Upload Hóa đơn',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Chụp ảnh hoặc chọn từ thư viện để upload hóa đơn của bạn',
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
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                      child: Image.file(
                        File(_selectedImage!.path),
                        height: 300,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton.icon(
                            onPressed: _showImageSourceDialog,
                            icon: Icon(Icons.refresh),
                            label: Text('Thay đổi'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: ThemeColors.getSurface(context),
                              foregroundColor: ThemeColors.getPrimary(context),
                              side: BorderSide(color: ThemeColors.getPrimary(context)),
                            ),
                          ),
                          ElevatedButton.icon(
                            onPressed: () => setState(() => _selectedImage = null),
                            icon: Icon(Icons.delete),
                            label: Text('Xóa'),
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
              GestureDetector(
                onTap: _showImageSourceDialog,
                child: Container(
                  height: 200,
                  decoration: BoxDecoration(
                    color: ThemeColors.getSurface(context),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: ThemeColors.getBorder(context),
                      width: 2,
                      style: BorderStyle.solid,
                    ),
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
                          size: 48,
                          color: ThemeColors.getPrimary(context),
                        ),
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Chụp ảnh hoặc chọn từ thư viện',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: ThemeColors.getTextPrimary(context),
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Chạm để mở camera hoặc chọn ảnh',
                        style: TextStyle(
                          fontSize: 14,
                          color: ThemeColors.getTextSecondary(context),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            SizedBox(height: 24),

            // Instructions
            Container(
              decoration: BoxDecoration(
                color: ThemeColors.getSurface(context),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: ThemeColors.getBorder(context)),
              ),
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info_outline, color: ThemeColors.getPrimary(context)),
                      SizedBox(width: 8),
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
                  SizedBox(height: 12),
                  _buildInstructionItem('1. Chụp ảnh rõ nét hóa đơn'),
                  _buildInstructionItem('2. Đảm bảo đủ ánh sáng'),
                  _buildInstructionItem('3. Căn chỉnh hóa đơn trong khung hình'),
                  _buildInstructionItem('4. Hệ thống sẽ tự động trích xuất thông tin'),
                ],
              ),
            ),

            SizedBox(height: 24),

            // Upload Button
            if (_selectedImage != null)
              ElevatedButton(
                onPressed: _isUploading ? null : _uploadInvoice,
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 4,
                  shadowColor: ThemeColors.getPrimary(context).withOpacity(0.3),
                ),
                child: _isUploading
                    ? Row(
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
                          Text('Đang upload...'),
                        ],
                      )
                    : Row(
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
      ),
    );
  }

  Widget _buildInstructionItem(String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8),
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
          SizedBox(width: 12),
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
}