import 'package:flutter/material.dart';

import '../../core/app_state.dart';
import '../../core/app_theme.dart';
import '../../core/e_samsar_api.dart';
import '../../core/models.dart';
import '../../features/auth/auth_screens.dart';
import '../../shared/actions.dart';
import '../../shared/cards.dart';
import '../../shared/ui.dart';

ESamsarApi _api(BuildContext context) => ESamsarApi(AppStateScope.read(context).api);

class DriverHomeScreen extends StatefulWidget {
  const DriverHomeScreen({super.key});

  @override
  State<DriverHomeScreen> createState() => _DriverHomeScreenState();
}

class _DriverHomeScreenState extends State<DriverHomeScreen> {
  late Future<_DriverDashboardData> future;

  @override
  void initState() {
    super.initState();
    future = _load();
  }

  Future<_DriverDashboardData> _load() async {
    final api = _api(context);
    final driver = await api.driverMe();
    final trucks = await api.trucks().catchError((_) => <TruckModel>[]);
    final applications = await api.myApplications().catchError((_) => <dynamic>[]);
    return _DriverDashboardData(driver: driver, trucks: trucks, applications: applications);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: FutureBuilder<_DriverDashboardData>(
        future: future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || !snapshot.hasData) {
            return _DriverHomeError(
              onRetry: () => setState(() {
                future = _load();
              }),
            );
          }

          final data = snapshot.data!;
          final driver = data.driver;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Bienvenue,', style: TextStyle(color: AppColors.muted)),
                        Text('Bonjour, ${driver.user.firstName}', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: AppColors.primary)),
                      ],
                    ),
                  ),
                  FilterChip(
                    selected: driver.available,
                    label: Text(driver.available ? 'Disponible' : 'Indisponible'),
                    onSelected: (value) async {
                      await _api(context).setAvailability(value);
                      setState(() {
                        future = _load();
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(child: StatCard(icon: Icons.star, value: driver.averageRating.toStringAsFixed(1), label: 'Note', color: AppColors.accent)),
                  const SizedBox(width: 10),
                  Expanded(child: StatCard(icon: Icons.local_shipping, value: '${driver.completedJobs}', label: 'Missions')),
                  const SizedBox(width: 10),
                  Expanded(child: StatCard(icon: Icons.location_on, value: driver.currentCity.isEmpty ? '-' : driver.currentCity, label: 'Ville')),
                ],
              ),
              const SizedBox(height: 22),
              _QuickAction(
                icon: Icons.search,
                title: 'Parcourir les offres',
                subtitle: 'Trouvez votre prochaine mission de transport.',
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const DriverOffersScreen())),
              ),
              _QuickAction(
                icon: Icons.smart_toy,
                title: 'Recherche IA',
                subtitle: 'Décrivez l’offre que vous cherchez.',
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AiAssistantScreen())),
              ),
            ],
            ),
          );
        },
      ),
    );
  }
}

class _DriverDashboardData {
  const _DriverDashboardData({
    required this.driver,
    required this.trucks,
    required this.applications,
  });

  final DriverProfile driver;
  final List<TruckModel> trucks;
  final List<dynamic> applications;
}

class _DriverHomeError extends StatelessWidget {
  const _DriverHomeError({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off_outlined, color: AppColors.primary, size: 46),
            const SizedBox(height: 12),
            const Text('Impossible de charger le tableau de bord', textAlign: TextAlign.center, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
            const SizedBox(height: 8),
            const Text('Vérifiez la connexion au backend puis réessayez.', textAlign: TextAlign.center, style: TextStyle(color: AppColors.muted)),
            const SizedBox(height: 18),
            ElevatedButton(onPressed: onRetry, child: const Text('Réessayer')),
          ],
        ),
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  const _QuickAction({required this.icon, required this.title, required this.subtitle, required this.onTap});

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
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
                    Text(subtitle, style: const TextStyle(color: AppColors.muted)),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}

class DriverOffersScreen extends StatefulWidget {
  const DriverOffersScreen({super.key});

  @override
  State<DriverOffersScreen> createState() => _DriverOffersScreenState();
}

class _DriverOffersScreenState extends State<DriverOffersScreen> {
  bool availableOnly = true;
  late Future<List<OfferSummary>> future;

  Future<List<OfferSummary>> _load() => _api(context).offers(availableOnly: availableOnly);

  @override
  void initState() {
    super.initState();
    future = _load();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Offres disponibles',
      child: Column(
        children: [
          SegmentedButton<bool>(
            segments: const [
              ButtonSegment(value: true, label: Text('Disponibles')),
              ButtonSegment(value: false, label: Text('Toutes')),
            ],
            selected: {availableOnly},
            onSelectionChanged: (value) => setState(() {
              availableOnly = value.first;
              future = _load();
            }),
          ),
          const SizedBox(height: 16),
          FutureBuilder<List<OfferSummary>>(
            future: future,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) return const CircularProgressIndicator();
              if (snapshot.hasError) {
                return EmptyState(icon: Icons.cloud_off_outlined, title: 'Impossible de charger les offres', message: snapshot.error.toString());
              }
              if (!snapshot.hasData) return const CircularProgressIndicator();
              final offers = snapshot.data!;
              if (offers.isEmpty) {
                return const EmptyState(icon: Icons.inventory_2_outlined, title: 'Aucune offre disponible', message: 'Revenez plus tard ou essayez la recherche IA.');
              }
              return Column(
                children: offers.map((offer) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: OfferCard(
                    offer: offer,
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => OfferDetailsScreen(offerId: offer.id, driverMode: true))),
                    trailing: const Icon(Icons.chevron_right),
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

class OfferDetailsScreen extends StatefulWidget {
  const OfferDetailsScreen({required this.offerId, required this.driverMode, super.key});

  final int offerId;
  final bool driverMode;

  @override
  State<OfferDetailsScreen> createState() => _OfferDetailsScreenState();
}

class _OfferDetailsScreenState extends State<OfferDetailsScreen> {
  late Future<Map<String, dynamic>> future;

  @override
  void initState() {
    super.initState();
    future = _api(context).offerDetails(widget.offerId);
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Détails de l’offre',
      child: FutureBuilder<Map<String, dynamic>>(
        future: future,
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const CircularProgressIndicator();
          final o = snapshot.data!;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(child: Text(o['title'] ?? '', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900))),
                        StatusChip(o['status'] ?? ''),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(o['description'] ?? '', style: const TextStyle(color: AppColors.muted)),
                    const Divider(height: 28),
                    _InfoLine(icon: Icons.route, text: '${o['departureCity']} → ${o['arrivalCity']}'),
                    _InfoLine(icon: Icons.inventory, text: '${o['weightKg']} kg · ${vehicleFr(o['requiredVehicleType'] ?? '')}'),
                    _InfoLine(icon: Icons.payments, text: money(o['proposedPrice'] ?? 0)),
                    _InfoLine(icon: Icons.calendar_month, text: o['transportDate']?.toString() ?? '-'),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              if (widget.driverMode) ...[
                ElevatedButton.icon(onPressed: _apply, icon: const Icon(Icons.send), label: const Text('Postuler à cette offre')),
                const SizedBox(height: 10),
                OutlinedButton.icon(onPressed: _contactShipper, icon: const Icon(Icons.chat), label: const Text('Contacter sur WhatsApp')),
              ] else ...[
                ElevatedButton(onPressed: () => _api(context).startOffer(widget.offerId).then((_) => showSuccess(context, 'Transport démarré.')).catchError((e) => showError(context, e)), child: const Text('Démarrer le transport')),
                const SizedBox(height: 10),
                OutlinedButton(onPressed: () => _api(context).completeOffer(widget.offerId).then((_) => showSuccess(context, 'Offre terminée.')).catchError((e) => showError(context, e)), child: const Text('Terminer le transport')),
              ],
            ],
          );
        },
      ),
    );
  }

  Future<void> _apply() async {
    final message = TextEditingController();
    final price = TextEditingController();
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => Padding(
        padding: EdgeInsets.fromLTRB(16, 16, 16, MediaQuery.of(context).viewInsets.bottom + 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Postuler à l’offre', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
            const SizedBox(height: 12),
            TextField(controller: message, decoration: const InputDecoration(labelText: 'Message')),
            const SizedBox(height: 12),
            TextField(controller: price, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Prix proposé')),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                try {
                  await _api(context).applyToOffer(widget.offerId, message.text, price.text);
                  if (!mounted) return;
                  Navigator.pop(context);
                  showSuccess(context, 'Candidature envoyée avec succès.');
                } catch (e) {
                  if (mounted) showError(context, e);
                }
              },
              child: const Text('Envoyer ma candidature'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _contactShipper() async {
    try {
      final json = await _api(context).whatsappShipper(widget.offerId);
      if (mounted) await openExternalUrl(context, json['whatsappUrl']);
    } catch (e) {
      if (mounted) showError(context, e);
    }
  }
}

class _InfoLine extends StatelessWidget {
  const _InfoLine({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(children: [Icon(icon, size: 18, color: AppColors.primary), const SizedBox(width: 8), Expanded(child: Text(text))]),
    );
  }
}

class DriverApplicationsScreen extends StatefulWidget {
  const DriverApplicationsScreen({super.key});

  @override
  State<DriverApplicationsScreen> createState() => _DriverApplicationsScreenState();
}

class _DriverApplicationsScreenState extends State<DriverApplicationsScreen> {
  late Future<List<dynamic>> future;

  @override
  void initState() {
    super.initState();
    future = _api(context).myApplications();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Mes candidatures',
      child: FutureBuilder<List<dynamic>>(
        future: future,
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const CircularProgressIndicator();
          final apps = snapshot.data!;
          if (apps.isEmpty) return const EmptyState(icon: Icons.assignment_outlined, title: 'Aucune candidature', message: 'Postulez à une offre pour la retrouver ici.');
          return Column(
            children: apps.map((app) {
              final offer = app['offer'] ?? {};
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [Expanded(child: Text(offer['title'] ?? '', style: const TextStyle(fontWeight: FontWeight.w800))), StatusChip(app['status'] ?? '')]),
                      Text('${offer['departureCity']} → ${offer['arrivalCity']}'),
                      Text(money(app['proposedPrice'] ?? 0), style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w900)),
                      if (app['status'] == 'PENDING') TextButton(onPressed: () async {
                        await _api(context).cancelApplication(app['id']);
                        setState(() {
                          future = _api(context).myApplications();
                        });
                      }, child: const Text('Annuler la candidature')),
                    ],
                  ),
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}

class DriverTrucksScreen extends StatefulWidget {
  const DriverTrucksScreen({super.key});

  @override
  State<DriverTrucksScreen> createState() => _DriverTrucksScreenState();
}

class _DriverTrucksScreenState extends State<DriverTrucksScreen> {
  late Future<List<TruckModel>> future;

  @override
  void initState() {
    super.initState();
    future = _api(context).trucks();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Mes véhicules',
      actions: [IconButton(onPressed: () => _showTruckForm(), icon: const Icon(Icons.add))],
      child: FutureBuilder<List<TruckModel>>(
        future: future,
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const CircularProgressIndicator();
          final trucks = snapshot.data!;
          if (trucks.isEmpty) return const EmptyState(icon: Icons.local_shipping_outlined, title: 'Aucun véhicule ajouté', message: 'Ajoutez votre premier véhicule pour commencer.');
          return Column(
            children: trucks.map((truck) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: TruckCard(
                truck: truck,
                onEdit: () => _showTruckForm(truck),
                onToggle: () async {
                  await _api(context).setTruckActive(truck.id, !truck.active);
                  setState(() {
                    future = _api(context).trucks();
                  });
                },
                onDelete: () async {
                  await _api(context).deleteTruck(truck.id);
                  setState(() {
                    future = _api(context).trucks();
                  });
                },
              ),
            )).toList(),
          );
        },
      ),
    );
  }

  Future<void> _showTruckForm([TruckModel? truck]) async {
    final brand = TextEditingController(text: truck?.brand ?? '');
    final model = TextEditingController(text: truck?.model ?? '');
    final plate = TextEditingController(text: truck?.plateNumber ?? '');
    final capacity = TextEditingController(text: truck?.capacityKg.toStringAsFixed(0) ?? '');
    String type = truck?.vehicleType ?? 'VAN';
    bool active = truck?.active ?? true;
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => StatefulBuilder(
        builder: (context, setSheet) => Padding(
          padding: EdgeInsets.fromLTRB(16, 16, 16, MediaQuery.of(context).viewInsets.bottom + 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(truck == null ? 'Ajouter un véhicule' : 'Modifier le véhicule', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
              const SizedBox(height: 12),
              TextField(controller: brand, decoration: const InputDecoration(labelText: 'Marque')),
              const SizedBox(height: 8),
              TextField(controller: model, decoration: const InputDecoration(labelText: 'Modèle')),
              const SizedBox(height: 8),
              TextField(controller: plate, decoration: const InputDecoration(labelText: 'Immatriculation')),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: type,
                decoration: const InputDecoration(labelText: 'Type de véhicule'),
                items: ['MOTORCYCLE', 'SMALL_VAN', 'PICKUP', 'VAN', 'SMALL_TRUCK', 'MEDIUM_TRUCK', 'BIG_TRUCK']
                    .map((v) => DropdownMenuItem(value: v, child: Text(vehicleFr(v))))
                    .toList(),
                onChanged: (v) => setSheet(() => type = v!),
              ),
              const SizedBox(height: 8),
              TextField(controller: capacity, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Capacité en kg')),
              SwitchListTile(value: active, onChanged: (v) => setSheet(() => active = v), title: const Text('Véhicule actif')),
              ElevatedButton(
                onPressed: () async {
                  await _api(context).saveTruck({
                    'brand': brand.text,
                    'model': model.text,
                    'plateNumber': plate.text,
                    'vehicleType': type,
                    'capacityKg': num.tryParse(capacity.text) ?? 0,
                    'active': active,
                  }, id: truck?.id);
                  if (!mounted) return;
                  Navigator.pop(context);
                  setState(() {
                    future = _api(context).trucks();
                  });
                },
                child: const Text('Enregistrer'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class DriverProfileScreen extends StatelessWidget {
  const DriverProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = AppStateScope.of(context);
    return AppScaffold(
      title: 'Mon profil',
      child: Column(
        children: [
          FutureBuilder<DriverProfile>(
            future: _api(context).driverMe(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const CircularProgressIndicator();
              final driver = snapshot.data!;
              return AppCard(
                child: Column(
                  children: [
                    const CircleAvatar(radius: 34, child: Icon(Icons.person, size: 34)),
                    const SizedBox(height: 12),
                    Text(driver.user.fullName, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
                    Text(driver.user.email, style: const TextStyle(color: AppColors.muted)),
                    const Divider(height: 28),
                    _InfoLine(icon: Icons.phone, text: driver.user.phone),
                    _InfoLine(icon: Icons.location_on, text: driver.currentCity),
                    _InfoLine(icon: Icons.star, text: 'Note ${driver.averageRating.toStringAsFixed(1)}'),
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

class AiAssistantScreen extends StatefulWidget {
  const AiAssistantScreen({super.key});

  @override
  State<AiAssistantScreen> createState() => _AiAssistantScreenState();
}

class _AiAssistantScreenState extends State<AiAssistantScreen> {
  final message = TextEditingController();
  Map<String, dynamic>? response;
  bool busy = false;

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Assistant IA',
      child: Column(
        children: [
          AppCard(
            child: Column(
              children: [
                TextField(controller: message, minLines: 2, maxLines: 4, decoration: const InputDecoration(labelText: 'Décrivez votre recherche')),
                const SizedBox(height: 12),
                ElevatedButton(onPressed: busy ? null : _send, child: const Text('Rechercher')),
              ],
            ),
          ),
          const SizedBox(height: 16),
          if (busy) const CircularProgressIndicator(),
          if (response != null) _AiResults(response: response!),
        ],
      ),
    );
  }

  Future<void> _send() async {
    setState(() => busy = true);
    try {
      response = await _api(context).aiChat(message.text);
    } catch (e) {
      if (mounted) showError(context, e);
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }
}

class _AiResults extends StatelessWidget {
  const _AiResults({required this.response});

  final Map<String, dynamic> response;

  @override
  Widget build(BuildContext context) {
    final results = response['results'] ?? {};
    final offers = (results['offers'] as List?) ?? [];
    final drivers = (results['drivers'] as List?) ?? [];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Résultats', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
        const SizedBox(height: 10),
        if (offers.isEmpty && drivers.isEmpty)
          const EmptyState(icon: Icons.smart_toy_outlined, title: 'Aucun résultat trouvé', message: 'Essayez une recherche plus précise.'),
        ...offers.whereType<Map<String, dynamic>>().map((json) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: OfferCard(offer: OfferSummary.fromJson(json)),
        )),
        ...drivers.whereType<Map<String, dynamic>>().map((json) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: DriverCard(driver: DriverProfile.fromJson(json)),
        )),
      ],
    );
  }
}

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  late Future<List<NotificationModel>> future;

  @override
  void initState() {
    super.initState();
    future = _api(context).notifications();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Notifications', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w900)),
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.primary,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: () async {
              await _api(context).markAllNotificationsRead();
              if (!mounted) return;
              setState(() {
                future = _api(context).notifications();
              });
            },
            child: const Text('Tout lire'),
          ),
        ],
      ),
      body: SafeArea(
        child: FutureBuilder<List<NotificationModel>>(
          future: future,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Padding(
                padding: const EdgeInsets.all(18),
                child: EmptyState(icon: Icons.cloud_off_outlined, title: 'Notifications indisponibles', message: snapshot.error.toString()),
              );
            }
            final items = snapshot.data ?? [];
            if (items.isEmpty) {
              return const Padding(
                padding: EdgeInsets.all(18),
                child: EmptyState(icon: Icons.notifications_none, title: 'Aucune notification', message: 'Vos notifications apparaîtront ici.'),
              );
            }
            return ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
              itemBuilder: (context, index) {
                final notification = items[index];
                return _ProfessionalNotificationCard(
                  notification: notification,
                  onOpen: () => _openNotification(notification),
                  onRead: () => _markRead(notification),
                );
              },
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemCount: items.length,
            );
          },
        ),
      ),
    );
  }

  Future<void> _markRead(NotificationModel notification) async {
    await _api(context).markNotificationRead(notification.id);
    if (!mounted) return;
    setState(() {
      future = _api(context).notifications();
    });
  }

  Future<void> _openNotification(NotificationModel notification) async {
    if (!notification.seen) {
      await _api(context).markNotificationRead(notification.id);
    }
    if (!mounted) return;
    setState(() {
      future = _api(context).notifications();
    });
    if (notification.offerId != null) {
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => OfferDetailsScreen(offerId: notification.offerId!, driverMode: true)),
      );
      if (!mounted) return;
      setState(() {
        future = _api(context).notifications();
      });
    } else {
      _showNotificationDetails(notification);
    }
  }

  void _showNotificationDetails(NotificationModel notification) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _NotificationIcon(type: notification.type, seen: notification.seen),
                const SizedBox(width: 12),
                Expanded(child: Text(notification.title, style: const TextStyle(color: AppColors.primary, fontSize: 21, fontWeight: FontWeight.w900))),
              ],
            ),
            const SizedBox(height: 14),
            Text(notification.message, style: const TextStyle(color: AppColors.muted, height: 1.4, fontWeight: FontWeight.w700)),
            const SizedBox(height: 18),
            ElevatedButton(onPressed: () => Navigator.pop(context), child: const Text('Compris')),
          ],
        ),
      ),
    );
  }
}

class _ProfessionalNotificationCard extends StatelessWidget {
  const _ProfessionalNotificationCard({required this.notification, required this.onOpen, required this.onRead});

  final NotificationModel notification;
  final VoidCallback onOpen;
  final VoidCallback onRead;

  @override
  Widget build(BuildContext context) {
    final hasOffer = notification.offerId != null;
    return InkWell(
      onTap: onOpen,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: notification.seen ? const Color(0xFFE4EAEA) : AppColors.primary.withOpacity(.35)),
          boxShadow: const [BoxShadow(color: Color(0x0F000000), blurRadius: 14, offset: Offset(0, 6))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _NotificationIcon(type: notification.type, seen: notification.seen),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(notification.title, style: const TextStyle(color: AppColors.text, fontSize: 16, fontWeight: FontWeight.w900)),
                      const SizedBox(height: 2),
                      Text(
                        '${_notificationTypeFr(notification.type)}${_notificationDate(notification.createdAt).isEmpty ? '' : ' · ${_notificationDate(notification.createdAt)}'}',
                        style: const TextStyle(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.w900),
                      ),
                    ],
                  ),
                ),
                if (!notification.seen)
                  Container(width: 10, height: 10, decoration: const BoxDecoration(color: AppColors.accent, shape: BoxShape.circle))
                else
                  const Icon(Icons.done_all, color: AppColors.success, size: 20),
              ],
            ),
            const SizedBox(height: 12),
            Text(notification.message, maxLines: 3, overflow: TextOverflow.ellipsis, style: const TextStyle(color: AppColors.muted, height: 1.35, fontWeight: FontWeight.w700)),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: onOpen,
                    icon: Icon(hasOffer ? Icons.inventory_2_outlined : Icons.visibility_outlined),
                    label: Text(hasOffer ? 'Voir l’offre' : 'Détails'),
                  ),
                ),
                const SizedBox(width: 10),
                IconButton.filledTonal(
                  onPressed: onRead,
                  icon: Icon(notification.seen ? Icons.check_circle : Icons.mark_email_read_outlined),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _NotificationIcon extends StatelessWidget {
  const _NotificationIcon({required this.type, required this.seen});

  final String type;
  final bool seen;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 46,
      height: 46,
      decoration: BoxDecoration(
        color: _notificationColor(type).withOpacity(seen ? .10 : .18),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Icon(_notificationIcon(type), color: _notificationColor(type), size: 25),
    );
  }
}

IconData _notificationIcon(String type) {
  return switch (type) {
    'NEW_MATCHING_OFFER' => Icons.local_shipping_outlined,
    'APPLICATION_ACCEPTED' => Icons.check_circle_outline,
    'APPLICATION_REJECTED' => Icons.cancel_outlined,
    'OFFER_CANCELED' => Icons.event_busy_outlined,
    'OFFER_COMPLETED' => Icons.done_all,
    'REVIEW_RECEIVED' => Icons.star_outline,
    _ => Icons.notifications_active_outlined,
  };
}

Color _notificationColor(String type) {
  return switch (type) {
    'APPLICATION_ACCEPTED' || 'OFFER_COMPLETED' => AppColors.success,
    'APPLICATION_REJECTED' || 'OFFER_CANCELED' => AppColors.error,
    'NEW_MATCHING_OFFER' => AppColors.primary,
    'REVIEW_RECEIVED' => AppColors.accent,
    _ => AppColors.primaryContainer,
  };
}

String _notificationTypeFr(String type) {
  return switch (type) {
    'NEW_MATCHING_OFFER' => 'Nouvelle offre compatible',
    'DRIVER_APPLIED' => 'Nouvelle candidature',
    'APPLICATION_ACCEPTED' => 'Candidature acceptée',
    'APPLICATION_REJECTED' => 'Candidature refusée',
    'OFFER_CANCELED' => 'Offre annulée',
    'OFFER_COMPLETED' => 'Offre terminée',
    'REVIEW_RECEIVED' => 'Nouvel avis',
    _ => 'Notification',
  };
}

String _notificationDate(String value) {
  if (value.length < 16) return '';
  return value.substring(0, 16).replaceFirst('T', ' ');
}
