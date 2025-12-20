import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../providers/auth_provider.dart';
import '../services/api_service.dart';
import '../utils/exception_handler.dart';
import '../utils/theme_colors.dart';
import '../config/api_config.dart';
import 'camera_screen.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _imagePicker = ImagePicker();
  late TextEditingController _fullNameController;
  File? _selectedImage;
  bool _isLoading = false;
  bool _isUploadingImage = false;

  @override
  void initState() {
    super.initState();
    final authProvider = context.read<AuthProvider>();
    _fullNameController = TextEditingController(
      text: authProvider.user?.fullName ?? '',
    );
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    super.dispose();
  }

  Future<void> _showImageSourceDialog() async {
    final authProvider = context.read<AuthProvider>();
    final currentUser = authProvider.user;
    
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
                _openCamera();
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
            if (currentUser?.avatarUrl != null && currentUser!.avatarUrl!.isNotEmpty)
              ListTile(
                leading: Icon(Icons.delete, color: ThemeColors.getDanger(context)),
                title: const Text('Xóa ảnh đại diện'),
                onTap: () {
                  Navigator.pop(context);
                  setState(() {
                    _selectedImage = null;
                  });
                  _saveProfile(removeAvatar: true);
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
        _selectedImage = result;
      });
      // Tự động upload ảnh khi chụp
      await _uploadAndSaveProfile();
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 800,
        maxHeight: 800,
      );

      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
        // Tự động upload ảnh khi chọn
        await _uploadAndSaveProfile();
      }
    } catch (e) {
      if (mounted) {
        ExceptionHandler.showErrorSnackBar(context, e);
      }
    }
  }

  Future<void> _uploadAndSaveProfile() async {
    if (_selectedImage == null) return;

    final authProvider = context.read<AuthProvider>();
    final user = authProvider.user;
    if (user == null) return;

    setState(() {
      _isUploadingImage = true;
    });

    try {
      // Upload ảnh lên server
      final apiService = ApiService();
      final avatarUrl = await apiService.uploadAvatar(user.id, user.id, _selectedImage!);
      
      // Cập nhật profile với avatarUrl mới
      await authProvider.updateProfile(
        fullName: _fullNameController.text.trim(),
        avatarUrl: avatarUrl,
      );

      if (mounted) {
        setState(() {
          _isUploadingImage = false;
          _selectedImage = null; // Clear selected image để hiển thị ảnh từ server
        });
        ExceptionHandler.showSuccessSnackBar(context, 'Đã cập nhật ảnh đại diện thành công');
      }
    } catch (e) {
      setState(() {
        _isUploadingImage = false;
      });
      if (mounted) {
        ExceptionHandler.showErrorSnackBar(context, e);
      }
    }
  }

  Future<void> _saveProfile({bool removeAvatar = false}) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final authProvider = context.read<AuthProvider>();
      final user = authProvider.user;
      if (user == null) {
        ExceptionHandler.showErrorSnackBar(context, 'Chưa đăng nhập');
        setState(() {
          _isLoading = false;
        });
        return;
      }
      
      // Nếu có ảnh mới được chọn, cần upload lên server trước
      String? avatarUrl;
      
      if (removeAvatar) {
        avatarUrl = '';
      } else if (_selectedImage != null) {
        // Upload file to server and get URL
        final apiService = ApiService();
        avatarUrl = await apiService.uploadAvatar(user.id, user.id, _selectedImage!);
      }
      
      await authProvider.updateProfile(
        fullName: _fullNameController.text.trim(),
        avatarUrl: avatarUrl,
      );

      if (mounted) {
        ExceptionHandler.showSuccessSnackBar(context, 'Cập nhật thông tin thành công');
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ExceptionHandler.showErrorSnackBar(context, e);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeColors.getBackground(context),
      appBar: AppBar(
        title: const Text('Chỉnh sửa thông tin'),
        elevation: 0,
      ),
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, _) {
          final user = authProvider.user;
          if (user == null) {
            return const Center(
              child: Text('Chưa đăng nhập'),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Avatar Section
                  Center(
                    child: Column(
                      children: [
                        Stack(
                          children: [
                            CircleAvatar(
                              radius: 48,
                              backgroundColor: ThemeColors.getPrimary(context),
                              backgroundImage: _selectedImage != null
                                  ? FileImage(_selectedImage!) as ImageProvider
                                  : (user.avatarUrl != null && user.avatarUrl!.isNotEmpty
                                      ? NetworkImage(ApiConfig.buildImageUrl(user.avatarUrl)) as ImageProvider
                                      : null),
                              child: _selectedImage == null && 
                                     (user.avatarUrl == null || user.avatarUrl!.isEmpty)
                                  ? Text(
                                      user.fullName.isNotEmpty
                                          ? user.fullName[0].toUpperCase()
                                          : 'U',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 24,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    )
                                  : null,
                            ),
                            if (_isUploadingImage)
                              Positioned.fill(
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.5),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Center(
                                    child: CircularProgressIndicator(
                                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            TextButton.icon(
                              onPressed: _isUploadingImage ? null : () => _showImageSourceDialog(),
                              icon: const Icon(Icons.camera_alt),
                              label: const Text('Đổi ảnh đại diện'),
                            ),
                            if (_selectedImage != null) ...[
                              const SizedBox(width: 8),
                              IconButton(
                                onPressed: () {
                                  setState(() {
                                    _selectedImage = null;
                                  });
                                },
                                icon: Icon(Icons.close, color: ThemeColors.getDanger(context)),
                                tooltip: 'Hủy chọn ảnh',
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Full Name Field
                  TextFormField(
                    controller: _fullNameController,
                    decoration: InputDecoration(
                      labelText: 'Họ và tên',
                      hintText: 'Nhập họ và tên',
                      prefixIcon: const Icon(Icons.person),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: ThemeColors.getBorder(context)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: ThemeColors.getPrimary(context),
                          width: 2,
                        ),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Vui lòng nhập họ và tên';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Email Field (Read-only)
                  TextFormField(
                    initialValue: user.email,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      prefixIcon: const Icon(Icons.email),
                      enabled: false,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: ThemeColors.getBorder(context)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Role Field (Read-only)
                  TextFormField(
                    initialValue: user.role,
                    decoration: InputDecoration(
                      labelText: 'Vai trò',
                      prefixIcon: const Icon(Icons.badge),
                      enabled: false,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: ThemeColors.getBorder(context)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Save Button
                  ElevatedButton(
                    onPressed: (_isLoading || _isUploadingImage) ? null : () => _saveProfile(),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 4,
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Text(
                            'Lưu thay đổi',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
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
  }
}



