import 'package:flutter/material.dart';
import 'package:gastos/constants/app_colors.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isDarkMode = true; // Basado en tu diseño que dice "Oscuro"
  String _selectedCurrency = "\$ Peso Mexicano (MXN)";
  final List<String> _currencies = [
    "\$ Dólar (USD)",
    "€ Euro (EUR)",
    "\$ Peso Mexicano (MXN)",
    "\$ Peso Argentino (ARS)",
    "\$ Peso Colombiano (COP)",
    "\$ Peso Chileno (CLP)",
  ];
  final TextEditingController _budgetController = TextEditingController(text: "1000");

  @override
  void dispose() {
    _budgetController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Ajustes"),
        actions: const [
          SizedBox(width: 10),
        ],
      ),
      body: Stack( // Envolver con Stack
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 100), // Padding inferior
            child: Column(
              children: [
                _buildThemeOption(),
                const Divider(height: 30),
                _buildCurrencyOption(),
                const Divider(height: 30),
                _buildBudgetOption(),
                const Divider(height: 30),
                _buildSerenityTip(),
                const SizedBox(height: 40),
                _buildAppInfo(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThemeOption() {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: const Icon(Icons.palette_outlined, size: 28),
      title: const Text("Tema", style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
      subtitle: Text(_isDarkMode ? "Oscuro" : "Claro", style: const TextStyle(color: AppColors.secondaryText)),
      trailing: Switch(
        value: _isDarkMode,
        onChanged: (value) {
          setState(() {
            _isDarkMode = value;
          });
          // Aquí iría la lógica para cambiar el tema de la app
        },
        activeColor: AppColors.accentBrown,
      ),
    );
  }

  Widget _buildCurrencyOption() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.attach_money, size: 28),
          title: const Text("Moneda", style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
          subtitle: const Text("Selecciona tu moneda principal", style: const TextStyle(color: AppColors.secondaryText)),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(12),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedCurrency,
              isExpanded: true,
              icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.secondaryText),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedCurrency = newValue!;
                });
              },
              items: _currencies.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBudgetOption() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.track_changes_outlined, size: 28),
          title: const Text("Presupuesto Mensual", style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
          subtitle: const Text("Define tu meta mensual", style: const TextStyle(color: AppColors.secondaryText)),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _budgetController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            prefixText: "\$ ",
            hintText: "1000.00",
            filled: true,
            fillColor: AppColors.cardBackground,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSerenityTip() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            const Icon(Icons.lightbulb_outline, color: AppColors.orange, size: 30),
            const SizedBox(width: 12),
            Expanded(
              child: RichText(
                text: const TextSpan(
                  style: TextStyle(fontFamily: 'Lato', color: AppColors.secondaryText, fontSize: 14, height: 1.4),
                  children: [
                    TextSpan(text: "Consejo de Serenidad: ", style: TextStyle(fontWeight: FontWeight.bold)),
                    TextSpan(text: "El manejo consciente de tus finanzas es una práctica de autocuidado. Tómate un momento cada día para revisar tus gastos con calma y sin juicio."),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppInfo() {
    return Column(
      children: [
        const Icon(Icons.savings_outlined, color: AppColors.orange, size: 50),
        const SizedBox(height: 12),
        const Text(
          "Serenidad Financiera",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        const Text(
          "Tu camino hacia la paz financiera",
          style: TextStyle(color: AppColors.secondaryText, fontSize: 14),
        ),
        const SizedBox(height: 8),
        const Text(
          "Versión 1.0.0",
          style: TextStyle(color: AppColors.secondaryText, fontSize: 12),
        ),
      ],
    );
  }
}