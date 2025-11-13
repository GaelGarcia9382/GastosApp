import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gastos/constants/app_colors.dart';
import 'package:gastos/screens/splash_screen.dart';
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Serenidad Financiera',
      debugShowCheckedModeBanner: false,

      // --- Configuración de Localización ---
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('es', 'ES'), // Soportar español
        Locale('en', 'US'), // Soportar inglés
      ],
      locale: const Locale('es', 'ES'), // Forzar español por defecto
      // --- Fin de la Configuración ---

      theme: _buildTheme(Brightness.light),
      // Podrías agregar el tema oscuro aquí si lo deseas
      // darkTheme: _buildTheme(Brightness.dark),
      // themeMode: ThemeMode.dark, // Para forzar el tema oscuro como en tu diseño
      home: const SplashScreen(),
    );
  }

  ThemeData _buildTheme(Brightness brightness) {
    // Por ahora, nos basamos en el tema claro/beige de tus diseños
    var baseTheme = ThemeData(
      brightness: brightness,
      scaffoldBackgroundColor: AppColors.background,
      primaryColor: AppColors.accentBrown,
      textTheme: GoogleFonts.latoTextTheme(
        ThemeData(brightness: brightness).textTheme,
      ).apply(
        bodyColor: AppColors.primaryText,
        displayColor: AppColors.primaryText,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: IconThemeData(color: AppColors.primaryText),
        titleTextStyle: TextStyle(
          color: AppColors.primaryText,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: AppColors.cardBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      iconTheme: const IconThemeData(
        color: AppColors.secondaryText,
      ),
      dividerColor: AppColors.cardBackground,
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.accentBrown,
        foregroundColor: Colors.white,
      ),
    );

    return baseTheme;
  }
}