class AuthState {
  final bool isLoading;
  final String error;
  final bool isLoggedIn;

  const AuthState({
    this.isLoading = false,
    this.error = '',
    this.isLoggedIn = false,
  });

  AuthState copyWith({
    bool? isLoading,
    String? error,
    bool? isLoggedIn,
    String? userPhone,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
    );
  }
}
