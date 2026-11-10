import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:amiludo/layers/functional/Library/presentation/library_actions.dart';
import 'package:amiludo/layers/technical/Theme/components/list_row.dart';
import 'package:amiludo/l10n/app_localizations.dart';

void main() {
  testWidgets('library secondary actions render as five list rows', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        locale: Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(body: LibraryActions()),
      ),
    );
    expect(find.byType(ListRow), findsNWidgets(5));
    expect(find.text('Scan a box'), findsOneWidget);
  });
}
