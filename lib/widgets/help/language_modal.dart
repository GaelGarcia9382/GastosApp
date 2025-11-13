import 'package:flutter/material.dart';
import 'package:gastos/constants/app_colors.dart';

class LanguageModal extends StatefulWidget {
  const LanguageModal({super.key});

  @override
  State<LanguageModal> createState() => _LanguageModalState();
}

class _LanguageModalState extends State<LanguageModal> {
  String _selectedLanguage = 'es_LA'; // Valor inicial

  final Map<String, String> languages = {
    'en': 'English',
    'ja': '日本語',
    'fr': 'Français',
    'de': 'Deutsch',
    'es_ES': 'Español (España)',
    'es_LA': 'Español (Latinoamérica)',
    'ko': '한국어',
    'pt_BR': 'Português (Brasil)',
  };

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.background,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text("Cambiar idioma"),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: languages.entries.map((entry) {
              return RadioListTile<String>(
                title: Text(entry.value),
                value: entry.key,
                groupValue: _selectedLanguage,
                onChanged: (value) {
                  setState(() {
                    _selectedLanguage = value!;
                  });
                },
                activeColor: AppColors.accentBrown,
              );
            }).toList(),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text("Cancelar", style: TextStyle(color: AppColors.secondaryText)),
        ),
        ElevatedButton(
          onPressed: () {
            // Lógica para guardar el idioma
            Navigator.of(context).pop();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.accentBrown,
            foregroundColor: Colors.white,
          ),
          child: const Text("Guardar"),
        ),
      ],
    );
  }
}