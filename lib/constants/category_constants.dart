// En lib/constants/category_constants.dart (Nuevo Archivo)
import 'package:flutter/material.dart';
import 'package:gastos/constants/app_colors.dart';

// Mapeo centralizado de categoría a ícono y color
const Map<String, Map<String, dynamic>> categoryVisualsMap = {
  'Alimentación': {'icon': Icons.restaurant, 'color': AppColors.red},
  'Transporte': {'icon': Icons.directions_car, 'color': AppColors.blue},
  'Entretenimiento': {'icon': Icons.videogame_asset, 'color': AppColors.purple},
  'Salud': {'icon': Icons.medical_services, 'color': AppColors.green},
  'Educación': {'icon': Icons.school, 'color': AppColors.yellow},
  'Compras': {'icon': Icons.shopping_bag, 'color': AppColors.orange},
};

// Función de ayuda para obtener el color
Color getColorForCategory(String categoryName) {
  // Retorna el color específico o gris por defecto si no se encuentra
  return categoryVisualsMap[categoryName]?['color'] ?? Colors.grey;
}

// Función de ayuda para obtener el ícono
IconData getIconForCategory(String categoryName) {
  // Retorna el ícono específico o uno por defecto
  return categoryVisualsMap[categoryName]?['icon'] ?? Icons.monetization_on;
}