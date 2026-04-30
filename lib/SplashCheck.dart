import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'LoginScreen.dart';
import 'admin/login_page.dart';
import 'DashboardScreen.dart';
import 'admin/admin_dashboard.dart';

class SplashCheck extends StatefulWidget {
  const SplashCheck({super.key});

  @override
  State<SplashCheck> createState() => _SplashCheckState();
}

class _SplashCheckState extends State<SplashCheck> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _start();
    });
  }

  Future<void> _start() async {
    await Future.delayed(const Duration(milliseconds: 500));

    if (!mounted) return;

    await checkLogin();
  }

  Future<void> checkLogin() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");

    if (!mounted) return;

    Widget nextPage;

    if (token == null || token.isEmpty) {
      nextPage = kIsWeb ? LoginPage() : const LoginScreen();
    } else {
      nextPage = kIsWeb
          ? const AdminDashboard()
          : const DashboardScreen();
    }

    // 🔥 مهم جدًا: تأخير آمن للتنقل
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => nextPage),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}