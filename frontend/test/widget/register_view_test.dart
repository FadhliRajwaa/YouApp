import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:youapp/modules/auth/views/register_view.dart';
import 'package:youapp/modules/auth/controllers/auth_controller.dart';

void main() {
  setUp(() {
    Get.testMode = true;
    Get.put(AuthController());
  });

  tearDown(() {
    Get.reset();
  });

  group('RegisterView', () {
    testWidgets('renders register title', (WidgetTester tester) async {
      await tester.pumpWidget(
        GetMaterialApp(
          home: const RegisterView(),
        ),
      );

      expect(find.text('Register'), findsWidgets);
    });

    testWidgets('renders all input fields', (WidgetTester tester) async {
      await tester.pumpWidget(
        GetMaterialApp(
          home: const RegisterView(),
        ),
      );

      expect(find.text('Enter Email'), findsOneWidget);
      expect(find.text('Create Username'), findsOneWidget);
      expect(find.text('Create Password'), findsOneWidget);
      expect(find.text('Confirm Password'), findsOneWidget);
    });

    testWidgets('renders login link', (WidgetTester tester) async {
      await tester.pumpWidget(
        GetMaterialApp(
          home: const RegisterView(),
        ),
      );

      // RichText with TextSpan children
      expect(
        find.byWidgetPredicate((widget) =>
            widget is RichText &&
            widget.text.toPlainText().contains('Login here')),
        findsOneWidget,
      );
    });

    testWidgets('has two password visibility toggles',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        GetMaterialApp(
          home: const RegisterView(),
        ),
      );

      // Two visibility off icons (password + confirm password)
      expect(find.byIcon(Icons.visibility_off), findsNWidgets(2));
    });

    testWidgets('can enter text in fields', (WidgetTester tester) async {
      await tester.pumpWidget(
        GetMaterialApp(
          home: const RegisterView(),
        ),
      );

      final controller = Get.find<AuthController>();

      // Enter email
      await tester.enterText(
          find.byType(TextField).at(0), 'test@test.com');
      expect(controller.emailController.text, 'test@test.com');

      // Enter username
      await tester.enterText(find.byType(TextField).at(1), 'testuser');
      expect(controller.usernameController.text, 'testuser');
    });
  });
}
