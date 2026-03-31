import 'package:employee_self_service/config/api.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'login_page.dart';

class RegisterPage extends StatelessWidget {
  RegisterPage({super.key});

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  void showSnack(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> registerAdmin(BuildContext context, String email, String password) async {
    final url = Uri.parse(adminregister);

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 201) {
        print("✅ تم التسجيل: ${data['adminId']}");
        showSnack(context, data['message']);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoginPage()),
        );
      } else {
        print("❌ فشل التسجيل: ${data['message']}");
        showSnack(context, data['message'] ?? 'حدث خطأ');
      }
    } catch (e) {
      print("⚠️ خطأ في الاتصال بالسيرفر: $e");
      showSnack(context, 'فشل الاتصال بالسيرفر');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("إنشاء حساب Admin")),
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
              const Text("إنشاء حساب جديد",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(labelText: "إيميل الشركة"),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: passwordController,
                decoration: const InputDecoration(labelText: "كلمة السر"),
                obscureText: true,
              ),
              const SizedBox(height: 10),
              TextField(
                controller: confirmPasswordController,
                decoration: const InputDecoration(labelText: "تأكيد كلمة السر"),
                obscureText: true,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  String email = emailController.text.trim();
                  String pass = passwordController.text;
                  String confirmPass = confirmPasswordController.text;

                  if (email.isEmpty || pass.isEmpty || confirmPass.isEmpty) {
                    showSnack(context, "عبّي كل الحقول");
                    return;
                  }

                  if (!email.contains("@")) {
                    showSnack(context, "الإيميل غير صحيح");
                    return;
                  }

                  if (pass != confirmPass) {
                    showSnack(context, "كلمة السر غير متطابقة");
                    return;
                  }

                  // نرسل البيانات للسيرفر
                  registerAdmin(context, email, pass);
                },
                child: const Text("إنشاء الحساب"),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => LoginPage()),
                  );
                },
                child: const Text("لديك حساب بالفعل؟ تسجيل الدخول"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}