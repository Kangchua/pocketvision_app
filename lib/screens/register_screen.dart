import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../utils/app_theme.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  String? _emailError;
  String? _passwordError;
  String? _confirmPasswordError;

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  String _getPasswordStrength(String password) {
    if (password.length < 8) return 'Yếu';
    if (!RegExp(r'[a-z]').hasMatch(password)) return 'Yếu';
    if (!RegExp(r'[A-Z]').hasMatch(password)) return 'Trung bình';
    if (!RegExp(r'[0-9]').hasMatch(password)) return 'Trung bình';
    if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password)) return 'Tốt';
    return 'Mạnh';
  }

  Color _getStrengthColor(String strength) {
    switch (strength) {
      case 'Yếu': return Colors.red;
      case 'Trung bình': return Colors.orange;
      case 'Tốt': return Colors.yellow;
      case 'Mạnh': return Colors.green;
      default: return Colors.grey;
    }
  }

  void _validateForm() {
    setState(() {
      _emailError = null;
      _passwordError = null;
      _confirmPasswordError = null;

      if (_emailController.text.isNotEmpty && !_isValidEmail(_emailController.text)) {
        _emailError = 'Email không hợp lệ';
      }

      if (_passwordController.text.isNotEmpty) {
        if (_passwordController.text.length < 8) {
          _passwordError = 'Mật khẩu phải có ít nhất 8 ký tự';
        } else if (!RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$').hasMatch(_passwordController.text)) {
          _passwordError = 'Mật khẩu phải chứa chữ hoa, chữ thường, số và ký tự đặc biệt';
        }
      }

      if (_confirmPasswordController.text.isNotEmpty && _passwordController.text != _confirmPasswordController.text) {
        _confirmPasswordError = 'Mật khẩu xác nhận không khớp';
      }
    });
  }

  void _register() async {
    _validateForm();

    if (_fullNameController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _passwordController.text.isEmpty ||
        _confirmPasswordController.text.isEmpty ||
        _emailError != null ||
        _passwordError != null ||
        _confirmPasswordError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Vui lòng kiểm tra lại thông tin')),
      );
      return;
    }

    try {
      await context.read<AuthProvider>().register(
            fullName: _fullNameController.text,
            email: _emailController.text,
            password: _passwordController.text,
            confirmPassword: _confirmPasswordController.text,
          );

      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/home');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi đăng ký: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.surface,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Tạo tài khoản',
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Đăng ký để bắt đầu quản lý tài chính',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              SizedBox(height: 32),
              TextField(
                controller: _fullNameController,
                decoration: InputDecoration(
                  hintText: 'Họ và tên',
                  prefixIcon: Icon(Icons.person, color: AppColors.textTertiary),
                ),
              ),
              SizedBox(height: 16),
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  hintText: 'Email',
                  prefixIcon: Icon(Icons.email, color: AppColors.textTertiary),
                  errorText: _emailError,
                ),
                keyboardType: TextInputType.emailAddress,
                onChanged: (_) => _validateForm(),
              ),
              SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                decoration: InputDecoration(
                  hintText: 'Mật khẩu',
                  prefixIcon: Icon(Icons.lock, color: AppColors.textTertiary),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                      color: AppColors.textTertiary,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                  errorText: _passwordError,
                ),
                obscureText: _obscurePassword,
                onChanged: (_) => _validateForm(),
              ),
              if (_passwordController.text.isNotEmpty) ...[
                SizedBox(height: 8),
                Row(
                  children: [
                    Text('Độ mạnh: ', style: TextStyle(color: AppColors.textSecondary)),
                    Text(
                      _getPasswordStrength(_passwordController.text),
                      style: TextStyle(
                        color: _getStrengthColor(_getPasswordStrength(_passwordController.text)),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
              SizedBox(height: 16),
              TextField(
                controller: _confirmPasswordController,
                decoration: InputDecoration(
                  hintText: 'Xác nhận mật khẩu',
                  prefixIcon: Icon(Icons.lock, color: AppColors.textTertiary),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureConfirm
                          ? Icons.visibility_off
                          : Icons.visibility,
                      color: AppColors.textTertiary,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureConfirm = !_obscureConfirm;
                      });
                    },
                  ),
                  errorText: _confirmPasswordError,
                ),
                obscureText: _obscureConfirm,
                onChanged: (_) => _validateForm(),
              ),
              SizedBox(height: 24),
              Consumer<AuthProvider>(
                builder: (context, authProvider, _) {
                  return ElevatedButton(
                    onPressed: authProvider.isLoading ? null : _register,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: authProvider.isLoading
                        ? SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation(Colors.white),
                              strokeWidth: 2,
                            ),
                          )
                        : Text(
                            'Tạo tài khoản',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
