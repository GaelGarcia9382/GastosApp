import 'package:flutter/material.dart';
import 'package:gastos/constants/app_colors.dart';
import 'package:gastos/widgets/common/help_button.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  String _selectedCategory = "Todas las categorías";
  String _selectedMonth = "Noviembre de 2025";

  // Datos de ejemplo
  final List<String> _categories = ["Todas las categorías", "Alimentación", "Transporte", "Entretenimiento", "Salud", "Educación"];
  final List<String> _months = ["Todos los meses", "Noviembre de 2025", "Octubre 2025", "Septiembre 2025"];

  final List<Map<String, dynamic>> _expenses = [
    {
      'fecha': 'Martes, 11 de Noviembre de 2025',
      'items': [
        {'nombre': 'Gato nuevo', 'categoria': 'Educación', 'monto': 100.00, 'icono': Icons.school, 'color': AppColors.green},
        {'nombre': 'Fortnite', 'categoria': 'Entretenimiento', 'monto': 20.00, 'icono': Icons.videogame_asset, 'color': AppColors.purple},
      ],
      'total': 120.00
    },
    // Puedes agregar más días...
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Historial"),
        actions: [
          // Botón de Filtro
          IconButton(
            icon: const Icon(Icons.filter_list, color: AppColors.primaryText, size: 28),
            onPressed: () {
              // Lógica para mostrar/ocultar filtros
            },
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: Stack( // Envolver con Stack
        children: [
          CustomScrollView(
            slivers: [
              // Filtros
              SliverToBoxAdapter(
                child: _buildFilters(),
              ),

              // Lista de Gastos Agrupados por Día
              SliverList.builder(
                itemCount: _expenses.length,
                itemBuilder: (context, index) {
                  final dayData = _expenses[index];
                  return _buildDayGroup(dayData);
                },
              ),
              // Espaciador para que el botón flotante no tape contenido
              const SliverToBoxAdapter(
                child: SizedBox(height: 100),
              ),
            ],
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

  Widget _buildDayGroup(Map<String, dynamic> dayData) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Encabezado del día (Total y Fecha)
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
                        "\$${dayData['total'].toStringAsFixed(2)}",
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text("Gastos: ${dayData['items'].length}", style: const TextStyle(color: AppColors.secondaryText, fontSize: 14)),
                      Text(
                        dayData['fecha'],
                        style: const TextStyle(color: AppColors.secondaryText, fontSize: 14, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          // Lista de gastos de ese día
          ...List.generate(dayData['items'].length, (index) {
            final item = dayData['items'][index];
            return _buildExpenseTile(item);
          }),
        ],
      ),
    );
  }

  Widget _buildExpenseTile(Map<String, dynamic> item) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: (item['color'] as Color).withOpacity(0.15),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(item['icono'], color: item['color'], size: 24),
        ),
        title: Text(item['categoria'], style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(item['nombre'], style: const TextStyle(color: AppColors.secondaryText)),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "\$${item['monto'].toStringAsFixed(2)}",
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, color: AppColors.red, size: 22),
              onPressed: () {
                // Lógica para borrar gasto
              },
            ),
          ],
        ),
      ),
    );
  }
}