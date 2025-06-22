import 'package:finance_tracker/presentation/views/settings/widgets/settings_tile.dart';
import 'package:flutter/material.dart';

class ThemeSwitcher extends StatelessWidget {
  const ThemeSwitcher({super.key});

  @override
  Widget build(BuildContext context) {
    return SettingsTile(
      title: 'Dark Mode',
      leading: const Icon(Icons.dark_mode),
      trailing: Switch(
        value: Theme.of(context).brightness == Brightness.dark,
        onChanged: (_) {
          // TODO: Implement theme switching logic
        },
      ),
    );
  }
}
