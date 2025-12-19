import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/category_provider.dart';
import '../providers/auth_provider.dart';
import '../models/category.dart';
import '../utils/exception_handler.dart';
import '../utils/theme_colors.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _iconController = TextEditingController();

  final List<String> _availableIcons = [
    'shopping_cart',
    'restaurant',
    'local_gas_station',
    'home',
    'school',
    'medical_services',
    'flight',
    'directions_car',
    'local_movies',
    'sports_soccer',
    'shopping_bag',
    'local_hospital',
    'local_laundry_service',
    'local_shipping',
    'local_taxi',
    'pedal_bike',
    'train',
    'directions_bus',
    'local_shipping',
    'local_post_office',
  ];

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    final user = context.read<AuthProvider>().user;
    if (user == null) return;
    
    try {
      await context.read<CategoryProvider>().fetchCategories(user.id);
      final error = context.read<CategoryProvider>().error;
      if (error != null && mounted) {
        ExceptionHandler.showErrorSnackBar(context, error);
      }
    } catch (e) {
      if (mounted) {
        ExceptionHandler.showErrorSnackBar(context, e);
      }
    }
  }

  void _showAddCategoryDialog() {
    _nameController.clear();
    _iconController.clear();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: ThemeColors.getSurface(context),
        title: Text(
          'Thêm danh mục mới',
          style: TextStyle(color: ThemeColors.getTextPrimary(context)),
        ),
        content: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: 'Tên danh mục',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng nhập tên danh mục';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: _iconController.text.isEmpty ? null : _iconController.text,
                  decoration: InputDecoration(
                    labelText: 'Icon',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  items: _availableIcons.map((icon) {
                    return DropdownMenuItem<String>(
                      value: icon,
                      child: Row(
                        children: [
                          Icon(_getIconData(icon), size: 20),
                          SizedBox(width: 8),
                          Text(icon),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    _iconController.text = value ?? '';
                  },
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Hủy',
              style: TextStyle(color: ThemeColors.getTextSecondary(context)),
            ),
          ),
          ElevatedButton(
            onPressed: _saveCategory,
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
            ),
            child: Text('Thêm'),
          ),
        ],
      ),
    );
  }

  void _saveCategory() async {
    if (!_formKey.currentState!.validate()) return;

    final user = context.read<AuthProvider>().user;
    if (user == null) return;


    try {
      await context.read<CategoryProvider>().addCategory(
        userId: user.id,
        name: _nameController.text.trim(),
        icon: _iconController.text.trim().isEmpty ? 'category' : _iconController.text.trim(),
      );
      Navigator.pop(context);
      ExceptionHandler.showSuccessSnackBar(context, 'Thêm danh mục thành công');
    } catch (e) {
      ExceptionHandler.showErrorSnackBar(context, e);
    }
  }

  IconData _getIconData(String iconName) {
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
      case 'shopping_bag':
        return Icons.shopping_bag;
      case 'local_hospital':
        return Icons.local_hospital;
      case 'local_laundry_service':
        return Icons.local_laundry_service;
      case 'local_shipping':
        return Icons.local_shipping;
      case 'local_taxi':
        return Icons.local_taxi;
      case 'pedal_bike':
        return Icons.pedal_bike;
      case 'train':
        return Icons.train;
      case 'directions_bus':
        return Icons.directions_bus;
      case 'local_post_office':
        return Icons.local_post_office;
      default:
        return Icons.category;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeColors.getBackground(context),
      appBar: AppBar(
        title: Text('Danh mục chi tiêu'),
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.add, color: ThemeColors.getPrimary(context)),
            onPressed: _showAddCategoryDialog,
          ),
        ],
      ),
      body: Consumer<CategoryProvider>(
        builder: (context, categoryProvider, _) {
          if (categoryProvider.isLoading) {
            return Center(child: CircularProgressIndicator());
          }

          if (categoryProvider.categories.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.category,
                    size: 64,
                    color: ThemeColors.getTextSecondary(context),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Chưa có danh mục nào',
                    style: TextStyle(
                      fontSize: 18,
                      color: ThemeColors.getTextSecondary(context),
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Thêm danh mục để phân loại chi tiêu',
                    style: TextStyle(
                      fontSize: 14,
                      color: ThemeColors.getTextSecondary(context),
                    ),
                  ),
                  SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: _showAddCategoryDialog,
                    icon: Icon(Icons.add),
                    label: Text('Thêm danh mục đầu tiên'),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                  ),
                ],
              ),
            );
          }

          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.0,
            ),
            itemCount: categoryProvider.categories.length,
            itemBuilder: (context, index) {
              final category = categoryProvider.categories[index];
              return _buildCategoryCard(category);
            },
          );
        },
      ),
    );
  }

  Widget _buildCategoryCard(Category category) {
    final color = ThemeColors.getPrimary(context);

    return Container(
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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            // Navigate to category details or edit
          },
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        _getIconData(category.icon ?? 'category'),
                        color: color,
                        size: 32,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Flexible(
                      child: Text(
                        category.name,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: ThemeColors.getTextPrimary(context),
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                top: 4,
                right: 4,
                child: IconButton(
                  icon: Icon(Icons.delete, color: ThemeColors.getDanger(context), size: 18),
                  onPressed: () => _deleteCategory(category),
                  padding: const EdgeInsets.all(4),
                  constraints: const BoxConstraints(),
                  visualDensity: VisualDensity.compact,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _deleteCategory(Category category) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: ThemeColors.getSurface(context),
        title: Text(
          'Xóa danh mục?',
          style: TextStyle(color: ThemeColors.getTextPrimary(context)),
        ),
        content: Text(
          'Bạn có chắc chắn muốn xóa danh mục "${category.name}"?',
          style: TextStyle(color: ThemeColors.getTextSecondary(context)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Hủy',
              style: TextStyle(color: ThemeColors.getTextSecondary(context)),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              'Xóa',
              style: TextStyle(color: ThemeColors.getDanger(context)),
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await context.read<CategoryProvider>().deleteCategory(category.id);
        if (mounted) {
          ExceptionHandler.showSuccessSnackBar(context, 'Xóa danh mục thành công');
        }
      } catch (e) {
        if (mounted) {
          ExceptionHandler.showErrorSnackBar(context, e);
        }
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _iconController.dispose();
    super.dispose();
  }
}