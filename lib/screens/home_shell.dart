import 'package:flutter/material.dart';

import '../store.dart';
import '../theme.dart';
import 'dashboard_screen.dart';
import 'modules_screen.dart';
import 'profile_screen.dart';
import 'results_screen.dart';
import 'trajectory_screen.dart';

/// Pastki navigatsiya — rasmda ko'rsatilgan 5 ta asosiy bo'lim.
class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => HomeShellState();

  /// Boshqa ekranlardan tabni almashtirish uchun.
  static void goTo(BuildContext context, int index) {
    context.findAncestorStateOfType<HomeShellState>()?.setTab(index);
  }
}

class HomeShellState extends State<HomeShell> {
  int _index = 0;

  void setTab(int i) => setState(() => _index = i);

  @override
  Widget build(BuildContext context) {
    // DIQQAT: bu ro'yxat `const` bo'lmasligi kerak — aks holda Flutter bir xil
    // vidjet nusxasini ko'rib, ekranlarni qayta qurmaydi va progress yangilanmaydi.
    return AnimatedBuilder(
      animation: appState,
      builder: (context, _) {
        final pages = <Widget>[
          const DashboardScreen(),
          const TrajectoryScreen(),
          const ModulesScreen(),
          const ResultsScreen(),
          const ProfileScreen(),
        ];
        return Scaffold(
          body: IndexedStack(index: _index, children: pages),
          bottomNavigationBar: NavigationBar(
            selectedIndex: _index,
            onDestinationSelected: setTab,
            backgroundColor: Colors.white,
            indicatorColor: const Color(0xFFDBEAFE),
            height: 66,
            labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.home_outlined),
                selectedIcon: Icon(Icons.home, color: AppColors.primary),
                label: 'Bosh sahifa',
              ),
              NavigationDestination(
                icon: Icon(Icons.route_outlined),
                selectedIcon: Icon(Icons.route, color: AppColors.primary),
                label: 'Traektoriya',
              ),
              NavigationDestination(
                icon: Icon(Icons.grid_view_outlined),
                selectedIcon: Icon(Icons.grid_view, color: AppColors.primary),
                label: 'Modullar',
              ),
              NavigationDestination(
                icon: Icon(Icons.bar_chart_outlined),
                selectedIcon: Icon(Icons.bar_chart, color: AppColors.primary),
                label: 'Natijalar',
              ),
              NavigationDestination(
                icon: Icon(Icons.person_outline),
                selectedIcon: Icon(Icons.person, color: AppColors.primary),
                label: 'Profil',
              ),
            ],
          ),
        );
      },
    );
  }
}
