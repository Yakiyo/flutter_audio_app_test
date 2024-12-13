import 'package:audio_service/audio_service.dart';
import 'package:audio_session/audio_session.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:logger/logger.dart';
import 'package:melody/core/themes.dart';
import 'package:melody/core/utils.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'core/audio_handler.dart';
import 'core/settings.dart';
import 'ui/pages/library.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await init();

  runApp(const MainApp());
}

Future<void> init() async {
  // TODO: handle permission stuff
  // request permissions
  // await OnAudioQuery().checkAndRequest(retryRequest: true);

  // Hive section
  await Hive.initFlutter();
  await Future.wait([
    Hive.openBox("settings"),
    Hive.openBox("history"),
  ]);

  final i = GetIt.instance;
  // todo: make logs go to file in prod
  i.registerLazySingleton<Logger>(
      () => Logger(level: kDebugMode ? Level.debug : Level.info));

  final [audioHandler, packageInfo] =
      await Future.wait([initAudioService(), PackageInfo.fromPlatform()]);

  i.registerSingleton(audioHandler as AudioHandler);
  i.registerSingleton(packageInfo as PackageInfo);
  i.registerLazySingleton(() => ThemeManager());
  i.registerLazySingleton(() => OnAudioQuery());
  i.registerLazySingleton(() => PlaybackModeManager());

  AudioSession.instance.then(
      (value) => value.configure(const AudioSessionConfiguration.music()));
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: get<ThemeManager>().theme,
      builder: (context, value, child) => MaterialApp(
        debugShowCheckedModeBanner: false,
        themeMode: value,
        theme: Themes.light,
        darkTheme: Themes.dark,
        home: const LibraryPage(),
      ),
    );
  }
}
