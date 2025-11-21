import 'package:shared_preferences/shared_preferences.dart';

class SettingsStorageService {
  static const String _budgetKey = 'monthly_budget';

  // Obtiene el presupuesto, por defecto 1000.00 si no existe
  Future<double> getMonthlyBudget() async {
    final prefs = await SharedPreferences.getInstance();
    // Usamos ?? para proporcionar un valor predeterminado si no se encuentra nada
    return prefs.getDouble(_budgetKey) ?? 1000.00;
  }

  // Guarda el nuevo valor del presupuesto
  Future<void> setMonthlyBudget(double amount) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_budgetKey, amount);
  }
}