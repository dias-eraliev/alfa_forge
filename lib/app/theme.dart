import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PRIMETheme {
  static const Color bg = Color(0xFF000000);
  static const Color cardBg = Color(0xFF0E0E0E);
  static const Color primary = Color(0xFF660000);
  static const Color sand = Color(0xFFE9E1D1);
  static const Color sandWeak = Color(0xFFCFC5B2);
  static const Color line = Color(0xFF2A2A2A);
  static const Color success = Color(0xFF2C8F4E);
  static const Color warn = Color(0xFFCC8F1A);

  static ThemeData dark() {
    final base = ThemeData.dark(useMaterial3: true);
    final PRIME = GoogleFonts.robotoSlabTextTheme(base.textTheme);
    final mono = GoogleFonts.jetBrainsMonoTextTheme(base.textTheme);

    final text = base.textTheme.copyWith(
      displayLarge: PRIME.displayLarge?.copyWith(color: sand, fontSize: 48),
      displayMedium: PRIME.displayMedium?.copyWith(color: sand, fontSize: 36),
      headlineSmall: PRIME.headlineSmall?.copyWith(color: sand, letterSpacing: 1),
      titleLarge: mono.titleLarge?.copyWith(color: sand),
      titleMedium: mono.titleMedium?.copyWith(color: sandWeak),
      bodyLarge: mono.bodyLarge?.copyWith(color: sand),
      bodyMedium: mono.bodyMedium?.copyWith(color: sandWeak),
      labelLarge: mono.labelLarge?.copyWith(color: sand),
    );

    const scheme = ColorScheme.dark(
      primary: primary,
      onPrimary: sand,
      surface: bg,
      onSurface: sand,
      secondary: sand,
      onSecondary: bg,
      outline: line,
    );

    return base.copyWith(
      colorScheme: scheme,
      scaffoldBackgroundColor: bg,
      cardColor: const Color(0xFF0E0E0E),
      dividerColor: line,
      textTheme: text,
      appBarTheme: const AppBarTheme(
        backgroundColor: bg,
        foregroundColor: sand,
        elevation: 0,
      ),
      checkboxTheme: CheckboxThemeData(
        side: const BorderSide(color: sand),
        fillColor: WidgetStateProperty.resolveWith((s) =>
            s.contains(WidgetState.selected) ? primary : Colors.transparent),
        checkColor: WidgetStateProperty.all(sand),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.black,
        selectedItemColor: sand,
        unselectedItemColor: sandWeak,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}
