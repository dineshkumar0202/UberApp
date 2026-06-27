import 'package:flutter_test/flutter_test.dart';
import 'package:ridoo_customer/app.dart';

void main() {
  testWidgets('Ridoo splash shows app name', (WidgetTester tester) async {
    await tester.pumpWidget(const RidooCustomerApp());
    expect(find.text('Ridoo'), findsOneWidget);
  });
}
