import 'package:flutter/material.dart';
import 'colors.dart';
import 'text_styles.dart';

/// App Theme Configuration
/// Provides the main theme data for the Tricket app
class AppTheme {
  AppTheme._();

  /// Main app theme
  static ThemeData get lightTheme => ThemeData(
    // Color Scheme
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primaryColor,
      primary: AppColors.primaryColor,
      secondary: AppColors.kSecondaryColor,
      surface: AppColors.white,
      error: AppColors.errorColor,
      onPrimary: AppColors.white,
      onSecondary: AppColors.white,
      onSurface: AppColors.black13,
      onError: AppColors.white,
    ),

    // Primary Colors
    primaryColor: AppColors.primaryColor,
    canvasColor: AppColors.primaryAccent,
    secondaryHeaderColor: AppColors.secondaryColorLight,
    scaffoldBackgroundColor: AppColors.backgroundColor,
    hintColor: AppColors.hintColor,

    // Font Family
    fontFamily: 'NotoSans',

    // Material 3
    useMaterial3: true,

    // Text Theme
    textTheme: TextTheme(
      headlineLarge: AppTextStyles.headlineLarge.copyWith(
        color: AppColors.black13,
      ),
      headlineMedium: AppTextStyles.headlineMedium.copyWith(
        color: AppColors.black13,
      ),
      headlineSmall: AppTextStyles.headlineSmall.copyWith(
        color: AppColors.black13,
      ),
      titleLarge: AppTextStyles.titleLarge.copyWith(color: AppColors.black13),
      titleMedium: AppTextStyles.titleMedium.copyWith(color: AppColors.black13),
      titleSmall: AppTextStyles.text14SemiBold.copyWith(
        color: AppColors.black13,
      ),
      bodyLarge: AppTextStyles.bodyLarge.copyWith(color: AppColors.black13),
      bodyMedium: AppTextStyles.bodyMedium.copyWith(color: AppColors.black13),
      bodySmall: AppTextStyles.bodySmall.copyWith(color: AppColors.black13),
      labelLarge: AppTextStyles.labelLarge.copyWith(color: AppColors.black13),
      labelMedium: AppTextStyles.labelMedium.copyWith(color: AppColors.black13),
      labelSmall: AppTextStyles.labelSmall.copyWith(color: AppColors.black13),
    ),

    // App Bar Theme
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.primaryColor,
      foregroundColor: AppColors.white,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: AppTextStyles.text18SemiBold.copyWith(
        color: AppColors.white,
      ),
    ),

    // Elevated Button Theme
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primaryColor,
        foregroundColor: AppColors.white,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        textStyle: AppTextStyles.buttonMedium,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    ),

    // Outlined Button Theme
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primaryColor,
        side: const BorderSide(color: AppColors.primaryColor),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        textStyle: AppTextStyles.buttonMedium,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    ),

    // Text Button Theme
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.primaryColor,
        textStyle: AppTextStyles.buttonMedium,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    ),

    // Input Decoration Theme
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.whiteF9,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.textFieldBorderColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.textFieldBorderColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.primaryColor, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.errorColor),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.errorColor, width: 2),
      ),
      hintStyle: AppTextStyles.text14.copyWith(color: AppColors.hintColor),
      labelStyle: AppTextStyles.text14.copyWith(color: AppColors.grey),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    ),

    // Card Theme
    cardTheme: CardThemeData(
      color: AppColors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.all(8),
    ),

    // Divider Theme
    dividerTheme: const DividerThemeData(
      color: AppColors.textFieldBorderColor,
      thickness: 1,
      space: 1,
    ),

    // Icon Theme
    iconTheme: const IconThemeData(color: AppColors.grey, size: 24),

    // Slider Theme
    sliderTheme: SliderThemeData(
      overlayShape: SliderComponentShape.noOverlay,
      trackHeight: 2.0,
      thumbColor: AppColors.gradient1,
      activeTrackColor: AppColors.gradient1,
      inactiveTrackColor: AppColors.textFieldBorderColor,
      thumbShape: const RoundSliderThumbShape(
        enabledThumbRadius: 8.0,
        elevation: 0,
      ),
      minThumbSeparation: 0,
      trackShape: const RectangularSliderTrackShape(),
    ),

    // Checkbox Theme
    checkboxTheme: CheckboxThemeData(
      fillColor: WidgetStateProperty.resolveWith<Color?>((
        Set<WidgetState> states,
      ) {
        if (states.contains(WidgetState.selected)) {
          return AppColors.primaryColor;
        }
        return AppColors.textFieldBorderColor;
      }),
      checkColor: WidgetStateProperty.all(AppColors.white),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2)),
    ),

    // Radio Theme
    radioTheme: RadioThemeData(
      fillColor: WidgetStateProperty.resolveWith<Color?>((
        Set<WidgetState> states,
      ) {
        if (states.contains(WidgetState.selected)) {
          return AppColors.primaryColor;
        }
        return AppColors.textFieldBorderColor;
      }),
    ),

    // Switch Theme
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith<Color?>((
        Set<WidgetState> states,
      ) {
        if (states.contains(WidgetState.selected)) {
          return AppColors.primaryColor;
        }
        return AppColors.textFieldBorderColor;
      }),
      trackColor: WidgetStateProperty.resolveWith<Color?>((
        Set<WidgetState> states,
      ) {
        if (states.contains(WidgetState.selected)) {
          return AppColors.primaryColor.withValues(alpha: 0.3);
        }
        return AppColors.textFieldBorderColor.withValues(alpha: 0.3);
      }),
    ),

    // Bottom Navigation Bar Theme
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: AppColors.white,
      selectedItemColor: AppColors.primaryColor,
      unselectedItemColor: AppColors.grey,
      type: BottomNavigationBarType.fixed,
      elevation: 8,
      selectedLabelStyle: AppTextStyles.text10SemiBold,
      unselectedLabelStyle: AppTextStyles.text10,
    ),

    // Tab Bar Theme
    tabBarTheme: TabBarThemeData(
      labelColor: AppColors.primaryColor,
      unselectedLabelColor: AppColors.grey,
      indicatorColor: AppColors.primaryColor,
      labelStyle: AppTextStyles.text14SemiBold,
      unselectedLabelStyle: AppTextStyles.text14,
    ),

    // Floating Action Button Theme
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: AppColors.primaryColor,
      foregroundColor: AppColors.white,
      elevation: 6,
      shape: CircleBorder(),
    ),

    // Snackbar Theme
    snackBarTheme: SnackBarThemeData(
      backgroundColor: AppColors.black13,
      contentTextStyle: AppTextStyles.text14.copyWith(color: AppColors.white),
      actionTextColor: AppColors.primaryColor,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ),

    // Dialog Theme
    dialogTheme: DialogThemeData(
      backgroundColor: AppColors.white,
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      titleTextStyle: AppTextStyles.text18SemiBold.copyWith(
        color: AppColors.black13,
      ),
      contentTextStyle: AppTextStyles.text14.copyWith(color: AppColors.black13),
    ),

    // Bottom Sheet Theme
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: AppColors.white,
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
    ),
  );

  /// Dark theme (optional for future use)
  static ThemeData get darkTheme => lightTheme.copyWith(
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primaryColor,
      brightness: Brightness.dark,
      primary: AppColors.primaryColor,
      secondary: AppColors.kSecondaryColor,
      surface: AppColors.dark1A,
      error: AppColors.errorColor,
      onPrimary: AppColors.white,
      onSecondary: AppColors.white,
      onSurface: AppColors.white,
      onError: AppColors.white,
    ),
    scaffoldBackgroundColor: AppColors.dark1A,
    appBarTheme: lightTheme.appBarTheme.copyWith(
      backgroundColor: AppColors.dark1A,
    ),
    cardTheme: lightTheme.cardTheme.copyWith(color: AppColors.dark29),
  );
}
