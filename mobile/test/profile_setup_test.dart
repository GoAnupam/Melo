import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:melo/app/app.dart';
import 'package:melo/app/routes.dart';
import 'package:melo/features/profile/screens/intentions_screen.dart';
import 'package:melo/features/profile/screens/interests_screen.dart';
import 'package:melo/features/profile/screens/photos_screen.dart';
import 'package:melo/features/profile/screens/preview_screen.dart';
import 'package:melo/features/profile/screens/prompts_screen.dart';

void main() {
  testWidgets('Profile setup flows from basics to preview', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.75;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      const MeloApp(initialLocation: AppRoutes.setupBasics),
    );
    await tester.pumpAndSettle();

    Finder button(String label) => find.widgetWithText(InkWell, label);

    // --- Basics -------------------------------------------------------
    await tester.enterText(find.byType(TextField).first, 'Aanya');
    await tester.tap(find.text('Select your birthday'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Woman'));
    await tester.tap(find.text('Men'));
    await tester.ensureVisible(find.text('Pune'));
    await tester.tap(find.text('Pune'));
    await tester.pumpAndSettle();
    await tester.tap(button('Continue'));
    await tester.pumpAndSettle();
    expect(find.byType(IntentionsScreen), findsOneWidget);

    // --- Intentions ---------------------------------------------------
    await tester.tap(find.text('Long-term relationship'));
    await tester.pump();
    await tester.tap(button('Continue'));
    await tester.pumpAndSettle();
    expect(find.byType(InterestsScreen), findsOneWidget);

    // --- Interests: limit of 7 is enforced ----------------------------
    const picks = [
      'Cricket',
      'Football',
      'Badminton',
      'Gym',
      'Yoga',
      'Running',
      'Trekking',
    ];
    for (final interest in picks) {
      await tester.tap(find.text(interest));
      await tester.pump();
    }
    await tester.ensureVisible(find.text('Dance'));
    await tester.tap(find.text('Dance'));
    await tester.pump();
    expect(find.textContaining('You can pick up to 7'), findsOneWidget);
    await tester.tap(button('Continue  ·  7/7'));
    await tester.pumpAndSettle();
    expect(find.byType(PhotosScreen), findsOneWidget);

    // --- Photos: add two via the mock picker --------------------------
    for (var i = 0; i < 2; i++) {
      await tester.tap(find.bySemanticsLabel('Add photo').first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Choose from library'));
      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle();
    }
    expect(find.text('Main'), findsOneWidget);
    await tester.tap(button('Continue'));
    await tester.pumpAndSettle();
    expect(find.byType(PromptsScreen), findsOneWidget);

    // --- Prompts ------------------------------------------------------
    await tester.tap(button('Choose a prompt'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('My ideal Sunday'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Chai and a long walk.');
    await tester.pump();
    await tester.tap(button('Save answer'));
    await tester.pumpAndSettle();
    expect(find.text('Chai and a long walk.'), findsOneWidget);
    await tester.tap(button('Preview profile'));
    await tester.pumpAndSettle();

    // --- Preview ------------------------------------------------------
    expect(find.byType(PreviewScreen), findsOneWidget);
    expect(find.textContaining('Aanya, '), findsOneWidget);
    expect(find.text('Pune'), findsOneWidget);
    expect(find.text('Chai and a long walk.'), findsOneWidget);
  });
}
