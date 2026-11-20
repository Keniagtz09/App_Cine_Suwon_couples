import 'package:flutter_test/flutter_test.dart';
import 'package:cine_suwon/main.dart';

void main() {
  testWidgets('CineSuwonApp smoke test', (WidgetTester tester) async {
    expect(const CineSuwonApp(), isNotNull);
  });
}