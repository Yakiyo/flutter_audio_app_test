import 'package:flutter/material.dart';

import '../../core/themes.dart';
import '../../core/utils.dart';

class MyFab extends StatelessWidget {
  const MyFab({super.key});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
        child: const Icon(Icons.sunny),
        onPressed: () {
          final tm = get<ThemeManager>();
          final theme = tm.theme;
          if (theme.value == ThemeMode.light) {
            tm.setTheme(ThemeMode.dark.name);
          } else {
            tm.setTheme(ThemeMode.light.name);
          }
        },
      );
  }
}