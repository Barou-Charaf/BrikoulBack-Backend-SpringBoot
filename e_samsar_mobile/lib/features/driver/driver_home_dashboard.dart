import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/app_state.dart';
import '../../core/app_theme.dart';
import '../../core/e_samsar_api.dart';
import '../../core/models.dart';
import '../../shared/ui.dart';
import 'driver_ai_screen.dart';
import 'driver_screens.dart';

// Accès à l'API via le scope global
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

  // Chargement des données combinées (Profil + Camions + Candidatures)
  Future<_DriverDashboardData> _load() async {
    final api = _api(context);
    final driver = await api.driverMe();
    final trucks = await api.trucks().catchError((_) => <TruckModel>[]);
    final applications = await api.myApplications().catchError((_) => <dynamic>[]);
    return _DriverDashboardData(driver: driver, trucks: trucks, applications: applications);
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB), // Fond ultra-clair moderne
      body: FutureBuilder<_DriverDashboardData>(
        future: future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primary));
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

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ── HEADER LIQUIDE (Indigo Gradient + Bas-Gauche Arrondi) ─────
                Container(
                  padding: EdgeInsets.fromLTRB(24, topPadding + 20, 24, 60),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topRight,
                      end: Alignment.bottomLeft,
                      colors: [AppColors.primary, AppColors.primaryDark],
                    ),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(80),
                    ),
                  ),
                  child: Column(
                    children: [
                      // Barre supérieure : Nom & Notification
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Bonjour,", style: GoogleFonts.plusJakartaSans(color: Colors.white70, fontSize: 14)),
                              Text(
                                driver.user.firstName.isEmpty ? 'Chauffeur' : driver.user.firstName,
                                style: GoogleFonts.plusJakartaSans(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w800),
                              ),
                            ],
                          ),
                          const CircleAvatar(
                            radius: 22,
                            backgroundColor: Colors.white12,
                            child: Icon(Icons.notifications_none_rounded, color: Colors.white),
                          )
                        ],
                      ),
                      const SizedBox(height: 40),
                      // Stats épurées (Sans boîtes)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildMinimalStat(Icons.star_rounded, AppColors.accent, driver.averageRating.toStringAsFixed(1), "Note"),
                          _buildMinimalStat(Icons.local_shipping_rounded, Colors.white, "${driver.completedJobs}", "Missions"),
                          _buildMinimalStat(Icons.account_balance_wallet_rounded, Colors.white, "0 DH", "Solde"),
                        ],
                      )
                    ],
                  ),
                ),

                // ── CARTE DE CHECK-IN (Flottante & Arrondie) ──────────────────
                Transform.translate(
                  offset: const Offset(0, -35),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: AppCard(
                      child: Container(
                        padding: const EdgeInsets.all(28),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(32),
                          boxShadow: [
                            BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 40, offset: const Offset(0, 20))
                          ],
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width: 10,
                                  height: 10,
                                  decoration: BoxDecoration(
                                    color: driver.available ? const Color(0xFF2ECC71) : Colors.grey,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  driver.available ? "VOUS ÊTES EN LIGNE" : "VOUS ÊTES HORS LIGNE",
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 11, 
                                    fontWeight: FontWeight.w800, 
                                    letterSpacing: 1.2, 
                                    color: driver.available ? const Color(0xFF2ECC71) : Colors.grey
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            SizedBox(
                              width: double.infinity,
                              height: 60,
                              child: ElevatedButton(
                                onPressed: () async {
                                  await _api(context).setAvailability(!driver.available);
                                  setState(() { future = _load(); });
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: driver.available ? const Color(0xFFF1F5F9) : AppColors.accent,
                                  foregroundColor: driver.available ? AppColors.error : Colors.white,
                                  shape: const StadiumBorder(), // Bouton Pilule
                                  elevation: driver.available ? 0 : 4,
                                ),
                                child: Text(
                                  driver.available ? "SE RETIRER DU MAUKIF" : "FAIRE MON CHECK-IN",
                                  style: const TextStyle(fontWeight: FontWeight.w900, letterSpacing: 0.5),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                // ── ACTIONS & STATUTS ─────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Actions rapides", style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.w800)),
                      const SizedBox(height: 20),
                      
                      _ModernActionTile(
                        title: "Parcourir les offres de fret",
                        subtitle: "Trouvez des chargements à travers le Maroc",
                        icon: Icons.search_rounded,
                        color: AppColors.primary,
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const DriverOffersScreen())),
                      ),
                      
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _ModernMiniTile(
                              title: "Mes Véhicules",
                              icon: Icons.local_shipping_outlined,
                              color: Colors.blueGrey,
                              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const DriverTrucksScreen())),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _ModernMiniTile(
                              title: "Assistant IA",
                              icon: Icons.auto_awesome_rounded,
                              color: AppColors.primary,
                              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfessionalAiAssistantScreen())),
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 32),
                      Text("Suivi d'activité", style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.w800)),
                      const SizedBox(height: 16),
                      
                      _StatusTile(
                        count: pendingApplications,
                        title: "Candidatures en attente",
                        icon: Icons.hourglass_empty_rounded,
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const DriverApplicationsScreen())),
                      ),
                      const SizedBox(height: 10),
                      _StatusTile(
                        count: activeTrucks,
                        title: "Véhicules opérationnels",
                        icon: Icons.check_circle_outline_rounded,
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const DriverTrucksScreen())),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 100),
              ],
            ),
          );
        },
      ),
      // Bouton IA flottant permanent
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        elevation: 4,
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfessionalAiAssistantScreen())),
        child: const Icon(Icons.auto_awesome_rounded, color: Colors.white),
      ),
    );
  }

  Widget _buildMinimalStat(IconData icon, Color color, String value, String label) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 8),
        Text(value, style: GoogleFonts.plusJakartaSans(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800)),
        Text(label, style: GoogleFonts.plusJakartaSans(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.w500)),
      ],
    );
  }
}

// ── CLASSES DE SUPPORT (Logique & Erreurs) ───────────────────────────────────

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
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.wifi_off_rounded, size: 64, color: Colors.grey),
            const SizedBox(height: 20),
            Text("Oups ! Connexion perdue", style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            const Text("Impossible de joindre le serveur E-Samsar.", textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 24),
            ElevatedButton(onPressed: onRetry, child: const Text("RÉESSAYER")),
          ],
        ),
      ),
    );
  }
}

// ── WIDGETS PRIVÉS (Composants UI) ───────────────────────────────────────────

class _ModernActionTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ModernActionTile({required this.title, required this.subtitle, required this.icon, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(15)),
          child: Icon(icon, color: color),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        trailing: const Icon(Icons.chevron_right_rounded, color: Colors.grey),
      ),
    );
  }
}

class _ModernMiniTile extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ModernMiniTile({required this.title, required this.icon, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: Column(
            children: [
              Icon(icon, color: color, size: 28),
              const SizedBox(height: 12),
              Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusTile extends StatelessWidget {
  final int count;
  final String title;
  final IconData icon;
  final VoidCallback onTap;

  const _StatusTile({required this.count, required this.title, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: ListTile(
        onTap: onTap,
        leading: Icon(icon, color: AppColors.primary, size: 22),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(color: AppColors.accent.withOpacity(0.15), borderRadius: BorderRadius.circular(12)),
          child: Text("$count", style: const TextStyle(color: AppColors.accent, fontWeight: FontWeight.w900)),
        ),
      ),
    );
  }
}