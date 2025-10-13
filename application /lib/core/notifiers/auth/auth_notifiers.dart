import 'package:flutter/widgets.dart';
import '../../apis/auth_api.dart';
import 'auth_state.dart';

class AuthNotifiers extends ChangeNotifier {
  final AuthApi _authApi = AuthApi();

  AuthState _state = const AuthState();
  bool get isLoading => _state.isLoading;
  Future<void> login(String email, String password) async {
    _updateState(isLoading: true);
    try {
      final user = await _authApi.login(email, password);
      if (user != null) {
        _updateState(isLoading: false, isLoggedIn: true);
      } else {
        _updateState(isLoading: false, error: 'Login failed');
      }
    } catch (e) {
      _updateState(isLoading: false, error: e.toString());
    }
  }

  Future<void> logout() async {
    _updateState(isLoading: true);
    try {
      await _authApi.logout();
      _updateState(isLoading: false, isLoggedIn: false);
    } catch (e) {
      _updateState(isLoading: false, error: e.toString());
    }
  }

  Future<void> register(
      String name, String email, String password, String phone) async {
    _updateState(isLoading: true);
    try {
      await _authApi.register(
        name: name,
        email: email,
        password: password,
        phone: phone,
      );
      _updateState(isLoading: false, isLoggedIn: true);
    } catch (e) {
      _updateState(isLoading: false, error: e.toString());
    }
  }

  void _updateState({
    bool? isLoading,
    String? error,
    bool? isLoggedIn,
  }) {
    _state = _state.copyWith(
      isLoading: isLoading,
      error: error,
      isLoggedIn: isLoggedIn,
    );
    notifyListeners();
  }
}
