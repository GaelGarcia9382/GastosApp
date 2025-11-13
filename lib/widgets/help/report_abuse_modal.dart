import 'package:flutter/material.dart';
import 'package:gastos/constants/app_colors.dart';

class ReportAbuseModal extends StatefulWidget {
  const ReportAbuseModal({super.key});

  @override
  State<ReportAbuseModal> createState() => _ReportAbuseModalState();
}

class _ReportAbuseModalState extends State<ReportAbuseModal> {
  String? _selectedCategory;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.background,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text("Denunciar abuso"),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Todos los campos marcados con * son obligatorios",
            style: TextStyle(color: AppColors.secondaryText, fontSize: 14),
          ),
          const SizedBox(height: 20),
          const Text(
            "Tipo de incidencia con el contenido *",
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              borderRadius: BorderRadius.circular(12),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedCategory,
                hint: const Text("Selecciona una categoría"),
                isExpanded: true,
                items: const [
                  DropdownMenuItem(value: 'spam', child: Text("Spam o contenido comercial")),
                  DropdownMenuItem(value: 'odio', child: Text("Lenguaje de odio")),
                  DropdownMenuItem(value: 'acoso', child: Text("Acoso")),
                  DropdownMenuItem(value: 'otro', child: Text("Otro")),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedCategory = value;
                  });
                },
              ),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text("Cancelar", style: TextStyle(color: AppColors.secondaryText)),
        ),
        ElevatedButton(
          onPressed: _selectedCategory == null ? null : () {
            // Lógica para enviar denuncia
            Navigator.of(context).pop();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.accentBrown,
            foregroundColor: Colors.white,
          ),
          child: const Text("Enviar"),
        ),
      ],
    );
  }
}