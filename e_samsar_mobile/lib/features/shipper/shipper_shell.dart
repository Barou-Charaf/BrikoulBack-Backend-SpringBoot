import 'package:flutter/material.dart';

import '../../core/app_theme.dart';
import 'professional_shipper_screens.dart';

class ShipperShell extends StatefulWidget {
  const ShipperShell({super.key});

  @override
  State<ShipperShell> createState() => _ShipperShellState();
}

class _ShipperShellState extends State<ShipperShell> {
  int index = 0;

  final screens = const [
    ProfessionalShipperHomeScreen(),
    ProfessionalShipperOffersScreen(),
    ProfessionalShipperDriversScreen(),
    ProfessionalShipperApplicationsScreen(),
    ProfessionalShipperProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: screens[index],
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (value) => setState(() => index = value),
        backgroundColor: AppColors.surface,
        indicatorColor: AppColors.primary.withOpacity(.12),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Accueil'),
          NavigationDestination(icon: Icon(Icons.inventory_2_outlined), selectedIcon: Icon(Icons.inventory_2), label: 'Offres'),
          NavigationDestination(icon: Icon(Icons.people_outline), selectedIcon: Icon(Icons.people), label: 'Chauffeurs'),
          NavigationDestination(icon: Icon(Icons.assignment_outlined), selectedIcon: Icon(Icons.assignment), label: 'Candidats'),
          NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'Profil'),
        ],
      ),
      floatingActionButton: index == 0 || index == 1
          ? FloatingActionButton(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfessionalCreateOfferScreen())),
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
}
