import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:gastos/constants/app_colors.dart';
import 'package:gastos/data/gasto.dart'; // Asegúrate de que esta ruta esté actualizada
import 'package:gastos/data/gasto_storage_service.dart'; // Asegúrate de que esta ruta esté actualizada

// ➡️ Importar el servicio y modelo de Categoría
import 'package:gastos/data/category.dart';
import 'package:gastos/data/category_storage_service.dart';

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
  final CategoryStorageService _categoryService = CategoryStorageService(); // ⬅️ Nuevo Servicio

  DateTime _selectedDate = DateTime.now();
  Category? _selectedCategory; // ⬅️ Ahora almacena el objeto Category completo

  late Future<List<Category>> _categoriesFuture; // ⬅️ Future para categorías

  @override
  void initState() {
    super.initState();
    _categoriesFuture = _categoryService.getCategories(); // Cargar categorías al inicio
  }

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
      categoria: _selectedCategory!.nombre, // ⬅️ Usamos el nombre del objeto Category
      fecha: _selectedDate,
      descripcion: descripcionText.isNotEmpty ? descripcionText : null,
    );

    await _storageService.addGasto(newGasto);

    _showSnackBar("Gasto de \$${cantidad.toStringAsFixed(2)} agregado con éxito.", Colors.green);

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

          // ➡️ Selector de Categoría (Ahora usa FutureBuilder)
          const Text("Categoría", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 10),
          FutureBuilder<List<Category>>(
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
                return const Text("No hay categorías disponibles. Crea una en la pestaña 'Categorías'.");
              }

              // ➡️ Contruir el Grid de Categorías con datos dinámicos
              return _buildCategoryGrid(categories);
            },
          ),

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

  // ➡️ Reemplazo de _buildCategoryGrid para aceptar la lista Category
  Widget _buildCategoryGrid(List<Category> categories) {
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
        final category = categories[index];
        // Comparamos por ID para mantener la selección
        final isSelected = _selectedCategory?.id == category.id;

        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedCategory = category;
            });
          },
          child: Container(
            decoration: BoxDecoration(
              // Usar el color dinámico de la categoría
              color: isSelected ? category.color.withOpacity(0.15) : AppColors.cardBackground,
              borderRadius: BorderRadius.circular(12),
              border: isSelected ? Border.all(color: category.color, width: 2) : null,
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
                  child: Icon(category.icon, color: category.color), // ⬅️ Usar IconData y Color dinámicos
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    category.nombre,
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

  Widget _buildTextField(String label, String hint, {int maxLines = 1, TextInputType keyboardType = TextInputType.text, TextEditingController? controller}) {
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
}