import 'package:flutter/material.dart';

import '../../core/api_client.dart';
import '../../core/app_state.dart';
import '../../core/app_theme.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Stack(
        children: [
          Positioned(
            left: -90,
            bottom: 130,
            child: Icon(
              Icons.local_shipping,
              size: 170,
              color: Colors.white.withOpacity(.08),
            ),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.all(28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 96,
                    height: 96,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(28),
                    ),
                    child: const Icon(Icons.local_shipping, color: AppColors.primary, size: 54),
                  ),
                  const SizedBox(height: 28),
                  const Text(
                    'E-Samsar',
                    style: TextStyle(color: Colors.white, fontSize: 42, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'LOGISTIQUE MAROCAINE PREMIUM',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white.withOpacity(.62),
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 90),
                  Text(
                    'Chargement...',
                    style: TextStyle(color: Colors.white.withOpacity(.78), fontSize: 18, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: 160,
                    child: LinearProgressIndicator(
                      minHeight: 4,
                      backgroundColor: Colors.white.withOpacity(.14),
                      color: Colors.white.withOpacity(.65),
                    ),
                  ),
                  const SizedBox(height: 68),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.verified_user_outlined, color: Colors.white.withOpacity(.58), size: 18),
                      const SizedBox(width: 8),
                      Text(
                        'SÉCURISÉ PAR E-SAMSAR TECH',
                        style: TextStyle(
                          color: Colors.white.withOpacity(.58),
                          fontWeight: FontWeight.w700,
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
    );
  }
}

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return _AuthPage(
      maxWidth: 430,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _TopBrandBar(showMenu: true),
          const SizedBox(height: 22),
          Container(
            height: 210,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(22),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.primary.withOpacity(.12),
                  AppColors.primary.withOpacity(.03),
                ],
              ),
            ),
            child: Center(
              child: Icon(Icons.local_shipping, size: 132, color: AppColors.primary.withOpacity(.18)),
            ),
          ),
          const SizedBox(height: 18),
          _WelcomeCard(
            onLogin: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginScreen())),
            onRegister: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RegisterScreen())),
          ),
          const SizedBox(height: 18),
          const _FeatureTile(
            color: AppColors.accent,
            icon: Icons.speed_outlined,
            title: 'Rapidité',
            text: 'Trouvez un transporteur en moins de 5 minutes.',
          ),
          const SizedBox(height: 14),
          const _FeatureTile(
            color: AppColors.secondary,
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
      maxWidth: 430,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 38),
          const _BrandHeader(),
          const SizedBox(height: 34),
          _Panel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text('Connexion', style: _AuthTextStyles.title),
                const SizedBox(height: 4),
                const Text('Accédez à votre espace transport', style: _AuthTextStyles.subtitle),
                const SizedBox(height: 28),
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
                    child: const Text('Mot de passe oublié ?'),
                  ),
                ),
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
                  child: const Text('Créer un compte'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
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
      maxWidth: 560,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _TopBrandBar(onBack: () => Navigator.pop(context), showHelp: true),
          const SizedBox(height: 34),
          const Text('Créer un compte', style: TextStyle(fontSize: 34, fontWeight: FontWeight.w900, color: AppColors.text)),
          const SizedBox(height: 12),
          const Text(
            'Rejoignez la première plateforme de transport logistique au Maroc.',
            style: TextStyle(fontSize: 20, height: 1.35, color: AppColors.muted),
          ),
          const SizedBox(height: 30),
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
              const SizedBox(width: 20),
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
              const SizedBox(width: 20),
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
              Checkbox(value: accepted, onChanged: (value) => setState(() => accepted = value ?? false)),
              const Expanded(
                child: Padding(
                  padding: EdgeInsets.only(top: 10),
                  child: Text.rich(
                    TextSpan(
                      text: "J'accepte les ",
                      children: [
                        TextSpan(text: "Conditions d'utilisation", style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w800)),
                        TextSpan(text: ' et la '),
                        TextSpan(text: 'Politique de confidentialité', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w800)),
                        TextSpan(text: " d'E-Samsar."),
                      ],
                    ),
                    style: TextStyle(fontSize: 16, height: 1.3, color: AppColors.muted),
                  ),
                ),
              ),
            ],
          ),
          if (error != null) ...[
            const SizedBox(height: 12),
            _ErrorBox(error!),
          ],
          const SizedBox(height: 20),
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
              child: const Text('Vous avez déjà un compte ? Se connecter'),
            ),
          ),
        ],
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
      maxWidth: 560,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _TopBrandBar(onBack: () => Navigator.pop(context)),
          const SizedBox(height: 54),
          const _CircleIcon(Icons.email_outlined),
          const SizedBox(height: 28),
          const Text(
            "Vérification de l'e-mail",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 34, fontWeight: FontWeight.w900, color: AppColors.primary),
          ),
          const SizedBox(height: 14),
          const Text(
            'Entrez le code de vérification reçu par e-mail.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 20, height: 1.35, color: AppColors.muted),
          ),
          const SizedBox(height: 34),
          _InfoCard(
            icon: Icons.lock_outline,
            badge: 'SÉCURITÉ',
            text: 'En mode test, le backend imprime aussi ce code dans la console après inscription.',
          ),
          const SizedBox(height: 30),
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
          const SizedBox(height: 22),
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
              child: const Text('Retour à la connexion'),
            ),
          ),
        ],
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
      maxWidth: 620,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _TopBrandBar(onBack: () => Navigator.pop(context)),
          const SizedBox(height: 120),
          _Panel(
            padding: const EdgeInsets.all(42),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const _CircleIcon(Icons.lock_outline),
                const SizedBox(height: 28),
                const Text(
                  'Mot de passe oublié',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 34, fontWeight: FontWeight.w900, color: AppColors.text),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Saisissez votre e-mail pour recevoir un code de réinitialisation sécurisé.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 19, height: 1.35, color: AppColors.muted),
                ),
                const SizedBox(height: 34),
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
                const SizedBox(height: 18),
                TextButton.icon(
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ResetPasswordScreen())),
                  icon: const Icon(Icons.key_outlined),
                  label: const Text("J'ai déjà un code"),
                ),
                TextButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.chevron_left),
                  label: const Text('Retour à la connexion'),
                ),
              ],
            ),
          ),
        ],
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
      maxWidth: 620,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _TopBrandBar(onBack: () => Navigator.pop(context)),
          const SizedBox(height: 110),
          _Panel(
            padding: const EdgeInsets.all(42),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const _CircleIcon(Icons.refresh),
                const SizedBox(height: 28),
                const Text(
                  'Réinitialiser le mot de passe',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 30, fontWeight: FontWeight.w900, color: AppColors.text),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Veuillez saisir le code reçu et choisir votre nouveau mot de passe sécurisé.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 17, height: 1.35, color: AppColors.muted),
                ),
                const SizedBox(height: 32),
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
                const SizedBox(height: 26),
                _PrimaryButton(
                  text: 'Réinitialiser',
                  icon: Icons.arrow_forward,
                  busy: busy,
                  onPressed: _reset,
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),
          Center(
            child: TextButton(
              onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen())),
              child: const Text("Besoin d'aide ? Contacter le support"),
            ),
          ),
        ],
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
  const _AuthPage({required this.child, this.maxWidth = 430});

  final Widget child;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          Positioned(
            top: -90,
            right: -100,
            child: _SoftCircle(size: 260, color: AppColors.primary.withOpacity(.08)),
          ),
          Positioned(
            bottom: -120,
            left: -120,
            child: _SoftCircle(size: 280, color: AppColors.accent.withOpacity(.08)),
          ),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 22),
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: maxWidth),
                  child: child,
                ),
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

class _BrandHeader extends StatelessWidget {
  const _BrandHeader();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 74,
          height: 74,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [BoxShadow(color: Color(0x22000000), blurRadius: 14, offset: Offset(0, 8))],
          ),
          child: const Icon(Icons.local_shipping_outlined, color: Colors.white, size: 38),
        ),
        const SizedBox(height: 24),
        const Text(
          'E-Samsar',
          style: TextStyle(color: AppColors.primary, fontSize: 38, fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 8),
        const Text(
          'La logistique intelligente au Maroc',
          textAlign: TextAlign.center,
          style: TextStyle(color: AppColors.muted, fontSize: 17),
        ),
      ],
    );
  }
}

class _TopBrandBar extends StatelessWidget {
  const _TopBrandBar({this.onBack, this.showHelp = false, this.showMenu = false});

  final VoidCallback? onBack;
  final bool showHelp;
  final bool showMenu;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (onBack != null)
          IconButton(
            onPressed: onBack,
            icon: const Icon(Icons.arrow_back, color: AppColors.primary, size: 30),
          )
        else
          const SizedBox(width: 4),
        const SizedBox(width: 8),
        const Expanded(
          child: Text(
            'E-Samsar',
            style: TextStyle(color: AppColors.primary, fontSize: 34, fontWeight: FontWeight.w900),
          ),
        ),
        if (showHelp)
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.help_outline, color: AppColors.primary, size: 28),
          ),
        if (showMenu)
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.menu, color: AppColors.primary, size: 30),
          ),
      ],
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
        color: AppColors.surface.withOpacity(.94),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.outline),
        boxShadow: const [BoxShadow(color: Color(0x10000000), blurRadius: 18, offset: Offset(0, 10))],
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
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: icon == null ? null : Icon(icon, color: const Color(0xFF6E7B7D)),
            suffixIcon: suffix,
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
              height: 56,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: AppColors.surfaceLow,
                borderRadius: const BorderRadius.horizontal(left: Radius.circular(14)),
                border: Border.all(color: AppColors.outline),
              ),
              child: const Center(
                child: Text('+212', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.muted)),
              ),
            ),
            Expanded(
              child: TextField(
                controller: controller,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  hintText: '6 12 34 56 78',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.horizontal(right: Radius.circular(14)),
                    borderSide: BorderSide(color: AppColors.outline),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.horizontal(right: Radius.circular(14)),
                    borderSide: BorderSide(color: AppColors.outline),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.horizontal(right: Radius.circular(14)),
                    borderSide: BorderSide(color: AppColors.primary, width: 1.6),
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
      child: busy
          ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
          : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(text),
                if (icon != null) ...[
                  const SizedBox(width: 12),
                  Icon(icon, size: 28),
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
          child: Text(text, style: const TextStyle(color: Color(0xFF768184), fontWeight: FontWeight.w900)),
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
      style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w900,
        color: AppColors.muted,
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
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.error.withOpacity(.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.error.withOpacity(.28)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.error_outline, color: AppColors.error, size: 20),
          const SizedBox(width: 8),
          Expanded(child: Text(message, style: const TextStyle(color: AppColors.error, fontWeight: FontWeight.w700))),
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
      borderRadius: BorderRadius.circular(14),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        height: 142,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: selected ? AppColors.primary : AppColors.outline, width: selected ? 2 : 1),
          boxShadow: const [BoxShadow(color: Color(0x0C000000), blurRadius: 8, offset: Offset(0, 4))],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(color: AppColors.primary.withOpacity(.10), shape: BoxShape.circle),
              child: Icon(icon, color: AppColors.primary, size: 30),
            ),
            const SizedBox(height: 18),
            Text(label, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: AppColors.text)),
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
        decoration: BoxDecoration(color: AppColors.primary.withOpacity(.10), shape: BoxShape.circle),
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
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.outline),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(color: AppColors.accent.withOpacity(.18), shape: BoxShape.circle),
            child: Icon(icon, color: AppColors.primary),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                  decoration: BoxDecoration(color: AppColors.accent.withOpacity(.18), borderRadius: BorderRadius.circular(99)),
                  child: Text(badge, style: const TextStyle(color: AppColors.secondary, fontWeight: FontWeight.w900)),
                ),
                const SizedBox(height: 8),
                Text(text, style: const TextStyle(color: AppColors.muted, height: 1.3)),
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
      padding: const EdgeInsets.all(22),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Bienvenue sur E-Samsar',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.primary, fontSize: 27, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 10),
          const Text(
            'Transportez vos marchandises simplement.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.muted, fontSize: 17, height: 1.3),
          ),
          const SizedBox(height: 22),
          ElevatedButton(onPressed: onLogin, child: const Text('Se connecter')),
          const SizedBox(height: 12),
          OutlinedButton(onPressed: onRegister, child: const Text('Créer un compte')),
          const SizedBox(height: 20),
          const Divider(color: AppColors.outline),
          const SizedBox(height: 14),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
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
        Icon(icon, color: AppColors.primary, size: 24),
        const SizedBox(height: 10),
        Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.muted)),
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(.10),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(.20)),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(14)),
            child: Icon(icon, color: Colors.white, size: 26),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: AppColors.primary, fontSize: 18, fontWeight: FontWeight.w900)),
                const SizedBox(height: 4),
                Text(text, style: const TextStyle(color: AppColors.muted, fontSize: 14, height: 1.25)),
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
        const SizedBox(height: 24),
        const Text("En vous connectant, vous acceptez nos conditions d'utilisation.", textAlign: TextAlign.center),
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
          Icon(icon, color: AppColors.muted, size: 18),
          const SizedBox(width: 8),
        ],
        Text(text, style: const TextStyle(color: AppColors.muted, fontWeight: FontWeight.w800)),
      ],
    );
  }
}

class _AuthTextStyles {
  static const title = TextStyle(fontSize: 30, fontWeight: FontWeight.w900, color: AppColors.text);
  static const subtitle = TextStyle(fontSize: 18, color: AppColors.muted);
}
