import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ticksave/core/settings/app_settings.dart';
import 'package:ticksave/main.dart';

void main() {
  testWidgets('TickSave arranca y muestra la pantalla de login', (WidgetTester tester) async {
    await tester.pumpWidget(TickSaveApp(settings: AppSettingsController()));
    await tester.pumpAndSettle();

    expect(find.byType(MaterialApp), findsOneWidget);
    expect(find.text('TickSave'), findsOneWidget);
  });
}
