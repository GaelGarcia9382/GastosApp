import 'dart:convert';

class Gasto {
  // CAMPOS DEL MODELO:
  int? id;
  double cantidad;
  String categoria;
  DateTime fecha;
  String? descripcion; // Opcional (nullable)

  Gasto({
    this.id,
    required this.cantidad,
    required this.categoria,
    required this.fecha,
    this.descripcion, // Ya no es 'required'
  });

  // Método para convertir Gasto a un Map (para SharedPreferences/JSON)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'cantidad': cantidad,
      'categoria': categoria,
      'fecha': fecha.toIso8601String(),
      'descripcion': descripcion,
    };
  }

  // Método estático para crear Gasto desde un Map (desde SharedPreferences/JSON)
  factory Gasto.fromJson(Map<String, dynamic> json) {
    return Gasto(
      id: json['id'],
      cantidad: json['cantidad'],
      categoria: json['categoria'],
      fecha: DateTime.parse(json['fecha']),
      descripcion: json['descripcion'],
    );
  }

  // Método copyWith para la función de Actualizar (Update)
  Gasto copyWith({
    int? id,
    double? cantidad,
    String? categoria,
    DateTime? fecha,
    String? descripcion,
  }) {
    return Gasto(
      id: id ?? this.id,
      cantidad: cantidad ?? this.cantidad,
      categoria: categoria ?? this.categoria,
      fecha: fecha ?? this.fecha,
      descripcion: descripcion ?? this.descripcion,
    );
  }
}