import 'dart:math';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:gastos/constants/app_colors.dart';
import 'package:gastos/data/gasto.dart';
import 'package:gastos/data/gasto_storage_service.dart';
import 'package:gastos/data/category.dart';
import 'package:gastos/data/category_storage_service.dart';
import 'package:gastos/data/settings_storage_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  final GastoStorageService _storageService = GastoStorageService();
  final CategoryStorageService _categoryService = CategoryStorageService();
  final SettingsStorageService _settingsService = SettingsStorageService();

  late Future<List<dynamic>> _combinedDataFuture;

  @override
  void initState() {
    super.initState();
    _loadCombinedData();
  }

  void refreshHome() {
    _loadCombinedData();
  }

  void _loadCombinedData() {
    setState(() {
      _combinedDataFuture = Future.wait([
        _storageService.getGastos(),
        _categoryService.getCategories(),
        _settingsService.getMonthlyBudget(),
      ]);
    });
  }

  Map<String, dynamic> _calculateStats(List<Gasto> expenses, Map<String, Category> categoryMap, double dynamicBudget) {
    if (expenses.isEmpty) {
      return {
        'totalGastado': 0.0,
        'categorias': [],
        'presupuesto': dynamicBudget,
      };
    }

    double totalGastado = 0.0;
    final Map<String, double> categorias = {};

    for (var expense in expenses) {
      totalGastado += expense.cantidad;
      categorias.update(
        expense.categoria,
            (value) => value + expense.cantidad,
        ifAbsent: () => expense.cantidad,
      );
    }

    final List<Map<String, dynamic>> categoriasList = categorias.entries.map((entry) {
      final String nombre = entry.key;
      final double monto = entry.value;
      final Category? cat = categoryMap[nombre];

      return {
        'nombre': nombre,
        'monto': monto,
        'porcentaje': totalGastado > 0 ? monto / totalGastado : 0.0,
        'color': cat?.color ?? Colors.grey,
        'icon': cat?.icon ?? Icons.monetization_on,
      };
    }).toList();

    categoriasList.sort((a, b) => b['monto'].compareTo(a['monto']));

    return {
      'totalGastado': totalGastado,
      'categorias': categoriasList,
      'presupuesto': dynamicBudget,
    };
  }

  @override
  Widget build(BuildContext context) {
    final String monthYear = DateFormat.yMMMM('es_ES').format(DateTime.now());

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ➡️ 1. ENCABEZADO (Fuera del FutureBuilder)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    monthYear,
                    style: const TextStyle(color: AppColors.secondaryText, fontSize: 16),
                  ),
                ],
              ),
              const Text(
                "Resumen Mensual",
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.primaryText),
              ),
              const SizedBox(height: 20),

              // ➡️ 2. CONTENIDO DINÁMICO
              FutureBuilder<List<dynamic>>(
                future: _combinedDataFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text("Error: ${snapshot.error}"));
                  }

                  final List<Gasto> expenses = snapshot.data![0];
                  final List<Category> categoriesList = snapshot.data![1];
                  final double dynamicBudget = snapshot.data![2];

                  final Map<String, Category> categoryMap = {
                    for (var cat in categoriesList) cat.nombre: cat
                  };

                  if (expenses.isEmpty) {
                    return _buildEmptyHomeScreen();
                  }

                  final stats = _calculateStats(expenses, categoryMap, dynamicBudget);
                  final double totalGastado = stats['totalGastado'];
                  final double presupuesto = stats['presupuesto'];
                  final double disponible = presupuesto - totalGastado;
                  final double porcentajeGastado = totalGastado / presupuesto;
                  final List<Map<String, dynamic>> categorias = stats['categorias'];

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSummaryCard(totalGastado, disponible, presupuesto, min(porcentajeGastado, 1.0)),
                      const SizedBox(height: 30),
                      const Text(
                        "Categorías Principales",
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.primaryText),
                      ),
                      const SizedBox(height: 20),
                      _buildChartPlaceholder(categorias, totalGastado),
                      const SizedBox(height: 30),
                      ...categorias.map((cat) {
                        return _buildCategoryItem(
                            cat['nombre'],
                            cat['monto'],
                            cat['porcentaje'],
                            cat['color'],
                            cat['icon']
                        );
                      }).toList(),
                      const SizedBox(height: 80),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyHomeScreen() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24.0),
        child: Text("Aún no hay gastos registrados.", style: TextStyle(fontSize: 16, color: AppColors.secondaryText)),
      ),
    );
  }

  Widget _buildSummaryCard(double totalGastado, double disponible, double presupuesto, double porcentaje) {
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
          BoxShadow(color: AppColors.accentLightBrown.withOpacity(0.4), blurRadius: 15, offset: const Offset(0, 8)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Total Gastado", style: TextStyle(color: AppColors.primaryText, fontSize: 16)),
          Text("\$${totalGastado.toStringAsFixed(2)}", style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text("Disponible: \$${disponible.toStringAsFixed(2)} / \$${presupuesto.toStringAsFixed(2)}", style: const TextStyle(color: AppColors.primaryText, fontSize: 14)),
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

  Widget _buildChartPlaceholder(List<Map<String, dynamic>> categorias, double total) {
    if (total == 0) return const SizedBox.shrink();

    final List<Color> colors = [];
    final List<double> stops = [];
    double currentStop = 0.0;

    for (var cat in categorias) {
      final double porcentaje = cat['porcentaje'];
      if (currentStop > 0.0) { colors.add(cat['color']); stops.add(currentStop); }
      currentStop += porcentaje;
      colors.add(cat['color']); stops.add(currentStop);
    }
    if (currentStop < 1.0) { colors.add(Colors.transparent); stops.add(1.0); }

    return Center(
      child: Container(
        width: 180, height: 180,
        decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: AppColors.cardBackground, width: 20)),
        child: Center(
          child: Container(
            width: 140, height: 140,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: SweepGradient(colors: colors, stops: stops, transform: const GradientRotation(-pi / 2)),
            ),
            child: Center(child: Container(width: 100, height: 100, decoration: const BoxDecoration(color: AppColors.background, shape: BoxShape.circle))),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryItem(String nombre, double monto, double porcentaje, Color color, IconData icon) {
    return Card(
      margin: const EdgeInsets.only(bottom: 15),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(width: 12),
            Expanded(child: Text(nombre, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600))),
            Text("\$${monto.toStringAsFixed(2)}", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(width: 8),
            Text("${(porcentaje * 100).toStringAsFixed(0)}%", style: const TextStyle(fontSize: 14, color: AppColors.secondaryText)),
          ],
        ),
      ),
    );
  }
}