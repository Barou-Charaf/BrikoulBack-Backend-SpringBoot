import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../core/app_theme.dart';

class AppScaffold extends StatelessWidget {
  const AppScaffold({
    required this.title,
    required this.child,
    this.actions,
    this.bottomNavigationBar,
    super.key,
  });

  final String title;
  final Widget child;
  final List<Widget>? actions;
  final Widget? bottomNavigationBar;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title), actions: actions),
      bottomNavigationBar: bottomNavigationBar,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: child,
        ),
      ),
    );
  }
}

class AppCard extends StatelessWidget {
  const AppCard({required this.child, this.padding = const EdgeInsets.all(16), super.key});

  final Widget child;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE9ECEF)),
        boxShadow: const [
          BoxShadow(color: Color(0x0A000000), blurRadius: 10, offset: Offset(0, 2)),
        ],
      ),
      child: child,
    );
  }
}

class BrandHeader extends StatelessWidget {
  const BrandHeader({this.subtitle = 'La logistique intelligente au Maroc', super.key});

  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(18),
          ),
          child: const Icon(Icons.local_shipping, color: Colors.white, size: 34),
        ),
        const SizedBox(height: 14),
        const Text(
          'E-Samsar',
          style: TextStyle(color: AppColors.primary, fontSize: 30, fontWeight: FontWeight.w800),
        ),
        Text(subtitle, style: const TextStyle(color: AppColors.muted)),
      ],
    );
  }
}

class StatusChip extends StatelessWidget {
  const StatusChip(this.status, {super.key});

  final String status;

  @override
  Widget build(BuildContext context) {
    final color = switch (status) {
      'COMPLETED' || 'ACCEPTED' => AppColors.success,
      'CANCELED' => AppColors.error,
      'REJECTED' => Colors.grey,
      'ASSIGNED' => Colors.purple,
      'IN_PROGRESS' => AppColors.primary,
      'NOTIFIED' => Colors.blue,
      _ => Colors.orange,
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        statusFr(status),
        style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w700),
      ),
    );
  }
}

class EmptyState extends StatelessWidget {
  const EmptyState({required this.icon, required this.title, required this.message, super.key});

  final IconData icon;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        children: [
          Icon(icon, size: 42, color: AppColors.primary),
          const SizedBox(height: 10),
          Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
          const SizedBox(height: 6),
          Text(message, textAlign: TextAlign.center, style: const TextStyle(color: AppColors.muted)),
        ],
      ),
    );
  }
}

class StatCard extends StatelessWidget {
  const StatCard({required this.icon, required this.value, required this.label, this.color = AppColors.primary, super.key});

  final IconData icon;
  final String value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(12),
      child: SizedBox(
        height: 86,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color),
            const SizedBox(height: 6),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(value, maxLines: 1, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
            ),
            Text(label, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12, color: AppColors.muted)),
          ],
        ),
      ),
    );
  }
}

String statusFr(String status) {
  return switch (status) {
    'PENDING' => 'En attente',
    'NOTIFIED' => 'Chauffeurs notifiés',
    'ASSIGNED' => 'Assignée',
    'IN_PROGRESS' => 'En cours',
    'COMPLETED' => 'Terminée',
    'CANCELED' => 'Annulée',
    'ACCEPTED' => 'Acceptée',
    'REJECTED' => 'Refusée',
    _ => status,
  };
}

String vehicleFr(String type) {
  return switch (type) {
    'MOTORCYCLE' => 'Moto',
    'SMALL_VAN' => 'Petite fourgonnette',
    'PICKUP' => 'Pickup',
    'VAN' => 'Fourgon',
    'SMALL_TRUCK' => 'Petit camion',
    'MEDIUM_TRUCK' => 'Camion moyen',
    'BIG_TRUCK' => 'Grand camion',
    _ => type,
  };
}

String money(num value) => '${NumberFormat.decimalPattern('fr').format(value)} MAD';
