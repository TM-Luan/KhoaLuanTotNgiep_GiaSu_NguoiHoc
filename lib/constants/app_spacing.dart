/// App-wide spacing and design constants for consistent UI
class AppSpacing {
  // Padding and Margin Constants
  static const double xs = 4.0;    // Extra small spacing
  static const double sm = 8.0;    // Small spacing
  static const double md = 12.0;   // Medium spacing  
  static const double lg = 16.0;   // Large spacing (default)
  static const double xl = 20.0;   // Extra large spacing
  static const double xxl = 24.0;  // 2x extra large spacing
  static const double xxxl = 32.0; // 3x extra large spacing

  // Card specific spacing
  static const double cardPadding = lg;           // 16px
  static const double cardMargin = md;            // 12px
  static const double cardBorderRadius = md;     // 12px
  static const double cardElevation = 3.0;
  
  // Button specific spacing
  static const double buttonPaddingHorizontal = md;  // 12px
  static const double buttonPaddingVertical = sm;    // 8px
  static const double buttonBorderRadius = 6.0;
  
  // Icon container spacing
  static const double iconContainerPadding = sm;     // 8px
  static const double iconContainerRadius = sm;      // 8px
  static const double iconSize = 24.0;
  static const double smallIconSize = 18.0;
  static const double buttonIconSize = 14.0;
  
  // AppBar spacing
  static const double appBarIconSpacing = md;        // 12px
  static const double appBarPadding = md;            // 12px
  
  // List and grid spacing
  static const double listPadding = lg;              // 16px
  static const double itemSpacing = md;              // 12px
  static const double sectionSpacing = lg;           // 16px
}

/// Typography constants for consistent text styling
class AppTypography {
  // Font Sizes
  static const double heading1 = 24.0;
  static const double heading2 = 20.0;
  static const double heading3 = 18.0;
  static const double body1 = 16.0;
  static const double body2 = 14.0;
  static const double caption = 13.0;
  static const double small = 12.0;
  static const double tiny = 11.0;
  
  // Common text styles
  static const double appBarTitle = heading3;     // 18px
  static const double cardTitle = body2;          // 14px
  static const double buttonText = small;         // 12px
  static const double listItem = body2;           // 14px
}

/// Color opacity constants
class AppOpacity {
  static const double iconBackground = 0.2;
  static const double overlay = 0.5;
  static const double disabled = 0.6;
  static const double subtle = 0.7;
}