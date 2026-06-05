import 'package:flutter_test/flutter_test.dart';
import 'package:all_in_box/app.dart';

void main() {
  testWidgets('App should render', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    expect(find.text('all-in-box'), findsOneWidget);
  });
}
