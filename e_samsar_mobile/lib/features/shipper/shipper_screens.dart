import 'package:flutter/material.dart';

import '../../core/app_state.dart';
import '../../core/app_theme.dart';
import '../../core/e_samsar_api.dart';
import '../../core/models.dart';
import '../../features/auth/auth_screens.dart';
import '../../features/driver/driver_screens.dart';
import '../../shared/actions.dart';
import '../../shared/cards.dart';
import '../../shared/ui.dart';

ESamsarApi _api(BuildContext context) => ESamsarApi(AppStateScope.read(context).api);

class ShipperHomeScreen extends StatelessWidget {
  const ShipperHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Accueil Expéditeur',
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications_outlined),
          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationsScreen())),
        ),
      ],
      child: FutureBuilder<ShipperProfile>(
        future: _api(context).shipperMe(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const CircularProgressIndicator();
          final shipper = snapshot.data!;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Bienvenue,', style: TextStyle(color: AppColors.muted)),
              Text('Bonjour, ${shipper.user.firstName}', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: AppColors.primary)),
              const SizedBox(height: 6),
              Text(shipper.companyName.isEmpty ? 'Entreprise non renseignée' : shipper.companyName, style: const TextStyle(color: AppColors.muted)),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(child: StatCard(icon: Icons.star, value: shipper.averageRating.toStringAsFixed(1), label: 'Note', color: AppColors.accent)),
                  const SizedBox(width: 10),
                  Expanded(child: StatCard(icon: Icons.done_all, value: '${shipper.completedOffers}', label: 'Offres')),
                  const SizedBox(width: 10),
                  const Expanded(child: StatCard(icon: Icons.notifications, value: '-', label: 'Alertes')),
                ],
              ),
              const SizedBox(height: 22),
              _ActionTile(icon: Icons.add_circle, title: 'Créer une offre', subtitle: 'Publiez un transport et notifiez les meilleurs chauffeurs.', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CreateOfferScreen()))),
              _ActionTile(icon: Icons.people, title: 'Rechercher des chauffeurs', subtitle: 'Trouvez des chauffeurs disponibles par ville et véhicule.', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ShipperDriversScreen()))),
              _ActionTile(icon: Icons.smart_toy, title: 'Recherche IA', subtitle: 'Décrivez votre besoin en langage naturel.', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AiAssistantScreen()))),
            ],
          );
        },
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({required this.icon, required this.title, required this.subtitle, required this.onTap});

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        child: AppCard(
          child: Row(
            children: [
              Icon(icon, color: AppColors.primary, size: 30),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
                Text(subtitle, style: const TextStyle(color: AppColors.muted)),
              ])),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}

class CreateOfferScreen extends StatefulWidget {
  const CreateOfferScreen({super.key});

  @override
  State<CreateOfferScreen> createState() => _CreateOfferScreenState();
}

class _CreateOfferScreenState extends State<CreateOfferScreen> {
  final title = TextEditingController();
  final description = TextEditingController();
  final departure = TextEditingController(text: 'Casablanca');
  final arrival = TextEditingController(text: 'Rabat');
  final pickup = TextEditingController();
  final delivery = TextEditingController();
  final weight = TextEditingController(text: '700');
  final price = TextEditingController(text: '1200');
  final maxDrivers = TextEditingController(text: '10');
  String goodsType = 'FURNITURE';
  String vehicleType = 'VAN';
  bool busy = false;

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Créer une offre',
      child: AppCard(
        child: Column(
          children: [
            TextField(controller: title, decoration: const InputDecoration(labelText: 'Titre')),
            const SizedBox(height: 10),
            TextField(controller: description, decoration: const InputDecoration(labelText: 'Description')),
            const SizedBox(height: 10),
            TextField(controller: departure, decoration: const InputDecoration(labelText: 'Ville de départ')),
            const SizedBox(height: 10),
            TextField(controller: arrival, decoration: const InputDecoration(labelText: 'Ville d’arrivée')),
            const SizedBox(height: 10),
            TextField(controller: pickup, decoration: const InputDecoration(labelText: 'Adresse de chargement')),
            const SizedBox(height: 10),
            TextField(controller: delivery, decoration: const InputDecoration(labelText: 'Adresse de livraison')),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: goodsType,
              decoration: const InputDecoration(labelText: 'Type de marchandise'),
              items: const ['FOOD', 'FURNITURE', 'ELECTRONICS', 'CONSTRUCTION_MATERIALS', 'CLOTHES', 'AGRICULTURE', 'OTHER']
                  .map((v) => DropdownMenuItem(value: v, child: Text(v)))
                  .toList(),
              onChanged: (v) => setState(() => goodsType = v!),
            ),
            const SizedBox(height: 10),
            TextField(controller: weight, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Poids en kg')),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: vehicleType,
              decoration: const InputDecoration(labelText: 'Type de véhicule requis'),
              items: ['MOTORCYCLE', 'SMALL_VAN', 'PICKUP', 'VAN', 'SMALL_TRUCK', 'MEDIUM_TRUCK', 'BIG_TRUCK']
                  .map((v) => DropdownMenuItem(value: v, child: Text(vehicleFr(v))))
                  .toList(),
              onChanged: (v) => setState(() => vehicleType = v!),
            ),
            const SizedBox(height: 10),
            TextField(controller: price, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Prix proposé')),
            const SizedBox(height: 10),
            TextField(controller: maxDrivers, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Nombre maximum de chauffeurs')),
            const SizedBox(height: 18),
            ElevatedButton(onPressed: busy ? null : _submit, child: const Text('Créer l’offre')),
          ],
        ),
      ),
    );
  }

  Future<void> _submit() async {
    setState(() => busy = true);
    try {
      await _api(context).createOffer({
        'title': title.text,
        'description': description.text,
        'departureCity': departure.text,
        'arrivalCity': arrival.text,
        'pickupAddress': pickup.text,
        'deliveryAddress': delivery.text,
        'goodsType': goodsType,
        'weightKg': num.tryParse(weight.text) ?? 0,
        'requiredVehicleType': vehicleType,
        'proposedPrice': num.tryParse(price.text) ?? 0,
        'maxDriversToNotify': int.tryParse(maxDrivers.text) ?? 10,
        'transportDate': DateTime.now().add(const Duration(days: 7)).toIso8601String(),
      });
      if (!mounted) return;
      showSuccess(context, 'Offre créée et chauffeurs compatibles notifiés.');
      Navigator.pop(context);
    } catch (e) {
      if (mounted) showError(context, e);
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }
}

class ShipperOffersScreen extends StatefulWidget {
  const ShipperOffersScreen({super.key});

  @override
  State<ShipperOffersScreen> createState() => _ShipperOffersScreenState();
}

class _ShipperOffersScreenState extends State<ShipperOffersScreen> {
  late Future<List<OfferSummary>> future;

  @override
  void initState() {
    super.initState();
    future = _api(context).myOffers();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Mes offres',
      actions: [
        IconButton(
          onPressed: () async {
            await Navigator.push(context, MaterialPageRoute(builder: (_) => const CreateOfferScreen()));
            if (!mounted) return;
            setState(() {
              future = _api(context).myOffers();
            });
          },
          icon: const Icon(Icons.add),
        ),
      ],
      child: FutureBuilder<List<OfferSummary>>(
        future: future,
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const CircularProgressIndicator();
          final offers = snapshot.data!;
          if (offers.isEmpty) return const EmptyState(icon: Icons.inventory_2_outlined, title: 'Aucune offre', message: 'Créez votre première offre de transport.');
          return Column(
            children: offers.map((offer) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: OfferCard(
                offer: offer,
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => OfferDetailsScreen(offerId: offer.id, driverMode: false))),
                trailing: PopupMenuButton<String>(
                  onSelected: (value) async {
                    if (value == 'cancel') await _api(context).cancelOffer(offer.id);
                    if (value == 'delete') await _api(context).deleteOffer(offer.id);
                    setState(() {
                      future = _api(context).myOffers();
                    });
                  },
                  itemBuilder: (_) => const [
                    PopupMenuItem(value: 'cancel', child: Text('Annuler')),
                    PopupMenuItem(value: 'delete', child: Text('Supprimer')),
                  ],
                ),
              ),
            )).toList(),
          );
        },
      ),
    );
  }
}

class ShipperDriversScreen extends StatefulWidget {
  const ShipperDriversScreen({super.key});

  @override
  State<ShipperDriversScreen> createState() => _ShipperDriversScreenState();
}

class _ShipperDriversScreenState extends State<ShipperDriversScreen> {
  final city = TextEditingController();
  late Future<List<DriverProfile>> future;

  @override
  void initState() {
    super.initState();
    future = _api(context).drivers();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Rechercher des chauffeurs',
      child: Column(
        children: [
          AppCard(
            child: Row(
              children: [
                Expanded(child: TextField(controller: city, decoration: const InputDecoration(labelText: 'Ville'))),
                const SizedBox(width: 10),
                IconButton(
                  onPressed: () => setState(() {
                    future = _api(context).drivers(city: city.text);
                  }),
                  icon: const Icon(Icons.search),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          FutureBuilder<List<DriverProfile>>(
            future: future,
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const CircularProgressIndicator();
              final drivers = snapshot.data!;
              if (drivers.isEmpty) return const EmptyState(icon: Icons.people_outline, title: 'Aucun chauffeur trouvé', message: 'Essayez une autre ville ou utilisez l’assistant IA.');
              return Column(
                children: drivers.map((driver) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: DriverCard(
                    driver: driver,
                    onWhatsApp: () async {
                      final json = await _api(context).whatsappDriver(driver.id);
                      if (context.mounted) await openExternalUrl(context, json['whatsappUrl']);
                    },
                  ),
                )).toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}

class ShipperApplicationsScreen extends StatefulWidget {
  const ShipperApplicationsScreen({super.key});

  @override
  State<ShipperApplicationsScreen> createState() => _ShipperApplicationsScreenState();
}

class _ShipperApplicationsScreenState extends State<ShipperApplicationsScreen> {
  final offerId = TextEditingController();
  Future<List<dynamic>>? future;

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Candidatures reçues',
      child: Column(
        children: [
          AppCard(
            child: Row(
              children: [
                Expanded(child: TextField(controller: offerId, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'ID de l’offre'))),
                IconButton(
                  onPressed: () => setState(() {
                    future = _api(context).offerApplications(int.tryParse(offerId.text) ?? 0);
                  }),
                  icon: const Icon(Icons.search),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          if (future == null)
            const EmptyState(icon: Icons.assignment_outlined, title: 'Choisissez une offre', message: 'Entrez l’ID d’une offre pour voir ses candidatures.')
          else
            FutureBuilder<List<dynamic>>(
              future: future,
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const CircularProgressIndicator();
                final apps = snapshot.data!;
                if (apps.isEmpty) return const EmptyState(icon: Icons.assignment_outlined, title: 'Aucune candidature', message: 'Cette offre n’a pas encore de candidature.');
                return Column(
                  children: apps.map((app) {
                    final driver = app['driver'] ?? {};
                    final user = driver['user'] ?? {};
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: AppCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(children: [Expanded(child: Text('${user['firstName'] ?? ''} ${user['lastName'] ?? ''}', style: const TextStyle(fontWeight: FontWeight.w900))), StatusChip(app['status'] ?? '')]),
                            Text(app['message'] ?? ''),
                            Text(money(app['proposedPrice'] ?? 0), style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w900)),
                            Row(
                              children: [
                                TextButton(onPressed: () => _act(app['id'], true), child: const Text('Accepter')),
                                TextButton(onPressed: () => _act(app['id'], false), child: const Text('Refuser')),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
        ],
      ),
    );
  }

  Future<void> _act(int id, bool accept) async {
    try {
      if (accept) {
        await _api(context).acceptApplication(id);
        if (mounted) showSuccess(context, 'Candidature acceptée.');
      } else {
        await _api(context).rejectApplication(id);
        if (mounted) showSuccess(context, 'Candidature refusée.');
      }
      setState(() {
        future = _api(context).offerApplications(int.tryParse(offerId.text) ?? 0);
      });
    } catch (e) {
      if (mounted) showError(context, e);
    }
  }
}

class ShipperProfileScreen extends StatelessWidget {
  const ShipperProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = AppStateScope.of(context);
    return AppScaffold(
      title: 'Mon profil',
      child: Column(
        children: [
          FutureBuilder<ShipperProfile>(
            future: _api(context).shipperMe(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const CircularProgressIndicator();
              final shipper = snapshot.data!;
              return AppCard(
                child: Column(
                  children: [
                    const CircleAvatar(radius: 34, child: Icon(Icons.business, size: 34)),
                    const SizedBox(height: 12),
                    Text(shipper.user.fullName, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
                    Text(shipper.user.email, style: const TextStyle(color: AppColors.muted)),
                    const Divider(height: 28),
                    _Line(Icons.business, shipper.companyName),
                    _Line(Icons.phone, shipper.user.phone),
                    _Line(Icons.location_on, shipper.address),
                    _Line(Icons.star, 'Note ${shipper.averageRating.toStringAsFixed(1)}'),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 14),
          OutlinedButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AiAssistantScreen())), child: const Text('Assistant IA')),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: () async {
              await app.logout();
              if (context.mounted) Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const WelcomeScreen()), (_) => false);
            },
            child: const Text('Se déconnecter'),
          ),
        ],
      ),
    );
  }
}

class _Line extends StatelessWidget {
  const _Line(this.icon, this.text);

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(children: [Icon(icon, color: AppColors.primary, size: 18), const SizedBox(width: 8), Expanded(child: Text(text.isEmpty ? '-' : text))]),
    );
  }
}
