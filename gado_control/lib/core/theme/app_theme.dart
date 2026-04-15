import 'package:flutter/material.dart';

/// AppTheme centraliza 100% das decisões visuais do app.
/// Para mudar qualquer cor, fonte ou forma — altere AQUI, não nas telas.
class AppTheme {
  AppTheme._(); // Impede instanciação acidental

  // ─── Paleta principal ───────────────────────────────────────────────────────
  static const Color primary = Color(0xFF1B5E20); // Verde floresta escuro
  static const Color primaryLight = Color(0xFF43A047); // Verde médio
  static const Color primarySurface = Color(0xFFE8F5E9); // Verde bem claro
  static const Color secondary = Color(0xFF5D4037); // Marrom terra
  static const Color secondaryLight = Color(0xFF8D6E63); // Marrom claro
  static const Color accent = Color(0xFFF9A825); // Âmbar / colheita

  // ─── Status / semântica ─────────────────────────────────────────────────────
  static const Color success = Color(0xFF2E7D32);
  static const Color warning = Color(0xFFF57F17);
  static const Color error = Color(0xFFC62828);
  static const Color info = Color(0xFF1565C0);

  // ─── Neutros ────────────────────────────────────────────────────────────────
  static const Color background = Color(0xFFF5F5F0); // Off-white terroso
  static const Color surface = Colors.white;
  static const Color textPrimary = Color(0xFF1C1C1C);
  static const Color textSecondary = Color(0xFF616161);
  static const Color divider = Color(0xFFE0E0E0);

  // ─── Forma padrão ───────────────────────────────────────────────────────────
  static final ShapeBorder _cardShape = RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(16),
  );

  static final ShapeBorder _chipShape = RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(8),
  );

  // ─── Tema claro ─────────────────────────────────────────────────────────────
  static ThemeData get light {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: primary,
      brightness: Brightness.light,
      primary: primary,
      secondary: secondary,
      surface: surface,
      error: error,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: background,

      // AppBar
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 2,
        backgroundColor: primary,
        foregroundColor: Colors.white,
        titleTextStyle: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Colors.white,
          letterSpacing: 0.3,
        ),
        iconTheme: IconThemeData(color: Colors.white),
      ),

      // Cards
      cardTheme: CardThemeData(
        elevation: 2,
        shadowColor: Colors.black12,
        color: surface,
        shape: _cardShape,
        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 0),
      ),

      // Botões elevados (ação primária)
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),

      // Botões outlined (ação secundária)
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primary,
          minimumSize: const Size(double.infinity, 52),
          side: const BorderSide(color: primary, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),

      // Campos de texto
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: primarySurface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: divider),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: error, width: 1.5),
        ),
        labelStyle: const TextStyle(color: textSecondary),
        hintStyle: TextStyle(color: textSecondary.withValues(alpha: 0.6)),
      ),

      // Chips
      chipTheme: ChipThemeData(
        shape: _chipShape as OutlinedBorder,
        backgroundColor: primarySurface,
        labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
      ),

      // Divisor
      dividerTheme: const DividerThemeData(
        color: divider,
        thickness: 1,
        space: 24,
      ),

      // FloatingActionButton
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: CircleBorder(),
      ),

      // ListTile
      listTileTheme: const ListTileThemeData(
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        iconColor: primary,
      ),
    );
  }
}

/// Extensão para acessar cores customizadas diretamente via context.
/// Uso: context.appColors.primary
extension AppColors on BuildContext {
  _AppColorsData get appColors => const _AppColorsData();
}

class _AppColorsData {
  const _AppColorsData();
  Color get primary => AppTheme.primary;
  Color get secondary => AppTheme.secondary;
  Color get accent => AppTheme.accent;
  Color get success => AppTheme.success;
  Color get warning => AppTheme.warning;
  Color get error => AppTheme.error;
  Color get background => AppTheme.background;
}
