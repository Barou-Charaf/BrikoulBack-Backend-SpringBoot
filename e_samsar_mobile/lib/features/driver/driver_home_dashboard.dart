import 'package:flutter/material.dart';

import '../../core/app_state.dart';
import '../../core/app_theme.dart';
import '../../core/e_samsar_api.dart';
import '../../core/models.dart';
import 'driver_ai_screen.dart';
import 'driver_screens.dart';

ESamsarApi _api(BuildContext context) => ESamsarApi(AppStateScope.read(context).api);

class ProfessionalDriverHomeScreen extends StatefulWidget {
  const ProfessionalDriverHomeScreen({super.key});

  @override
  State<ProfessionalDriverHomeScreen> createState() => _ProfessionalDriverHomeScreenState();
}

class _ProfessionalDriverHomeScreenState extends State<ProfessionalDriverHomeScreen> {
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
          final activeTrucks = data.trucks.where((truck) => truck.active).length;
          final pendingApplications = data.applications.where((app) => app is Map && app['status'] == 'PENDING').length;

          return CustomScrollView(
            slivers: [
              SliverAppBar(
                pinned: true,
                elevation: 0,
                backgroundColor: AppColors.surface,
                surfaceTintColor: AppColors.surface,
                leading: IconButton(
                  icon: const Icon(Icons.menu, color: AppColors.primary),
                  onPressed: () {},
                ),
                title: const Text(
                  'Accueil Chauffeur',
                  style: TextStyle(color: AppColors.primary, fontSize: 24, fontWeight: FontWeight.w900),
                ),
                actions: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.notifications_outlined, color: AppColors.primary),
                        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationsScreen())),
                      ),
                      Positioned(
                        top: 14,
                        right: 13,
                        child: Container(width: 8, height: 8, decoration: const BoxDecoration(color: AppColors.error, shape: BoxShape.circle)),
                      ),
                    ],
                  ),
                  const SizedBox(width: 8),
                ],
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 100),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _DriverTopBar(
                        firstName: driver.user.firstName.isEmpty ? 'Chauffeur' : driver.user.firstName,
                        available: driver.available,
                        onAvailabilityChanged: (value) async {
                          await _api(context).setAvailability(value);
                          if (!mounted) return;
                          setState(() {
                            future = _load();
                          });
                        },
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(child: _DashboardStatCard(icon: Icons.star, iconColor: AppColors.secondary, value: '${driver.averageRating.toStringAsFixed(1)}/5', label: 'Note')),
                          const SizedBox(width: 12),
                          Expanded(child: _DashboardStatCard(icon: Icons.local_shipping, iconColor: AppColors.primary, value: '${driver.completedJobs}', label: 'Missions')),
                          const SizedBox(width: 12),
                          Expanded(child: _DashboardStatCard(icon: Icons.location_on_outlined, iconColor: const Color(0xFF6F797A), value: driver.currentCity.isEmpty ? '-' : driver.currentCity, label: 'Ville')),
                        ],
                      ),
                      const SizedBox(height: 30),
                      const _SectionTitle('Actions rapides'),
                      const SizedBox(height: 12),
                      _MainActionCard(
                        title: 'Parcourir les offres',
                        subtitle: 'Trouvez votre prochaine mission de transport à travers le Maroc.',
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const DriverOffersScreen())),
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: _MiniActionCard(
                              icon: Icons.add_circle_outline,
                              title: 'Ajouter un véhicule',
                              color: AppColors.secondary,
                              background: AppColors.accent.withOpacity(.10),
                              border: AppColors.accent.withOpacity(.42),
                              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const DriverTrucksScreen())),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: _MiniActionCard(
                              icon: Icons.smart_toy,
                              title: 'Recherche IA',
                              color: AppColors.primary,
                              background: AppColors.primary.withOpacity(.08),
                              border: AppColors.primary.withOpacity(.25),
                              showProgress: true,
                              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfessionalAiAssistantScreen())),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 30),
                      const _SectionTitle('Statut actuel'),
                      const SizedBox(height: 12),
                      _StatusActionCard(
                        icon: Icons.pending_actions_outlined,
                        title: 'Candidatures en attente',
                        subtitle: '$pendingApplications dossier${pendingApplications > 1 ? 's' : ''} en cours de revue',
                        accent: AppColors.accent,
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const DriverApplicationsScreen())),
                      ),
                      const SizedBox(height: 12),
                      _StatusActionCard(
                        icon: Icons.check_circle_outline,
                        title: 'Véhicules actifs',
                        subtitle: '$activeTrucks véhicule${activeTrucks > 1 ? 's' : ''} prêt${activeTrucks > 1 ? 's' : ''} pour mission',
                        accent: AppColors.primary,
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const DriverTrucksScreen())),
                      ),
                      const SizedBox(height: 26),
                      const _PremiumBanner(),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _DriverDashboardData {
  const _DriverDashboardData({required this.driver, required this.trucks, required this.applications});

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

class _DriverTopBar extends StatelessWidget {
  const _DriverTopBar({required this.firstName, required this.available, required this.onAvailabilityChanged});

  final String firstName;
  final bool available;
  final ValueChanged<bool> onAvailabilityChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Bienvenue,', style: TextStyle(color: AppColors.muted, fontSize: 16, fontWeight: FontWeight.w800)),
              const SizedBox(height: 4),
              Text('Bonjour, $firstName', style: const TextStyle(color: AppColors.primary, fontSize: 30, height: 1.05, fontWeight: FontWeight.w900)),
            ],
          ),
        ),
        const SizedBox(width: 12),
        _AvailabilityPill(available: available, onChanged: onAvailabilityChanged),
      ],
    );
  }
}

class _AvailabilityPill extends StatelessWidget {
  const _AvailabilityPill({required this.available, required this.onChanged});

  final bool available;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onChanged(!available),
      borderRadius: BorderRadius.circular(999),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: available ? const Color(0xFFE0E6E7) : AppColors.surfaceLow,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: AppColors.outline.withOpacity(.55)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 14, height: 14, decoration: BoxDecoration(color: available ? const Color(0xFF2ECC71) : const Color(0xFF6F797A), shape: BoxShape.circle)),
            const SizedBox(width: 9),
            Text(available ? 'Disponible' : 'Indisponible', style: const TextStyle(color: AppColors.text, fontSize: 15, fontWeight: FontWeight.w900)),
          ],
        ),
      ),
    );
  }
}

class _DashboardStatCard extends StatelessWidget {
  const _DashboardStatCard({required this.icon, required this.iconColor, required this.value, required this.label});

  final IconData icon;
  final Color iconColor;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 132,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE7ECEC)),
        boxShadow: const [BoxShadow(color: Color(0x10000000), blurRadius: 12, offset: Offset(0, 5))],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: iconColor, size: 30),
          const SizedBox(height: 8),
          FittedBox(fit: BoxFit.scaleDown, child: Text(value, maxLines: 1, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: AppColors.text))),
          const SizedBox(height: 2),
          Text(label, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: AppColors.muted, fontSize: 12, fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(text, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: AppColors.text));
  }
}

class _MainActionCard extends StatelessWidget {
  const _MainActionCard({required this.title, required this.subtitle, required this.onTap});

  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        height: 150,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [BoxShadow(color: Color(0x2400535B), blurRadius: 18, offset: Offset(0, 9))],
        ),
        child: Stack(
          children: [
            Positioned(right: -30, bottom: -34, child: Icon(Icons.search, size: 132, color: Colors.white.withOpacity(.12))),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(title, style: const TextStyle(color: Colors.white, fontSize: 27, fontWeight: FontWeight.w900)),
                const SizedBox(height: 12),
                Text(subtitle, style: TextStyle(color: Colors.white.withOpacity(.88), fontSize: 17, height: 1.35, fontWeight: FontWeight.w700)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MiniActionCard extends StatelessWidget {
  const _MiniActionCard({required this.icon, required this.title, required this.color, required this.background, required this.border, required this.onTap, this.showProgress = false});

  final IconData icon;
  final String title;
  final Color color;
  final Color background;
  final Color border;
  final VoidCallback onTap;
  final bool showProgress;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        height: 118,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(color: background, borderRadius: BorderRadius.circular(16), border: Border.all(color: border)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(icon, color: color, size: 30),
            Text(title, style: TextStyle(color: color, fontSize: 16, fontWeight: FontWeight.w900)),
            if (showProgress)
              ClipRRect(
                borderRadius: BorderRadius.circular(99),
                child: LinearProgressIndicator(minHeight: 4, value: .66, color: color, backgroundColor: color.withOpacity(.18)),
              ),
          ],
        ),
      ),
    );
  }
}

class _StatusActionCard extends StatelessWidget {
  const _StatusActionCard({required this.icon, required this.title, required this.subtitle, required this.accent, required this.onTap});

  final IconData icon;
  final String title;
  final String subtitle;
  final Color accent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: accent.withOpacity(.75)),
          boxShadow: const [BoxShadow(color: Color(0x0D000000), blurRadius: 10, offset: Offset(0, 5))],
        ),
        child: Row(
          children: [
            Container(width: 48, height: 48, decoration: BoxDecoration(color: accent.withOpacity(.12), shape: BoxShape.circle), child: Icon(icon, color: accent, size: 30)),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(color: AppColors.text, fontSize: 20, fontWeight: FontWeight.w900)),
                  const SizedBox(height: 4),
                  Text(subtitle, style: const TextStyle(color: AppColors.muted, fontSize: 16)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Color(0xFF6F797A), size: 30),
          ],
        ),
      ),
    );
  }
}

class _PremiumBanner extends StatelessWidget {
  const _PremiumBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 152,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFFB6C5C7), AppColors.primary]),
        boxShadow: const [BoxShadow(color: Color(0x22000000), blurRadius: 16, offset: Offset(0, 8))],
      ),
      child: Stack(
        children: [
          Positioned(right: -12, top: -8, child: Icon(Icons.local_shipping, size: 118, color: Colors.white.withOpacity(.16))),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                decoration: BoxDecoration(color: AppColors.accent, borderRadius: BorderRadius.circular(999)),
                child: const Text('OFFRE PREMIUM', style: TextStyle(color: AppColors.text, fontSize: 12, fontWeight: FontWeight.w900)),
              ),
              const SizedBox(height: 10),
              const Text('Boostez votre visibilité', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900)),
              const SizedBox(height: 4),
              Text("Passez au compte vérifié pour plus d'offres", style: TextStyle(color: Colors.white.withOpacity(.84), fontSize: 15, fontWeight: FontWeight.w800)),
            ],
          ),
        ],
      ),
    );
  }
}
