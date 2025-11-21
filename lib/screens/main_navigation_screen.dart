import 'package:flutter/material.dart';
import 'package:gastos/constants/app_colors.dart';
import 'package:gastos/screens/categories/categories_screen.dart';
import 'package:gastos/screens/history/history_screen.dart';
import 'package:gastos/screens/home/home_screen.dart';
import 'package:gastos/screens/new_expense/new_expense_screen.dart';
import 'package:gastos/screens/settings/settings_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _selectedIndex = 0;

  // ➡️ 1. DEFINIR LA GLOBAL KEY USANDO EL ESTADO PÚBLICO
  final GlobalKey<HistoryScreenState> _historyKey = GlobalKey<HistoryScreenState>();

  // 2. ASIGNAR LAS PANTALLAS
  late final List<Widget> _widgetOptions = <Widget>[
    const HomeScreen(),
    HistoryScreen(key: _historyKey), // ⬅️ Asignar la Key
    const CategoriesScreen(),
    const SettingsScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // ➡️ 3. FUNCIÓN ASÍNCRONA PARA ABRIR EL MODAL Y REFRESCAR EL HISTORIAL
  void _onAddExpenseTapped() async {
    // Abrir el modal y esperar el resultado (será 'true' si se guardó un gasto)
    final bool? shouldRefresh = await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.9,
          minChildSize: 0.5,
          maxChildSize: 0.9,
          builder: (_, controller) {
            return Container(
              decoration: const BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: NewExpenseScreen(scrollController: controller),
            );
          },
        );
      },
    );

    // ➡️ 4. COMPROBAR EL RESULTADO Y FORZAR EL REFRESCO EN EL HIJO
    if (shouldRefresh == true) {
      // Llama al método refreshHistory() de la pantalla de historial
      _historyKey.currentState?.refreshHistory();

      // Opcional: Cambiar a la pestaña de Historial (índice 1)
      if (_selectedIndex != 1) {
        _onItemTapped(1);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _widgetOptions,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _onAddExpenseTapped, // ⬅️ Llama a la función de refresco
        shape: const CircleBorder(),
        child: const Icon(Icons.add, size: 30),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8.0,
        color: Colors.white,
        elevation: 10,
        shadowColor: Colors.black.withOpacity(0.1),
        child: SizedBox(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              // Espaciador para la izquierda
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildNavItem(Icons.home, "Inicio", 0),
                  _buildNavItem(Icons.history, "Historial", 1),
                ],
              ),
              // Espaciador para la derecha
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildNavItem(Icons.category, "Categorías", 2),
                  _buildNavItem(Icons.settings, "Ajustes", 3),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    final isSelected = _selectedIndex == index;
    final color = isSelected ? AppColors.accentBrown : AppColors.secondaryText;

    return MaterialButton(
      minWidth: 40,
      onPressed: () => _onItemTapped(index),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color),
          if (isSelected)
            Container(
              margin: const EdgeInsets.only(top: 4),
              height: 4,
              width: 4,
              decoration: const BoxDecoration(
                color: AppColors.accentBrown,
                shape: BoxShape.circle,
              ),
            ),
        ],
      ),
    );
  }
}