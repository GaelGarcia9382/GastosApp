import 'package:flutter/material.dart';
import 'package:gastos/constants/app_colors.dart';

class KeyboardModal extends StatefulWidget {
  const KeyboardModal({super.key});

  @override
  State<KeyboardModal> createState() => _KeyboardModalState();
}

class _KeyboardModalState extends State<KeyboardModal> {
  String _selectedLayout = 'es_LA'; // Valor inicial

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.background,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text("Disposición del teclado"),
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
          const Text("Disposición del teclado:"),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              borderRadius: BorderRadius.circular(12),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedLayout,
                isExpanded: true,
                items: const [
                  DropdownMenuItem(value: 'es_LA', child: Text("Español (Latinoamérica)")),
                  DropdownMenuItem(value: 'en_US', child: Text("English (US)")),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedLayout = value!;
                  });
                },
              ),
            ),
          ),
          const SizedBox(height: 15),
          const Text(
            "Los atajos de teclado no cambiarán automáticamente.",
            style: TextStyle(color: AppColors.secondaryText, fontSize: 14),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text("Cerrar", style: TextStyle(color: AppColors.secondaryText)),
        ),
      ],
    );
  }
}