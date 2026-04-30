import 'dart:convert';
import 'package:easy_localization/easy_localization.dart';
import 'package:employee_self_service/DashboardScreen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'config/api.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController loginController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool loading = false;
  Future<void> handleLogin() async {
    if (mounted) setState(() => loading = true);

    try {
      final url = Uri.parse(employeelogin);

      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "identifier": loginController.text.trim(),
          "password": passwordController.text.trim(),
        }),
      );

      final data = response.body.isNotEmpty
          ? jsonDecode(response.body)
          : {};

      if (response.statusCode == 200) {
        final token = data["token"];
        final prefs = await SharedPreferences.getInstance();

        await prefs.setString("token", token);
        await prefs.setString("role", "employee");

        if (!mounted) return;

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const DashboardScreen()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data["message"] ?? "Login failed")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  Widget buildInputField({
    required String label,
    required String hint,
    required IconData icon,
    required TextEditingController controller,
    bool isPassword = false,
  }) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            width: double.infinity,
            height: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFEFF6FF), Colors.white],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: Center(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 400),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: const [
                    BoxShadow(blurRadius: 10, color: Colors.black12),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: const BoxDecoration(
                        color: Color(0xFF2563EB),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.business,
                        color: Colors.white,
                        size: 40,
                      ),
                    ),
                    const SizedBox(height: 12),

                    Text(
                      "login".tr(),
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 12),

                    Text(
                      "ess_system".tr(),
                      style: const TextStyle(color: Colors.grey),
                    ),

                    const SizedBox(height: 12),

                    buildInputField(
                      label: "email".tr() + " / " + "employee_id".tr(),
                      hint: "example@gmail.com أو EMP-001",
                      icon: Icons.person,
                      controller: loginController,
                    ),

                    const SizedBox(height: 12),

                    buildInputField(
                      label: "password".tr(),
                      hint: "••••••••",
                      icon: Icons.lock,
                      controller: passwordController,
                      isPassword: true,
                    ),

                    const SizedBox(height: 12),

                    ElevatedButton(
                      onPressed: loading ? null : handleLogin,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2563EB),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                      ),
                      child: loading
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              "login".tr(),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: Colors.black,
                              ),
                            ),
                    ),

                    const SizedBox(height: 12),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("forgot_password".tr()),
                        GestureDetector(
                          onTap: () {},
                          child: Text(
                            "recover_account".tr(),
                            style: const TextStyle(color: Color(0xFF2563EB)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          Positioned(
            top: 40,
            right: 20,
            child: PopupMenuButton<Locale>(
              icon:  Icon(Icons.language, color: Colors.black),
              onSelected: (Locale locale) async {
                await context.setLocale(locale);
              },
              itemBuilder: (context) => const [
                PopupMenuItem(value: Locale('ar', 'SA'), child: Text("🇯🇴 عربي")),
                PopupMenuItem(value: Locale('en', 'US'), child: Text("🇺🇸 English")),
                PopupMenuItem(value: Locale('fr', 'FR'), child: Text("🇫🇷 Français")),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
