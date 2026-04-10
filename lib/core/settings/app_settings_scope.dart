import 'package:flutter/material.dart';

import 'app_settings.dart';

/// Expone [AppSettingsController] al árbol bajo [MaterialApp].
class AppSettingsScope extends InheritedNotifier<AppSettingsController> {
  const AppSettingsScope({
    super.key,
    required AppSettingsController super.notifier,
    required super.child,
  });

  static AppSettingsController of(BuildContext context) {
    final scope =
        context.dependOnInheritedWidgetOfExactType<AppSettingsScope>();
    assert(scope != null, 'AppSettingsScope no encontrado sobre este contexto');
    return scope!.notifier!;
  }
}
