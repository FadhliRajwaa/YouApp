import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:youapp/modules/auth/views/login_view.dart';
import 'package:youapp/modules/auth/controllers/auth_controller.dart';

void main() {
  setUp(() {
    Get.testMode = true;
    Get.put(AuthController());
  });

  tearDown(() {
    Get.reset();
  });

  group('LoginView', () {
    testWidgets('renders login title', (WidgetTester tester) async {
      await tester.pumpWidget(
        GetMaterialApp(
          home: const LoginView(),
        ),
      );

      expect(find.text('Login'), findsWidgets);
    });

    testWidgets('renders email and password fields',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        GetMaterialApp(
          home: const LoginView(),
        ),
      );

      expect(find.text('Enter Username/Email'), findsOneWidget);
      expect(find.text('Enter Password'), findsOneWidget);
    });

    testWidgets('renders back button', (WidgetTester tester) async {
      await tester.pumpWidget(
        GetMaterialApp(
          home: const LoginView(),
        ),
      );

      expect(find.text('Back'), findsOneWidget);
      expect(find.byIcon(Icons.chevron_left), findsOneWidget);
    });

    testWidgets('renders register link', (WidgetTester tester) async {
      await tester.pumpWidget(
        GetMaterialApp(
          home: const LoginView(),
        ),
      );

      // RichText with TextSpan children
      expect(
        find.byWidgetPredicate((widget) =>
            widget is RichText &&
            widget.text.toPlainText().contains('Register here')),
        findsOneWidget,
      );
    });

    testWidgets('password visibility toggle works',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        GetMaterialApp(
          home: const LoginView(),
        ),
      );

      // Initially password is hidden
      expect(find.byIcon(Icons.visibility_off), findsOneWidget);

      // Tap visibility toggle
      await tester.tap(find.byType(IconButton).first);
      await tester.pump();

      expect(find.byIcon(Icons.visibility), findsOneWidget);
    });
  });
}
