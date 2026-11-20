import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import '../../core/auth/auth_provider_kind.dart';
import '../../core/auth/email_password.dart';
import '../../l10n/l10n_ext.dart';
import '../../providers/auth_providers.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_snack.dart';

/// Google + email/password controls. Used on the auth gate and (rarely)
/// Settings if a leftover guest session is still present.
///
/// The email part has two modes: sign in (default) and create account, which
/// adds a "confirm password" field. Validation errors show on the field.
class SignInForm extends ConsumerStatefulWidget {
  const SignInForm({super.key, this.onSignedIn});

  final VoidCallback? onSignedIn;

  @override
  ConsumerState<SignInForm> createState() => _SignInFormState();
}

class _SignInFormState extends ConsumerState<SignInForm> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  bool _hidePassword = true;
  bool _createMode = false;
  String? _emailError;
  String? _passwordError;
  String? _confirmError;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _afterOk() async {
    if (!mounted) return;
    widget.onSignedIn?.call();
    showAppSnack(context, context.l10n.accountSignedInSnack);
  }

  Future<void> _google(AuthProviderKind provider) async {
    final ok = await ref.read(authActionsProvider).signIn(provider);
    if (ok) await _afterOk();
  }

  void _setMode(bool create) {
    setState(() {
      _createMode = create;
      _emailError = null;
      _passwordError = null;
      _confirmError = null;
      _confirm.clear();
    });
    ref.read(authErrorProvider.notifier).state = null;
  }

  String? _emailIssue(AppLocalizations l10n) {
    final issue = validateEmailPassword(
      email: _email.text,
      password: 'x' * kMinAuthPasswordLength,
    );
    return issue == null ? null : l10n.authInvalidEmail;
  }

  Future<void> _forgotPassword() async {
    final l10n = context.l10n;
    final emailError = _emailIssue(l10n);
    setState(() => _emailError = emailError);
    if (emailError != null) return;
    final ok = await ref
        .read(authActionsProvider)
        .requestPasswordReset(_email.text.trim());
    if (!mounted) return;
    if (ok) {
      showAppSnack(context, l10n.authResetEmailSent);
    }
  }

  Future<void> _submit() async {
    final l10n = context.l10n;
    final emailError = _emailIssue(l10n);
    final passwordError = _password.text.length < kMinAuthPasswordLength
        ? l10n.authShortPassword
        : null;
    final confirmError =
        _createMode && passwordError == null && _confirm.text != _password.text
        ? l10n.authPasswordMismatch
        : null;
    setState(() {
      _emailError = emailError;
      _passwordError = passwordError;
      _confirmError = confirmError;
    });
    if (emailError != null || passwordError != null || confirmError != null) {
      return;
    }

    final actions = ref.read(authActionsProvider);
    final ok = _createMode
        ? await actions.signUpWithEmail(_email.text, _password.text)
        : await actions.signInWithEmail(_email.text, _password.text);
    if (ok) await _afterOk();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final auth = ref.watch(authServiceProvider);
    final busy = ref.watch(authBusyProvider);
    final error = ref.watch(authErrorProvider);

    if (busy) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(
          child: SizedBox(
            width: 28,
            height: 28,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      );
    }

    final passwordToggle = IconButton(
      onPressed: () => setState(() => _hidePassword = !_hidePassword),
      icon: Icon(
        _hidePassword
            ? Icons.visibility_outlined
            : Icons.visibility_off_outlined,
      ),
    );

    return AutofillGroup(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final provider in auth.availableProviders) ...[
            if (provider == AuthProviderKind.apple)
              // Apple's own button style (HIG), same size and position as
              // Google.
              SignInWithAppleButton(
                onPressed: () => _google(provider),
                text: l10n.signInWith(provider.label),
                style: SignInWithAppleButtonStyle.white,
                height: 44,
                borderRadius: const BorderRadius.all(Radius.circular(22)),
              )
            else
              // Google sign-in branding: light button, multicolor "G".
              FilledButton.icon(
                onPressed: () => _google(provider),
                icon: const GoogleGLogo(size: 18),
                label: Text(l10n.signInWith(provider.label)),
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF1F1F1F),
                ),
              ),
            const SizedBox(height: 8),
          ],
          _orDivider(l10n),
          const SizedBox(height: 12),
          TextField(
            controller: _email,
            keyboardType: TextInputType.emailAddress,
            autofillHints: const [AutofillHints.email],
            textInputAction: TextInputAction.next,
            autocorrect: false,
            onChanged: (_) {
              if (_emailError != null) setState(() => _emailError = null);
            },
            decoration: _fieldDecoration(
              l10n.authEmailLabel,
              errorText: _emailError,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _password,
            obscureText: _hidePassword,
            autofillHints: [
              _createMode ? AutofillHints.newPassword : AutofillHints.password,
            ],
            textInputAction: _createMode
                ? TextInputAction.next
                : TextInputAction.done,
            onSubmitted: _createMode ? null : (_) => _submit(),
            onChanged: (_) {
              if (_passwordError != null) {
                setState(() => _passwordError = null);
              }
            },
            decoration: _fieldDecoration(
              l10n.authPasswordLabel,
              errorText: _passwordError,
              suffixIcon: passwordToggle,
            ),
          ),
          if (_createMode) ...[
            const SizedBox(height: 12),
            TextField(
              controller: _confirm,
              obscureText: _hidePassword,
              autofillHints: const [AutofillHints.newPassword],
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _submit(),
              onChanged: (_) {
                if (_confirmError != null) {
                  setState(() => _confirmError = null);
                }
              },
              decoration: _fieldDecoration(
                l10n.authConfirmPasswordLabel,
                errorText: _confirmError,
              ),
            ),
          ],
          const SizedBox(height: 16),
          FilledButton(
            onPressed: _submit,
            child: Text(
              _createMode ? l10n.authCreateAccount : l10n.authSignInEmail,
            ),
          ),
          // Server / auth errors stay next to the button that caused them.
          if (error != null && error.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              _localizeAuthError(l10n, error),
              style: GoogleFonts.rajdhani(
                color: AppTheme.signal,
                fontSize: 13,
                height: 1.35,
              ),
            ),
          ],
          const SizedBox(height: 4),
          if (_createMode)
            TextButton(
              onPressed: () => _setMode(false),
              child: Text(l10n.authHaveAccount),
            )
          else ...[
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: _forgotPassword,
                child: Text(l10n.authForgotPassword),
              ),
            ),
            TextButton(
              onPressed: () => _setMode(true),
              child: Text(l10n.authNoAccount),
            ),
          ],
        ],
      ),
    );
  }

  InputDecoration _fieldDecoration(
    String label, {
    String? errorText,
    Widget? suffixIcon,
  }) {
    OutlineInputBorder border(Color color, [double width = 1]) {
      return OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: color, width: width),
      );
    }

    return InputDecoration(
      labelText: label,
      errorText: errorText,
      errorMaxLines: 2,
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: AppTheme.asphaltElevated,
      border: border(AppTheme.mist.withValues(alpha: 0.24)),
      enabledBorder: border(AppTheme.mist.withValues(alpha: 0.24)),
      focusedBorder: border(AppTheme.line, 2),
      errorBorder: border(AppTheme.signal),
      focusedErrorBorder: border(AppTheme.signal, 2),
    );
  }

  Widget _orDivider(AppLocalizations l10n) {
    return Row(
      children: [
        const Expanded(child: Divider()),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Text(
            l10n.authOrEmail,
            style: GoogleFonts.rajdhani(color: AppTheme.steel, fontSize: 12),
          ),
        ),
        const Expanded(child: Divider()),
      ],
    );
  }
}

String _localizeAuthError(AppLocalizations l10n, String raw) {
  return switch (classifyEmailAuthError(raw)) {
    EmailAuthServerIssue.invalidCredentials => l10n.authInvalidCredentials,
    EmailAuthServerIssue.emailNotConfirmed ||
    EmailAuthServerIssue.needsEmailConfirm => l10n.authConfirmEmailThenSignIn,
    EmailAuthServerIssue.alreadyRegistered => l10n.authEmailAlreadyRegistered,
    EmailAuthServerIssue.unknown => l10n.userFacingError(raw),
  };
}

/// Google's multicolor "G" mark, drawn without an asset or SVG dependency.
class GoogleGLogo extends StatelessWidget {
  const GoogleGLogo({super.key, this.size = 18});

  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: size,
      child: const CustomPaint(painter: _GoogleGPainter()),
    );
  }
}

class _GoogleGPainter extends CustomPainter {
  const _GoogleGPainter();

  static const _blue = Color(0xFF4285F4);
  static const _green = Color(0xFF34A853);
  static const _yellow = Color(0xFFFBBC05);
  static const _red = Color(0xFFEA4335);

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.shortestSide;
    final stroke = s * 0.2;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (s - stroke) / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);
    const deg = 3.141592653589793 / 180;

    Paint arc(Color color) => Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke;

    // Angles: 0 = 3 o'clock, clockwise. The opening sits at the upper right.
    canvas.drawArc(rect, 0 * deg, 45 * deg, false, arc(_blue));
    canvas.drawArc(rect, 45 * deg, 100 * deg, false, arc(_green));
    canvas.drawArc(rect, 145 * deg, 70 * deg, false, arc(_yellow));
    canvas.drawArc(rect, 215 * deg, 100 * deg, false, arc(_red));

    // Crossbar of the G.
    canvas.drawRect(
      Rect.fromLTRB(
        center.dx,
        center.dy - stroke / 2,
        center.dx + radius + stroke / 2,
        center.dy + stroke / 2,
      ),
      Paint()..color = _blue,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
