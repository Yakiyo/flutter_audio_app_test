import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../../core/settings.dart';
import '../../core/themes.dart';
import '../../core/utils.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final tileColor = Theme.of(context).colorScheme.secondary;
    const shape = RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(10)));
    const padding = EdgeInsets.only(left: 10, right: 20);
    final playback = get<PlaybackModeManager>();
    return Scaffold(
      appBar: AppBar(title: const Text("Settings")),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Text(
                  "Appearance",
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
              ListTile(
                tileColor: tileColor,
                dense: true,
                title: const Text("Theme"),
                contentPadding: padding,
                shape: shape,
                trailing: ValueListenableBuilder(
                  valueListenable: get<ThemeManager>().theme,
                  builder: (context, value, child) =>
                      Text(value.name.capitalize),
                ),
                onTap: () => _showThemeDialog(context),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Text(
                  "Playback",
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
              ListTile(
                tileColor: tileColor,
                contentPadding: padding,
                shape: shape,
                title: const Text("Queue Append Mode"),
                subtitle: ValueListenableBuilder(
                  valueListenable: playback.appendMode,
                  builder: (context, value, child) => Text(switch (value) {
                    AppendMode.start => "Add after current track",
                    AppendMode.end => "Add to end of queue",
                  }),
                ),
                onTap: () {
                  playback.toggleAppend();
                },
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Text(
                  "About",
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
              ListTile(
                tileColor: tileColor,
                contentPadding: padding,
                isThreeLine: true,
                shape: shape,
                title: RichText(
                    text:TextSpan(children: [
                  TextSpan(text: "Melody  ", style: TextStyle(
                    color: Theme.of(context).textTheme.bodySmall?.color
                  )),
                  const WidgetSpan(
                      child: Icon(
                    Ionicons.musical_notes,
                    size: 15,
                  )),
                ])),
                subtitle: const Text(
                    "\nA music player for android built with Flutter.\n"
                    "Consider leaving a star on GitHub."),
                trailing: const Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                        onPressed: _openGithub,
                        icon: Icon(
                          Ionicons.logo_github,
                          size: 20,
                        )),
                  ],
                ),
              ),
              const Divider(
                color: Colors.transparent,
              ),
              ListTile(
                tileColor: tileColor,
                contentPadding: padding,
                shape: shape,
                title: const Text("Version"),
                subtitle: Text(get<PackageInfo>().version),
                trailing: const Icon(Icons.flutter_dash),
              ),
              // TODO: add a new release checker thingy here someday
            ],
          ),
        ),
      ),
    );
  }

  void _showThemeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.secondary,
        title: const Text("Theme Mode"),
        actionsAlignment: MainAxisAlignment.start,
        actionsOverflowDirection: VerticalDirection.up,
        content: _themeSelector(context),
      ),
    );
  }

  Widget _themeSelector(BuildContext context) {
    final c = get<ThemeManager>();
    final color = Theme.of(context).textTheme.bodyLarge!.color;
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final theme in ThemeMode.values)
          TextButton.icon(
            style: ButtonStyle(
              iconColor: WidgetStatePropertyAll(color),
              foregroundColor: WidgetStatePropertyAll(color),
            ),
            onPressed: () => c.theme.value = theme,
            icon: Icon(c.theme.value.name == theme.name
                ? Icons.radio_button_checked
                : Icons.radio_button_unchecked),
            label: Text(theme.name.capitalize),
          )
      ],
    );
  }
}

void _openGithub() => launchUrlString("https://github.com/Yakiyo/melody");
