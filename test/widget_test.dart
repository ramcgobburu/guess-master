import 'package:flutter_test/flutter_test.dart';
import 'package:ipl_predictor/main.dart';

void main() {
  testWidgets('App renders splash screen', (WidgetTester tester) async {
    await tester.pumpWidget(const GuessMasterApp());
    expect(find.text('Guess Master'), findsOneWidget);
  });
}
