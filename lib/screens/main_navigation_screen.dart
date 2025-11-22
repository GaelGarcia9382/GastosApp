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

class _MainNavigationScreenState extends State<MainNavigationScreen> with AutomaticKeepAliveClientMixin {
  int _selectedIndex = 0;

  // ✅ SOLO las 2 GlobalKeys originales - ELIMINA LAS OTRAS
  final GlobalKey<HistoryScreenState> _historyKey = GlobalKey<HistoryScreenState>();
  final GlobalKey<HomeScreenState> _homeKey = GlobalKey<HomeScreenState>();

  @override
  bool get wantKeepAlive => true;

  void _globalRefresh() {
    _homeKey.currentState?.refreshHome();
    _historyKey.currentState?.refreshHistory();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _onAddExpenseTapped() async {
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
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: const BorderRadius.only(
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

    if (shouldRefresh == true) {
      _globalRefresh();
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          // ✅ Solo estas dos pantallas necesitan GlobalKeys
          HomeScreen(key: _homeKey),
          HistoryScreen(
            key: _historyKey,
            onExpenseChanged: _globalRefresh,
          ),

          // ❌ ESTAS NO DEBEN TENER GLOBALKEYS
          CategoriesScreen(
            onCategoriesChanged: _globalRefresh, // Solo el callback
          ),
          SettingsScreen(
            onSettingsChanged: _globalRefresh, // Solo el callback
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _onAddExpenseTapped,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, size: 30),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      // ➡️ BottomAppBar dinámico
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8.0,
        // El color ahora viene automáticamente del tema
        child: SizedBox(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildNavItem(Icons.home, "Inicio", 0),
                  _buildNavItem(Icons.history, "Historial", 1),
                ],
              ),
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

    final color = isSelected
        ? AppColors.accentBrown
        : Theme.of(context).iconTheme.color;

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