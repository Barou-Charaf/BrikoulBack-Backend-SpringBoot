import 'package:flutter/material.dart';

import 'core/app_state.dart';
import 'core/app_theme.dart';
import 'features/auth/auth_screens.dart';
import 'features/driver/driver_shell.dart';
import 'features/shipper/shipper_shell.dart';

class ESamsarApp extends StatefulWidget {
  const ESamsarApp({super.key});

  @override
  State<ESamsarApp> createState() => _ESamsarAppState();
}

class _ESamsarAppState extends State<ESamsarApp> {
  final AppState appState = AppState();

  @override
  void initState() {
    super.initState();
    appState.restoreSession();
  }

  @override
  Widget build(BuildContext context) {
    return AppStateScope(
      notifier: appState,
      child: MaterialApp(
        title: 'E-Samsar',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(),
        routes: {
          '/driver': (_) => const DriverShell(),
          '/shipper': (_) => const ShipperShell(),
        },
        home: AnimatedBuilder(
          animation: appState,
          builder: (context, _) {
            if (appState.booting) {
              return const SplashScreen();
            }
            if (!appState.isAuthenticated) {
              return const WelcomeScreen();
            }
            final role = appState.currentRole;
            if (role == 'DRIVER') {
              return const DriverShell();
            }
            if (role == 'SHIPPER') {
              return const ShipperShell();
            }
            return UnsupportedRoleScreen(appState: appState);
          },
        ),
      ),
    );
  }
}

class UnsupportedRoleScreen extends StatelessWidget {
  const UnsupportedRoleScreen({required this.appState, super.key});

  final AppState appState;

  @override
  Widget build(BuildContext context) {
    final user = appState.currentUser;
    return Scaffold(
      appBar: AppBar(title: const Text('Session connectée')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.warning_amber_rounded, size: 56),
                const SizedBox(height: 16),
                const Text(
                  'Rôle utilisateur non reconnu',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 10),
                Text(
                  'Email: ${user?.email ?? '-'}\nRôle reçu: ${user?.role ?? '-'}',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () => appState.logout(),
                  child: const Text('Se déconnecter'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
