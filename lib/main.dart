import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:google_fonts/google_fonts.dart';

import 'SplashCheck.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();

  runApp(
    EasyLocalization(
      supportedLocales: const [
        Locale('en', 'US'),
        Locale('ar', 'SA'),
        Locale('fr', 'FR'),
      ],
      path: 'assets/translations',
      fallbackLocale: const Locale('en', 'US'),
      saveLocale: true,
      startLocale: const Locale('en', 'US'),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      // ? ????? ????????? (??? ????)
      locale: context.locale,

      supportedLocales: context.supportedLocales,
      localizationsDelegates: context.localizationDelegates,

      theme: ThemeData(
        useMaterial3: true,

        textTheme: GoogleFonts.cairoTextTheme(
          Theme.of(context).textTheme,
        ),

        appBarTheme: AppBarTheme(
          iconTheme: const IconThemeData(
            color: Colors.white,
          ),
          titleTextStyle: GoogleFonts.cairo(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          centerTitle: true,
        ),
      ),

      home: const SplashCheck(),
    );
  }
}