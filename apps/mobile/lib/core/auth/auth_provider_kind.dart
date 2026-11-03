/// Supported cloud identity providers. Add new cases as providers ship
/// (Apple, email magic-link, etc.) — keep UI and [AuthService] switch-based.
enum AuthProviderKind {
  /// Sign in with Apple (iOS only; App Store guideline 4.8).
  apple,
  google,
  // email,
}

extension AuthProviderKindX on AuthProviderKind {
  String get id => switch (this) {
        AuthProviderKind.apple => 'apple',
        AuthProviderKind.google => 'google',
      };

  String get label => switch (this) {
        AuthProviderKind.apple => 'Apple',
        AuthProviderKind.google => 'Google',
      };
}
