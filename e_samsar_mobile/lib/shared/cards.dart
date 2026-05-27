import 'package:flutter/material.dart';

import '../core/app_theme.dart';
import '../core/models.dart';
import 'ui.dart';

class OfferCard extends StatelessWidget {
  const OfferCard({required this.offer, this.onTap, this.trailing, super.key});

  final OfferSummary offer;
  final VoidCallback? onTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(child: Text(offer.title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800))),
                StatusChip(offer.status),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.location_on, color: AppColors.primary, size: 18),
                Expanded(child: Text('${offer.departureCity} → ${offer.arrivalCity}')),
              ],
            ),
            const SizedBox(height: 8),
            Text('${vehicleFr(offer.vehicleType)} · ${offer.weightKg.toStringAsFixed(0)} kg', style: const TextStyle(color: AppColors.muted)),
            const SizedBox(height: 12),
            Row(
              children: [
                Text(money(offer.price), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: AppColors.primary)),
                const Spacer(),
                if (trailing != null) trailing!,
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class DriverCard extends StatelessWidget {
  const DriverCard({required this.driver, this.onWhatsApp, super.key});

  final DriverProfile driver;
  final VoidCallback? onWhatsApp;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: AppColors.primary.withOpacity(.12),
                child: const Icon(Icons.person, color: AppColors.primary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(driver.user.fullName, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
                    Text(driver.currentCity, style: const TextStyle(color: AppColors.muted)),
                  ],
                ),
              ),
              Icon(driver.available ? Icons.check_circle : Icons.pause_circle, color: driver.available ? AppColors.success : Colors.grey),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.star, color: AppColors.accent, size: 18),
              Text(' ${driver.averageRating.toStringAsFixed(1)}'),
              const SizedBox(width: 18),
              const Icon(Icons.local_shipping, color: AppColors.primary, size: 18),
              Text(' ${driver.completedJobs} missions'),
            ],
          ),
          if (onWhatsApp != null) ...[
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: onWhatsApp,
              icon: const Icon(Icons.chat, color: AppColors.whatsApp),
              label: const Text('Contacter sur WhatsApp'),
            ),
          ],
        ],
      ),
    );
  }
}

class TruckCard extends StatelessWidget {
  const TruckCard({required this.truck, this.onEdit, this.onToggle, this.onDelete, super.key});

  final TruckModel truck;
  final VoidCallback? onEdit;
  final VoidCallback? onToggle;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.local_shipping, color: AppColors.primary),
              const SizedBox(width: 10),
              Expanded(child: Text('${truck.brand} ${truck.model}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800))),
              StatusChip(truck.active ? 'ACCEPTED' : 'REJECTED'),
            ],
          ),
          const SizedBox(height: 10),
          Text('Immatriculation: ${truck.plateNumber}'),
          Text('${vehicleFr(truck.vehicleType)} · ${truck.capacityKg.toStringAsFixed(0)} kg', style: const TextStyle(color: AppColors.muted)),
          const SizedBox(height: 12),
          Row(
            children: [
              TextButton(onPressed: onEdit, child: const Text('Modifier')),
              TextButton(onPressed: onToggle, child: Text(truck.active ? 'Désactiver' : 'Activer')),
              const Spacer(),
              IconButton(onPressed: onDelete, icon: const Icon(Icons.delete_outline, color: AppColors.error)),
            ],
          ),
        ],
      ),
    );
  }
}
