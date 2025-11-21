// En lib/models/category.dart (Nuevo Archivo)
import 'package:flutter/material.dart';

class Category {
  int? id;
  String nombre;
  int iconCodePoint; // Guardamos el código del icono
  int colorValue;    // Guardamos el valor entero del Color (hex)

  Category({
    this.id,
    required this.nombre,
    required this.iconCodePoint,
    required this.colorValue,
  });

  // Constructor de ayuda para usar con IconData y Color
  IconData get icon => IconData(iconCodePoint, fontFamily: 'MaterialIcons');
  Color get color => Color(colorValue);

  // Método para convertir a Map (para almacenamiento JSON)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'iconCodePoint': iconCodePoint,
      'colorValue': colorValue,
    };
  }

  // Factory para crear desde Map (al cargar desde JSON)
  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'],
      nombre: json['nombre'],
      iconCodePoint: json['iconCodePoint'],
      colorValue: json['colorValue'],
    );
  }

  // Método para facilitar la actualización
  Category copyWith({
    int? id,
    String? nombre,
    int? iconCodePoint,
    int? colorValue,
  }) {
    return Category(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      iconCodePoint: iconCodePoint ?? this.iconCodePoint,
      colorValue: colorValue ?? this.colorValue,
    );
  }
}