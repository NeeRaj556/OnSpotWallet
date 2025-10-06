import 'package:flutter/widgets.dart';
import 'package:flutter_starter_kit/core/apis/auth_api.dart';

import 'auth_state.dart';

class AuthNotifiers extends ChangeNotifier {
  final AuthApi _authApi = AuthApi();

  AuthState _state = const AuthState();
  bool get isLoading => _state.isLoading;
  void login(String email, String password) {
    _updateState(isLoading: true);
    _authApi.login(email, password);
    _updateState(isLoading: false, isLoggedIn: true);
  }

  void logout() {
    _updateState(isLoading: true);
    _authApi.logout();
    _updateState(isLoading: false, isLoggedIn: false);
  }

  void register(String email, String password) {
    _updateState(isLoading: true);
    _authApi.register(email, password);
    _updateState(isLoading: false, isLoggedIn: true);
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
