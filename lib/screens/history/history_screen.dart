import 'package:flutter/material.dart';
import 'package:gastos/constants/app_colors.dart';
import 'package:gastos/widgets/common/help_button.dart';
import 'package:intl/intl.dart';
import 'package:gastos/data/gasto.dart';
import 'package:gastos/data/gasto_storage_service.dart';

class HistoryScreen extends StatefulWidget {
  // Acepta la Key
  const HistoryScreen({super.key});

  @override
  // ➡️ CAMBIO: Usar el nombre de la clase de Estado sin guion bajo
  State<HistoryScreen> createState() => HistoryScreenState();
}

// ➡️ CAMBIO CLAVE: Clase de Estado Pública (Visible para MainNavigationScreen)
class HistoryScreenState extends State<HistoryScreen> {
  final GastoStorageService _storageService = GastoStorageService();
  late Future<List<Gasto>> _gastosFuture;

  String _selectedCategory = "Todas las categorías";
  String _selectedMonth = "Noviembre de 2025";

  final List<String> _categories = ["Todas las categorías", "Alimentación", "Transporte", "Entretenimiento", "Salud", "Educación"];
  final List<String> _months = ["Todos los meses", "Noviembre de 2025", "Octubre 2025", "Septiembre 2025"];

  @override
  void initState() {
    super.initState();
    _loadGastos();
  }

  // Función interna para recargar la lista
  void _loadGastos() {
    setState(() {
      _gastosFuture = _storageService.getGastos();
    });
  }

  // ➡️ MÉTODO PÚBLICO LLAMADO POR EL PADRE (MainNavigationScreen)
  void refreshHistory() {
    _loadGastos();
  }

  // Lógica para agrupar la lista simple de Gasto por día
  Map<String, List<Gasto>> _groupExpensesByDate(List<Gasto> expenses) {
    final Map<String, List<Gasto>> grouped = {};

    for (var expense in expenses) {
      final String dateKey = DateFormat('yyyy-MM-dd').format(expense.fecha);

      if (!grouped.containsKey(dateKey)) {
        grouped[dateKey] = [];
      }
      grouped[dateKey]!.add(expense);
    }
    return grouped;
  }

  // Función de mapeo de categoría a ícono y color
  Map<String, dynamic> _getCategoryVisuals(String category) {
    final Map<String, Map<String, dynamic>> categoryMap = {
      'Alimentación': {'icon': Icons.restaurant, 'color': AppColors.red},
      'Transporte': {'icon': Icons.directions_car, 'color': AppColors.blue},
      'Entretenimiento': {'icon': Icons.videogame_asset, 'color': AppColors.purple},
      'Salud': {'icon': Icons.medical_services, 'color': AppColors.green},
      'Educación': {'icon': Icons.school, 'color': AppColors.yellow},
      'Compras': {'icon': Icons.shopping_bag, 'color': AppColors.orange},
    };
    return categoryMap[category] ?? {'icon': Icons.monetization_on, 'color': Colors.grey};
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Historial"),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list, color: AppColors.primaryText, size: 28),
            onPressed: () {},
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: Stack(
        children: [
          FutureBuilder<List<Gasto>>(
            future: _gastosFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(child: Text('Error al cargar gastos: ${snapshot.error}'));
              }

              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text('Aún no hay gastos registrados. ¡Agrega uno!'));
              }

              final List<Gasto> todosLosGastos = snapshot.data!;
              final groupedExpenses = _groupExpensesByDate(todosLosGastos);
              final List<String> sortedDates = groupedExpenses.keys.toList()..sort((a, b) => b.compareTo(a));

              return CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: _buildFilters(),
                  ),

                  SliverList.builder(
                    itemCount: sortedDates.length,
                    itemBuilder: (context, index) {
                      final dateKey = sortedDates[index];
                      final dayExpenses = groupedExpenses[dateKey]!;
                      return _buildDayGroup(dayExpenses);
                    },
                  ),
                  const SliverToBoxAdapter(
                    child: SizedBox(height: 100),
                  ),
                ],
              );
            },
          ),
          const Positioned(
            bottom: 80,
            right: 16,
            child: HelpButton(),
          ),
        ],
      ),
      // El FloatingActionButton se ha movido a MainNavigationScreen.
    );
  }

  Widget _buildFilters() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      color: AppColors.background,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDropdown("Categoría", _selectedCategory, _categories, (val) {
            setState(() => _selectedCategory = val!);
          }),
          const SizedBox(height: 10),
          _buildDropdown("Mes", _selectedMonth, _months, (val) {
            setState(() => _selectedMonth = val!);
          }),
        ],
      ),
    );
  }

  Widget _buildDropdown(String label, String value, List<String> items, ValueChanged<String?> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 14, color: AppColors.secondaryText)),
        DropdownButton<String>(
          value: value,
          isExpanded: true,
          underline: Container(height: 1, color: AppColors.cardBackground),
          icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.secondaryText),
          onChanged: onChanged,
          items: items.map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildDayGroup(List<Gasto> dayExpenses) {
    final double totalDay = dayExpenses.fold(0, (sum, item) => sum + item.cantidad);
    final String readableDate = DateFormat('EEEE, d \'de\' MMMM \'de\' y', 'es_ES').format(dayExpenses.first.fecha);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Total", style: TextStyle(color: AppColors.secondaryText, fontSize: 14)),
                      Text(
                        "\$${totalDay.toStringAsFixed(2)}",
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text("Gastos: ${dayExpenses.length}", style: const TextStyle(color: AppColors.secondaryText, fontSize: 14)),
                      Text(
                        readableDate,
                        style: const TextStyle(color: AppColors.secondaryText, fontSize: 14, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          ...dayExpenses.map((item) => _buildExpenseTile(item)).toList(),
        ],
      ),
    );
  }

  Widget _buildExpenseTile(Gasto gasto) {
    final visuals = _getCategoryVisuals(gasto.categoria);
    final IconData icon = visuals['icon'];
    final Color color = visuals['color'];

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        title: Text(gasto.categoria, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(gasto.descripcion ?? 'Sin descripción', style: const TextStyle(color: AppColors.secondaryText)),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "\$${gasto.cantidad.toStringAsFixed(2)}",
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, color: AppColors.red, size: 22),
              onPressed: () {
                // TODO: Lógica para borrar gasto
              },
            ),
          ],
        ),
      ),
    );
  }
}