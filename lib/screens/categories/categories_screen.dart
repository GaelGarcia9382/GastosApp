import 'package:flutter/material.dart';
import 'package:gastos/constants/app_colors.dart';
import 'package:gastos/widgets/categories/category_edit_modal.dart';
import 'package:gastos/data/category.dart';
import 'package:gastos/data/category_storage_service.dart';

class CategoriesScreen extends StatefulWidget {
  final Function? onCategoriesChanged;

  const CategoriesScreen({super.key, this.onCategoriesChanged});

  @override
  // ➡️ CAMBIO: Usar el estado público
  State<CategoriesScreen> createState() => CategoriesScreenState();
}

// ➡️ CLASE DE ESTADO PÚBLICA
class CategoriesScreenState extends State<CategoriesScreen> {
  final CategoryStorageService _storageService = CategoryStorageService();
  late Future<List<Category>> _categoriesFuture;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  // Método público para el refresco global
  void refreshCategories() {
    _loadCategories();
  }

  void _loadCategories() {
    setState(() {
      _categoriesFuture = _storageService.getCategories();
    });
    // Notificamos a la navegación principal para refrescar HOME y HISTORIAL
    widget.onCategoriesChanged?.call();
  }

  // Lógica para guardar (Crear o Editar)
  void _showCategoryModal({Category? category}) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return CategoryEditModal(
          category: category != null ? {
            'nombre': category.nombre,
            'icono': category.icon,
            'color': category.color,
          } : null,
          onSave: (String nombre, IconData icono, Color color) async {
            final newCategory = Category(
              id: category?.id,
              nombre: nombre,
              iconCodePoint: icono.codePoint,
              colorValue: color.value,
            );

            await _storageService.saveCategory(newCategory);

            _loadCategories();
            Navigator.of(context).pop();
          },
        );
      },
    );
  }

  // Lógica para eliminar
  void _deleteCategory(Category category) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Categoría'),
        content: Text('¿Seguro que quieres eliminar la categoría "${category.nombre}"? Esto no eliminará los gastos ya registrados.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Eliminar', style: TextStyle(color: AppColors.red))),
        ],
      ),
    ) ?? false;

    if (confirmed && category.id != null) {
      await _storageService.deleteCategory(category.id!);
      _loadCategories();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Categorías"),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline, color: AppColors.primaryText, size: 28),
            onPressed: () => _showCategoryModal(),
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: FutureBuilder<List<Category>>(
        future: _categoriesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text("Error al cargar categorías: ${snapshot.error}"));
          }

          final List<Category> categories = snapshot.data ?? [];
          if (categories.isEmpty) {
            return const Center(child: Text("Aún no tienes categorías. ¡Crea una!"));
          }

          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
            itemCount: categories.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final category = categories[index];
              return _buildCategoryTile(
                category.nombre,
                category.icon,
                category.color,
                onEdit: () => _showCategoryModal(category: category),
                onDelete: () => _deleteCategory(category),
              );
            },
          );
        },
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