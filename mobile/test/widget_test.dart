import 'package:flutter_test/flutter_test.dart';

import 'package:melo/app/app.dart';
import 'package:melo/features/onboarding/screens/splash_screen.dart';
import 'package:melo/features/onboarding/screens/welcome_screen.dart';

void main() {
  testWidgets('Splash hands off to the welcome screen', (tester) async {
    await tester.pumpWidget(const MeloApp());
    expect(find.byType(SplashScreen), findsOneWidget);

    await tester.pumpAndSettle();
    await tester.pump(SplashScreen.holdDuration);
    await tester.pumpAndSettle();

    expect(find.byType(WelcomeScreen), findsOneWidget);
    expect(find.text('Get started'), findsOneWidget);
  });
}
