import 'package:flutter/material.dart';
import '../utils/app_theme.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Trợ giúp & Hỗ trợ'),
        elevation: 0,
        backgroundColor: AppColors.surface,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // FAQ Section
            _buildSectionHeader('Câu hỏi thường gặp'),
            _buildFAQItem(
              question: 'Làm thế nào để thêm chi tiêu?',
              answer: 'Vào màn hình "Chi tiêu", nhấn nút "+" ở góc dưới bên phải, sau đó điền thông tin chi tiêu và nhấn "Lưu".',
            ),
            _buildFAQItem(
              question: 'Làm thế nào để tạo ngân sách?',
              answer: 'Vào màn hình "Ngân sách", nhấn nút "+" để tạo ngân sách mới. Bạn có thể đặt giới hạn chi tiêu theo danh mục hoặc tổng thể.',
            ),
            _buildFAQItem(
              question: 'Làm thế nào để chụp ảnh hóa đơn?',
              answer: 'Vào màn hình "Hóa đơn", nhấn nút "+", chọn tab "Chụp ảnh", sau đó chọn ảnh từ thư viện hoặc chụp ảnh mới. Ứng dụng sẽ tự động trích xuất thông tin từ hóa đơn.',
            ),
            _buildFAQItem(
              question: 'Làm thế nào để xóa dữ liệu?',
              answer: 'Vào "Cài đặt" > "Dữ liệu" > "Xóa tất cả dữ liệu". Lưu ý: Hành động này không thể hoàn tác.',
            ),
            const SizedBox(height: 24),

            // Contact Section
            _buildSectionHeader('Liên hệ hỗ trợ'),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                children: [
                  _buildContactItem(
                    icon: Icons.email,
                    title: 'Email',
                    subtitle: 'support@pocketvision.com',
                    onTap: () {
                      // TODO: Open email app
                    },
                  ),
                  const Divider(),
                  _buildContactItem(
                    icon: Icons.phone,
                    title: 'Điện thoại',
                    subtitle: '1900-xxxx',
                    onTap: () {
                      // TODO: Open phone app
                    },
                  ),
                  const Divider(),
                  _buildContactItem(
                    icon: Icons.chat,
                    title: 'Chat trực tuyến',
                    subtitle: 'Có sẵn 24/7',
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Tính năng đang được phát triển'),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // App Info
            _buildSectionHeader('Thông tin ứng dụng'),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                children: [
                  _buildInfoRow('Phiên bản', '1.0.0'),
                  const Divider(),
                  _buildInfoRow('Ngày phát hành', '2024'),
                  const Divider(),
                  _buildInfoRow('Nhà phát triển', 'PocketVision Team'),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }

  Widget _buildFAQItem({
    required String question,
    required String answer,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: ExpansionTile(
        title: Text(
          question,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              answer,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(
          fontSize: 14,
          color: AppColors.textSecondary,
        ),
      ),
      trailing: const Icon(Icons.chevron_right, color: AppColors.textSecondary),
      onTap: onTap,
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}




