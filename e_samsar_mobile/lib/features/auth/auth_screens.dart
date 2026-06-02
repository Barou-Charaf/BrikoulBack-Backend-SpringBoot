import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/api_client.dart';
import '../../core/app_state.dart';
import '../../core/app_theme.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.primary,
              AppColors.primaryDark,
            ],
          ),
        ),
        child: Stack(
          children: [
            // Soft decorative glowing circles in the background
            Positioned(
              left: -80,
              bottom: 120,
              child: Container(
                width: 320,
                height: 320,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.03),
                ),
              ),
            ),
            Positioned(
              right: -50,
              top: 80,
              child: Container(
                width: 260,
                height: 260,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.accent.withOpacity(0.04),
                ),
              ),
            ),
            Center(
              child: Padding(
                padding: const EdgeInsets.all(28),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(28),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.12),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: const Icon(Icons.local_shipping, color: AppColors.primary, size: 54),
                    ),
                    const SizedBox(height: 32),
                    Text(
                      'E-Samsar',
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontSize: 46,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'LOGISTIQUE MAROCAINE PREMIUM',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        color: Colors.white.withOpacity(0.65),
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 80),
                    Text(
                      'Chargement...',
                      style: GoogleFonts.inter(
                        color: Colors.white.withOpacity(0.85),
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: 160,
                      child: LinearProgressIndicator(
                        minHeight: 5,
                        borderRadius: BorderRadius.circular(99),
                        backgroundColor: Colors.white.withOpacity(0.15),
                        color: AppColors.accent,
                      ),
                    ),
                    const SizedBox(height: 68),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.verified_user_outlined, color: Colors.white.withOpacity(0.6), size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'SÉCURISÉ PAR E-SAMSAR TECH',
                          style: GoogleFonts.inter(
                            color: Colors.white.withOpacity(0.6),
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                            letterSpacing: 1,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return _AuthPage(
      title: 'E-Samsar',
      subtitle: 'LOGISTIQUE MAROCAINE PREMIUM',
      showMenu: true,
      maxWidth: 430,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _WelcomeCard(
            onLogin: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginScreen())),
            onRegister: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RegisterScreen())),
          ),
          const SizedBox(height: 24),
          const _FeatureTile(
            color: AppColors.accent,
            icon: Icons.speed_outlined,
            title: 'Rapidité',
            text: 'Trouvez un transporteur en moins de 5 minutes.',
          ),
          const SizedBox(height: 14),
          const _FeatureTile(
            color: AppColors.primary,
            icon: Icons.attach_money,
            title: 'Meilleur Prix',
            text: 'Comparez les offres et économisez sur vos envois.',
          ),
        ],
      ),
    );
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final email = TextEditingController();
  final password = TextEditingController();
  bool obscure = true;
  String? error;

  @override
  void dispose() {
    email.dispose();
    password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final app = AppStateScope.of(context);
    return _AuthPage(
      title: 'Connexion',
      subtitle: 'Accédez à votre espace transport',
      onBack: () => Navigator.pop(context),
      maxWidth: 430,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _Panel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _LabeledField(
                  label: 'Adresse e-mail',
                  hint: 'exemple@mail.com',
                  icon: Icons.mail_outline,
                  controller: email,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 18),
                _LabeledField(
                  label: 'Mot de passe',
                  hint: '••••••••',
                  icon: Icons.lock_outline,
                  controller: password,
                  obscureText: obscure,
                  suffix: IconButton(
                    icon: Icon(obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                    onPressed: () => setState(() => obscure = !obscure),
                  ),
                ),
                if (error != null) ...[
                  const SizedBox(height: 14),
                  _ErrorBox(error!),
                ],
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ForgotPasswordScreen())),
                    child: Text(
                      'Mot de passe oublié ?',
                      style: GoogleFonts.inter(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                _PrimaryButton(
                  text: 'Se connecter',
                  busy: app.busy,
                  onPressed: () => _login(app),
                ),
                const SizedBox(height: 24),
                const _DividerText('OU'),
                const SizedBox(height: 24),
                OutlinedButton(
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RegisterScreen())),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(58),
                    side: const BorderSide(color: AppColors.outline, width: 1.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    textStyle: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  child: const Text('Créer un compte'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 34),
          const _AuthFooter(),
        ],
      ),
    );
  }

  Future<void> _login(AppState app) async {
    setState(() => error = null);
    if (email.text.trim().isEmpty || password.text.isEmpty) {
      setState(() => error = 'Veuillez saisir votre e-mail et votre mot de passe.');
      return;
    }
    try {
      await app.login(email.text, password.text);
      if (mounted) {
        final role = app.currentRole;
        if (role == 'SHIPPER') {
          Navigator.pushNamedAndRemoveUntil(context, '/shipper', (_) => false);
          return;
        }
        if (role == 'DRIVER') {
          Navigator.pushNamedAndRemoveUntil(context, '/driver', (_) => false);
          return;
        }
        setState(() => error = 'Rôle utilisateur non reconnu: ${app.currentUser?.role ?? "-"}');
      }
    } catch (e) {
      setState(() => error = e.toString());
    }
  }
}

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final firstName = TextEditingController();
  final lastName = TextEditingController();
  final email = TextEditingController();
  final password = TextEditingController();
  final phone = TextEditingController();
  String role = 'SHIPPER';
  bool busy = false;
  bool obscure = true;
  bool accepted = false;
  String? error;

  @override
  void dispose() {
    firstName.dispose();
    lastName.dispose();
    email.dispose();
    password.dispose();
    phone.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _AuthPage(
      title: 'Créer un compte',
      subtitle: 'Rejoignez la 1ère plateforme de transport au Maroc',
      onBack: () => Navigator.pop(context),
      showHelp: true,
      maxWidth: 560,
      child: _Panel(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const _FieldLabel('JE SUIS UN :'),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: _RoleCard(
                    label: 'Expéditeur',
                    icon: Icons.inventory_2_outlined,
                    selected: role == 'SHIPPER',
                    onTap: () => setState(() => role = 'SHIPPER'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _RoleCard(
                    label: 'Chauffeur',
                    icon: Icons.local_shipping,
                    selected: role == 'DRIVER',
                    onTap: () => setState(() => role = 'DRIVER'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),
            Row(
              children: [
                Expanded(
                  child: _LabeledField(
                    label: 'Prénom',
                    hint: 'Ahmed',
                    icon: Icons.person_outline,
                    controller: firstName,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _LabeledField(
                    label: 'Nom',
                    hint: 'Mansouri',
                    controller: lastName,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            _LabeledField(
              label: 'Adresse e-mail',
              hint: 'contact@exemple.ma',
              icon: Icons.mail_outline,
              controller: email,
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 18),
            _PhoneField(controller: phone),
            const SizedBox(height: 18),
            _LabeledField(
              label: 'Mot de passe',
              hint: 'Minimum 8 caractères',
              icon: Icons.lock_outline,
              controller: password,
              obscureText: obscure,
              suffix: IconButton(
                icon: Icon(obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                onPressed: () => setState(() => obscure = !obscure),
              ),
            ),
            const SizedBox(height: 18),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Checkbox(
                  value: accepted,
                  activeColor: AppColors.primary,
                  onChanged: (value) => setState(() => accepted = value ?? false),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Text.rich(
                      TextSpan(
                        text: "J'accepte les ",
                        children: [
                          TextSpan(
                            text: "Conditions d'utilisation",
                            style: GoogleFonts.inter(color: AppColors.primary, fontWeight: FontWeight.w800),
                          ),
                          const TextSpan(text: ' et la '),
                          TextSpan(
                            text: 'Politique de confidentialité',
                            style: GoogleFonts.inter(color: AppColors.primary, fontWeight: FontWeight.w800),
                          ),
                          const TextSpan(text: " d'E-Samsar."),
                        ],
                      ),
                      style: GoogleFonts.inter(fontSize: 14, height: 1.35, color: AppColors.muted),
                    ),
                  ),
                ),
              ],
            ),
            if (error != null) ...[
              const SizedBox(height: 12),
              _ErrorBox(error!),
            ],
            const SizedBox(height: 24),
            _PrimaryButton(
              text: 'Créer mon compte',
              icon: Icons.arrow_forward,
              busy: busy,
              onPressed: _register,
            ),
            const SizedBox(height: 24),
            Center(
              child: TextButton(
                onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen())),
                child: Text(
                  'Vous avez déjà un compte ? Se connecter',
                  style: GoogleFonts.inter(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _register() async {
    setState(() => error = null);
    if (!accepted) {
      setState(() => error = "Veuillez accepter les conditions d'utilisation.");
      return;
    }
    if (firstName.text.trim().isEmpty ||
        lastName.text.trim().isEmpty ||
        email.text.trim().isEmpty ||
        password.text.length < 8 ||
        phone.text.trim().isEmpty) {
      setState(() => error = 'Complétez tous les champs. Le mot de passe doit contenir au moins 8 caractères.');
      return;
    }

    setState(() => busy = true);
    try {
      await ApiClient().post('/api/auth/register', {
        'firstName': firstName.text.trim(),
        'lastName': lastName.text.trim(),
        'email': email.text.trim(),
        'password': password.text,
        'phone': phone.text.trim(),
        'role': role,
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Compte créé. Entrez le code reçu par e-mail ou affiché dans les logs backend.')),
      );
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const VerifyEmailScreen()));
    } catch (e) {
      if (mounted) setState(() => error = e.toString());
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }
}

class VerifyEmailScreen extends StatefulWidget {
  const VerifyEmailScreen({super.key});

  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  final token = TextEditingController();
  bool busy = false;
  String? error;

  @override
  void dispose() {
    token.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _AuthPage(
      title: 'Vérification',
      subtitle: 'Entrez le code reçu par e-mail',
      onBack: () => Navigator.pop(context),
      maxWidth: 560,
      child: _Panel(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const _CircleIcon(Icons.email_outlined),
            const SizedBox(height: 28),
            _InfoCard(
              icon: Icons.lock_outline,
              badge: 'SÉCURITÉ',
              text: 'En mode test, le backend imprime aussi ce code dans la console après inscription.',
            ),
            const SizedBox(height: 28),
            _LabeledField(
              label: 'CODE DE VÉRIFICATION',
              hint: 'Ex: 123456',
              icon: Icons.key_outlined,
              controller: token,
              keyboardType: TextInputType.number,
            ),
            if (error != null) ...[
              const SizedBox(height: 14),
              _ErrorBox(error!),
            ],
            const SizedBox(height: 28),
            _PrimaryButton(
              text: 'Vérifier mon e-mail',
              icon: Icons.arrow_forward,
              busy: busy,
              onPressed: _verify,
            ),
            const SizedBox(height: 24),
            Center(
              child: TextButton(
                onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen())),
                child: Text(
                  'Retour à la connexion',
                  style: GoogleFonts.inter(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _verify() async {
    setState(() => error = null);
    if (token.text.trim().isEmpty) {
      setState(() => error = 'Entrez le code de vérification.');
      return;
    }
    setState(() => busy = true);
    try {
      await ApiClient().post('/api/auth/verify-email', {'token': token.text.trim()});
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('E-mail vérifié avec succès.')));
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
    } catch (e) {
      if (mounted) setState(() => error = e.toString());
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }
}

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final email = TextEditingController();
  bool busy = false;
  String? error;

  @override
  void dispose() {
    email.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _AuthPage(
      title: 'Mot de passe',
      subtitle: 'Récupérez l\'accès à votre compte',
      onBack: () => Navigator.pop(context),
      maxWidth: 620,
      child: _Panel(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const _CircleIcon(Icons.lock_outline),
            const SizedBox(height: 28),
            _LabeledField(
              label: 'Adresse e-mail',
              hint: 'nom@exemple.com',
              icon: Icons.mail_outline,
              controller: email,
              keyboardType: TextInputType.emailAddress,
            ),
            if (error != null) ...[
              const SizedBox(height: 14),
              _ErrorBox(error!),
            ],
            const SizedBox(height: 28),
            _PrimaryButton(
              text: 'Envoyer le code',
              icon: Icons.send_outlined,
              busy: busy,
              onPressed: _send,
            ),
            const SizedBox(height: 22),
            TextButton.icon(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ResetPasswordScreen())),
              icon: const Icon(Icons.key_outlined, color: AppColors.primary),
              label: Text(
                "J'ai déjà un code",
                style: GoogleFonts.inter(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            TextButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.chevron_left, color: AppColors.primary),
              label: Text(
                'Retour à la connexion',
                style: GoogleFonts.inter(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _send() async {
    setState(() => error = null);
    if (email.text.trim().isEmpty) {
      setState(() => error = 'Entrez votre adresse e-mail.');
      return;
    }
    setState(() => busy = true);
    try {
      await ApiClient().post('/api/auth/forgot-password', {'email': email.text.trim()});
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Si cet e-mail existe, un code a été envoyé et imprimé dans les logs backend.')),
      );
      Navigator.push(context, MaterialPageRoute(builder: (_) => const ResetPasswordScreen()));
    } catch (e) {
      if (mounted) setState(() => error = e.toString());
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }
}

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final token = TextEditingController();
  final password = TextEditingController();
  final confirmPassword = TextEditingController();
  bool busy = false;
  bool obscure = true;
  bool obscureConfirm = true;
  String? error;

  @override
  void dispose() {
    token.dispose();
    password.dispose();
    confirmPassword.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _AuthPage(
      title: 'Réinitialisation',
      subtitle: 'Choisissez votre nouveau mot de passe',
      onBack: () => Navigator.pop(context),
      maxWidth: 620,
      child: _Panel(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const _CircleIcon(Icons.refresh),
            const SizedBox(height: 28),
            _LabeledField(
              label: 'CODE DE RÉINITIALISATION',
              hint: 'Entrez le code à 6 chiffres',
              icon: Icons.key_outlined,
              controller: token,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 18),
            _LabeledField(
              label: 'NOUVEAU MOT DE PASSE',
              hint: 'Minimum 8 caractères',
              icon: Icons.lock_outline,
              controller: password,
              obscureText: obscure,
              suffix: IconButton(
                icon: Icon(obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                onPressed: () => setState(() => obscure = !obscure),
              ),
            ),
            const SizedBox(height: 18),
            _LabeledField(
              label: 'CONFIRMER LE NOUVEAU MOT DE PASSE',
              hint: 'Répétez le mot de passe',
              icon: Icons.verified_user_outlined,
              controller: confirmPassword,
              obscureText: obscureConfirm,
              suffix: IconButton(
                icon: Icon(obscureConfirm ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                onPressed: () => setState(() => obscureConfirm = !obscureConfirm),
              ),
            ),
            if (error != null) ...[
              const SizedBox(height: 14),
              _ErrorBox(error!),
            ],
            const SizedBox(height: 28),
            _PrimaryButton(
              text: 'Réinitialiser',
              icon: Icons.arrow_forward,
              busy: busy,
              onPressed: _reset,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _reset() async {
    setState(() => error = null);
    if (token.text.trim().isEmpty || password.text.length < 8) {
      setState(() => error = 'Entrez le code et un mot de passe de 8 caractères minimum.');
      return;
    }
    if (password.text != confirmPassword.text) {
      setState(() => error = 'Les deux mots de passe ne correspondent pas.');
      return;
    }
    setState(() => busy = true);
    try {
      await ApiClient().post('/api/auth/reset-password', {'token': token.text.trim(), 'newPassword': password.text});
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Mot de passe réinitialisé.')));
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
    } catch (e) {
      if (mounted) setState(() => error = e.toString());
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }
}

class _AuthPage extends StatelessWidget {
  const _AuthPage({
    required this.child,
    required this.title,
    this.subtitle,
    this.onBack,
    this.showHelp = false,
    this.showMenu = false,
    this.maxWidth = 430,
    super.key,
  });

  final Widget child;
  final String title;
  final String? subtitle;
  final VoidCallback? onBack;
  final bool showHelp;
  final bool showMenu;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Background soft circles for premium vibes on the bottom
          Positioned(
            bottom: -120,
            left: -120,
            child: _SoftCircle(size: 280, color: AppColors.accent.withOpacity(.06)),
          ),
          Positioned(
            top: 250,
            right: -80,
            child: _SoftCircle(size: 240, color: AppColors.primary.withOpacity(.04)),
          ),
          // The scrollable body overlapping the header curve
          Positioned.fill(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  // Curved Header at the top of the scroll content or stacked
                  _IndigoHeaderCurve(
                    title: title,
                    subtitle: subtitle,
                    onBack: onBack,
                    showHelp: showHelp,
                    showMenu: showMenu,
                  ),
                  const SizedBox(height: 12),
                  // Constrain the actual form card
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: maxWidth),
                        child: child,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SoftCircle extends StatelessWidget {
  const _SoftCircle({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}

class _IndigoHeaderCurve extends StatelessWidget {
  const _IndigoHeaderCurve({
    required this.title,
    this.subtitle,
    this.onBack,
    this.showHelp = false,
    this.showMenu = false,
  });

  final String title;
  final String? subtitle;
  final VoidCallback? onBack;
  final bool showHelp;
  final bool showMenu;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 260, // Height representing ~25-30% of the screen
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.primary,
            AppColors.primaryDark,
          ],
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(40)),
      ),
      child: Stack(
        children: [
          // Soft circles for premium glowing backdrop effect
          Positioned(
            top: -40,
            left: -40,
            child: Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.04),
              ),
            ),
          ),
          Positioned(
            bottom: -60,
            right: -20,
            child: Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.03),
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (onBack != null)
                        IconButton(
                          onPressed: onBack,
                          icon: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
                        )
                      else
                        const SizedBox(width: 48), // Spacer to balance when there's no back button
                      // Brand Name Centered
                      Text(
                        'E-SAMSAR',
                        style: GoogleFonts.inter(
                          color: Colors.white.withOpacity(0.85),
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 2.0,
                        ),
                      ),
                      if (showHelp)
                        IconButton(
                          onPressed: () {},
                          icon: const Icon(Icons.help_outline, color: Colors.white, size: 26),
                        )
                      else if (showMenu)
                        IconButton(
                          onPressed: () {},
                          icon: const Icon(Icons.menu, color: Colors.white, size: 28),
                        )
                      else
                        const SizedBox(width: 48),
                    ],
                  ),
                  const Spacer(),
                  Text(
                    title,
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontSize: 34,
                      fontWeight: FontWeight.w800,
                      height: 1.15,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 6),
                    Text(
                      subtitle!,
                      style: GoogleFonts.inter(
                        color: Colors.white.withOpacity(0.72),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Panel extends StatelessWidget {
  const _Panel({required this.child, this.padding = const EdgeInsets.all(28)});

  final Widget child;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.outline),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _LabeledField extends StatelessWidget {
  const _LabeledField({
    required this.label,
    required this.hint,
    required this.controller,
    this.icon,
    this.suffix,
    this.obscureText = false,
    this.keyboardType,
  });

  final String label;
  final String hint;
  final TextEditingController controller;
  final IconData? icon;
  final Widget? suffix;
  final bool obscureText;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _FieldLabel(label),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.text,
          ),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            hintText: hint,
            hintStyle: GoogleFonts.inter(
              fontSize: 15,
              fontWeight: FontWeight.w400,
              color: AppColors.muted,
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            prefixIcon: icon == null
                ? null
                : Icon(icon, color: AppColors.primary.withOpacity(0.54), size: 22),
            suffixIcon: suffix,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: AppColors.outline),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: AppColors.outline),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
            ),
          ),
        ),
      ],
    );
  }
}

class _PhoneField extends StatelessWidget {
  const _PhoneField({required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _FieldLabel('Téléphone'),
        const SizedBox(height: 8),
        Row(
          children: [
            Container(
              height: 58,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: AppColors.surfaceLow,
                borderRadius: const BorderRadius.horizontal(left: Radius.circular(16)),
                border: Border.all(color: AppColors.outline),
              ),
              child: Center(
                child: Text(
                  '+212',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.muted,
                  ),
                ),
              ),
            ),
            Expanded(
              child: TextField(
                controller: controller,
                keyboardType: TextInputType.phone,
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.text,
                ),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  hintText: '6 12 34 56 78',
                  hintStyle: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                    color: AppColors.muted,
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                  border: OutlineInputBorder(
                    borderRadius: const BorderRadius.horizontal(right: Radius.circular(16)),
                    borderSide: const BorderSide(color: AppColors.outline),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: const BorderRadius.horizontal(right: Radius.circular(16)),
                    borderSide: const BorderSide(color: AppColors.outline),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: const BorderRadius.horizontal(right: Radius.circular(16)),
                    borderSide: const BorderSide(color: AppColors.primary, width: 2),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  const _PrimaryButton({required this.text, required this.onPressed, this.busy = false, this.icon});

  final String text;
  final VoidCallback onPressed;
  final bool busy;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: busy ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.accent,
        foregroundColor: Colors.white,
        minimumSize: const Size.fromHeight(58),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        textStyle: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.5,
        ),
      ),
      child: busy
          ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
          : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(text),
                if (icon != null) ...[
                  const SizedBox(width: 12),
                  Icon(icon, size: 22),
                ],
              ],
            ),
    );
  }
}

class _DividerText extends StatelessWidget {
  const _DividerText(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(child: Divider(color: AppColors.outline)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18),
          child: Text(
            text,
            style: GoogleFonts.inter(
              color: AppColors.muted,
              fontWeight: FontWeight.w800,
              fontSize: 14,
            ),
          ),
        ),
        const Expanded(child: Divider(color: AppColors.outline)),
      ],
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w800,
        color: AppColors.primary.withOpacity(0.8),
        letterSpacing: 0.5,
      ),
    );
  }
}

class _ErrorBox extends StatelessWidget {
  const _ErrorBox(this.message);

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.error.withOpacity(.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.error.withOpacity(.24)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.error_outline, color: AppColors.error, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: GoogleFonts.inter(
                color: AppColors.error,
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  const _RoleCard({required this.label, required this.icon, required this.selected, required this.onTap});

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 150,
        decoration: BoxDecoration(
          color: selected ? Colors.white : AppColors.surfaceLow.withOpacity(0.6),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? AppColors.accent : AppColors.outline,
            width: selected ? 2.5 : 1,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: AppColors.accent.withOpacity(0.12),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  )
                ]
              : const [
                  BoxShadow(
                    color: Color(0x05000000),
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  )
                ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: selected ? AppColors.accent.withOpacity(0.12) : AppColors.primary.withOpacity(0.06),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: selected ? AppColors.accent : AppColors.primary,
                size: 32,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: selected ? AppColors.accent : AppColors.text,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CircleIcon extends StatelessWidget {
  const _CircleIcon(this.icon);

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 86,
        height: 86,
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(.08),
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.primary.withOpacity(0.12), width: 1.5),
        ),
        child: Icon(icon, color: AppColors.primary, size: 42),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.icon, required this.badge, required this.text});

  final IconData icon;
  final String badge;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceLow.withOpacity(0.5),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.outline),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.accent.withOpacity(.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppColors.accent),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.accent.withOpacity(.12),
                    borderRadius: BorderRadius.circular(99),
                  ),
                  child: Text(
                    badge,
                    style: GoogleFonts.inter(
                      color: AppColors.accent,
                      fontWeight: FontWeight.w800,
                      fontSize: 11,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  text,
                  style: GoogleFonts.inter(
                    color: AppColors.muted,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _WelcomeCard extends StatelessWidget {
  const _WelcomeCard({required this.onLogin, required this.onRegister});

  final VoidCallback onLogin;
  final VoidCallback onRegister;

  @override
  Widget build(BuildContext context) {
    return _Panel(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Bienvenue sur E-Samsar',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              color: AppColors.primary,
              fontSize: 26,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Transportez vos marchandises simplement.',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              color: AppColors.muted,
              fontSize: 16,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 28),
          _PrimaryButton(onPressed: onLogin, text: 'Se connecter'),
          const SizedBox(height: 14),
          OutlinedButton(
            onPressed: onRegister,
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(58),
              side: const BorderSide(color: AppColors.outline, width: 1.5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              textStyle: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            child: const Text('Créer un compte'),
          ),
          const SizedBox(height: 28),
          const Divider(color: AppColors.outline),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: const [
              Expanded(child: _MiniTrust(icon: Icons.verified_user_outlined, label: 'Sécurisé')),
              Expanded(child: _MiniTrust(icon: Icons.local_shipping_outlined, label: 'Fiable')),
              Expanded(child: _MiniTrust(icon: Icons.support_agent_outlined, label: 'Support 24/7')),
            ],
          ),
        ],
      ),
    );
  }
}

class _MiniTrust extends StatelessWidget {
  const _MiniTrust({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.06),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: AppColors.primary, size: 20),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            color: AppColors.muted,
          ),
        ),
      ],
    );
  }
}

class _FeatureTile extends StatelessWidget {
  const _FeatureTile({required this.color, required this.icon, required this.title, required this.text});

  final Color color;
  final IconData icon;
  final String title;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: color.withOpacity(.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(.16)),
      ),
      child: Row(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.24),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(icon, color: Colors.white, size: 26),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    color: AppColors.primary,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  text,
                  style: GoogleFonts.inter(
                    color: AppColors.muted,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AuthFooter extends StatelessWidget {
  const _AuthFooter();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Wrap(
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 16,
          runSpacing: 8,
          children: const [
            _FooterItem(icon: Icons.language, text: 'Français (MA)'),
            _FooterItem(text: "Centre d'aide"),
          ],
        ),
        const SizedBox(height: 20),
        Text(
          "En vous connectant, vous acceptez nos conditions d'utilisation.",
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(
            color: AppColors.muted,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _FooterItem extends StatelessWidget {
  const _FooterItem({required this.text, this.icon});

  final String text;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon != null) ...[
          Icon(icon, color: AppColors.muted, size: 16),
          const SizedBox(width: 6),
        ],
        Text(
          text,
          style: GoogleFonts.inter(
            color: AppColors.muted,
            fontWeight: FontWeight.w800,
            fontSize: 13,
          ),
        ),
      ],
    );
  }
}
