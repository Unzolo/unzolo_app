import 'package:flutter_test/flutter_test.dart';
import 'package:unzolo/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const UnzoloApp());
    expect(find.byType(UnzoloApp), findsOneWidget);
  });
}
