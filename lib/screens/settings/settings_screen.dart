import 'package:flutter/material.dart';
import 'package:gastos/constants/app_colors.dart';
// ➡️ Importaciones de Lógica
import 'package:gastos/data/settings_storage_service.dart';

class SettingsScreen extends StatefulWidget {
  final Function? onSettingsChanged;

  const SettingsScreen({super.key, this.onSettingsChanged});

  @override
  // ➡️ CLASE DE ESTADO PÚBLICA
  State<SettingsScreen> createState() => SettingsScreenState();
}

class SettingsScreenState extends State<SettingsScreen> {
  // Servicio de configuración
  final SettingsStorageService _settingsService = SettingsStorageService();

  bool _isDarkMode = true;
  String _selectedCurrency = "\$ Peso Mexicano (MXN)";
  final List<String> _currencies = [
    "\$ Dólar (USD)",
    "€ Euro (EUR)",
    "\$ Peso Mexicano (MXN)",
    "\$ Peso Argentino (ARS)",
    "\$ Peso Colombiano (COP)",
    "\$ Peso Chileno (CLP)",
  ];
  final TextEditingController _budgetController = TextEditingController();
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadBudget();
  }

  void _loadBudget() async {
    final budget = await _settingsService.getMonthlyBudget();
    _budgetController.text = budget.toStringAsFixed(2);
  }

  void _saveBudget() async {
    if (_isSaving) return;

    final text = _budgetController.text.replaceAll(',', '.');
    final double? newBudget = double.tryParse(text);

    if (newBudget == null || newBudget < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, ingresa un presupuesto válido y positivo.'), backgroundColor: AppColors.red),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    await _settingsService.setMonthlyBudget(newBudget);

    widget.onSettingsChanged?.call();

    setState(() {
      _isSaving = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Presupuesto guardado en \$${newBudget.toStringAsFixed(2)}.'), backgroundColor: AppColors.green),
    );
  }

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
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
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

  // ➡️ WIDGET 1: Restaurado completamente
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
          // Lógica para cambiar el tema
        },
        activeColor: AppColors.accentBrown,
      ),
    );
  }

  // ➡️ WIDGET 2: Restaurado completamente
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

  // WIDGET 3: _buildBudgetOption (Actualizado con botón de guardado)
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

        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _isSaving ? null : _saveBudget,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accentBrown,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: _isSaving
                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Text("Guardar Presupuesto", style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.w600)),
          ),
        ),
      ],
    );
  }

  // ➡️ WIDGET 4: Restaurado completamente
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

  // ➡️ WIDGET 5: Restaurado completamente
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