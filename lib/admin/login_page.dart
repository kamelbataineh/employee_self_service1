import 'package:employee_self_service/admin/register_page.dart';
import 'package:flutter/material.dart';
import 'admin_dashboard.dart';

class LoginPage extends StatelessWidget {
  LoginPage({super.key});

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  void showSnack(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

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
               Text("تسجيل دخول الأدمن",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
               SizedBox(height: 20),
              TextField(
                  controller: emailController,
                  decoration:  InputDecoration(labelText: "إيميل الشركة")),
               SizedBox(height: 10),
              TextField(
                  controller: passwordController,
                  decoration:  InputDecoration(labelText: "كلمة السر"),
                  obscureText: true),
               SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (emailController.text.isEmpty ||
                      passwordController.text.isEmpty) {
                    showSnack(context, "عبّي الحقول المطلوبة");
                    return;
                  }

                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>  AdminDashboard()),
                  );
                },
                child:  Text("دخول"),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>  RegisterPage()),
                  );
                },
                child:  Text("إنشاء حساب"),
              )
            ],
          ),
        ),
      ),
    );
  }
}