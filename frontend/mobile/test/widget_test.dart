import 'package:flutter_test/flutter_test.dart';

import 'package:exambank/app.dart';

void main() {
  testWidgets('App boots', (tester) async {
    await tester.pumpWidget(const ExamBankApp());
    expect(find.byType(ExamBankApp), findsOneWidget);
  });
}
