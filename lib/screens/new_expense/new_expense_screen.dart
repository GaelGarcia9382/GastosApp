import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:gastos/constants/app_colors.dart';

class NewExpenseScreen extends StatefulWidget {
  // El ScrollController es para que el modal funcione bien
  final ScrollController? scrollController;

  const NewExpenseScreen({super.key, this.scrollController});

  @override
  State<NewExpenseScreen> createState() => _NewExpenseScreenState();
}

class _NewExpenseScreenState extends State<NewExpenseScreen> {
  DateTime _selectedDate = DateTime(2025, 11, 12);
  String? _selectedCategory; // Nombre de la categoría seleccionada

  // Datos de ejemplo para las categorías
  final Map<String, IconData> categories = {
    'Alimentación': Icons.restaurant,
    'Transporte': Icons.directions_car,
    'Entretenimiento': Icons.videogame_asset,
    'Salud': Icons.medical_services,
    'Educación': Icons.school,
    'Compras': Icons.shopping_bag,
  };

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      locale: const Locale('es', 'ES'), // Para que el DatePicker salga en español
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      controller: widget.scrollController,
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Encabezado con título y botón de cerrar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Nuevo Gasto",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryText,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, color: AppColors.secondaryText),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Formulario
          _buildTextField("Cantidad", "0.00", keyboardType: TextInputType.number),
          const SizedBox(height: 20),

          // Selector de Categoría
          const Text("Categoría", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 10),
          _buildCategoryGrid(),

          const SizedBox(height: 20),

          // Selector de Fecha
          _buildDateField(),
          const SizedBox(height: 20),

          // Descripción
          _buildTextField("Descripción (opcional)", "Agrega una nota sobre este gasto...", maxLines: 3),
          const SizedBox(height: 30),

          // Botón de Agregar Gasto
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: () {
                // Lógica para agregar gasto
                Navigator.of(context).pop(); // Cierra el modal
              },
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: AppColors.cardBackground, // Como en el diseño
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                "Agregar Gasto",
                style: TextStyle(
                  color: AppColors.secondaryText, // Color tenue como en el diseño
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(String label, String hint, {int maxLines = 1, TextInputType keyboardType = TextInputType.text}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        TextField(
          keyboardType: keyboardType,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: AppColors.secondaryText),
            filled: true,
            fillColor: AppColors.cardBackground,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.all(16),
          ),
        ),
      ],
    );
  }

  Widget _buildDateField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Fecha", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () => _selectDate(context),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  DateFormat.yMd('es_ES').format(_selectedDate), // Formato 12/11/2025
                  style: const TextStyle(fontSize: 16),
                ),
                const Icon(Icons.calendar_today, color: AppColors.secondaryText),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryGrid() {
    // Usamos GridView.builder para un grid dinámico
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, // Dos columnas como en el diseño
        childAspectRatio: 3.5, // Ancho > Alto
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final categoryName = categories.keys.elementAt(index);
        final categoryIcon = categories.values.elementAt(index);
        final isSelected = _selectedCategory == categoryName;

        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedCategory = categoryName;
            });
          },
          child: Container(
            decoration: BoxDecoration(
              color: isSelected ? AppColors.accentLightBrown.withOpacity(0.5) : AppColors.cardBackground,
              borderRadius: BorderRadius.circular(12),
              border: isSelected ? Border.all(color: AppColors.accentBrown, width: 2) : null,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Container(
                  margin: const EdgeInsets.all(8),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.white : AppColors.background,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(categoryIcon, color: AppColors.accentBrown),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    categoryName,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}