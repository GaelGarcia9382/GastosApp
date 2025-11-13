import 'package:flutter/material.dart';
import 'package:gastos/constants/app_colors.dart';
import 'package:gastos/widgets/categories/category_edit_modal.dart';
import 'package:gastos/widgets/common/help_button.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  // Datos de ejemplo
  final List<Map<String, dynamic>> _categories = [
    { 'nombre': 'Alimentación', 'icono': Icons.restaurant, 'color': AppColors.orange },
    { 'nombre': 'Transporte', 'icono': Icons.directions_car, 'color': AppColors.blue },
    { 'nombre': 'Entretenimiento', 'icono': Icons.videogame_asset, 'color': AppColors.purple },
    { 'nombre': 'Salud', 'icono': Icons.medical_services, 'color': AppColors.red },
    { 'nombre': 'Educación', 'icono': Icons.school, 'color': AppColors.green },
  ];

  void _showCategoryModal({Map<String, dynamic>? category}) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return CategoryEditModal(
          category: category,
          onSave: (String nombre, IconData icono, Color color) {
            // Aquí irá la lógica para guardar (Crear o Editar)
            if (category == null) {
              // Lógica de Crear
              setState(() {
                _categories.add({'nombre': nombre, 'icono': icono, 'color': color});
              });
            } else {
              // Lógica de Editar
              setState(() {
                // Aquí buscarías la categoría por ID y la actualizarías
                final index = _categories.indexWhere((c) => c['nombre'] == category['nombre']);
                if (index != -1) {
                  _categories[index] = {'nombre': nombre, 'icono': icono, 'color': color};
                }
              });
            }
            Navigator.of(context).pop();
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Categorías"),
        actions: [
          // Botón de Añadir (+)
          IconButton(
            icon: const Icon(Icons.add_circle_outline, color: AppColors.primaryText, size: 28),
            onPressed: () {
              _showCategoryModal(); // Llamar sin categoría para "Crear"
            },
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: Stack( // Envolver con Stack
        children: [
          ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 100), // Padding inferior
            itemCount: _categories.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final category = _categories[index];
              return _buildCategoryTile(
                category['nombre'],
                category['icono'],
                category['color'],
                onEdit: () {
                  _showCategoryModal(category: category); // Llamar con categoría para "Editar"
                },
                onDelete: () {
                  // Lógica para eliminar
                  setState(() {
                    _categories.removeAt(index);
                  });
                },
              );
            },
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

  Widget _buildCategoryTile(String nombre, IconData icono, Color color, {required VoidCallback onEdit, required VoidCallback onDelete}) {
    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icono, color: color, size: 28),
        ),
        title: Text(
          nombre,
          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit_outlined, color: AppColors.secondaryText, size: 22),
              onPressed: onEdit,
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, color: AppColors.red, size: 22),
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }
}