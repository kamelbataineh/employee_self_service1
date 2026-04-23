// login_page.dart
import 'dart:convert';
import 'package:easy_localization/easy_localization.dart';
import 'package:employee_self_service/admin/admin_dashboard.dart';
import 'package:employee_self_service/admin/register_page.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api.dart';

class LoginPage extends StatelessWidget {
  LoginPage({super.key});

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  void showSnack(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  ////////////////////////////////
  ////////////////////////////////
  ////////////////////////////////
  ////////////////////////////////

  Future<void> login(BuildContext context) async {
    final url = Uri.parse(adminlogin);

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': emailController.text.trim(),
          'password': passwordController.text,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        final token = data['token'];
        final adminId = data['admin']?['_id'];
        final prefs = await SharedPreferences.getInstance();

        await prefs.setString("token", token);
        await prefs.setString("adminId", adminId ?? "");
        await prefs.setString("role", "admin");

        showSnack(context, data['message'] ?? "تم تسجيل الدخول");

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => AdminDashboard()),
        );
      } else {
        showSnack(context, data['message'] ?? 'حدث خطأ');
      }
    } catch (e) {
      showSnack(context, 'فشل الاتصال بالسيرفر');
    }
  }

  //////////////////////////////////////////////////////////////////////////////
  //////////////////////////////////////////////////////////////////////////////

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          width: 400,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "admin_login".tr(),
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              TextField(
                controller: emailController,
                decoration: InputDecoration(labelText: "إيميل الشركة"),
              ),
              SizedBox(height: 10),
              TextField(
                controller: passwordController,
                decoration: InputDecoration(labelText: "كلمة السر"),
                obscureText: true,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (emailController.text.isEmpty ||
                      passwordController.text.isEmpty) {
                    showSnack(context, "عبّي الحقول المطلوبة");
                    return;
                  }
                  login(context);
                },
                child: Text("دخول"),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => RegisterPage()),
                  );
                },
                child: Text("إنشاء حساب"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
