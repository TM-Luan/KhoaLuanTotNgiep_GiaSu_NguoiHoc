import 'package:flutter/material.dart';

class AppColors {
  // Legacy colors (keep for compatibility)
  static const Color primaryBlue = Color(0xFF0865B3);
  static const Color white = Colors.white;
  static const Color grey = Color(0xFF9E9E9E);
  static const Color black = Colors.black;
  static const Color lightBlue = Colors.blue;
  static const Color lightGrey = Color(0xFFF5F4FA);
  static const Color lightwhite = Color(0xFFFAFAFA);
  
  // New standardized color system
  // Primary blue theme
  static final Color primary = Colors.blue.shade600;
  static final Color primaryLight = Colors.blue.shade400;
  static final Color primaryDark = Colors.blue.shade700;
  static final Color primarySurface = Colors.blue.shade50;
  static final Color primaryContainer = Colors.blue.shade100;
  
  // Status colors
  static final Color success = Colors.green.shade600;
  static final Color successLight = Colors.green.shade400;
  static final Color successSurface = Colors.green.shade50;
  static final Color successContainer = Colors.green.shade100;
  
  static final Color warning = Colors.orange.shade600;
  static final Color warningLight = Colors.orange.shade400;
  static final Color warningSurface = Colors.orange.shade50;
  static final Color warningContainer = Colors.orange.shade100;
  
  static final Color error = Colors.red.shade600;
  static final Color errorLight = Colors.red.shade400;
  static final Color errorSurface = Colors.red.shade50;
  static final Color errorContainer = Colors.red.shade100;
  
  // Neutral colors
  static final Color grey50 = Colors.grey.shade50;
  static final Color grey100 = Colors.grey.shade100;
  static final Color grey200 = Colors.grey.shade200;
  static final Color grey300 = Colors.grey.shade300;
  static final Color grey600 = Colors.grey.shade600;
  static final Color grey700 = Colors.grey.shade700;
  
  // Text colors
  static const Color textPrimary = Colors.black87;
  static const Color textSecondary = Colors.black54;
  static const Color textLight = Colors.white;
  static final Color textMuted = Colors.grey.shade600;
  
  // Background colors
  static const Color background = Colors.white;
  static final Color backgroundGrey = Colors.grey.shade50;
  
  // Border colors
  static final Color border = Colors.grey.shade300;
  static final Color borderLight = Colors.grey.shade200;
}

/// Gradient definitions for consistent styling
class AppGradients {
  static LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AppColors.primary, AppColors.primaryLight],
  );
  
  static LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AppColors.primarySurface, AppColors.white],
  );
  
  static LinearGradient buttonGradient = LinearGradient(
    colors: [AppColors.primaryLight, AppColors.primary],
  );
}
