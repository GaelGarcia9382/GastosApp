import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
// ➡️ Asegúrate de que esta ruta sea correcta para tu modelo
import 'package:gastos/data/gasto.dart';

class GastoStorageService {
  static const String _gastosKey = 'lista_gastos';

  // --- LÓGICA DE LECTURA (R de CRUD) ---
  Future<List<Gasto>> getGastos() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? gastosJsonString = prefs.getString(_gastosKey);

    if (gastosJsonString == null) {
      return [];
    }

    final List<dynamic> gastosJsonList = json.decode(gastosJsonString);

    return gastosJsonList.map((jsonMap) => Gasto.fromJson(jsonMap)).toList();
  }

  // --- LÓGICA DE CREACIÓN (C de CRUD) ---
  Future<void> addGasto(Gasto nuevoGasto) async {
    List<Gasto> gastos = await getGastos();

    // Asignar un ID único
    final int newId = gastos.isEmpty
        ? 1
        : (gastos.map((g) => g.id ?? 0).reduce((a, b) => a > b ? a : b)) + 1;

    final gastoConId = nuevoGasto.copyWith(id: newId);

    // Añadir el nuevo gasto a la lista
    gastos.add(gastoConId);

    // Codificar y guardar la nueva lista completa
    final List<Map<String, dynamic>> gastosJsonList =
    gastos.map((gasto) => gasto.toJson()).toList();

    final String gastosJsonString = json.encode(gastosJsonList);

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_gastosKey, gastosJsonString);
  }

// (Aquí se añadirán las funciones de Actualizar y Eliminar)
}