// En lib/services/category_storage_service.dart (Nuevo Archivo)
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:gastos/data/category.dart';

class CategoryStorageService {
  static const String _categoriesKey = 'lista_categorias';

  Future<List<Category>> getCategories() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? jsonString = prefs.getString(_categoriesKey);

    if (jsonString == null) return [];

    final List<dynamic> jsonList = json.decode(jsonString);
    return jsonList.map((jsonMap) => Category.fromJson(jsonMap)).toList();
  }

  // CREAR / ACTUALIZAR
  Future<void> saveCategory(Category category) async {
    List<Category> categories = await getCategories();

    if (category.id == null) {
      // ➡️ CREAR: Asignar nuevo ID y añadir
      final int newId = categories.isEmpty
          ? 1
          : (categories.map((c) => c.id ?? 0).reduce((a, b) => a > b ? a : b)) + 1;
      final newCategory = category.copyWith(id: newId);
      categories.add(newCategory);

    } else {
      // ➡️ ACTUALIZAR: Buscar por ID y reemplazar
      final index = categories.indexWhere((c) => c.id == category.id);
      if (index != -1) {
        categories[index] = category;
      }
    }

    // Codificar y guardar la lista completa
    final List<Map<String, dynamic>> jsonList =
    categories.map((c) => c.toJson()).toList();
    final String jsonString = json.encode(jsonList);

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_categoriesKey, jsonString);
  }

  // ELIMINAR
  Future<void> deleteCategory(int id) async {
    List<Category> categories = await getCategories();
    categories.removeWhere((c) => c.id == id);

    final List<Map<String, dynamic>> jsonList =
    categories.map((c) => c.toJson()).toList();
    final String jsonString = json.encode(jsonList);

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_categoriesKey, jsonString);
  }
}