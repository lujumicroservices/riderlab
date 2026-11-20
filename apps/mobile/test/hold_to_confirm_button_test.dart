import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:motoline/features/ride_active/widgets/hold_to_confirm_button.dart';
import 'package:motoline/l10n/app_localizations.dart';
import 'package:motoline/widgets/app_toast.dart';

Widget _wrap(Widget child) {
  return MaterialApp(
    locale: const Locale('es'),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: AppToastHost(
      child: Scaffold(body: Center(child: child)),
    ),
  );
}

void main() {
  testWidgets('short tap does not confirm and shows the hold hint', (
    tester,
  ) async {
    var confirmed = 0;
    await tester.pumpWidget(
      _wrap(
        HoldToConfirmButton(onConfirmed: () => confirmed++, label: 'Terminar'),
      ),
    );

    await tester.tap(find.text('Terminar'));
    await tester.pump(const Duration(milliseconds: 300));
    expect(confirmed, 0);
    expect(find.text('Mantén presionado para terminar'), findsOneWidget);
    await tester.pumpAndSettle(const Duration(seconds: 6));
  });

  testWidgets('holding ~1 s confirms exactly once', (tester) async {
    var confirmed = 0;
    await tester.pumpWidget(
      _wrap(
        HoldToConfirmButton(onConfirmed: () => confirmed++, label: 'Terminar'),
      ),
    );

    final gesture = await tester.startGesture(
      tester.getCenter(find.text('Terminar')),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    expect(confirmed, 0);
    await tester.pump(const Duration(milliseconds: 600));
    expect(confirmed, 1);
    await gesture.up();
    await tester.pumpAndSettle();
    expect(confirmed, 1);
    expect(find.text('Mantén presionado para terminar'), findsNothing);
  });

  testWidgets('button is at least 56 dp tall', (tester) async {
    await tester.pumpWidget(
      _wrap(HoldToConfirmButton(onConfirmed: () {}, label: 'Terminar')),
    );
    expect(
      tester.getSize(find.byType(HoldToConfirmButton)).height,
      greaterThanOrEqualTo(56),
    );
  });
}
