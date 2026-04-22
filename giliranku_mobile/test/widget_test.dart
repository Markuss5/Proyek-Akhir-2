import 'package:flutter_test/flutter_test.dart';
import 'package:giliranku/main.dart'; 

void main() {
  testWidgets('App load test', (WidgetTester tester) async {
    // Mengetes apakah aplikasi bisa terbuka tanpa error
    await tester.pumpWidget(const MyApp());
  });
}