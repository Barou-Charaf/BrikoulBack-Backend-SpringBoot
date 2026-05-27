import 'package:flutter/material.dart';

import '../../core/app_theme.dart';
import 'driver_ai_screen.dart';
import 'driver_home_dashboard.dart';
import 'driver_interface_screens.dart';
import 'driver_screens.dart';

class DriverShell extends StatefulWidget {
  const DriverShell({super.key});

  @override
  State<DriverShell> createState() => _DriverShellState();
}

class _DriverShellState extends State<DriverShell> {
  int index = 0;

  final screens = const [
    ProfessionalDriverHomeScreen(),
    ProfessionalDriverOffersScreen(),
    ProfessionalDriverApplicationsScreen(),
    ProfessionalDriverTrucksScreen(),
    ProfessionalDriverProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: screens[index],
      floatingActionButton: index == 0
          ? FloatingActionButton(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              elevation: 10,
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfessionalAiAssistantScreen())),
              child: const Icon(Icons.smart_toy),
            )
          : null,
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          border: Border(top: BorderSide(color: AppColors.outline)),
          boxShadow: [BoxShadow(color: Color(0x12000000), blurRadius: 14, offset: Offset(0, -4))],
        ),
        child: NavigationBar(
          selectedIndex: index,
          onDestinationSelected: (value) => setState(() => index = value),
          backgroundColor: AppColors.surface,
          indicatorColor: Color(0xFFE0F3F5),
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          destinations: const [
            NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Accueil'),
            NavigationDestination(icon: Icon(Icons.local_shipping_outlined), selectedIcon: Icon(Icons.local_shipping), label: 'Offres'),
            NavigationDestination(icon: Icon(Icons.assignment_outlined), selectedIcon: Icon(Icons.assignment_turned_in), label: 'Candidats'),
            NavigationDestination(icon: Icon(Icons.commute_outlined), selectedIcon: Icon(Icons.commute), label: 'Véhicules'),
            NavigationDestination(icon: Icon(Icons.account_circle_outlined), selectedIcon: Icon(Icons.account_circle), label: 'Profil'),
          ],
        ),
      ),
    );
  }
}
