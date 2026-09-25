import 'package:flutter_test/flutter_test.dart';
import 'package:kayo/main.dart';

void main() {
  testWidgets('App initializes', (WidgetTester tester) async {
    await tester.pumpWidget(const KayoApp());
    expect(find.byType(KayoApp), findsOneWidget);
  });
}
