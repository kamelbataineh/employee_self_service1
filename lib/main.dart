import 'package:employee_self_service/LoginScreen.dart';
import 'package:employee_self_service/admin/login_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        textTheme: GoogleFonts.cairoTextTheme(Theme.of(context).textTheme),
        appBarTheme: AppBarTheme(
          titleTextStyle: GoogleFonts.cairo(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          toolbarTextStyle: GoogleFonts.cairoTextTheme(
            Theme.of(context).textTheme,
          ).bodyMedium,
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          iconTheme: const IconThemeData(color: Colors.white),
        ),
      ),
      home: kIsWeb ? LoginPage() : LoginScreen(),
    );
  }
}
