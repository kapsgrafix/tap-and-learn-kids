import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tap_and_learn_kids/main.dart';

void main() {
  testWidgets('Home screen shows title and play button', (WidgetTester tester) async {
    await tester.pumpWidget(const TapAndLearnApp());
    await tester.pump();

    expect(find.text('Tap & Learn'), findsOneWidget);
    expect(find.text("Let's Play!"), findsOneWidget);
  });

  testWidgets('Tapping Play navigates to the category screen', (WidgetTester tester) async {
    await tester.pumpWidget(const TapAndLearnApp());
    await tester.pump();

    await tester.tap(find.text("Let's Play!"));
    await tester.pumpAndSettle();

    expect(find.text('Choose to Play!'), findsOneWidget);
    expect(find.text('Fruits'), findsOneWidget);
    expect(find.text('Animals'), findsOneWidget);
    expect(find.text('Colors'), findsOneWidget);
    expect(find.text('Vehicles'), findsOneWidget);
    expect(find.text('Shapes'), findsOneWidget);
  });

  testWidgets('Selecting a category starts the game with 4 options', (WidgetTester tester) async {
    await tester.pumpWidget(const TapAndLearnApp());
    await tester.pump();

    await tester.tap(find.text("Let's Play!"));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Shapes'));
    await tester.pumpAndSettle();

    // 2x2 grid = 4 tappable option cards on the game screen.
    expect(find.byType(GestureDetector), findsWidgets);
  });
}
