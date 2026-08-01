import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';

/// ─── Design Tokens ────────────────────────────────────────────────────────
class AppColors {
  static const bgPrimary    = Color(0xFF080808);
  static const bgSecondary  = Color(0xFF111111);
  static const bgCard       = Color(0xFF161616);
  static const bgCardHover  = Color(0xFF1E1E1E);

  static const gold         = Color(0xFFD4A853);
  static const goldLight    = Color(0xFFFFD700);
  static const goldDim      = Color(0xFF9A7838);
  static const roseGold     = Color(0xFFE8A598);
  static const ruby         = Color(0xFFC0392B);
  static const silver       = Color(0xFFA8B4C0);
  static const green        = Color(0xFF2ECC71);
  static const red          = Color(0xFFE74C3C);

  static const textPrimary   = Color(0xFFF5F0E8);
  static const textSecondary = Color(0xFFB0A898);
  static const textMuted     = Color(0xFF706860);

  static const border       = Color(0x2ED4A853); // rgba(212,168,83,0.18)
  static const borderBright = Color(0x73D4A853); // rgba(212,168,83,0.45)

  static const goldGradientStart = Color(0xFFC8860A);
  static const goldGradientMid   = Color(0xFFFFD700);
}

class AppGradients {
  static const gold = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFC8860A), Color(0xFFFFD700), Color(0xFFC8860A)],
    stops: [0.0, 0.5, 1.0],
  );

  static const holdingsHero = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1A1200), Color(0xFF0D0900)],
  );

  static const profitHero = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF001A08), Color(0xFF000D04)],
  );

  static const withdrawBtn = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1A5C2E), Color(0xFF27AE60)],
  );
}

class AppRadius {
  static const sm = Radius.circular(8);
  static const md = Radius.circular(14);
  static const lg = Radius.circular(22);
  static const xl = Radius.circular(30);
  static const smBR  = BorderRadius.all(sm);
  static const mdBR  = BorderRadius.all(md);
  static const lgBR  = BorderRadius.all(lg);
  static const xlBR  = BorderRadius.all(xl);
}

/// ─── App ──────────────────────────────────────────────────────────────────
class BlackDiamondApp extends StatelessWidget {
  const BlackDiamondApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Black Diamond',
      debugShowCheckedModeBanner: false,
      theme: _buildTheme(),
      home: const SplashScreen(),
      routes: {
        '/login': (_) => const LoginScreen(),
      },
    );
  }

  ThemeData _buildTheme() {
    final base = ThemeData.dark();
    return base.copyWith(
      scaffoldBackgroundColor: AppColors.bgPrimary,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.gold,
        secondary: AppColors.gold,
        surface: AppColors.bgCard,
      ),
      textTheme: GoogleFonts.interTextTheme(base.textTheme).copyWith(
        bodyLarge:  GoogleFonts.inter(color: AppColors.textPrimary, fontSize: 15),
        bodyMedium: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 13),
        bodySmall:  GoogleFonts.inter(color: AppColors.textMuted, fontSize: 12),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.bgSecondary,
        hintStyle: GoogleFonts.inter(color: AppColors.textMuted, fontSize: 15),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: AppRadius.mdBR,
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadius.mdBR,
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadius.mdBR,
          borderSide: const BorderSide(color: AppColors.gold, width: 1.5),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.gold,
          foregroundColor: const Color(0xFF1A0E00),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: AppRadius.mdBR),
          textStyle: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w700, letterSpacing: 1),
        ),
      ),
      scrollbarTheme: const ScrollbarThemeData(
        thickness: WidgetStatePropertyAll(3),
        radius: Radius.circular(4),
      ),
    );
  }
}
