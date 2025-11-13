import 'dart:math';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:gastos/constants/app_colors.dart';
import 'package:gastos/widgets/common/help_button.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Formateador para la fecha
    final String monthYear =
    DateFormat.yMMMM('es_ES').format(DateTime(2025, 11));

    // Datos de ejemplo
    double totalGastado = 120.00;
    double presupuesto = 1000.00;
    double disponible = presupuesto - totalGastado;
    double porcentajeGastado = totalGastado / presupuesto;

    return Scaffold(
      // Usamos un Stack para poner el botón de ayuda flotante
      body: Stack(
        children: [
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Fila superior con Fecha
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        monthYear, // "noviembre de 2025"
                        style: const TextStyle(
                          color: AppColors.secondaryText,
                          fontSize: 16,
                        ),
                      ),
                      // El botón de ayuda ahora es flotante
                    ],
                  ),
                  const Text(
                    "Resumen Mensual",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryText,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Tarjeta de Resumen de Gastos
                  _buildSummaryCard(
                      totalGastado, disponible, presupuesto, porcentajeGastado),

                  const SizedBox(height: 30),
                  const Text(
                    "Categorías Principales",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryText,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Gráfico (Placeholder)
                  _buildChartPlaceholder(),

                  const SizedBox(height: 30),

                  // Lista de Categorías
                  _buildCategoryItem("Educación", 100.00, 0.83, AppColors.green,
                      Icons.school),
                  _buildCategoryItem("Entretenimiento", 20.00, 0.17,
                      AppColors.purple, Icons.videogame_asset),
                  // Padding inferior para que no tape el botón de menú
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
          // Botón de Ayuda Flotante
          const Positioned(
            bottom: 80, // Por encima de la barra de navegación
            right: 16,
            child: HelpButton(),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(double totalGastado, double disponible,
      double presupuesto, double porcentaje) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          colors: [Color(0xFFD3BBA5), Color(0xFFC8A98C)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.accentLightBrown.withOpacity(0.4),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Total Gastado",
              style: TextStyle(color: AppColors.primaryText, fontSize: 16)),
          Text(
            "\$${totalGastado.toStringAsFixed(2)}",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 36,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Disponible: \$${disponible.toStringAsFixed(2)} / \$${presupuesto.toStringAsFixed(2)}",
            style: const TextStyle(color: AppColors.primaryText, fontSize: 14),
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: porcentaje,
              minHeight: 12,
              backgroundColor: Colors.white.withOpacity(0.3),
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChartPlaceholder() {
    // Placeholder para el gráfico de dona
    return Center(
      child: Container(
        width: 180,
        height: 180,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.cardBackground, width: 20),
        ),
        child: Center(
          child: Container(
            width: 140,
            height: 140,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              // Simulación del gráfico
              gradient: SweepGradient(
                colors: [
                  AppColors.green,
                  AppColors.green,
                  AppColors.purple,
                  Colors.transparent,
                ],
                stops: [0.0, 0.83, 0.83, 1.0],
                transform: GradientRotation(-pi / 2), // Empezar desde arriba
              ),
            ),
            child: Center(
              child: Container(
                width: 100,
                height: 100,
                decoration: const BoxDecoration(
                  color: AppColors.background,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryItem(String nombre, double monto, double porcentaje,
      Color color, IconData icono) {
    return Card(
      margin: const EdgeInsets.only(bottom: 15),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Icon(icono, color: color, size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    nombre,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
                Text(
                  "\$${monto.toStringAsFixed(2)}",
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 8),
                Text(
                  "${(porcentaje * 100).toStringAsFixed(0)}%",
                  style: const TextStyle(
                      fontSize: 14, color: AppColors.secondaryText),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: porcentaje,
                minHeight: 8,
                backgroundColor: AppColors.background,
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
            ),
          ],
        ),
      ),
    );
  }
}