import 'package:flutter_test/flutter_test.dart';
import 'package:diary/main.dart'; // Adjust based on your pubspec name

void main() {
  testWidgets('Diary Login Test', (WidgetTester tester) async {
    await tester.pumpWidget(const DiaryApp());
    expect(find.text('Secure Diary Login'), findsOneWidget);
    expect(find.text('Unlock Diary'), findsOneWidget);
  });
}