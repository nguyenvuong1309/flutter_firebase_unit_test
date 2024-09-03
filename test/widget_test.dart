import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_firebase_unit_test/main.dart';
import 'package:flutter_test/flutter_test.dart';

const MessagesCollection = 'messages';

void main() {
  testWidgets('🚀 Shows messages', (WidgetTester tester) async {
    // Populate the fake database.
    final firestore = FakeFirebaseFirestore();
    await firestore.collection(MessagesCollection).add({
      'message': 'Hello world!',
      'created_at': FieldValue.serverTimestamp(),
    });

    // Render the widget.
    await tester.pumpWidget(MaterialApp(
        title: 'Firestore Example',
        home: MyHomePage.withFirestore(firestore: firestore)));
    // Let the snapshots stream fire a snapshot.
    await tester.idle();
    // Re-render.
    await tester.pump();
    // Verify the output.
    expect(find.text('Hello world!'), findsOneWidget);
    expect(find.text('Message 1 of 1'), findsOneWidget);
    print("✅ ~ unit test 1 passed");
  });

  testWidgets('🚀 Adds messages', (WidgetTester tester) async {
    // Instantiate the mock database.
    final firestore = FakeFirebaseFirestore();

    // Render the widget.
    await tester.pumpWidget(MaterialApp(
        title: 'Firestore Example',
        home: MyHomePage.withFirestore(firestore: firestore)));
    // Verify that there is no data.
    expect(find.text('Hello world!'), findsNothing);

    // Tap the Add button.
    await tester.tap(find.byType(FloatingActionButton));
    // Let the snapshots stream fire a snapshot.
    await tester.idle();
    // Re-render.
    await tester.pump();

    // Verify the output.
    expect(find.text('Hello world!'), findsOneWidget);
    print("✅ ~ unit test 2 passed");
  });

  testWidgets("🚀 Add text to input and send", (WidgetTester tester) async {
    final firestore = FakeFirebaseFirestore();

    // Render the widget.
    await tester.pumpWidget(MaterialApp(
        title: 'Firestore Example',
        home: MyHomePage.withFirestore(firestore: firestore)));
    // Verify that there is no data.
    expect(find.text('Hello world!'), findsNothing);

    // Enter text into the TextField.
    await tester.enterText(find.byType(TextField), 'Nguyen duc vuong');
    // Tap the Send button.
    await tester.tap(find.text('Send'));
    // Let the snapshots stream fire a snapshot.
    await tester.idle();
    // Re-render.
    await tester.pump();

    // Verify the output.
    expect(find.text('Nguyen duc vuong'), findsOneWidget);
    print("✅ ~ unit test 3 passed");
  });
}
