import 'package:flutter_test/flutter_test.dart';

import 'package:hitera_mobile/main.dart';

void main() {
  testWidgets('HiteraApp smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const HiteraApp());
    await tester.pump();
    expect(find.text('HITERA'), findsWidgets);
  });
}
