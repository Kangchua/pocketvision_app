# Script to update screens for dark mode support
# This script adds ThemeColors import and updates common AppColors usages

$files = @(
    "lib\screens\budgets_screen.dart",
    "lib\screens\invoices_screen.dart",
    "lib\screens\reports_screen.dart",
    "lib\screens\add_expense_screen.dart",
    "lib\screens\add_invoice_screen.dart",
    "lib\screens\edit_expense_screen.dart",
    "lib\screens\profile_screen.dart",
    "lib\screens\settings_screen.dart",
    "lib\screens\notifications_screen.dart",
    "lib\screens\categories_screen.dart",
    "lib\screens\add_budget_screen.dart",
    "lib\screens\search_expenses_screen.dart",
    "lib\screens\ai_suggestions_screen.dart",
    "lib\screens\fill_expense_screen.dart",
    "lib\screens\help_screen.dart",
    "lib\screens\feedback_screen.dart",
    "lib\screens\edit_profile_screen.dart",
    "lib\screens\change_password_screen.dart",
    "lib\screens\security_screen.dart",
    "lib\screens\upload_invoice_screen.dart",
    "lib\screens\login_screen.dart",
    "lib\screens\register_screen.dart",
    "lib\screens\landing_screen.dart"
)

Write-Host "Note: This script is for reference. Manual updates are recommended for better control."



