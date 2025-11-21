import 'dart:math';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:gastos/constants/app_colors.dart';
import 'package:gastos/data/gasto.dart';
import 'package:gastos/data/gasto_storage_service.dart';

const double _presupuestoMensual = 1000.00;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  // ➡️ HACEMOS EL ESTADO PÚBLICO
  State<HomeScreen> createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  final GastoStorageService _storageService = GastoStorageService();
  late Future<List<Gasto>> _gastosFuture;

  @override
  void initState() {
    super.initState();
    _loadGastos();
  }

  // ➡️ MÉTODO PÚBLICO PARA SER LLAMADO DESDE MAINNAVIGATIONSCREEN
  void refreshHome() {
    _loadGastos();
  }

  void _loadGastos() {
    setState(() {
      _gastosFuture = _storageService.getGastos();
    });
  }

  Map<String, dynamic> _calculateStats(List<Gasto> expenses) {
    if (expenses.isEmpty) {
      return {
        'totalGastado': 0.0,
        'categorias': [],
        'presupuesto': _presupuestoMensual,
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
      final double monto = entry.value;
      return {
        'nombre': entry.key,
        'monto': monto,
        'porcentaje': monto / totalGastado,
      };
    }).toList();

    categoriasList.sort((a, b) => b['monto'].compareTo(a['monto']));

    return {
      'totalGastado': totalGastado,
      'categorias': categoriasList,
      'presupuesto': _presupuestoMensual,
    };
  }

  final Map<String, Map<String, dynamic>> _categoryVisuals = {
    'Alimentación': {'icon': Icons.restaurant, 'color': AppColors.red},
    'Transporte': {'icon': Icons.directions_car, 'color': AppColors.blue},
    'Entretenimiento': {'icon': Icons.videogame_asset, 'color': AppColors.purple},
    'Salud': {'icon': Icons.medical_services, 'color': AppColors.green},
    'Educación': {'icon': Icons.school, 'color': AppColors.yellow},
    'Compras': {'icon': Icons.shopping_bag, 'color': AppColors.orange},
  };


  @override
  Widget build(BuildContext context) {
    final String monthYear = DateFormat.yMMMM('es_ES').format(DateTime.now());

    return Scaffold(
      body: Stack(
        children: [
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Encabezado
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        monthYear,
                        style: const TextStyle(
                          color: AppColors.secondaryText,
                          fontSize: 16,
                        ),
                      ),
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

                  // FutureBuilder para cargar los datos
                  FutureBuilder<List<Gasto>>(
                      future: _gastosFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        }

                        if (snapshot.hasError) {
                          return const Text("Error al cargar datos.");
                        }

                        final List<Gasto> expenses = snapshot.data ?? [];

                        // Si no hay datos, mostramos un mensaje centrado
                        if (expenses.isEmpty) {
                          return const Center(child: Text("Aún no hay gastos registrados."));
                        }

                        final stats = _calculateStats(expenses);

                        final double totalGastado = stats['totalGastado'];
                        final double presupuesto = stats['presupuesto'];
                        final double disponible = presupuesto - totalGastado;
                        final double porcentajeGastado = totalGastado / presupuesto;
                        final List<Map<String, dynamic>> categorias = stats['categorias'];

                        // Devolvemos el resto de los Widgets dentro de un Column
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Tarjeta de Resumen de Gastos
                            _buildSummaryCard(
                                totalGastado,
                                disponible,
                                presupuesto,
                                min(porcentajeGastado, 1.0)
                            ),

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

                            // Gráfico (Usar datos dinámicos en el placeholder)
                            _buildChartPlaceholder(categorias, totalGastado),

                            const SizedBox(height: 30),

                            // Lista de Categorías (Mapeo dinámico)
                            ...categorias.map((cat) {
                              final visuals = _categoryVisuals[cat['nombre']] ?? {'icon': Icons.monetization_on, 'color': Colors.grey};
                              return _buildCategoryItem(
                                  cat['nombre'],
                                  cat['monto'],
                                  cat['porcentaje'],
                                  visuals['color'],
                                  visuals['icon']
                              );
                            }).toList(),

                            const SizedBox(height: 80),
                          ],
                        );
                      }
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(double totalGastado, double disponible,
      double presupuesto, double porcentaje) {
    // ... (sin cambios)
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

  Widget _buildChartPlaceholder(List<Map<String, dynamic>> categorias, double totalGastado) {
    // ... (sin cambios)
    if (totalGastado == 0) {
      return const Center(child: Text("No hay datos para mostrar en el gráfico."));
    }

    final List<Color> colors = [];
    final List<double> stops = [];
    double currentStop = 0.0;

    for (var cat in categorias) {
      final double porcentaje = cat['porcentaje'];
      final Color color = _categoryVisuals[cat['nombre']]?['color'] ?? Colors.grey;

      if (currentStop > 0.0) {
        colors.add(color);
        stops.add(currentStop);
      }

      currentStop += porcentaje;
      colors.add(color);
      stops.add(currentStop);
    }

    if (currentStop < 1.0) {
      colors.add(Colors.transparent);
      stops.add(1.0);
    }

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
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: SweepGradient(
                colors: colors,
                stops: stops,
                transform: const GradientRotation(-pi / 2),
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
    // ... (sin cambios)
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