import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';

abstract class Themes {
  static ThemeData get dark => ThemeData(
      brightness: Brightness.dark,
      textTheme: GoogleFonts.robotoTextTheme()
          .apply(displayColor: Colors.white, bodyColor: Colors.white),
      scaffoldBackgroundColor: Colors.black,
      iconTheme: const IconThemeData(color: Colors.grey),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.black,
      ),
      textButtonTheme: TextButtonThemeData(
        style: ButtonStyle(
          foregroundColor: WidgetStateProperty.all(Colors.white),
        ),
      ),
      colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.black,
          brightness: Brightness.dark,
          primary: Colors.black,
          secondary: const Color.fromARGB(255, 11, 11, 11),
          tertiary: Colors.grey[700]),
      navigationBarTheme: NavigationBarThemeData(
          backgroundColor: Colors.black,
          iconTheme:
              const WidgetStatePropertyAll(IconThemeData(color: Colors.white)),
          indicatorColor: Colors.grey[700],
          labelTextStyle:
              const WidgetStatePropertyAll(TextStyle(color: Colors.white))),
      listTileTheme: ListTileThemeData(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
          titleTextStyle: const TextStyle(color: Colors.white, fontSize: 14),
          iconColor: Colors.white,
          subtitleTextStyle: TextStyle(color: Colors.grey[400], fontSize: 12)),
      tabBarTheme: TabBarTheme(
        dividerColor: Colors.transparent,
        indicatorColor: Colors.transparent,
        labelPadding: const EdgeInsets.only(bottom: 10),
        dividerHeight: 20,
        // unselectedLabelColor: Colors.grey[700],
        unselectedLabelStyle: TextStyle(color: Colors.grey[300], fontSize: 12),
        labelStyle: const TextStyle(color: Colors.white, fontSize: 18),
      ),
      dialogTheme: const DialogTheme(
          backgroundColor: Color.fromARGB(255, 11, 11, 11),
          contentTextStyle: TextStyle(color: Colors.white)),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Color.fromARGB(255, 11, 11, 11),
      ));

  static ThemeData get light => ThemeData(
      brightness: Brightness.light,
      textTheme: GoogleFonts.robotoTextTheme()
          .apply(displayColor: Colors.black, bodyColor: Colors.black),
      colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.white,
          brightness: Brightness.light,
          primary: Colors.white,
          secondary: const Color.fromARGB(255, 243, 239, 239),
          tertiary: const Color.fromARGB(255, 236, 233, 233)),
      scaffoldBackgroundColor: Colors.white,
      iconTheme: const IconThemeData(color: Colors.grey),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
      ),
      navigationBarTheme: NavigationBarThemeData(
          backgroundColor: Colors.white,
          iconTheme:
              const WidgetStatePropertyAll(IconThemeData(color: Colors.black)),
          indicatorColor: Colors.grey[400],
          labelTextStyle:
              const WidgetStatePropertyAll(TextStyle(color: Colors.black))),
      listTileTheme: const ListTileThemeData(
        contentPadding: EdgeInsets.symmetric(horizontal: 5, vertical: 1),
        titleTextStyle: TextStyle(color: Colors.black, fontSize: 14),
        iconColor: Colors.black,
        subtitleTextStyle:
            TextStyle(color: Color.fromARGB(255, 68, 67, 67), fontSize: 12),
      ),
      tabBarTheme: TabBarTheme(
        dividerColor: Colors.transparent,
        indicatorColor: Colors.transparent,
        labelPadding: const EdgeInsets.only(bottom: 10),
        dividerHeight: 20,
        // unselectedLabelColor: Colors.grey[700],
        unselectedLabelStyle: TextStyle(color: Colors.grey[700], fontSize: 12),
        labelStyle: const TextStyle(color: Colors.black, fontSize: 18),
      ),
      dialogTheme: const DialogTheme(backgroundColor: Colors.white),
      textButtonTheme: const TextButtonThemeData(
        style: ButtonStyle(
          foregroundColor: WidgetStatePropertyAll(Colors.black),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Color.fromARGB(255, 243, 239, 239),
      ));
}

class ThemeManager {
  late final ValueNotifier<ThemeMode> theme;

  ThemeManager() {
    final pref = Hive.box("settings").get("theme", defaultValue: "system");
    theme = ValueNotifier(tmFromStr(pref));
  }

  void setTheme(String value) {
    theme.value = tmFromStr(value);

    Hive.box("settings").put("theme", value);
  }
}

ThemeMode tmFromStr(String value) => switch (value.toLowerCase()) {
      "light" => ThemeMode.light,
      "dark" => ThemeMode.dark,
      "system" => ThemeMode.system,
      _ => throw ArgumentError.value(
          value, "value", "not one of light/dark/system")
    };
