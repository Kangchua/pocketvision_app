import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../utils/exception_handler.dart';
import '../utils/theme_colors.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _login() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    // Validation
    if (email.isEmpty || password.isEmpty) {
      ExceptionHandler.showErrorSnackBar(context, 'Vui lòng nhập email và mật khẩu');
      return;
    }

    if (!ExceptionHandler.isValidEmail(email)) {
      ExceptionHandler.showErrorSnackBar(context, 'Email không hợp lệ');
      return;
    }

    if (password.length < 6) {
      ExceptionHandler.showErrorSnackBar(context, 'Mật khẩu phải có ít nhất 6 ký tự');
      return;
    }

    try {
      await context.read<AuthProvider>().login(
            email: email,
            password: password,
          );

      if (mounted && context.mounted) {
        Navigator.of(context).pushReplacementNamed('/home');
      }
    } catch (e) {
      if (mounted) {
        ExceptionHandler.showErrorSnackBar(context, e);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeColors.getBackground(context),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: 60),
              // Logo với gradient như web
              Center(
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    gradient: ThemeColors.getPrimaryGradient(context),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: ThemeColors.getGlowShadow(context),
                  ),
                  child: Icon(
                    Icons.account_balance_wallet_rounded,
                    size: 40,
                    color: Colors.white,
                  ),
                ),
              ),
              SizedBox(height: 24),
              Text(
                'Pocket Money',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  color: ThemeColors.getPrimary(context),
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.5,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Quản lý tài chính của bạn',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: ThemeColors.getTextSecondary(context),
                ),
              ),
              SizedBox(height: 48),
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  hintText: 'Email',
                  prefixIcon: Icon(Icons.email, color: ThemeColors.getTextTertiary(context)),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                decoration: InputDecoration(
                  hintText: 'Mật khẩu',
                  prefixIcon: Icon(Icons.lock, color: ThemeColors.getTextTertiary(context)),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                      color: ThemeColors.getTextTertiary(context),
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                ),
                obscureText: _obscurePassword,
              ),
              SizedBox(height: 32),
              Consumer<AuthProvider>(
                builder: (context, authProvider, _) {
                  return Container(
                    decoration: BoxDecoration(
                      gradient: ThemeColors.getPrimaryGradient(context),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: ThemeColors.getElegantShadow(context),
                    ),
                    child: ElevatedButton(
                      onPressed: authProvider.isLoading ? null : _login,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        padding: EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
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
                              'Đăng nhập',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.5,
                              ),
                            ),
                    ),
                  );
                },
              ),
              SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Chưa có tài khoản? ',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: ThemeColors.getTextSecondary(context),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => RegisterScreen(),
                        ),
                      );
                    },
                    child: Text(
                      'Đăng ký ngay',
                      style: TextStyle(
                        color: ThemeColors.getPrimary(context),
                        fontWeight: FontWeight.w600,
                        decoration: TextDecoration.underline,
                        decorationColor: ThemeColors.getPrimary(context),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
