import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'api_client.dart';
import 'models.dart';

class AppState extends ChangeNotifier {
  final ApiClient api = ApiClient();

  bool booting = true;
  bool busy = false;
  String? error;
  UserModel? currentUser;

  bool get isAuthenticated => api.token != null && currentUser != null;
  String get currentRole => UserModel.normalizeRole(currentUser?.role ?? '');

  Future<void> restoreSession() async {
    final prefs = await SharedPreferences.getInstance();
    api.token = prefs.getString('accessToken');
    if (api.token == null) {
      booting = false;
      notifyListeners();
      return;
    }
    try {
      final json = await api.get('/api/auth/me');
      currentUser = UserModel.fromJson(json);
    } catch (_) {
      await prefs.remove('accessToken');
      api.token = null;
    }
    booting = false;
    notifyListeners();
  }

  Future<void> login(String email, String password) async {
    busy = true;
    error = null;
    notifyListeners();
    try {
      final json = await api.post('/api/auth/login', {
        'email': email.trim(),
        'password': password,
      });
      api.token = json['accessToken']?.toString();
      final responseUser = json['user'];
      if (responseUser is Map<String, dynamic>) {
        currentUser = UserModel.fromJson(responseUser);
      }
      final freshUser = await api.get('/api/auth/me');
      currentUser = UserModel.fromJson(freshUser);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('accessToken', api.token!);
    } catch (e) {
      error = e.toString();
      rethrow;
    } finally {
      busy = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('accessToken');
    api.token = null;
    currentUser = null;
    notifyListeners();
  }
}

class AppStateScope extends InheritedNotifier<AppState> {
  const AppStateScope({
    required AppState super.notifier,
    required super.child,
    super.key,
  });

  static AppState of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppStateScope>();
    return scope!.notifier!;
  }

  static AppState read(BuildContext context) {
    final element = context.getElementForInheritedWidgetOfExactType<AppStateScope>();
    final scope = element!.widget as AppStateScope;
    return scope.notifier!;
  }
}
