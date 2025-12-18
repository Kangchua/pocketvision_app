import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/auth_provider.dart';
import '../utils/app_theme.dart';
import 'edit_profile_screen.dart';
import 'security_screen.dart';
import 'help_screen.dart';
import 'feedback_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _biometricEnabled = false;
  String _currency = 'VND';
  String _language = 'vi';

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _notificationsEnabled = prefs.getBool('notifications_enabled') ?? true;
      _biometricEnabled = prefs.getBool('biometric_enabled') ?? false;
      _currency = prefs.getString('currency') ?? 'VND';
      _language = prefs.getString('language') ?? 'vi';
    });
  }

  Future<void> _saveSetting(String key, dynamic value) async {
    final prefs = await SharedPreferences.getInstance();
    if (value is bool) {
      await prefs.setBool(key, value);
    } else if (value is String) {
      await prefs.setString(key, value);
    }
  }

  void _logout() async {
    final authProvider = context.read<AuthProvider>();
    await authProvider.logout();

    if (mounted) {
      Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Cài đặt'),
        elevation: 0,
        backgroundColor: AppColors.surface,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Account Section
            _buildSectionHeader('Tài khoản'),
            _buildSettingCard(
              icon: Icons.person,
              title: 'Thông tin cá nhân',
              subtitle: 'Cập nhật thông tin tài khoản',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const EditProfileScreen(),
                  ),
                );
              },
            ),
            _buildSettingCard(
              icon: Icons.security,
              title: 'Bảo mật',
              subtitle: 'Đổi mật khẩu, xác thực hai yếu tố',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SecurityScreen(),
                  ),
                );
              },
            ),

            SizedBox(height: 24),

            // Preferences Section
            _buildSectionHeader('Tùy chỉnh'),
            _buildSwitchCard(
              icon: Icons.notifications,
              title: 'Thông báo',
              subtitle: 'Nhận thông báo về chi tiêu và ngân sách',
              value: _notificationsEnabled,
              onChanged: (value) {
                setState(() => _notificationsEnabled = value);
                _saveSetting('notifications_enabled', value);
              },
            ),
            _buildDropdownCard(
              icon: Icons.attach_money,
              title: 'Đơn vị tiền tệ',
              subtitle: 'Chọn đơn vị tiền tệ hiển thị',
              value: _currency,
              items: ['VND', 'USD', 'EUR'],
              onChanged: (value) {
                setState(() => _currency = value!);
                _saveSetting('currency', value);
              },
            ),
            _buildDropdownCard(
              icon: Icons.language,
              title: 'Ngôn ngữ',
              subtitle: 'Chọn ngôn ngữ hiển thị',
              value: _language,
              items: ['vi', 'en'],
              itemLabels: ['Tiếng Việt', 'English'],
              onChanged: (value) {
                setState(() => _language = value!);
                _saveSetting('language', value);
              },
            ),

            SizedBox(height: 24),

            // Data Section
            _buildSectionHeader('Dữ liệu'),
            _buildSettingCard(
              icon: Icons.backup,
              title: 'Sao lưu dữ liệu',
              subtitle: 'Sao lưu dữ liệu lên đám mây',
              onTap: () {
                // Implement backup
              },
            ),
            _buildSettingCard(
              icon: Icons.restore,
              title: 'Khôi phục dữ liệu',
              subtitle: 'Khôi phục dữ liệu từ bản sao lưu',
              onTap: () {
                // Implement restore
              },
            ),
            _buildSettingCard(
              icon: Icons.delete_forever,
              title: 'Xóa tất cả dữ liệu',
              subtitle: 'Xóa vĩnh viễn tất cả dữ liệu chi tiêu',
              textColor: AppColors.danger,
              onTap: () {
                _showDeleteDataDialog();
              },
            ),

            SizedBox(height: 24),

            // App Info Section
            _buildSectionHeader('Ứng dụng'),
            _buildSettingCard(
              icon: Icons.info,
              title: 'Phiên bản',
              subtitle: '1.0.0',
              showArrow: false,
            ),
            _buildSettingCard(
              icon: Icons.help,
              title: 'Trợ giúp & Hỗ trợ',
              subtitle: 'Hướng dẫn sử dụng và FAQ',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const HelpScreen(),
                  ),
                );
              },
            ),
            _buildSettingCard(
              icon: Icons.feedback,
              title: 'Phản hồi',
              subtitle: 'Gửi ý kiến đóng góp',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const FeedbackScreen(),
                  ),
                );
              },
            ),

            SizedBox(height: 24),

            // Logout Button
            ElevatedButton(
              onPressed: _logout,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.danger,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 4,
                shadowColor: AppColors.danger.withOpacity(0.3),
              ),
              child: Text(
                'Đăng xuất',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),

            SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }

  Widget _buildSettingCard({
    required IconData icon,
    required String title,
    required String subtitle,
    Color? textColor,
    bool showArrow = true,
    VoidCallback? onTap,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 8),
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
      child: ListTile(
        leading: Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: AppColors.primary),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: textColor ?? AppColors.textPrimary,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            fontSize: 14,
            color: AppColors.textSecondary,
          ),
        ),
        trailing: showArrow ? Icon(Icons.chevron_right, color: AppColors.textSecondary) : null,
        onTap: onTap,
      ),
    );
  }

  Widget _buildSwitchCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 8),
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
      child: ListTile(
        leading: Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: AppColors.primary),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            fontSize: 14,
            color: AppColors.textSecondary,
          ),
        ),
        trailing: Switch(
          value: value,
          onChanged: onChanged,
          activeThumbColor: AppColors.primary,
        ),
      ),
    );
  }

  Widget _buildDropdownCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required String value,
    required List<String> items,
    List<String>? itemLabels,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 8),
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
      child: ExpansionTile(
        leading: Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: AppColors.primary),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            fontSize: 14,
            color: AppColors.textSecondary,
          ),
        ),
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: DropdownButtonFormField<String>(
              initialValue: value,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: AppColors.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: AppColors.primary, width: 2),
                ),
              ),
              items: items.map((item) {
                final index = items.indexOf(item);
                final label = itemLabels != null && index < itemLabels.length ? itemLabels[index] : item;
                return DropdownMenuItem<String>(
                  value: item,
                  child: Text(label),
                );
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteDataDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text(
          'Xóa tất cả dữ liệu',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        content: Text(
          'Hành động này không thể hoàn tác. Tất cả dữ liệu chi tiêu, ngân sách và hóa đơn sẽ bị xóa vĩnh viễn.',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Hủy',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Implement delete all data
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Tính năng đang được phát triển')),
              );
            },
            child: Text(
              'Xóa',
              style: TextStyle(color: AppColors.danger),
            ),
          ),
        ],
      ),
    );
  }
}