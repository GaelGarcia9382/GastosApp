import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:gastos/constants/app_colors.dart';
import 'package:gastos/data/gasto.dart';
import 'package:gastos/data/gasto_storage_service.dart';

class NewExpenseScreen extends StatefulWidget {
  final ScrollController? scrollController;
  const NewExpenseScreen({super.key, this.scrollController});

  @override
  State<NewExpenseScreen> createState() => _NewExpenseScreenState();
}

class _NewExpenseScreenState extends State<NewExpenseScreen> {
  // Controladores para capturar los datos
  final TextEditingController _cantidadController = TextEditingController();
  final TextEditingController _descripcionController = TextEditingController();

  final GastoStorageService _storageService = GastoStorageService();

  DateTime _selectedDate = DateTime.now();
  String? _selectedCategory;

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
      locale: const Locale('es', 'ES'),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _saveExpense() async {
    final cantidadText = _cantidadController.text.replaceAll(',', '.');
    final descripcionText = _descripcionController.text.trim();

    final double? cantidad = double.tryParse(cantidadText);

    if (cantidad == null || cantidad <= 0) {
      _showSnackBar("Por favor, ingresa una cantidad válida.", Colors.red);
      return;
    }
    if (_selectedCategory == null) {
      _showSnackBar("Por favor, selecciona una categoría.", Colors.red);
      return;
    }

    final newGasto = Gasto(
      cantidad: cantidad,
      categoria: _selectedCategory!,
      fecha: _selectedDate,
      descripcion: descripcionText.isNotEmpty ? descripcionText : null,
    );

    await _storageService.addGasto(newGasto);

    _showSnackBar("Gasto de \$${cantidad.toStringAsFixed(2)} agregado con éxito.", Colors.green);

    // ➡️ ESTE ES EL PASO CLAVE: Cerramos y enviamos 'true'
    Navigator.of(context).pop(true);
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
      ),
    );
  }

  @override
  void dispose() {
    _cantidadController.dispose();
    _descripcionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      controller: widget.scrollController,
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
          _buildTextField("Cantidad", "0.00", keyboardType: TextInputType.number, controller: _cantidadController),
          const SizedBox(height: 20),
          const Text("Categoría", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 10),
          _buildCategoryGrid(),
          const SizedBox(height: 20),
          _buildDateField(),
          const SizedBox(height: 20),
          _buildTextField("Descripción (opcional)", "Agrega una nota sobre este gasto...", maxLines: 3, controller: _descripcionController),
          const SizedBox(height: 30),

          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: _saveExpense,
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: AppColors.cardBackground,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                "Agregar Gasto",
                style: TextStyle(
                  color: AppColors.secondaryText,
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

  Widget _buildTextField(String label, String hint, {int maxLines = 1, TextInputType keyboardType = TextInputType.text, TextEditingController? controller}) {
    // ... (Método sin cambios en la lógica interna)
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
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
    // ... (Método sin cambios)
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Fecha", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
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
                  DateFormat.yMd('es_ES').format(_selectedDate),
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
    // ... (Método sin cambios)
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 3.5,
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