import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gastos/constants/app_colors.dart';
import 'package:gastos/screens/splash_screen.dart';
// ➡️ Importamos el servicio
import 'package:gastos/services/theme_service.dart';

// ➡️ Notificador Global: Toda la app escuchará esta variable
final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.light);

void main() async {
  // Aseguramos que los bindings estén listos antes de cargar preferencias
  WidgetsFlutterBinding.ensureInitialized();

  // ➡️ Cargamos el tema guardado
  final bool isDark = await ThemeService().isDarkMode();
  themeNotifier.value = isDark ? ThemeMode.dark : ThemeMode.light;

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // ➡️ Envolvemos todo en ValueListenableBuilder para escuchar cambios de tema
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (context, currentMode, _) {
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
            Locale('es', 'ES'),
            Locale('en', 'US'),
          ],
          locale: const Locale('es', 'ES'),
          // --- Fin de la Configuración ---

          // ➡️ Definimos ambos temas usando tu función constructora
          theme: _buildTheme(Brightness.light),
          darkTheme: _buildTheme(Brightness.dark),

          // ➡️ Usamos el modo actual del notificador
          themeMode: currentMode,

          home: const SplashScreen(),
        );
      },
    );
  }

  ThemeData _buildTheme(Brightness brightness) {
    final bool isDark = brightness == Brightness.dark;

    // Definimos colores dinámicos según el brillo
    final Color scaffoldBg = isDark ? const Color(0xFF121212) : AppColors.background;
    final Color cardBg = isDark ? const Color(0xFF1E1E1E) : AppColors.cardBackground;
    final Color textColor = isDark ? Colors.white : AppColors.primaryText;
    final Color iconColor = isDark ? Colors.white70 : AppColors.secondaryText;

    var baseTheme = ThemeData(
      brightness: brightness,
      scaffoldBackgroundColor: scaffoldBg,
      primaryColor: AppColors.accentBrown,

      // Configuración de Textos
      textTheme: GoogleFonts.latoTextTheme(
        ThemeData(brightness: brightness).textTheme,
      ).apply(
        bodyColor: textColor,
        displayColor: textColor,
      ),

      // Configuración de AppBar
      appBarTheme: AppBarTheme(
        backgroundColor: scaffoldBg,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: IconThemeData(color: textColor),
        titleTextStyle: TextStyle(
          color: textColor,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),

      // Configuración de Tarjetas
      cardTheme: CardThemeData(
        elevation: 0,
        color: cardBg,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),

      // Configuración de Íconos
      iconTheme: IconThemeData(
        color: iconColor,
      ),

      // Configuración de Inputs (TextFields)
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: cardBg, // El fondo del input se adapta al modo oscuro
        hintStyle: TextStyle(color: iconColor),
        prefixStyle: TextStyle(color: textColor),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),

      // Configuración de otros elementos
      dividerColor: cardBg,
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.accentBrown,
        foregroundColor: Colors.white,
      ),

      // Color de fondo de los diálogos/modales
      dialogBackgroundColor: cardBg,
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: cardBg,
        modalBackgroundColor: cardBg,
      ),
    );

    return baseTheme;
  }
}