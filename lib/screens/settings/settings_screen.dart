import 'package:flutter/material.dart';
import 'package:gastos/constants/app_colors.dart';
import 'package:gastos/data/settings_storage_service.dart';
// ➡️ Importamos el servicio de tema y el main
import 'package:gastos/services/theme_service.dart';
import 'package:gastos/main.dart';

class SettingsScreen extends StatefulWidget {
  final Function? onSettingsChanged;

  const SettingsScreen({super.key, this.onSettingsChanged});

  @override
  State<SettingsScreen> createState() => SettingsScreenState();
}

class SettingsScreenState extends State<SettingsScreen> {
  final SettingsStorageService _settingsService = SettingsStorageService();
  final ThemeService _themeService = ThemeService(); // ➡️ Instancia servicio tema

  String _selectedCurrency = "\$ Peso Mexicano (MXN)";
  final List<String> _currencies = [
    "\$ Dólar (USD)", "€ Euro (EUR)", "\$ Peso Mexicano (MXN)",
    "\$ Peso Argentino (ARS)", "\$ Peso Colombiano (COP)", "\$ Peso Chileno (CLP)",
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
        const SnackBar(content: Text('Por favor, ingresa un presupuesto válido.'), backgroundColor: AppColors.red),
      );
      return;
    }

    setState(() { _isSaving = true; });
    await _settingsService.setMonthlyBudget(newBudget);
    widget.onSettingsChanged?.call();
    setState(() { _isSaving = false; });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Presupuesto guardado.'), backgroundColor: AppColors.green),
    );
  }

  // ➡️ Función para cambiar el tema
  void _toggleTheme(bool isDark) {
    themeNotifier.value = isDark ? ThemeMode.dark : ThemeMode.light;
    _themeService.saveThemeMode(isDark);
  }

  @override
  void dispose() {
    _budgetController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Detectar el tema actual directamente del notifier
    final isDark = themeNotifier.value == ThemeMode.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Ajustes"),
        actions: const [
          SizedBox(width: 10),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
        child: Column(
          children: [
            _buildThemeOption(isDark), // Pasamos el estado
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
    );
  }

  // ➡️ Widget actualizado con lógica real
  Widget _buildThemeOption(bool isDark) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: const Icon(Icons.palette_outlined, size: 28),
      title: const Text("Tema", style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
      subtitle: Text(isDark ? "Oscuro" : "Claro", style: TextStyle(color: Theme.of(context).iconTheme.color)),
      trailing: Switch(
        value: isDark,
        onChanged: (value) {
          _toggleTheme(value);
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
          subtitle: Text("Selecciona tu moneda principal", style: TextStyle(color: Theme.of(context).iconTheme.color)),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          decoration: BoxDecoration(
            color: Theme.of(context).cardTheme.color, // Usa el color del tema
            borderRadius: BorderRadius.circular(12),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedCurrency,
              isExpanded: true,
              icon: Icon(Icons.keyboard_arrow_down, color: Theme.of(context).iconTheme.color),
              dropdownColor: Theme.of(context).cardTheme.color, // Fondo del menú
              style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color), // Color texto
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
          subtitle: Text("Define tu meta mensual", style: TextStyle(color: Theme.of(context).iconTheme.color)),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _budgetController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            prefixText: "\$ ",
            hintText: "1000.00",
            // fillColor se maneja automáticamente en el main.dart ahora
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
                text: TextSpan(
                  style: TextStyle(
                      fontFamily: 'Lato',
                      color: Theme.of(context).textTheme.bodyMedium?.color, // Color adaptable
                      fontSize: 14,
                      height: 1.4
                  ),
                  children: const [
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
        Text(
          "Tu camino hacia la paz financiera",
          style: TextStyle(color: Theme.of(context).iconTheme.color, fontSize: 14),
        ),
        const SizedBox(height: 8),
        Text(
          "Versión 1.0.0",
          style: TextStyle(color: Theme.of(context).iconTheme.color, fontSize: 12),
        ),
      ],
    );
  }
}