import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/api_client.dart';
import '../../core/app_state.dart';
import '../../core/app_theme.dart';
import '../../core/e_samsar_api.dart';
import '../../core/models.dart';
import '../../features/auth/auth_screens.dart';
import '../../features/driver/driver_screens.dart';
import '../../shared/actions.dart';
import '../../shared/ui.dart';

ESamsarApi _shipperApi(BuildContext context) => ESamsarApi(AppStateScope.read(context).api);

Future<String?> _pickGalleryImageDataUrl() async {
  final picked = await ImagePicker().pickImage(
    source: ImageSource.gallery,
    imageQuality: 55,
    maxWidth: 700,
    maxHeight: 700,
  );
  if (picked == null) return null;
  final bytes = await picked.readAsBytes();
  final name = picked.name.toLowerCase();
  final mime = name.endsWith('.png')
      ? 'png'
      : name.endsWith('.webp')
          ? 'webp'
          : 'jpeg';
  return 'data:image/$mime;base64,${base64Encode(bytes)}';
}

Uint8List? _dataImageBytes(String value) {
  final trimmed = value.trim();
  if (!trimmed.startsWith('data:image')) return null;
  final commaIndex = trimmed.indexOf(',');
  if (commaIndex == -1) return null;
  try {
    return base64Decode(trimmed.substring(commaIndex + 1));
  } catch (_) {
    return null;
  }
}

ImageProvider? _storedImageProvider(String value) {
  final trimmed = value.trim();
  if (trimmed.isEmpty) return null;
  final bytes = _dataImageBytes(trimmed);
  if (trimmed.startsWith('data:image')) return bytes == null ? null : MemoryImage(bytes);
  if (bytes != null) return MemoryImage(bytes);
  return NetworkImage(trimmed);
}

class ProfessionalShipperHomeScreen extends StatefulWidget {
  const ProfessionalShipperHomeScreen({super.key});

  @override
  State<ProfessionalShipperHomeScreen> createState() => _ProfessionalShipperHomeScreenState();
}

class _ProfessionalShipperHomeScreenState extends State<ProfessionalShipperHomeScreen> {
  late Future<_ShipperHomeData> future;

  @override
  void initState() {
    super.initState();
    future = _load();
  }

  Future<_ShipperHomeData> _load() async {
    final api = _shipperApi(context);
    final shipper = await api.shipperMe();
    final offers = await api.myOffers().catchError((_) => <OfferSummary>[]);
    return _ShipperHomeData(shipper: shipper, offers: offers);
  }

  @override
  Widget build(BuildContext context) {
    return _ShipperPageShell(
      title: 'Accueil Expéditeur',
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications_outlined),
          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationsScreen())),
        ),
      ],
      child: FutureBuilder<_ShipperHomeData>(
        future: future,
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final data = snapshot.data!;
          final shipper = data.shipper;
          final activeOffers = data.offers.where((offer) => offer.status != 'COMPLETED' && offer.status != 'CANCELED').length;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _ShipperHero(shipper: shipper),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(child: _MetricTile(icon: Icons.star, value: shipper.averageRating.toStringAsFixed(1), label: 'Note', color: AppColors.accent)),
                  const SizedBox(width: 10),
                  Expanded(child: _MetricTile(icon: Icons.inventory_2_outlined, value: '$activeOffers', label: 'Actives')),
                  const SizedBox(width: 10),
                  Expanded(child: _MetricTile(icon: Icons.done_all, value: '${shipper.completedOffers}', label: 'Terminées', color: AppColors.success)),
                ],
              ),
              const SizedBox(height: 20),
              _QuickActionCard(
                icon: Icons.add_circle_outline,
                title: 'Créer une offre',
                subtitle: 'Publiez un transport et notifiez les chauffeurs compatibles.',
                color: AppColors.primary,
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfessionalCreateOfferScreen())),
              ),
              const SizedBox(height: 12),
              _QuickActionCard(
                icon: Icons.people_alt_outlined,
                title: 'Trouver un chauffeur',
                subtitle: 'Recherchez par ville, capacité et type de véhicule.',
                color: AppColors.secondary,
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfessionalShipperDriversScreen())),
              ),
              const SizedBox(height: 12),
              _QuickActionCard(
                icon: Icons.smart_toy_outlined,
                title: 'Assistant IA',
                subtitle: 'Décrivez votre besoin, E-Samsar propose des chauffeurs.',
                color: AppColors.accent,
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfessionalShipperAiScreen())),
              ),
            ],
          );
        },
      ),
    );
  }
}

class ProfessionalCreateOfferScreen extends StatefulWidget {
  const ProfessionalCreateOfferScreen({super.key});

  @override
  State<ProfessionalCreateOfferScreen> createState() => _ProfessionalCreateOfferScreenState();
}

class _ProfessionalCreateOfferScreenState extends State<ProfessionalCreateOfferScreen> {
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
  void dispose() {
    title.dispose();
    description.dispose();
    departure.dispose();
    arrival.dispose();
    pickup.dispose();
    delivery.dispose();
    weight.dispose();
    price.dispose();
    maxDrivers.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _ShipperPageShell(
      title: 'Nouvelle offre',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _SectionHeader(icon: Icons.inventory_2_outlined, title: 'Détails du transport', subtitle: 'Les chauffeurs compatibles seront notifiés automatiquement.'),
          const SizedBox(height: 14),
          _Panel(
            child: Column(
              children: [
                TextField(controller: title, decoration: const InputDecoration(labelText: 'Titre *', prefixIcon: Icon(Icons.title))),
                const SizedBox(height: 10),
                TextField(controller: description, minLines: 2, maxLines: 4, decoration: const InputDecoration(labelText: 'Description', prefixIcon: Icon(Icons.notes_outlined))),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(child: TextField(controller: departure, decoration: const InputDecoration(labelText: 'Départ *', prefixIcon: Icon(Icons.trip_origin)))),
                    const SizedBox(width: 10),
                    Expanded(child: TextField(controller: arrival, decoration: const InputDecoration(labelText: 'Arrivée *', prefixIcon: Icon(Icons.location_on_outlined)))),
                  ],
                ),
                const SizedBox(height: 10),
                TextField(controller: pickup, decoration: const InputDecoration(labelText: 'Adresse de chargement', prefixIcon: Icon(Icons.upload_outlined))),
                const SizedBox(height: 10),
                TextField(controller: delivery, decoration: const InputDecoration(labelText: 'Adresse de livraison', prefixIcon: Icon(Icons.download_outlined))),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  value: goodsType,
                  decoration: const InputDecoration(labelText: 'Marchandise'),
                  items: const ['FOOD', 'FURNITURE', 'ELECTRONICS', 'CONSTRUCTION_MATERIALS', 'CLOTHES', 'AGRICULTURE', 'OTHER']
                      .map((value) => DropdownMenuItem(value: value, child: Text(_goodsFr(value))))
                      .toList(),
                  onChanged: (value) => setState(() => goodsType = value!),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(child: TextField(controller: weight, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Poids kg *', prefixIcon: Icon(Icons.scale_outlined)))),
                    const SizedBox(width: 10),
                    Expanded(child: TextField(controller: price, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Prix MAD *', prefixIcon: Icon(Icons.payments_outlined)))),
                  ],
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  value: vehicleType,
                  decoration: const InputDecoration(labelText: 'Véhicule requis'),
                  items: _vehicleTypes.map((value) => DropdownMenuItem(value: value, child: Text(vehicleFr(value)))).toList(),
                  onChanged: (value) => setState(() => vehicleType = value!),
                ),
                const SizedBox(height: 10),
                TextField(controller: maxDrivers, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Chauffeurs à notifier', prefixIcon: Icon(Icons.notifications_active_outlined))),
                const SizedBox(height: 18),
                ElevatedButton.icon(
                  onPressed: busy ? null : _submit,
                  icon: busy ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Icon(Icons.send),
                  label: Text(busy ? 'Publication...' : 'Créer et notifier'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _submit() async {
    final titleValue = title.text.trim();
    final departureValue = departure.text.trim();
    final arrivalValue = arrival.text.trim();
    final weightValue = num.tryParse(weight.text.trim().replaceAll(',', '.'));
    final priceValue = num.tryParse(price.text.trim().replaceAll(',', '.'));
    if (titleValue.isEmpty || departureValue.isEmpty || arrivalValue.isEmpty || weightValue == null || weightValue <= 0 || priceValue == null || priceValue <= 0) {
      showError(context, 'Veuillez compléter le titre, les villes, le poids et le prix.');
      return;
    }
    setState(() => busy = true);
    try {
      await _shipperApi(context).createOffer({
        'title': titleValue,
        'description': description.text.trim(),
        'departureCity': departureValue,
        'arrivalCity': arrivalValue,
        'pickupAddress': pickup.text.trim(),
        'deliveryAddress': delivery.text.trim(),
        'goodsType': goodsType,
        'weightKg': weightValue,
        'requiredVehicleType': vehicleType,
        'proposedPrice': priceValue,
        'maxDriversToNotify': int.tryParse(maxDrivers.text.trim()) ?? 10,
        'transportDate': DateTime.now().add(const Duration(days: 7)).toIso8601String(),
      });
      if (!mounted) return;
      showSuccess(context, 'Offre créée et chauffeurs compatibles notifiés.');
      Navigator.pop(context, true);
    } catch (error) {
      if (mounted) showError(context, error);
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }
}

class ProfessionalShipperOffersScreen extends StatefulWidget {
  const ProfessionalShipperOffersScreen({super.key});

  @override
  State<ProfessionalShipperOffersScreen> createState() => _ProfessionalShipperOffersScreenState();
}

class _ProfessionalShipperOffersScreenState extends State<ProfessionalShipperOffersScreen> {
  late Future<List<OfferSummary>> future;

  @override
  void initState() {
    super.initState();
    future = _shipperApi(context).myOffers();
  }

  @override
  Widget build(BuildContext context) {
    return _ShipperPageShell(
      title: 'Mes offres',
      actions: [
        IconButton(
          icon: const Icon(Icons.add_circle_outline),
          onPressed: () async {
            final changed = await Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfessionalCreateOfferScreen()));
            if (!mounted || changed != true) return;
            setState(() => future = _shipperApi(context).myOffers());
          },
        ),
      ],
      child: FutureBuilder<List<OfferSummary>>(
        future: future,
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final offers = snapshot.data!;
          if (offers.isEmpty) {
            return _PrettyEmpty(
              icon: Icons.inventory_2_outlined,
              title: 'Aucune offre',
              message: 'Créez votre première offre pour recevoir des candidatures.',
              actionLabel: 'Créer une offre',
              onAction: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfessionalCreateOfferScreen())),
            );
          }
          return Column(
            children: [
              _CreateOfferBanner(onTap: () async {
                final changed = await Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfessionalCreateOfferScreen()));
                if (!mounted || changed != true) return;
                setState(() => future = _shipperApi(context).myOffers());
              }),
              const SizedBox(height: 14),
              ...offers.map((offer) => Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: _ShipperOfferCard(
                      offer: offer,
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => OfferDetailsScreen(offerId: offer.id, driverMode: false))),
                      onCancel: () async {
                        await _shipperApi(context).cancelOffer(offer.id);
                        if (!mounted) return;
                        showSuccess(context, 'Offre annulée.');
                        setState(() => future = _shipperApi(context).myOffers());
                      },
                      onDelete: () async {
                        await _shipperApi(context).deleteOffer(offer.id);
                        if (!mounted) return;
                        showSuccess(context, 'Offre supprimée.');
                        setState(() => future = _shipperApi(context).myOffers());
                      },
                    ),
                  )),
            ],
          );
        },
      ),
    );
  }
}

class ProfessionalShipperDriversScreen extends StatefulWidget {
  const ProfessionalShipperDriversScreen({super.key});

  @override
  State<ProfessionalShipperDriversScreen> createState() => _ProfessionalShipperDriversScreenState();
}

class _ProfessionalShipperDriversScreenState extends State<ProfessionalShipperDriversScreen> {
  final city = TextEditingController();
  final capacity = TextEditingController();
  String? vehicleType;
  late Future<List<DriverProfile>> future;

  @override
  void initState() {
    super.initState();
    future = _shipperApi(context).drivers();
  }

  @override
  void dispose() {
    city.dispose();
    capacity.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _ShipperPageShell(
      title: 'Chauffeurs',
      actions: [
        IconButton(icon: const Icon(Icons.smart_toy_outlined), onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfessionalShipperAiScreen()))),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Panel(
            child: Column(
              children: [
                TextField(controller: city, textInputAction: TextInputAction.search, onSubmitted: (_) => _search(), decoration: const InputDecoration(labelText: 'Ville', prefixIcon: Icon(Icons.location_on_outlined))),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: vehicleType,
                        decoration: const InputDecoration(labelText: 'Véhicule'),
                        items: _vehicleTypes.map((value) => DropdownMenuItem(value: value, child: Text(vehicleFr(value)))).toList(),
                        onChanged: (value) => setState(() => vehicleType = value),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(child: TextField(controller: capacity, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Capacité min', prefixIcon: Icon(Icons.scale_outlined)))),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: ElevatedButton.icon(onPressed: _search, icon: const Icon(Icons.search), label: const Text('Rechercher'))),
                    const SizedBox(width: 10),
                    IconButton.filledTonal(onPressed: _reset, icon: const Icon(Icons.refresh)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          FutureBuilder<List<DriverProfile>>(
            future: future,
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
              final drivers = snapshot.data!;
              if (drivers.isEmpty) {
                return const _PrettyEmpty(icon: Icons.people_outline, title: 'Aucun chauffeur trouvé', message: 'Essayez une autre ville, un autre véhicule ou la recherche IA.');
              }
              return Column(
                children: drivers.map((driver) => Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: _ProfessionalDriverCard(
                        driver: driver,
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ShipperDriverDetailsScreen(driverId: driver.id))),
                        onWhatsApp: () => _contactDriver(driver.id),
                      ),
                    )).toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  void _search() {
    setState(() {
      future = _shipperApi(context).drivers(
        city: city.text.trim(),
        vehicleType: vehicleType,
        minCapacityKg: capacity.text.trim(),
      );
    });
  }

  void _reset() {
    city.clear();
    capacity.clear();
    setState(() {
      vehicleType = null;
      future = _shipperApi(context).drivers();
    });
  }

  Future<void> _contactDriver(int driverId) async {
    final json = await _shipperApi(context).whatsappDriver(driverId);
    if (mounted) await openExternalUrl(context, json['whatsappUrl']);
  }
}

class ShipperDriverDetailsScreen extends StatefulWidget {
  const ShipperDriverDetailsScreen({required this.driverId, super.key});

  final int driverId;

  @override
  State<ShipperDriverDetailsScreen> createState() => _ShipperDriverDetailsScreenState();
}

class _ShipperDriverDetailsScreenState extends State<ShipperDriverDetailsScreen> {
  late Future<_DriverDetailData> future;

  @override
  void initState() {
    super.initState();
    future = _load();
  }

  Future<_DriverDetailData> _load() async {
    final api = _shipperApi(context);
    final driver = await api.driverDetails(widget.driverId);
    final trucks = await api.driverTrucks(widget.driverId).catchError((_) => <TruckModel>[]);
    return _DriverDetailData(driver: driver, trucks: trucks);
  }

  @override
  Widget build(BuildContext context) {
    return _ShipperPageShell(
      title: 'Profil chauffeur',
      child: FutureBuilder<_DriverDetailData>(
        future: future,
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final data = snapshot.data!;
          final driver = data.driver;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _DriverProfileHero(driver: driver),
              const SizedBox(height: 14),
              _Panel(
                child: Column(
                  children: [
                    _InfoRow(Icons.email_outlined, driver.user.email),
                    const Divider(height: 24),
                    _InfoRow(Icons.phone_outlined, driver.user.phone),
                    const Divider(height: 24),
                    _InfoRow(Icons.location_on_outlined, driver.currentCity.isEmpty ? 'Ville non renseignée' : driver.currentCity),
                    const SizedBox(height: 14),
                    ElevatedButton.icon(
                      onPressed: () async {
                        final json = await _shipperApi(context).whatsappDriver(driver.id);
                        if (context.mounted) await openExternalUrl(context, json['whatsappUrl']);
                      },
                      icon: const Icon(Icons.chat),
                      label: const Text('Contacter sur WhatsApp'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              const _SectionHeader(icon: Icons.local_shipping_outlined, title: 'Véhicules du chauffeur', subtitle: 'Capacité, type et disponibilité déclarés.'),
              const SizedBox(height: 12),
              if (data.trucks.isEmpty)
                const _PrettyEmpty(icon: Icons.local_shipping_outlined, title: 'Aucun véhicule visible', message: 'Ce chauffeur n’a pas encore ajouté de véhicule.')
              else
                ...data.trucks.map((truck) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _PublicTruckCard(truck: truck),
                    )),
            ],
          );
        },
      ),
    );
  }
}

class ProfessionalShipperApplicationsScreen extends StatefulWidget {
  const ProfessionalShipperApplicationsScreen({super.key});

  @override
  State<ProfessionalShipperApplicationsScreen> createState() => _ProfessionalShipperApplicationsScreenState();
}

class _ProfessionalShipperApplicationsScreenState extends State<ProfessionalShipperApplicationsScreen> {
  bool loadingOffers = true;
  List<OfferSummary> offers = [];
  int? selectedOfferId;
  Future<List<dynamic>>? applicationsFuture;

  @override
  void initState() {
    super.initState();
    _loadOffers();
  }

  Future<void> _loadOffers() async {
    try {
      final loaded = await _shipperApi(context).myOffers();
      if (!mounted) return;
      setState(() {
        offers = loaded;
        selectedOfferId = loaded.isEmpty ? null : loaded.first.id;
        applicationsFuture = selectedOfferId == null ? null : _shipperApi(context).offerApplications(selectedOfferId!);
        loadingOffers = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() => loadingOffers = false);
      showError(context, error);
    }
  }

  @override
  Widget build(BuildContext context) {
    return _ShipperPageShell(
      title: 'Candidatures',
      child: loadingOffers
          ? const Center(child: CircularProgressIndicator())
          : offers.isEmpty
              ? _PrettyEmpty(
                  icon: Icons.assignment_outlined,
                  title: 'Aucune offre',
                  message: 'Créez une offre pour recevoir des candidatures.',
                  actionLabel: 'Créer une offre',
                  onAction: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfessionalCreateOfferScreen())),
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 48,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemBuilder: (context, index) {
                          final offer = offers[index];
                          return _OfferSelectorChip(
                            label: offer.title.isEmpty ? 'Offre #${offer.id}' : offer.title,
                            selected: selectedOfferId == offer.id,
                            onTap: () => setState(() {
                              selectedOfferId = offer.id;
                              applicationsFuture = _shipperApi(context).offerApplications(offer.id);
                            }),
                          );
                        },
                        separatorBuilder: (_, __) => const SizedBox(width: 10),
                        itemCount: offers.length,
                      ),
                    ),
                    const SizedBox(height: 16),
                    FutureBuilder<List<dynamic>>(
                      future: applicationsFuture,
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                        final apps = snapshot.data!;
                        if (apps.isEmpty) {
                          return const _PrettyEmpty(icon: Icons.assignment_outlined, title: 'Aucune candidature', message: 'Aucun chauffeur n’a encore postulé à cette offre.');
                        }
                        return Column(
                          children: apps.map((app) => Padding(
                                padding: const EdgeInsets.only(bottom: 14),
                                child: _ApplicationPanel(
                                  app: app,
                                  onDriverTap: () {
                                    final driver = ((app['driver'] as Map?)?.cast<String, dynamic>()) ?? <String, dynamic>{};
                                    final id = (driver['id'] as num?)?.toInt();
                                    if (id != null) Navigator.push(context, MaterialPageRoute(builder: (_) => ShipperDriverDetailsScreen(driverId: id)));
                                  },
                                  onAccept: () => _act((app['id'] as num).toInt(), true),
                                  onReject: () => _act((app['id'] as num).toInt(), false),
                                ),
                              )).toList(),
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
        await _shipperApi(context).acceptApplication(id);
        if (mounted) showSuccess(context, 'Candidature acceptée.');
      } else {
        await _shipperApi(context).rejectApplication(id);
        if (mounted) showSuccess(context, 'Candidature refusée.');
      }
      if (!mounted || selectedOfferId == null) return;
      setState(() => applicationsFuture = _shipperApi(context).offerApplications(selectedOfferId!));
    } catch (error) {
      if (mounted) showError(context, error);
    }
  }
}

class ProfessionalShipperProfileScreen extends StatefulWidget {
  const ProfessionalShipperProfileScreen({super.key});

  @override
  State<ProfessionalShipperProfileScreen> createState() => _ProfessionalShipperProfileScreenState();
}

class _ProfessionalShipperProfileScreenState extends State<ProfessionalShipperProfileScreen> {
  late Future<ShipperProfile> future;

  @override
  void initState() {
    super.initState();
    future = _shipperApi(context).shipperMe();
  }

  @override
  Widget build(BuildContext context) {
    final app = AppStateScope.of(context);
    return _ShipperPageShell(
      title: 'Mon profil',
      actions: [
        IconButton(
          icon: const Icon(Icons.edit_outlined),
          onPressed: () async {
            final shipper = await future;
            if (mounted) _showProfileForm(shipper);
          },
        ),
      ],
      child: FutureBuilder<ShipperProfile>(
        future: future,
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final shipper = snapshot.data!;
          return Column(
            children: [
              _ShipperHero(shipper: shipper),
              const SizedBox(height: 14),
              _Panel(
                child: Column(
                  children: [
                    _InfoRow(Icons.email_outlined, shipper.user.email),
                    const Divider(height: 24),
                    _InfoRow(Icons.phone_outlined, shipper.user.phone),
                    const Divider(height: 24),
                    _InfoRow(Icons.business_outlined, shipper.companyName.isEmpty ? 'Entreprise non renseignée' : shipper.companyName),
                    const Divider(height: 24),
                    _InfoRow(Icons.location_on_outlined, shipper.address.isEmpty ? 'Adresse non renseignée' : shipper.address),
                    const SizedBox(height: 14),
                    OutlinedButton.icon(onPressed: () => _showProfileForm(shipper), icon: const Icon(Icons.edit_outlined), label: const Text('Modifier mon profil')),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              _SettingsAction(icon: Icons.smart_toy_outlined, title: 'Assistant IA', subtitle: 'Trouver des chauffeurs avec une phrase', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfessionalShipperAiScreen()))),
              const SizedBox(height: 10),
              _SettingsAction(
                icon: Icons.logout,
                title: 'Se déconnecter',
                subtitle: 'Quitter votre session expéditeur',
                danger: true,
                onTap: () async {
                  await app.logout();
                  if (context.mounted) Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const WelcomeScreen()), (_) => false);
                },
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _showProfileForm(ShipperProfile shipper) async {
    final firstName = TextEditingController(text: shipper.user.firstName);
    final lastName = TextEditingController(text: shipper.user.lastName);
    final phone = TextEditingController(text: shipper.user.phone);
    final company = TextEditingController(text: shipper.companyName);
    final address = TextEditingController(text: shipper.address);
    String selectedImage = shipper.user.profileImageUrl;
    bool saving = false;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => StatefulBuilder(
        builder: (context, setSheet) => SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(context).viewInsets.bottom + 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('Modifier mon profil', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: AppColors.primary)),
              const SizedBox(height: 16),
              _ImagePickerField(
                imageValue: selectedImage,
                title: 'Photo de profil',
                subtitle: selectedImage.isEmpty ? 'Choisir une photo depuis la galerie' : 'Photo prête à être enregistrée',
                fallbackIcon: Icons.business_outlined,
                rounded: true,
                onPick: () async {
                  final image = await _pickGalleryImageDataUrl();
                  if (image != null) {
                    setSheet(() {
                      selectedImage = image;
                    });
                  }
                },
                onClear: selectedImage.isEmpty
                    ? null
                    : () => setSheet(() {
                          selectedImage = '';
                        }),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: TextField(controller: firstName, decoration: const InputDecoration(labelText: 'Prénom'))),
                  const SizedBox(width: 10),
                  Expanded(child: TextField(controller: lastName, decoration: const InputDecoration(labelText: 'Nom'))),
                ],
              ),
              const SizedBox(height: 10),
              TextField(controller: phone, decoration: const InputDecoration(labelText: 'Téléphone', prefixIcon: Icon(Icons.phone_outlined))),
              const SizedBox(height: 10),
              TextField(controller: company, decoration: const InputDecoration(labelText: 'Entreprise', prefixIcon: Icon(Icons.business_outlined))),
              const SizedBox(height: 10),
              TextField(controller: address, decoration: const InputDecoration(labelText: 'Adresse', prefixIcon: Icon(Icons.location_on_outlined))),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: saving
                    ? null
                    : () async {
                        try {
                          setSheet(() => saving = true);
                          await _shipperApi(context).updateShipper(
                            firstName: firstName.text.trim(),
                            lastName: lastName.text.trim(),
                            phone: phone.text.trim(),
                            profileImageUrl: selectedImage,
                            companyName: company.text.trim(),
                            address: address.text.trim(),
                          );
                          if (!mounted) return;
                          Navigator.pop(context);
                          showSuccess(context, 'Profil mis à jour.');
                          setState(() => future = _shipperApi(context).shipperMe());
                        } catch (error) {
                          if (!mounted) return;
                          setSheet(() => saving = false);
                          final message = error is ApiException ? error.message : 'Impossible de mettre à jour le profil.';
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
                        }
                      },
                child: saving ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Text('Enregistrer'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ProfessionalShipperAiScreen extends StatefulWidget {
  const ProfessionalShipperAiScreen({super.key});

  @override
  State<ProfessionalShipperAiScreen> createState() => _ProfessionalShipperAiScreenState();
}

class _ProfessionalShipperAiScreenState extends State<ProfessionalShipperAiScreen> {
  final message = TextEditingController();
  Map<String, dynamic>? response;
  String? error;
  bool busy = false;

  @override
  void dispose() {
    message.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final drivers = _driversFromResponse(response);
    return _ShipperPageShell(
      title: 'Assistant IA',
      actions: [
        IconButton(icon: const Icon(Icons.notifications_outlined), onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationsScreen()))),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionHeader(icon: Icons.smart_toy_outlined, title: 'Recherche intelligente', subtitle: 'Décrivez le chauffeur ou le véhicule recherché.'),
          const SizedBox(height: 14),
          _Panel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  controller: message,
                  minLines: 4,
                  maxLines: 6,
                  decoration: const InputDecoration(
                    hintText: 'Ex: Je cherche un fourgon à Casablanca avec 800 kg de capacité',
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    filled: false,
                  ),
                ),
                ElevatedButton.icon(onPressed: busy ? null : _send, icon: const Icon(Icons.auto_awesome), label: Text(busy ? 'Recherche...' : 'Trouver des chauffeurs')),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _SuggestionChip(label: 'Fourgon à Casablanca', onTap: () => _useSuggestion('Je cherche un chauffeur avec fourgon à Casablanca')),
              _SuggestionChip(label: 'Camion 2 tonnes', onTap: () => _useSuggestion('Je cherche un camion avec capacité 2 tonnes')),
              _SuggestionChip(label: 'Pickup à Rabat', onTap: () => _useSuggestion('Trouve-moi un chauffeur pickup à Rabat')),
            ],
          ),
          if (busy) ...[
            const SizedBox(height: 24),
            const Center(child: CircularProgressIndicator()),
          ],
          if (error != null) ...[
            const SizedBox(height: 18),
            _ErrorPanel(message: error!, onRetry: _send),
          ],
          if (response != null && !busy) ...[
            const SizedBox(height: 22),
            _AssistantBubble(text: response?['message']?.toString() ?? 'J’ai trouvé des chauffeurs correspondant à votre recherche.'),
            const SizedBox(height: 16),
            if (drivers.isEmpty)
              const _PrettyEmpty(icon: Icons.search_off, title: 'Aucun chauffeur trouvé', message: 'Essayez une ville, une capacité ou un type de véhicule différent.')
            else
              ...drivers.map((driver) => Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: _ProfessionalDriverCard(
                      driver: driver,
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ShipperDriverDetailsScreen(driverId: driver.id))),
                      onWhatsApp: () async {
                        final json = await _shipperApi(context).whatsappDriver(driver.id);
                        if (context.mounted) await openExternalUrl(context, json['whatsappUrl']);
                      },
                    ),
                  )),
          ],
        ],
      ),
    );
  }

  void _useSuggestion(String value) {
    message.text = value;
    _send();
  }

  Future<void> _send() async {
    final text = message.text.trim();
    if (text.isEmpty) {
      setState(() => error = 'Décrivez le type de chauffeur recherché.');
      return;
    }
    setState(() {
      busy = true;
      error = null;
    });
    try {
      response = await _shipperApi(context).aiChat(text);
    } catch (e) {
      error = e.toString();
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  List<DriverProfile> _driversFromResponse(Map<String, dynamic>? json) {
    final results = json?['results'];
    if (results is! Map<String, dynamic>) return [];
    final drivers = results['drivers'];
    if (drivers is! List) return [];
    return drivers.whereType<Map<String, dynamic>>().map(DriverProfile.fromJson).toList();
  }
}

class _ShipperPageShell extends StatelessWidget {
  const _ShipperPageShell({required this.title, required this.child, this.actions});

  final String title;
  final Widget child;
  final List<Widget>? actions;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(title, style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w900)),
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.primary,
        elevation: 0,
        actions: actions,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 96),
          child: child,
        ),
      ),
    );
  }
}

class _ShipperHomeData {
  const _ShipperHomeData({required this.shipper, required this.offers});

  final ShipperProfile shipper;
  final List<OfferSummary> offers;
}

class _DriverDetailData {
  const _DriverDetailData({required this.driver, required this.trucks});

  final DriverProfile driver;
  final List<TruckModel> trucks;
}

class _ShipperHero extends StatelessWidget {
  const _ShipperHero({required this.shipper});

  final ShipperProfile shipper;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(22),
        boxShadow: const [BoxShadow(color: Color(0x2200535B), blurRadius: 18, offset: Offset(0, 10))],
      ),
      child: Row(
        children: [
          _Avatar(user: shipper.user, radius: 38, fallbackIcon: Icons.business_outlined),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(shipper.user.fullName.isEmpty ? 'Expéditeur' : shipper.user.fullName, style: const TextStyle(color: Colors.white, fontSize: 23, fontWeight: FontWeight.w900)),
                const SizedBox(height: 4),
                Text(shipper.companyName.isEmpty ? 'Entreprise non renseignée' : shipper.companyName, style: TextStyle(color: Colors.white.withOpacity(.82))),
                const SizedBox(height: 8),
                Row(children: [
                  const Icon(Icons.star, color: AppColors.accent, size: 18),
                  const SizedBox(width: 5),
                  Text('${shipper.averageRating.toStringAsFixed(1)} · ${shipper.completedOffers} offres', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
                ]),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DriverProfileHero extends StatelessWidget {
  const _DriverProfileHero({required this.driver});

  final DriverProfile driver;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [AppColors.primary, AppColors.primaryContainer]),
        borderRadius: BorderRadius.circular(22),
        boxShadow: const [BoxShadow(color: Color(0x2200535B), blurRadius: 18, offset: Offset(0, 10))],
      ),
      child: Row(
        children: [
          _Avatar(user: driver.user, radius: 42, fallbackIcon: Icons.person_outline),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(driver.user.fullName.isEmpty ? 'Chauffeur' : driver.user.fullName, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900)),
                const SizedBox(height: 4),
                Text(driver.currentCity.isEmpty ? 'Ville non renseignée' : driver.currentCity, style: TextStyle(color: Colors.white.withOpacity(.84))),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _SmallDarkChip(icon: Icons.star, label: driver.averageRating.toStringAsFixed(1)),
                    _SmallDarkChip(icon: Icons.done_all, label: '${driver.completedJobs} missions'),
                    _SmallDarkChip(icon: driver.available ? Icons.check_circle : Icons.pause_circle, label: driver.available ? 'Disponible' : 'Indisponible'),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfessionalDriverCard extends StatelessWidget {
  const _ProfessionalDriverCard({required this.driver, required this.onTap, required this.onWhatsApp});

  final DriverProfile driver;
  final VoidCallback onTap;
  final VoidCallback onWhatsApp;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: _cardDecoration(),
        child: Column(
          children: [
            Row(
              children: [
                _Avatar(user: driver.user, radius: 34, fallbackIcon: Icons.person_outline, light: true),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(driver.user.fullName.isEmpty ? 'Chauffeur' : driver.user.fullName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.text)),
                      const SizedBox(height: 3),
                      Text(driver.currentCity.isEmpty ? 'Ville non renseignée' : driver.currentCity, style: const TextStyle(color: AppColors.muted, fontWeight: FontWeight.w700)),
                    ],
                  ),
                ),
                Icon(driver.available ? Icons.check_circle : Icons.pause_circle, color: driver.available ? AppColors.success : AppColors.muted),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                _InlineMetric(icon: Icons.star, text: driver.averageRating.toStringAsFixed(1), color: AppColors.accent),
                const SizedBox(width: 14),
                _InlineMetric(icon: Icons.local_shipping_outlined, text: '${driver.completedJobs} missions', color: AppColors.primary),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(child: OutlinedButton.icon(onPressed: onTap, icon: const Icon(Icons.visibility_outlined), label: const Text('Profil'))),
                const SizedBox(width: 10),
                IconButton.filled(
                  onPressed: onWhatsApp,
                  style: IconButton.styleFrom(backgroundColor: AppColors.whatsApp, foregroundColor: Colors.white),
                  icon: const Icon(Icons.chat),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ApplicationPanel extends StatelessWidget {
  const _ApplicationPanel({required this.app, required this.onDriverTap, required this.onAccept, required this.onReject});

  final Map<String, dynamic> app;
  final VoidCallback onDriverTap;
  final VoidCallback onAccept;
  final VoidCallback onReject;

  @override
  Widget build(BuildContext context) {
    final driver = ((app['driver'] as Map?)?.cast<String, dynamic>()) ?? <String, dynamic>{};
    final user = ((driver['user'] as Map?)?.cast<String, dynamic>()) ?? <String, dynamic>{};
    final profile = DriverProfile.fromJson(driver);
    final status = app['status']?.toString() ?? '';
    final pending = status == 'PENDING';
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: onDriverTap,
            child: Row(
              children: [
                _Avatar(user: profile.user, radius: 30, fallbackIcon: Icons.person_outline, light: true),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${user['firstName'] ?? ''} ${user['lastName'] ?? ''}'.trim().isEmpty ? 'Chauffeur' : '${user['firstName'] ?? ''} ${user['lastName'] ?? ''}'.trim(), style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900)),
                      Text(profile.currentCity.isEmpty ? 'Voir le profil et les véhicules' : profile.currentCity, style: const TextStyle(color: AppColors.muted, fontWeight: FontWeight.w700)),
                    ],
                  ),
                ),
                StatusChip(status),
              ],
            ),
          ),
          if ((app['message']?.toString() ?? '').isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(app['message'].toString(), style: const TextStyle(color: AppColors.muted, height: 1.35)),
          ],
          const SizedBox(height: 12),
          Text(money(app['proposedPrice'] ?? 0), style: const TextStyle(color: AppColors.secondary, fontSize: 22, fontWeight: FontWeight.w900)),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: ElevatedButton.icon(onPressed: pending ? onAccept : null, icon: const Icon(Icons.check), label: const Text('Accepter'))),
              const SizedBox(width: 10),
              Expanded(child: OutlinedButton.icon(onPressed: pending ? onReject : null, icon: const Icon(Icons.close), label: const Text('Refuser'))),
            ],
          ),
        ],
      ),
    );
  }
}

class _PublicTruckCard extends StatelessWidget {
  const _PublicTruckCard({required this.truck});

  final TruckModel truck;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: _cardDecoration(),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _StoredImagePreview(imageValue: truck.imageUrl, fallbackIcon: Icons.local_shipping, height: 142, width: double.infinity),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(child: Text('${truck.brand} ${truck.model}'.trim().isEmpty ? vehicleFr(truck.vehicleType) : '${truck.brand} ${truck.model}'.trim(), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900))),
                    StatusChip(truck.active ? 'ACCEPTED' : 'REJECTED'),
                  ],
                ),
                const SizedBox(height: 8),
                _InfoRow(Icons.confirmation_number_outlined, truck.plateNumber.isEmpty ? '-' : truck.plateNumber),
                const SizedBox(height: 8),
                _InfoRow(Icons.scale_outlined, '${vehicleFr(truck.vehicleType)} · ${truck.capacityKg.toStringAsFixed(0)} kg'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ShipperOfferCard extends StatelessWidget {
  const _ShipperOfferCard({required this.offer, required this.onTap, required this.onCancel, required this.onDelete});

  final OfferSummary offer;
  final VoidCallback onTap;
  final VoidCallback onCancel;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: _cardDecoration(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(child: Text(offer.title, style: const TextStyle(color: AppColors.primary, fontSize: 19, fontWeight: FontWeight.w900))),
                StatusChip(offer.status),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'cancel') onCancel();
                    if (value == 'delete') onDelete();
                  },
                  itemBuilder: (_) => const [
                    PopupMenuItem(value: 'cancel', child: Text('Annuler')),
                    PopupMenuItem(value: 'delete', child: Text('Supprimer')),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            _InfoRow(Icons.route_outlined, '${offer.departureCity} → ${offer.arrivalCity}'),
            const SizedBox(height: 8),
            _InfoRow(Icons.inventory_2_outlined, '${vehicleFr(offer.vehicleType)} · ${offer.weightKg.toStringAsFixed(0)} kg'),
            const SizedBox(height: 14),
            Row(
              children: [
                Text(money(offer.price), style: const TextStyle(color: AppColors.secondary, fontSize: 22, fontWeight: FontWeight.w900)),
                const Spacer(),
                TextButton(onPressed: onTap, child: const Text('Détails')),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ImagePickerField extends StatelessWidget {
  const _ImagePickerField({
    required this.imageValue,
    required this.title,
    required this.subtitle,
    required this.fallbackIcon,
    required this.onPick,
    this.onClear,
    this.rounded = false,
  });

  final String imageValue;
  final String title;
  final String subtitle;
  final IconData fallbackIcon;
  final VoidCallback onPick;
  final VoidCallback? onClear;
  final bool rounded;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: AppColors.surfaceLow, borderRadius: BorderRadius.circular(18), border: Border.all(color: const Color(0xFFE0EAEA))),
      child: Row(
        children: [
          _StoredImagePreview(imageValue: imageValue, fallbackIcon: fallbackIcon, height: 82, width: 82, rounded: rounded),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w900, fontSize: 15)),
                const SizedBox(height: 3),
                Text(subtitle, style: const TextStyle(color: AppColors.muted, fontSize: 12, fontWeight: FontWeight.w700)),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    ElevatedButton.icon(onPressed: onPick, icon: const Icon(Icons.photo_library_outlined, size: 18), label: const Text('Galerie')),
                    if (onClear != null) TextButton.icon(onPressed: onClear, icon: const Icon(Icons.close, size: 18), label: const Text('Retirer')),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.user, required this.radius, required this.fallbackIcon, this.light = false});

  final UserModel user;
  final double radius;
  final IconData fallbackIcon;
  final bool light;

  @override
  Widget build(BuildContext context) {
    final imageProvider = _storedImageProvider(user.profileImageUrl);
    if (imageProvider != null) return CircleAvatar(radius: radius, backgroundImage: imageProvider);
    return CircleAvatar(
      radius: radius,
      backgroundColor: light ? AppColors.primary.withOpacity(.12) : Colors.white.withOpacity(.18),
      child: user.firstName.isEmpty
          ? Icon(fallbackIcon, color: light ? AppColors.primary : Colors.white, size: radius)
          : Text(user.firstName.substring(0, 1).toUpperCase(), style: TextStyle(color: light ? AppColors.primary : Colors.white, fontSize: radius * .82, fontWeight: FontWeight.w900)),
    );
  }
}

class _StoredImagePreview extends StatelessWidget {
  const _StoredImagePreview({required this.imageValue, required this.fallbackIcon, required this.height, required this.width, this.rounded = false});

  final String imageValue;
  final IconData fallbackIcon;
  final double height;
  final double width;
  final bool rounded;

  @override
  Widget build(BuildContext context) {
    final trimmed = imageValue.trim();
    final radius = rounded ? BorderRadius.circular(height / 2) : BorderRadius.circular(16);
    Widget child = _fallback();
    final bytes = _dataImageBytes(trimmed);
    if (bytes != null) {
      child = Image.memory(bytes, height: height, width: width, fit: BoxFit.cover);
    } else if (trimmed.isNotEmpty && !trimmed.startsWith('data:image')) {
      child = Image.network(trimmed, height: height, width: width, fit: BoxFit.cover, errorBuilder: (_, __, ___) => _fallback());
    }
    return ClipRRect(borderRadius: radius, child: child);
  }

  Widget _fallback() {
    return Container(
      height: height,
      width: width,
      decoration: const BoxDecoration(gradient: LinearGradient(colors: [Color(0xFFDCE9EA), AppColors.primary])),
      child: Icon(fallbackIcon, size: height * .46, color: Colors.white.withOpacity(.86)),
    );
  }
}

class _MetricTile extends StatelessWidget {
  const _MetricTile({required this.icon, required this.value, required this.label, this.color = AppColors.primary});

  final IconData icon;
  final String value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 96,
      padding: const EdgeInsets.all(12),
      decoration: _cardDecoration(),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 6),
          FittedBox(child: Text(value, maxLines: 1, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900))),
          Text(label, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: AppColors.muted, fontSize: 12)),
        ],
      ),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  const _QuickActionCard({required this.icon, required this.title, required this.subtitle, required this.color, required this.onTap});

  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: _cardDecoration(),
        child: Row(
          children: [
            Container(width: 50, height: 50, decoration: BoxDecoration(color: color.withOpacity(.12), borderRadius: BorderRadius.circular(14)), child: Icon(icon, color: color, size: 30)),
            const SizedBox(width: 14),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900, color: AppColors.text)),
              const SizedBox(height: 3),
              Text(subtitle, style: const TextStyle(color: AppColors.muted, height: 1.28)),
            ])),
            const Icon(Icons.chevron_right, color: AppColors.primary),
          ],
        ),
      ),
    );
  }
}

class _CreateOfferBanner extends StatelessWidget {
  const _CreateOfferBanner({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(color: AppColors.accent.withOpacity(.12), borderRadius: BorderRadius.circular(18), border: Border.all(color: AppColors.accent.withOpacity(.45))),
        child: const Row(children: [
          Icon(Icons.add_circle_outline, color: AppColors.secondary, size: 30),
          SizedBox(width: 12),
          Expanded(child: Text('Créer une nouvelle offre', style: TextStyle(color: AppColors.secondary, fontWeight: FontWeight.w900, fontSize: 16))),
          Icon(Icons.chevron_right, color: AppColors.secondary),
        ]),
      ),
    );
  }
}

class _OfferSelectorChip extends StatelessWidget {
  const _OfferSelectorChip({required this.label, required this.selected, required this.onTap});

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 220),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: selected ? AppColors.primary : AppColors.outline),
        ),
        child: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: selected ? Colors.white : AppColors.muted, fontWeight: FontWeight.w900)),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.icon, required this.title, required this.subtitle});

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(width: 48, height: 48, decoration: BoxDecoration(color: AppColors.primary.withOpacity(.1), borderRadius: BorderRadius.circular(14)), child: Icon(icon, color: AppColors.primary, size: 28)),
        const SizedBox(width: 14),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: const TextStyle(color: AppColors.primary, fontSize: 21, fontWeight: FontWeight.w900)),
          Text(subtitle, style: const TextStyle(color: AppColors.muted, height: 1.25)),
        ])),
      ],
    );
  }
}

class _Panel extends StatelessWidget {
  const _Panel({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(width: double.infinity, padding: const EdgeInsets.all(16), decoration: _cardDecoration(), child: child);
  }
}

class _SettingsAction extends StatelessWidget {
  const _SettingsAction({required this.icon, required this.title, required this.subtitle, required this.onTap, this.danger = false});

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    final color = danger ? AppColors.error : AppColors.primary;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: _cardDecoration(),
        child: Row(children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(width: 14),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: TextStyle(color: color, fontWeight: FontWeight.w900, fontSize: 16)),
            Text(subtitle, style: const TextStyle(color: AppColors.muted)),
          ])),
          Icon(Icons.chevron_right, color: color),
        ]),
      ),
    );
  }
}

class _PrettyEmpty extends StatelessWidget {
  const _PrettyEmpty({required this.icon, required this.title, required this.message, this.actionLabel, this.onAction});

  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: _cardDecoration(),
      child: Column(children: [
        Icon(icon, color: AppColors.primary, size: 44),
        const SizedBox(height: 12),
        Text(title, textAlign: TextAlign.center, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
        const SizedBox(height: 8),
        Text(message, textAlign: TextAlign.center, style: const TextStyle(color: AppColors.muted)),
        if (actionLabel != null && onAction != null) ...[
          const SizedBox(height: 16),
          ElevatedButton(onPressed: onAction, child: Text(actionLabel!)),
        ],
      ]),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow(this.icon, this.text);

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Icon(icon, color: AppColors.primary, size: 19),
      const SizedBox(width: 8),
      Expanded(child: Text(text, style: const TextStyle(color: AppColors.muted, fontWeight: FontWeight.w700))),
    ]);
  }
}

class _InlineMetric extends StatelessWidget {
  const _InlineMetric({required this.icon, required this.text, required this.color});

  final IconData icon;
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Icon(icon, color: color, size: 18),
      const SizedBox(width: 5),
      Text(text, style: const TextStyle(color: AppColors.muted, fontWeight: FontWeight.w800)),
    ]);
  }
}

class _SmallDarkChip extends StatelessWidget {
  const _SmallDarkChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(color: Colors.white.withOpacity(.14), borderRadius: BorderRadius.circular(99)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, color: AppColors.accent, size: 15),
        const SizedBox(width: 5),
        Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 12)),
      ]),
    );
  }
}

class _SuggestionChip extends StatelessWidget {
  const _SuggestionChip({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      label: Text(label),
      onPressed: onTap,
      backgroundColor: AppColors.surfaceLow,
      side: const BorderSide(color: AppColors.outline),
      labelStyle: const TextStyle(color: AppColors.muted, fontWeight: FontWeight.w800),
    );
  }
}

class _AssistantBubble extends StatelessWidget {
  const _AssistantBubble({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 430),
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: AppColors.primaryContainer,
        borderRadius: BorderRadius.only(topRight: Radius.circular(18), bottomLeft: Radius.circular(18), bottomRight: Radius.circular(18)),
      ),
      child: Text(text, style: const TextStyle(color: Colors.white, fontSize: 17, height: 1.35, fontWeight: FontWeight.w700)),
    );
  }
}

class _ErrorPanel extends StatelessWidget {
  const _ErrorPanel({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.error.withOpacity(.08), borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.error.withOpacity(.3))),
      child: Row(children: [
        const Icon(Icons.error_outline, color: AppColors.error),
        const SizedBox(width: 10),
        Expanded(child: Text(message, style: const TextStyle(color: AppColors.error, fontWeight: FontWeight.w800))),
        TextButton(onPressed: onRetry, child: const Text('Réessayer')),
      ]),
    );
  }
}

BoxDecoration _cardDecoration() {
  return BoxDecoration(
    color: AppColors.surface,
    borderRadius: BorderRadius.circular(18),
    border: Border.all(color: const Color(0xFFE4EAEA)),
    boxShadow: const [BoxShadow(color: Color(0x0F000000), blurRadius: 14, offset: Offset(0, 6))],
  );
}

const _vehicleTypes = ['MOTORCYCLE', 'SMALL_VAN', 'PICKUP', 'VAN', 'SMALL_TRUCK', 'MEDIUM_TRUCK', 'BIG_TRUCK'];

String _goodsFr(String type) {
  return switch (type) {
    'FOOD' => 'Alimentaire',
    'FURNITURE' => 'Meubles',
    'ELECTRONICS' => 'Électronique',
    'CONSTRUCTION_MATERIALS' => 'Matériaux',
    'CLOTHES' => 'Vêtements',
    'AGRICULTURE' => 'Agriculture',
    _ => 'Autre',
  };
}
