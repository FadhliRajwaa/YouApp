import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:youapp/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('App Integration Tests', () {
    testWidgets('app launches and shows login screen',
        (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Should show login screen by default (no token)
      expect(find.text('Login'), findsWidgets);
      expect(find.text('Enter Username/Email'), findsOneWidget);
      expect(find.text('Enter Password'), findsOneWidget);
    });

    testWidgets('can navigate to register screen',
        (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Tap "Register here" link
      await tester.tap(find.text('Register here'));
      await tester.pumpAndSettle();

      // Should show register screen
      expect(find.text('Enter Email'), findsOneWidget);
      expect(find.text('Create Username'), findsOneWidget);
      expect(find.text('Create Password'), findsOneWidget);
      expect(find.text('Confirm Password'), findsOneWidget);
    });

    testWidgets('login shows error on empty fields',
        (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Tap login button without filling fields
      final loginButtons = find.text('Login');
      await tester.tap(loginButtons.last);
      await tester.pumpAndSettle();

      // Should show error snackbar
      expect(find.text('Please fill in all fields'), findsOneWidget);
    });
  });
}
