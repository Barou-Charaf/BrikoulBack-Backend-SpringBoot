import 'package:flutter/material.dart';

import '../../core/app_state.dart';
import '../../core/app_theme.dart';
import '../../core/e_samsar_api.dart';
import '../../core/models.dart';
import '../../shared/actions.dart';
import '../../shared/ui.dart';
import 'driver_screens.dart';

ESamsarApi _aiApi(BuildContext context) => ESamsarApi(AppStateScope.read(context).api);

class ProfessionalAiAssistantScreen extends StatefulWidget {
  const ProfessionalAiAssistantScreen({super.key});

  @override
  State<ProfessionalAiAssistantScreen> createState() => _ProfessionalAiAssistantScreenState();
}

class _ProfessionalAiAssistantScreenState extends State<ProfessionalAiAssistantScreen> {
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
    final offers = _offersFromResponse(response);
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('E-Samsar', style: TextStyle(color: AppColors.primary, fontSize: 28, fontWeight: FontWeight.w900)),
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.primary,
        elevation: 0,
        actions: [
          IconButton(icon: const Icon(Icons.notifications_outlined), onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationsScreen()))),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 22, 20, 110),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _AiHero(),
              const SizedBox(height: 20),
              _PromptCard(controller: message, busy: busy, onSearch: _send),
              const SizedBox(height: 16),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  _SuggestionChip(label: 'Offres Casablanca à Rabat', onTap: () => _useSuggestion('Je cherche des offres de Casablanca à Rabat')),
                  _SuggestionChip(label: 'Fourgon sous 1000 kg', onTap: () => _useSuggestion('Je cherche des missions pour fourgon sous 1000 kg')),
                  _SuggestionChip(label: 'Missions à Marrakech', onTap: () => _useSuggestion('Montre-moi des missions à Marrakech')),
                ],
              ),
              if (busy) ...[
                const SizedBox(height: 26),
                const Center(child: CircularProgressIndicator()),
              ],
              if (error != null) ...[
                const SizedBox(height: 20),
                _AiError(message: error!, onRetry: _send),
              ],
              if (response != null && !busy) ...[
                const SizedBox(height: 24),
                _AssistantBubble(text: response?['message']?.toString() ?? "J'ai trouvé des offres correspondant à votre recherche."),
                const SizedBox(height: 18),
                if (offers.isEmpty)
                  const _NoAiResults()
                else
                  ...offers.map((offer) => Padding(
                        padding: const EdgeInsets.only(bottom: 14),
                        child: _AiOfferCard(offer: offer),
                      )),
              ],
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        onPressed: _send,
        child: const Icon(Icons.auto_awesome),
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
      setState(() => error = 'Décrivez le type d’offre que vous recherchez.');
      return;
    }
    setState(() {
      busy = true;
      error = null;
    });
    try {
      response = await _aiApi(context).aiChat(text);
    } catch (e) {
      error = e.toString();
    } finally {
      if (mounted) {
        setState(() => busy = false);
      }
    }
  }

  List<OfferSummary> _offersFromResponse(Map<String, dynamic>? json) {
    final results = json?['results'];
    if (results is! Map<String, dynamic>) {
      return [];
    }
    final offers = results['offers'];
    if (offers is! List) {
      return [];
    }
    return offers.whereType<Map<String, dynamic>>().map(OfferSummary.fromJson).toList();
  }
}

class _AiHero extends StatelessWidget {
  const _AiHero();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 58,
          height: 58,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(colors: [AppColors.primary, AppColors.primaryContainer]),
            boxShadow: [BoxShadow(color: Color(0x2600535B), blurRadius: 14, offset: Offset(0, 7))],
          ),
          child: const Icon(Icons.smart_toy, color: Colors.white, size: 32),
        ),
        const SizedBox(width: 16),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Assistant IA', style: TextStyle(color: AppColors.primary, fontSize: 28, fontWeight: FontWeight.w900)),
              SizedBox(height: 2),
              Text('Simplifiez vos recherches logistiques', style: TextStyle(color: AppColors.muted, fontSize: 17)),
            ],
          ),
        ),
      ],
    );
  }
}

class _PromptCard extends StatelessWidget {
  const _PromptCard({required this.controller, required this.busy, required this.onSearch});

  final TextEditingController controller;
  final bool busy;
  final VoidCallback onSearch;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.outline),
        boxShadow: const [BoxShadow(color: Color(0x12000000), blurRadius: 16, offset: Offset(0, 8))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: controller,
            minLines: 4,
            maxLines: 6,
            decoration: const InputDecoration(
              hintText: "Décrivez l'offre que vous recherchez...",
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              filled: false,
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton.icon(
              onPressed: busy ? null : onSearch,
              icon: const Icon(Icons.search),
              label: Text(busy ? 'Recherche...' : 'Rechercher'),
            ),
          ),
        ],
      ),
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
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 420),
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: AppColors.primaryContainer,
          borderRadius: BorderRadius.only(topRight: Radius.circular(18), bottomLeft: Radius.circular(18), bottomRight: Radius.circular(18)),
        ),
        child: Text(text, style: const TextStyle(color: Colors.white, fontSize: 18, height: 1.35, fontWeight: FontWeight.w700)),
      ),
    );
  }
}

class _AiOfferCard extends StatelessWidget {
  const _AiOfferCard({required this.offer});

  final OfferSummary offer;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.outline),
        boxShadow: const [BoxShadow(color: Color(0x10000000), blurRadius: 14, offset: Offset(0, 7))],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 132,
            decoration: const BoxDecoration(
              gradient: LinearGradient(colors: [Color(0xFFB8915E), Color(0xFF00535B)], begin: Alignment.topLeft, end: Alignment.bottomRight),
            ),
            child: Stack(
              children: [
                Positioned(right: -14, bottom: -20, child: Icon(Icons.inventory_2, size: 124, color: Colors.white.withOpacity(.18))),
                Positioned(
                  top: 14,
                  right: 14,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                    decoration: BoxDecoration(color: AppColors.accent, borderRadius: BorderRadius.circular(99)),
                    child: const Text('Nouveau', style: TextStyle(color: AppColors.text, fontWeight: FontWeight.w900)),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: Text(offer.title, style: const TextStyle(color: AppColors.primary, fontSize: 22, fontWeight: FontWeight.w900))),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(money(offer.price), style: const TextStyle(color: AppColors.secondary, fontSize: 21, fontWeight: FontWeight.w900)),
                        const Text('Prix proposé', style: TextStyle(color: AppColors.muted, fontWeight: FontWeight.w800)),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                _AiInfo(Icons.location_on_outlined, '${offer.departureCity} → ${offer.arrivalCity}'),
                const SizedBox(height: 8),
                _AiInfo(Icons.local_shipping_outlined, '${vehicleFr(offer.vehicleType)} · ${offer.weightKg.toStringAsFixed(0)} kg'),
                const Divider(height: 28),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => OfferDetailsScreen(offerId: offer.id, driverMode: true))),
                        child: const Text('Voir détails'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    IconButton.filledTonal(
                      onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => OfferDetailsScreen(offerId: offer.id, driverMode: true))),
                      icon: const Icon(Icons.send),
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

class _AiInfo extends StatelessWidget {
  const _AiInfo(this.icon, this.text);

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

class _NoAiResults extends StatelessWidget {
  const _NoAiResults();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(18), border: Border.all(color: AppColors.outline)),
      child: const Column(
        children: [
          Icon(Icons.search_off, color: AppColors.primary, size: 42),
          SizedBox(height: 10),
          Text('Aucune offre trouvée', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
          SizedBox(height: 6),
          Text('Essayez une ville, un type de véhicule ou un poids différent.', textAlign: TextAlign.center, style: TextStyle(color: AppColors.muted)),
        ],
      ),
    );
  }
}

class _AiError extends StatelessWidget {
  const _AiError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.error.withOpacity(.08), borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.error.withOpacity(.3))),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: AppColors.error),
          const SizedBox(width: 10),
          Expanded(child: Text(message, style: const TextStyle(color: AppColors.error, fontWeight: FontWeight.w800))),
          TextButton(onPressed: onRetry, child: const Text('Réessayer')),
        ],
      ),
    );
  }
}
