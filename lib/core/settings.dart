import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:just_audio/just_audio.dart';

Box settings() => Hive.box("settings");

class PlaybackModeManager {
  // late final ValueNotifier<bool> shuffleMode;
  // late final ValueNotifier<RepeatMode> repeatMode;
  late final ValueNotifier<AppendMode> appendMode;

  PlaybackModeManager() {
    final settingsVal = settings();
    appendMode = ValueNotifier(
        amFromStr(settingsVal.get("append", defaultValue: "start")));
  }

  void setAppend(AppendMode value) {
    settings().put("append", value.name);
    appendMode.value = value;
  }

  void toggleAppend() {
    setAppend(appendMode.value == AppendMode.start
        ? AppendMode.end
        : AppendMode.start);
  }
}

enum RepeatMode { none, one, all }

RepeatMode rmFromStr(String value) => RepeatMode.values
    .firstWhere((e) => e.name == value, orElse: () => RepeatMode.none);

RepeatMode rmFromLoopMode(LoopMode mode) => switch (mode) {
      LoopMode.off => RepeatMode.none,
      LoopMode.one => RepeatMode.one,
      LoopMode.all => RepeatMode.all,
    };

LoopMode lmFromRepeatMode(RepeatMode mode) => switch (mode) {
      RepeatMode.none => LoopMode.off,
      RepeatMode.one => LoopMode.one,
      RepeatMode.all => LoopMode.all,
    };

enum AppendMode { start, end }

AppendMode amFromStr(String value) => AppendMode.values
    .firstWhere((e) => e.name == value, orElse: () => AppendMode.end);
