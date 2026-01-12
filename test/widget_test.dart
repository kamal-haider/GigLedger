import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gigledger/app/app.dart';

void main() {
  testWidgets('App smoke test', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: GigLedgerApp(),
      ),
    );

    // Verify that app title is displayed
    expect(find.text('GigLedger'), findsOneWidget);
  });
}
