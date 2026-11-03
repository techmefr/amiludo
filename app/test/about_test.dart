import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:amiludo/layers/technical/About/app_info.dart';

void main() {
  testWidgets(
    'public testing entry shows version, source and feedback actions',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: TextButton(
                onPressed: () => showProjectInfo(context),
                child: const Text('About'),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('About'));
      await tester.pumpAndSettle();
      expect(find.text(appVersion), findsOneWidget);
      expect(find.text(projectUrl), findsOneWidget);
      expect(find.text('Report a bug'), findsOneWidget);
      expect(find.text('Suggest an idea'), findsOneWidget);
      expect(
        Uri.parse(bugReportUrl).queryParameters['template'],
        'bug_report.yml',
      );
    },
  );
}
