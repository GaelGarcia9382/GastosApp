import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:gastos/constants/app_colors.dart';
import 'package:gastos/data/gasto.dart';
import 'package:gastos/data/gasto_storage_service.dart';
// ➡️ Importaciones dinámicas
import 'package:gastos/data/category.dart';
import 'package:gastos/data/category_storage_service.dart';

class HistoryScreen extends StatefulWidget {
  final Function? onExpenseChanged;

  const HistoryScreen({
    super.key,
    this.onExpenseChanged,
  });

  @override
  State<HistoryScreen> createState() => HistoryScreenState();
}

class HistoryScreenState extends State<HistoryScreen> {
  final GastoStorageService _storageService = GastoStorageService();
  final CategoryStorageService _categoryService = CategoryStorageService();

  late Future<List<dynamic>> _combinedDataFuture;

  @override
  void initState() {
    super.initState();
    _loadCombinedData();
  }

  void _loadCombinedData() {
    setState(() {
      _combinedDataFuture = Future.wait([
        _storageService.getGastos(),
        _categoryService.getCategories(),
      ]);
    });
  }

  void refreshHistory() {
    _loadCombinedData();
  }

  void _confirmAndDelete(Gasto gasto) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmar Eliminación'),
          content: Text('¿Estás seguro de que deseas eliminar el gasto "${gasto.descripcion ?? gasto.categoria}" de \$${gasto.cantidad.toStringAsFixed(2)}?'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: TextButton.styleFrom(foregroundColor: AppColors.red),
              child: const Text('Eliminar'),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      if (gasto.id != null) {
        await _storageService.deleteGasto(gasto.id!);

        _loadCombinedData();
        widget.onExpenseChanged?.call();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gasto eliminado con éxito.'), backgroundColor: Colors.green),
        );
      }
    }
  }

  // ➡️ Método auxiliar para obtener el visual de la categoría
  Map<String, dynamic> _getCategoryVisuals(String categoryName, Map<String, Category> categoryMap) {
    final Category? cat = categoryMap[categoryName];
    return {
      'icon': cat?.icon ?? Icons.monetization_on,
      'color': cat?.color ?? Colors.grey,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Historial de Gastos')),
      body: FutureBuilder<List<dynamic>>(
        future: _combinedDataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Error al cargar datos: ${snapshot.error}"));
          }

          final List<Gasto> gastos = snapshot.data![0];
          final List<Category> categoriesList = snapshot.data![1];

          final Map<String, Category> categoryMap = {
            for (var cat in categoriesList) cat.nombre: cat
          };

          if (gastos.isEmpty) {
            return const Center(
              child: Text(
                "Aún no tienes gastos registrados.",
                style: TextStyle(fontSize: 16, color: AppColors.secondaryText),
              ),
            );
          }

          gastos.sort((a, b) => b.fecha.compareTo(a.fecha));

          return ListView.builder(
            padding: const EdgeInsets.all(8.0),
            itemCount: gastos.length,
            itemBuilder: (context, index) {
              final gasto = gastos[index];
              return _buildExpenseTile(gasto, categoryMap);
            },
          );
        },
      ),
    );
  }

  Widget _buildExpenseTile(Gasto gasto, Map<String, Category> categoryMap) {
    final String formattedDate = DateFormat('dd MMM yyyy - HH:mm').format(gasto.fecha);

    final visuals = _getCategoryVisuals(gasto.categoria, categoryMap);
    final Color categoryColor = visuals['color'];
    final IconData categoryIcon = visuals['icon'];


    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(
          categoryIcon, // ⬅️ Usar el ícono real
          color: categoryColor,
        ),

        // 📝 Título: Muestra la descripción si existe, sino la categoría
        title: Text(
          gasto.descripcion != null && gasto.descripcion!.isNotEmpty
              ? gasto.descripcion!
              : gasto.categoria,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(formattedDate),
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
                _confirmAndDelete(gasto);
              },
            ),
          ],
        ),
      ),
    );
  }
}