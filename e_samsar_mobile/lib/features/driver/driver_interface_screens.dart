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
import '../../shared/ui.dart';
import 'driver_ai_screen.dart';
import 'driver_screens.dart';

ESamsarApi _driverApi(BuildContext context) => ESamsarApi(AppStateScope.read(context).api);

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

class ProfessionalDriverOffersScreen extends StatefulWidget {
  const ProfessionalDriverOffersScreen({super.key});

  @override
  State<ProfessionalDriverOffersScreen> createState() => _ProfessionalDriverOffersScreenState();
}

class _ProfessionalDriverOffersScreenState extends State<ProfessionalDriverOffersScreen> {
  final search = TextEditingController();
  bool availableOnly = true;
  late Future<List<OfferSummary>> future;

  @override
  void initState() {
    super.initState();
    future = _load();
  }

  Future<List<OfferSummary>> _load() {
    if (search.text.trim().isNotEmpty) {
      return _driverApi(context).searchOffers(departureCity: search.text.trim());
    }
    return _driverApi(context).offers(availableOnly: availableOnly);
  }

  @override
  Widget build(BuildContext context) {
    return _DriverPageShell(
      title: 'Offres disponibles',
      actions: [
        IconButton(
          icon: const Icon(Icons.smart_toy_outlined),
          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfessionalAiAssistantScreen())),
        ),
      ],
      child: Column(
        children: [
          _SearchPanel(
            controller: search,
            hint: 'Rechercher par ville de départ',
            onSearch: () => setState(() {
              future = _load();
            }),
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _FilterPill(
                  label: 'Disponibles',
                  selected: availableOnly,
                  onTap: () => setState(() {
                    availableOnly = true;
                    future = _load();
                  }),
                ),
                const SizedBox(width: 10),
                _FilterPill(
                  label: 'Toutes',
                  selected: !availableOnly,
                  onTap: () => setState(() {
                    availableOnly = false;
                    future = _load();
                  }),
                ),
                const SizedBox(width: 10),
                _FilterPill(label: 'Filtres', selected: false, icon: Icons.tune, onTap: () {}),
              ],
            ),
          ),
          const SizedBox(height: 18),
          FutureBuilder<List<OfferSummary>>(
            future: future,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
              if (snapshot.hasError) {
                return _PrettyEmpty(
                  icon: Icons.cloud_off_outlined,
                  title: 'Impossible de charger les offres',
                  message: snapshot.error.toString(),
                  actionLabel: 'Réessayer',
                  onAction: () => setState(() {
                    future = _load();
                  }),
                );
              }
              if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
              final offers = snapshot.data!;
              if (offers.isEmpty) {
                return const _PrettyEmpty(icon: Icons.inventory_2_outlined, title: 'Aucune offre disponible', message: 'Essayez une autre ville ou utilisez la recherche IA.');
              }
              return ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  if (index == offers.length) return const _AiOfferPromo();
                  final offer = offers[index];
                  return _ProfessionalOfferCard(
                    offer: offer,
                    onDetails: () => Navigator.push(context, MaterialPageRoute(builder: (_) => OfferDetailsScreen(offerId: offer.id, driverMode: true))),
                    onApply: () => Navigator.push(context, MaterialPageRoute(builder: (_) => OfferDetailsScreen(offerId: offer.id, driverMode: true))),
                  );
                },
                separatorBuilder: (_, __) => const SizedBox(height: 14),
                itemCount: offers.length + 1,
              );
            },
          ),
        ],
      ),
    );
  }
}

class ProfessionalDriverApplicationsScreen extends StatefulWidget {
  const ProfessionalDriverApplicationsScreen({super.key});

  @override
  State<ProfessionalDriverApplicationsScreen> createState() => _ProfessionalDriverApplicationsScreenState();
}

class _ProfessionalDriverApplicationsScreenState extends State<ProfessionalDriverApplicationsScreen> {
  late Future<List<dynamic>> future;

  @override
  void initState() {
    super.initState();
    future = _driverApi(context).myApplications();
  }

  @override
  Widget build(BuildContext context) {
    return _DriverPageShell(
      title: 'Mes candidatures',
      child: FutureBuilder<List<dynamic>>(
        future: future,
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final apps = snapshot.data!;
          if (apps.isEmpty) {
            return const _PrettyEmpty(icon: Icons.assignment_outlined, title: 'Aucune candidature', message: 'Postulez à une offre pour la retrouver ici.');
          }
          return Column(
            children: apps.map((app) {
              final offer = (app['offer'] as Map?) ?? {};
              final status = app['status']?.toString() ?? '';
              return Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: _ApplicationCard(
                  title: offer['title']?.toString() ?? 'Offre de transport',
                  route: '${offer['departureCity'] ?? '-'} → ${offer['arrivalCity'] ?? '-'}',
                  price: money(app['proposedPrice'] ?? 0),
                  status: status,
                  onCancel: status == 'PENDING'
                      ? () async {
                          await _driverApi(context).cancelApplication(app['id']);
                          if (!mounted) return;
                          setState(() {
                            future = _driverApi(context).myApplications();
                          });
                        }
                      : null,
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}

class ProfessionalDriverTrucksScreen extends StatefulWidget {
  const ProfessionalDriverTrucksScreen({super.key});

  @override
  State<ProfessionalDriverTrucksScreen> createState() => _ProfessionalDriverTrucksScreenState();
}

class _ProfessionalDriverTrucksScreenState extends State<ProfessionalDriverTrucksScreen> {
  late Future<List<TruckModel>> future;

  @override
  void initState() {
    super.initState();
    future = _driverApi(context).trucks();
  }

  @override
  Widget build(BuildContext context) {
    return _DriverPageShell(
      title: 'Mes véhicules',
      actions: [
        IconButton(icon: const Icon(Icons.add_circle_outline), onPressed: () => _showTruckForm()),
      ],
      child: FutureBuilder<List<TruckModel>>(
        future: future,
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final trucks = snapshot.data!;
          if (trucks.isEmpty) {
            return _PrettyEmpty(
              icon: Icons.local_shipping_outlined,
              title: 'Aucun véhicule ajouté',
              message: 'Ajoutez votre premier véhicule pour recevoir plus de missions.',
              actionLabel: 'Ajouter un véhicule',
              onAction: _showTruckForm,
            );
          }
          return Column(
            children: [
              _AddTruckBanner(onTap: _showTruckForm),
              const SizedBox(height: 14),
              ...trucks.map((truck) => Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: _TruckPanel(
                      truck: truck,
                      onEdit: () => _showTruckForm(truck),
                      onToggle: () async {
                        await _driverApi(context).setTruckActive(truck.id, !truck.active);
                        if (!mounted) return;
                        setState(() {
                          future = _driverApi(context).trucks();
                        });
                      },
                      onDelete: () async {
                        await _driverApi(context).deleteTruck(truck.id);
                        if (!mounted) return;
                        setState(() {
                          future = _driverApi(context).trucks();
                        });
                      },
                    ),
                  )),
            ],
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
    String selectedImage = truck?.imageUrl ?? '';
    String type = truck?.vehicleType ?? 'VAN';
    bool active = truck?.active ?? true;
    bool saving = false;
    String? plateError;
    String? capacityError;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => StatefulBuilder(
        builder: (context, setSheet) => SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(context).viewInsets.bottom + 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(truck == null ? 'Ajouter un véhicule' : 'Modifier le véhicule', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: AppColors.primary)),
              const SizedBox(height: 16),
              TextField(controller: brand, decoration: const InputDecoration(labelText: 'Marque', prefixIcon: Icon(Icons.local_shipping_outlined))),
              const SizedBox(height: 10),
              TextField(controller: model, decoration: const InputDecoration(labelText: 'Modèle', prefixIcon: Icon(Icons.badge_outlined))),
              const SizedBox(height: 10),
              _ImagePickerField(
                imageValue: selectedImage,
                title: 'Image du véhicule',
                subtitle: selectedImage.isEmpty ? 'Choisir une photo depuis la galerie' : 'Photo prête à être enregistrée',
                fallbackIcon: Icons.local_shipping_outlined,
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
              const SizedBox(height: 10),
              TextField(
                controller: plate,
                textCapitalization: TextCapitalization.characters,
                decoration: InputDecoration(
                  labelText: 'Immatriculation *',
                  hintText: 'Ex: 12345-A-6',
                  prefixIcon: const Icon(Icons.confirmation_number_outlined),
                  errorText: plateError,
                ),
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: type,
                decoration: const InputDecoration(labelText: 'Type de véhicule'),
                items: ['MOTORCYCLE', 'SMALL_VAN', 'PICKUP', 'VAN', 'SMALL_TRUCK', 'MEDIUM_TRUCK', 'BIG_TRUCK'].map((v) => DropdownMenuItem(value: v, child: Text(vehicleFr(v)))).toList(),
                onChanged: (v) => setSheet(() => type = v!),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: capacity,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Capacité en kg *',
                  prefixIcon: const Icon(Icons.scale_outlined),
                  errorText: capacityError,
                ),
              ),
              SwitchListTile(value: active, onChanged: (v) => setSheet(() => active = v), title: const Text('Véhicule actif')),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: saving
                    ? null
                    : () async {
                        final plateValue = plate.text.trim().toUpperCase();
                        final capacityValue = num.tryParse(capacity.text.trim().replaceAll(',', '.'));

                        setSheet(() {
                          plateError = plateValue.isEmpty ? "L'immatriculation est obligatoire" : null;
                          capacityError = capacityValue == null || capacityValue <= 0 ? 'Indiquez une capacité valide' : null;
                        });

                        if (plateError != null || capacityError != null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Veuillez compléter les champs obligatoires du véhicule.')),
                          );
                          return;
                        }

                        try {
                          setSheet(() {
                            saving = true;
                          });
                          await _driverApi(context).saveTruck({
                            'brand': brand.text.trim(),
                            'model': model.text.trim(),
                            'imageUrl': selectedImage,
                            'plateNumber': plateValue,
                            'vehicleType': type,
                            'capacityKg': capacityValue,
                            'active': active,
                          }, id: truck?.id);
                          if (!mounted) return;
                          Navigator.pop(context);
                          setState(() {
                            future = _driverApi(context).trucks();
                          });
                        } catch (error) {
                          if (!mounted) return;
                          setSheet(() {
                            saving = false;
                          });
                          final message = error is ApiException ? error.message : "Impossible d'enregistrer le véhicule.";
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
                        }
                      },
                child: saving
                    ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Text('Enregistrer'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ProfessionalDriverProfileScreen extends StatefulWidget {
  const ProfessionalDriverProfileScreen({super.key});

  @override
  State<ProfessionalDriverProfileScreen> createState() => _ProfessionalDriverProfileScreenState();
}

class _ProfessionalDriverProfileScreenState extends State<ProfessionalDriverProfileScreen> {
  late Future<DriverProfile> future;

  @override
  void initState() {
    super.initState();
    future = _driverApi(context).driverMe();
  }

  @override
  Widget build(BuildContext context) {
    final app = AppStateScope.read(context);
    return _DriverPageShell(
      title: 'Mon profil',
      actions: [
        IconButton(icon: const Icon(Icons.edit_outlined), onPressed: () async {
          final driver = await future;
          if (mounted) _showProfileForm(driver);
        }),
      ],
      child: FutureBuilder<DriverProfile>(
        future: future,
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final driver = snapshot.data!;
          return Column(
            children: [
              _ProfileHero(driver: driver),
              const SizedBox(height: 16),
              _ProfileInfoCard(driver: driver, onEdit: () => _showProfileForm(driver)),
              const SizedBox(height: 14),
              _SettingsAction(icon: Icons.smart_toy_outlined, title: 'Assistant IA', subtitle: 'Lancer une recherche intelligente', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfessionalAiAssistantScreen()))),
              const SizedBox(height: 10),
              _SettingsAction(
                icon: Icons.logout,
                title: 'Se déconnecter',
                subtitle: 'Quitter votre session chauffeur',
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

  Future<void> _showProfileForm(DriverProfile driver) async {
    final firstName = TextEditingController(text: driver.user.firstName);
    final lastName = TextEditingController(text: driver.user.lastName);
    final phone = TextEditingController(text: driver.user.phone);
    final city = TextEditingController(text: driver.currentCity);
    String selectedImage = driver.user.profileImageUrl;
    bool available = driver.available;

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
              TextField(controller: city, decoration: const InputDecoration(labelText: 'Ville actuelle', prefixIcon: Icon(Icons.location_on_outlined))),
              const SizedBox(height: 10),
              _ImagePickerField(
                imageValue: selectedImage,
                title: 'Photo de profil',
                subtitle: selectedImage.isEmpty ? 'Choisir une photo depuis la galerie' : 'Photo prête à être enregistrée',
                fallbackIcon: Icons.person_outline,
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
              SwitchListTile(value: available, title: const Text('Disponible'), onChanged: (v) => setSheet(() => available = v)),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () async {
                  await _driverApi(context).updateDriver(
                    firstName: firstName.text,
                    lastName: lastName.text,
                    phone: phone.text,
                    profileImageUrl: selectedImage,
                    currentCity: city.text,
                    available: available,
                  );
                  if (!mounted) return;
                  Navigator.pop(context);
                  setState(() {
                    future = _driverApi(context).driverMe();
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

class _DriverPageShell extends StatelessWidget {
  const _DriverPageShell({required this.title, required this.child, this.actions});

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

class _SearchPanel extends StatelessWidget {
  const _SearchPanel({required this.controller, required this.hint, required this.onSearch});

  final TextEditingController controller;
  final String hint;
  final VoidCallback onSearch;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      textInputAction: TextInputAction.search,
      onSubmitted: (_) => onSearch(),
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: const Icon(Icons.search),
        suffixIcon: IconButton(icon: const Icon(Icons.arrow_forward), onPressed: onSearch),
      ),
    );
  }
}

class _FilterPill extends StatelessWidget {
  const _FilterPill({required this.label, required this.selected, required this.onTap, this.icon});

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : AppColors.surfaceLow,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: selected ? AppColors.primary : AppColors.outline.withOpacity(.6)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[Icon(icon, size: 16, color: selected ? Colors.white : AppColors.primary), const SizedBox(width: 6)],
            Text(label, style: TextStyle(color: selected ? Colors.white : AppColors.muted, fontWeight: FontWeight.w900)),
          ],
        ),
      ),
    );
  }
}

class _ProfessionalOfferCard extends StatelessWidget {
  const _ProfessionalOfferCard({required this.offer, required this.onDetails, required this.onApply});

  final OfferSummary offer;
  final VoidCallback onDetails;
  final VoidCallback onApply;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: Text(offer.title, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: AppColors.primary, fontSize: 19, fontWeight: FontWeight.w900))),
              const SizedBox(width: 8),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 132),
                child: StatusChip(offer.status),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _InfoRow(Icons.route_outlined, '${offer.departureCity} → ${offer.arrivalCity}'),
          const SizedBox(height: 8),
          _InfoRow(Icons.inventory_2_outlined, '${vehicleFr(offer.vehicleType)} · ${offer.weightKg.toStringAsFixed(0)} kg'),
          const SizedBox(height: 14),
          Wrap(
            spacing: 10,
            runSpacing: 12,
            crossAxisAlignment: WrapCrossAlignment.center,
            alignment: WrapAlignment.spaceBetween,
            children: [
              SizedBox(
                width: 138,
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('PRIX PROPOSÉ', style: TextStyle(color: AppColors.muted, fontSize: 11, fontWeight: FontWeight.w900)),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(money(offer.price), maxLines: 1, style: const TextStyle(color: AppColors.secondary, fontSize: 22, fontWeight: FontWeight.w900)),
                ),
              ])),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextButton(onPressed: onDetails, child: const Text('Détails')),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: onApply,
                    style: ElevatedButton.styleFrom(minimumSize: const Size(110, 44)),
                    child: const Text('Postuler'),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ApplicationCard extends StatelessWidget {
  const _ApplicationCard({required this.title, required this.route, required this.price, required this.status, this.onCancel});

  final String title;
  final String route;
  final String price;
  final String status;
  final VoidCallback? onCancel;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [Expanded(child: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900))), StatusChip(status)]),
          const SizedBox(height: 10),
          _InfoRow(Icons.route_outlined, route),
          const SizedBox(height: 10),
          Text(price, style: const TextStyle(color: AppColors.primary, fontSize: 20, fontWeight: FontWeight.w900)),
          if (onCancel != null) ...[
            const SizedBox(height: 12),
            OutlinedButton.icon(onPressed: onCancel, icon: const Icon(Icons.close), label: const Text('Annuler la candidature')),
          ],
        ],
      ),
    );
  }
}

class _TruckPanel extends StatelessWidget {
  const _TruckPanel({required this.truck, required this.onEdit, required this.onToggle, required this.onDelete});

  final TruckModel truck;
  final VoidCallback onEdit;
  final VoidCallback onToggle;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: _cardDecoration(),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _TruckImage(truck: truck),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Expanded(child: Text('${truck.brand} ${truck.model}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900))),
                  StatusChip(truck.active ? 'ACCEPTED' : 'REJECTED'),
                ]),
                const SizedBox(height: 8),
                _InfoRow(Icons.confirmation_number_outlined, truck.plateNumber),
                const SizedBox(height: 8),
                _InfoRow(Icons.scale_outlined, '${vehicleFr(truck.vehicleType)} · ${truck.capacityKg.toStringAsFixed(0)} kg'),
                const SizedBox(height: 12),
                Row(children: [
                  TextButton(onPressed: onEdit, child: const Text('Modifier')),
                  TextButton(onPressed: onToggle, child: Text(truck.active ? 'Désactiver' : 'Activer')),
                  const Spacer(),
                  IconButton(onPressed: onDelete, icon: const Icon(Icons.delete_outline, color: AppColors.error)),
                ]),
              ],
            ),
          ),
        ],
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
      decoration: BoxDecoration(
        color: AppColors.surfaceLow,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE0EAEA)),
      ),
      child: Row(
        children: [
          _StoredImagePreview(
            imageValue: imageValue,
            fallbackIcon: fallbackIcon,
            height: 82,
            width: 82,
            rounded: rounded,
          ),
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
                    ElevatedButton.icon(
                      onPressed: onPick,
                      icon: const Icon(Icons.photo_library_outlined, size: 18),
                      label: const Text('Galerie'),
                    ),
                    if (onClear != null)
                      TextButton.icon(
                        onPressed: onClear,
                        icon: const Icon(Icons.close, size: 18),
                        label: const Text('Retirer'),
                      ),
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

class _StoredImagePreview extends StatelessWidget {
  const _StoredImagePreview({
    required this.imageValue,
    required this.fallbackIcon,
    required this.height,
    required this.width,
    this.rounded = false,
  });

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

class _TruckImage extends StatelessWidget {
  const _TruckImage({required this.truck});

  final TruckModel truck;

  @override
  Widget build(BuildContext context) {
    return _StoredImagePreview(
      imageValue: truck.imageUrl,
      fallbackIcon: Icons.local_shipping,
      height: 150,
      width: double.infinity,
    );
  }
}

class _AddTruckBanner extends StatelessWidget {
  const _AddTruckBanner({required this.onTap});

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
          Expanded(child: Text('Ajouter un nouveau véhicule', style: TextStyle(color: AppColors.secondary, fontWeight: FontWeight.w900, fontSize: 16))),
          Icon(Icons.chevron_right, color: AppColors.secondary),
        ]),
      ),
    );
  }
}

class _ProfileHero extends StatelessWidget {
  const _ProfileHero({required this.driver});

  final DriverProfile driver;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(22),
        boxShadow: const [BoxShadow(color: Color(0x2200535B), blurRadius: 18, offset: Offset(0, 10))],
      ),
      child: Row(
        children: [
          _ProfileAvatar(user: driver.user, radius: 38),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(driver.user.fullName, style: const TextStyle(color: Colors.white, fontSize: 23, fontWeight: FontWeight.w900)),
                const SizedBox(height: 4),
                Text(driver.currentCity.isEmpty ? 'Ville non renseignée' : driver.currentCity, style: TextStyle(color: Colors.white.withOpacity(.82))),
                const SizedBox(height: 8),
                Row(children: [
                  const Icon(Icons.star, color: AppColors.accent, size: 18),
                  const SizedBox(width: 5),
                  Text('${driver.averageRating.toStringAsFixed(1)} · ${driver.completedJobs} missions', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
                ]),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileInfoCard extends StatelessWidget {
  const _ProfileInfoCard({required this.driver, required this.onEdit});

  final DriverProfile driver;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Column(
        children: [
          _InfoRow(Icons.email_outlined, driver.user.email),
          const Divider(height: 24),
          _InfoRow(Icons.phone_outlined, driver.user.phone),
          const Divider(height: 24),
          _InfoRow(Icons.location_on_outlined, driver.currentCity.isEmpty ? '-' : driver.currentCity),
          const SizedBox(height: 14),
          OutlinedButton.icon(onPressed: onEdit, icon: const Icon(Icons.edit_outlined), label: const Text('Modifier mon profil')),
        ],
      ),
    );
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

class _ProfileAvatar extends StatelessWidget {
  const _ProfileAvatar({required this.user, this.radius = 28});

  final UserModel user;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final imageProvider = _storedImageProvider(user.profileImageUrl);
    if (imageProvider != null) {
      return CircleAvatar(radius: radius, backgroundImage: imageProvider);
    }
    return CircleAvatar(
      radius: radius,
      backgroundColor: Colors.white.withOpacity(.18),
      child: Text(user.firstName.isEmpty ? '?' : user.firstName.substring(0, 1).toUpperCase(), style: TextStyle(color: Colors.white, fontSize: radius, fontWeight: FontWeight.w900)),
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

class _AiOfferPromo extends StatelessWidget {
  const _AiOfferPromo();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: const LinearGradient(colors: [AppColors.primary, AppColors.primaryContainer]),
      ),
      child: Column(children: [
        const Icon(Icons.smart_toy, color: Colors.white, size: 38),
        const SizedBox(height: 10),
        Text('Laissez notre IA trouver les offres les plus rentables pour vous.', textAlign: TextAlign.center, style: TextStyle(color: Colors.white.withOpacity(.9), fontWeight: FontWeight.w800)),
        const SizedBox(height: 14),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.accent, foregroundColor: AppColors.text),
          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfessionalAiAssistantScreen())),
          child: const Text("Activer l'assistant IA"),
        ),
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

BoxDecoration _cardDecoration() {
  return BoxDecoration(
    color: AppColors.surface,
    borderRadius: BorderRadius.circular(18),
    border: Border.all(color: const Color(0xFFE4EAEA)),
    boxShadow: const [BoxShadow(color: Color(0x0F000000), blurRadius: 14, offset: Offset(0, 6))],
  );
}
