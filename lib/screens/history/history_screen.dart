import 'dart:convert'; // Necesario para GastoStorageService, asegúrate de que esté
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Necesario
import 'package:gastos/constants/app_colors.dart';
import 'package:gastos/data/gasto.dart'; // Asegúrate de tener tu modelo Gasto
import 'package:gastos/data/gasto_storage_service.dart'; // Asegúrate de tener tu servicio
import 'package:gastos/constants/category_constants.dart';

class HistoryScreen extends StatefulWidget {

  // ➡️ CALLBACK PARA NOTIFICAR AL PADRE SOBRE CAMBIOS (Eliminación)
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
  late Future<List<Gasto>> _gastosFuture;

  @override
  void initState() {
    super.initState();
    _loadGastos();
  }

  // Método público para ser llamado desde MainNavigationScreen
  void refreshHistory() {
    _loadGastos();
  }

  void _loadGastos() {
    setState(() {
      _gastosFuture = _storageService.getGastos();
    });
  }

  // ➡️ FUNCIÓN PARA CONFIRMAR Y ELIMINAR EL GASTO
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

        // 1. Forzar el refresco de la pantalla de historial
        _loadGastos();

        // 2. ➡️ NOTIFICAR AL PADRE (MainNavigationScreen)
        widget.onExpenseChanged?.call();

        // 3. Mostrar un mensaje de éxito
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gasto eliminado con éxito.'), backgroundColor: Colors.green),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Historial de Gastos'),
      ),
      body: FutureBuilder<List<Gasto>>(
        future: _gastosFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text("Error al cargar datos: ${snapshot.error}"));
          }

          final List<Gasto> gastos = snapshot.data ?? [];

          if (gastos.isEmpty) {
            return const Center(
              child: Text(
                "Aún no tienes gastos registrados.",
                style: TextStyle(fontSize: 16, color: AppColors.secondaryText),
              ),
            );
          }

          // Ordenar por fecha descendente
          gastos.sort((a, b) => b.fecha.compareTo(a.fecha));

          return ListView.builder(
            padding: const EdgeInsets.all(8.0),
            itemCount: gastos.length,
            itemBuilder: (context, index) {
              final gasto = gastos[index];
              return _buildExpenseTile(gasto);
            },
          );
        },
      ),
    );
  }

  // ➡️ MÉTODO DE CONSTRUCCIÓN CORREGIDO PARA MOSTRAR DETALLES
  Widget _buildExpenseTile(Gasto gasto) {
    final String formattedDate = DateFormat('dd MMM yyyy - HH:mm').format(gasto.fecha);

    // ➡️ CORRECCIÓN DEL ERROR: Usar la función importada
    final Color categoryColor = getColorForCategory(gasto.categoria);
    final IconData categoryIcon = getIconForCategory(gasto.categoria);


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

        // 🕑 Subtítulo: Muestra la fecha y hora
        subtitle: Text(formattedDate),

        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "\$${gasto.cantidad.toStringAsFixed(2)}",
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            // Botón de eliminar
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

// ⚠️ NOTA IMPORTANTE:
// Si tu archivo GastoStorageService.dart no tiene el método deleteGasto,
// asegúrate de que se vea así:

// // En GastoStorageService.dart
// Future<void> deleteGasto(int id) async {
//     List<Gasto> gastos = await getGastos();
//     gastos = gastos.where((gasto) => gasto.id != id).toList();
//     final List<Map<String, dynamic>> gastosJsonList = gastos.map((gasto) => gasto.toJson()).toList();
//     final String gastosJsonString = json.encode(gastosJsonList);
//     final SharedPreferences prefs = await SharedPreferences.getInstance();
//     await prefs.setString(_gastosKey, gastosJsonString);
// }