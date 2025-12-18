import 'package:flutter/material.dart';
import 'app_theme.dart';

/// Helper class để lấy màu sắc từ theme hiện tại
/// Hỗ trợ cả light mode và dark mode
class ThemeColors {
  static Color getBackground(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return brightness == Brightness.dark
        ? AppColorsDark.background
        : AppColors.background;
  }

  static Color getSurface(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return brightness == Brightness.dark
        ? AppColorsDark.surface
        : AppColors.surface;
  }

  static Color getSurfaceLight(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return brightness == Brightness.dark
        ? AppColorsDark.surfaceLight
        : AppColors.surfaceLight;
  }

  static Color getTextPrimary(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return brightness == Brightness.dark
        ? AppColorsDark.textPrimary
        : AppColors.textPrimary;
  }

  static Color getTextSecondary(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return brightness == Brightness.dark
        ? AppColorsDark.textSecondary
        : AppColors.textSecondary;
  }

  static Color getTextTertiary(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return brightness == Brightness.dark
        ? AppColorsDark.textTertiary
        : AppColors.textTertiary;
  }

  static Color getTextLight(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return brightness == Brightness.dark
        ? AppColorsDark.textLight
        : AppColors.textLight;
  }

  static Color getBorder(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return brightness == Brightness.dark
        ? AppColorsDark.border
        : AppColors.border;
  }

  static Color getBorderLight(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return brightness == Brightness.dark
        ? AppColorsDark.borderLight
        : AppColors.borderLight;
  }

  static Color getPrimary(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return brightness == Brightness.dark
        ? AppColorsDark.primary
        : AppColors.primary;
  }

  static Color getDanger(BuildContext context) {
    // Danger color giữ nguyên cho cả light và dark
    return AppColors.danger;
  }

  static Color getWarning(BuildContext context) {
    // Warning color giữ nguyên cho cả light và dark
    return AppColors.warning;
  }

  static Color getSuccess(BuildContext context) {
    // Success color giữ nguyên cho cả light và dark
    return AppColors.success;
  }

  static Color getInfo(BuildContext context) {
    // Info color giữ nguyên cho cả light và dark
    return AppColors.info;
  }
}

