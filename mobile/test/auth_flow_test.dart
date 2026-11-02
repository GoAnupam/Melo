import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:melo/app/app.dart';
import 'package:melo/app/routes.dart';
import 'package:melo/features/authentication/screens/email_login_screen.dart';
import 'package:melo/features/authentication/screens/otp_screen.dart';
import 'package:melo/features/authentication/screens/phone_login_screen.dart';
import 'package:melo/features/onboarding/screens/intro_screen.dart';
import 'package:melo/features/profile/screens/basics_screen.dart';

void main() {
  testWidgets('Get started walks through intro to phone login', (tester) async {
    await tester.pumpWidget(const MeloApp(initialLocation: AppRoutes.welcome));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Get started'));
    await tester.pumpAndSettle();
    expect(find.byType(IntroScreen), findsOneWidget);

    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Create account'));
    await tester.pumpAndSettle();
    expect(find.byType(PhoneLoginScreen), findsOneWidget);
  });

  testWidgets('Phone login validates, then OTP handles error and success', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MeloApp(initialLocation: AppRoutes.phoneLogin),
    );
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), '12345');
    await tester.pump();
    await tester.tap(find.text('Send code'));
    await tester.pump();
    expect(find.text('Enter a 10-digit mobile number.'), findsOneWidget);

    await tester.enterText(find.byType(TextField), '9876543210');
    await tester.tap(find.text('Send code'));
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();
    expect(find.byType(OtpScreen), findsOneWidget);

    await tester.enterText(find.byType(TextField), '424242');
    await tester.pump(const Duration(seconds: 1));
    await tester.pump();
    expect(find.textContaining("doesn't match"), findsOneWidget);
    await tester.pump();
    final codeField = tester.widget<TextField>(find.byType(TextField));
    expect(
      codeField.focusNode!.hasFocus,
      isTrue,
      reason: 'keyboard should return after a wrong code',
    );

    await tester.enterText(find.byType(TextField), '123456');
    await tester.pump(const Duration(seconds: 1));
    await tester.pump();
    await tester.pumpAndSettle();
    expect(find.byType(BasicsScreen), findsOneWidget);
  });

  testWidgets('Can switch from phone to email login', (tester) async {
    await tester.pumpWidget(
      const MeloApp(initialLocation: AppRoutes.phoneLogin),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Use email instead'));
    await tester.pumpAndSettle();
    expect(find.byType(EmailLoginScreen), findsOneWidget);
  });
}
