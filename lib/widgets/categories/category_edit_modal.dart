import 'package:flutter/material.dart';
import 'package:gastos/constants/app_colors.dart';

class CategoryEditModal extends StatefulWidget {
  final Map<String, dynamic>? category; // null si es "Crear", con datos si es "Editar"
  final Function(String nombre, IconData icono, Color color) onSave;

  const CategoryEditModal({
    super.key,
    this.category,
    required this.onSave,
  });

  @override
  State<CategoryEditModal> createState() => _CategoryEditModalState();
}

class _CategoryEditModalState extends State<CategoryEditModal> {
  late TextEditingController _nameController;
  late IconData _selectedIcon;
  late Color _selectedColor;

  // Lista de iconos de ejemplo (deberían coincidir con tu app)
  final List<IconData> _icons = [
    Icons.restaurant, Icons.directions_car, Icons.videogame_asset, Icons.medical_services,
    Icons.school, Icons.shopping_bag, Icons.home, Icons.flight,
    Icons.movie, Icons.devices, Icons.shopping_cart, Icons.build,
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.category?['nombre'] ?? '');
    _selectedIcon = widget.category?['icono'] ?? _icons.first;
    _selectedColor = widget.category?['color'] ?? AppColors.categoryColors.first;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isCreating = widget.category == null;

    return Dialog(
      backgroundColor: AppColors.background,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Encabezado
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    isCreating ? "Crear Categoría" : "Editar Categoría",
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: AppColors.secondaryText),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Nombre
              const Text("Nombre", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  hintText: "Nombre de la categoría",
                  filled: true,
                  fillColor: AppColors.cardBackground,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Icono
              const Text("Icono", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              const SizedBox(height: 10),
              _buildIconGrid(),

              const SizedBox(height: 20),

              // Color
              const Text("Color", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              const SizedBox(height: 10),
              _buildColorGrid(),

              const SizedBox(height: 20),

              // Vista Previa
              const Text("Vista Previa", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              const SizedBox(height: 10),
              _buildPreview(),

              const SizedBox(height: 30),

              // Botones de Acción
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text("Cancelar", style: TextStyle(color: AppColors.secondaryText)),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: () {
                      if (_nameController.text.isNotEmpty) {
                        widget.onSave(
                          _nameController.text,
                          _selectedIcon,
                          _selectedColor,
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accentBrown,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(isCreating ? "Crear" : "Guardar"),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIconGrid() {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      height: 150, // Altura fija para el grid de iconos
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 6,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
        ),
        itemCount: _icons.length,
        itemBuilder: (context, index) {
          final icon = _icons[index];
          final isSelected = _selectedIcon == icon;
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedIcon = icon;
              });
            },
            child: Container(
              decoration: BoxDecoration(
                color: isSelected ? _selectedColor : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
                border: isSelected ? Border.all(color: Colors.white, width: 2) : null,
              ),
              child: Icon(
                icon,
                color: isSelected ? Colors.white : AppColors.secondaryText,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildColorGrid() {
    return SizedBox(
      height: 100, // Altura fija para el grid de colores
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 5,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
        ),
        itemCount: AppColors.categoryColors.length,
        itemBuilder: (context, index) {
          final color = AppColors.categoryColors[index];
          final isSelected = _selectedColor == color;
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedColor = color;
              });
            },
            child: Container(
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(8),
                border: isSelected ? Border.all(color: AppColors.primaryText, width: 3) : null,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPreview() {
    return Card(
      elevation: 0,
      color: Colors.white, // Fondo blanco para la vista previa
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: _selectedColor.withOpacity(0.15),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(_selectedIcon, color: _selectedColor, size: 28),
        ),
        title: Text(
          _nameController.text.isEmpty ? "Nombre" : _nameController.text,
          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}