import 'dart:convert';
import 'package:employee_self_service/DashboardScreen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController companyIdController = TextEditingController();
  final TextEditingController employeeIdController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool loading = false;

  void handleLogin() async {
    if (companyIdController.text.isEmpty ||
        employeeIdController.text.isEmpty ||
        passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("جميع الحقول مطلوبة")),
      );
      return;
    }

    setState(() => loading = true);

    try {
      final res = await http.post(
        Uri.parse("http://YOUR_SERVER/api/employee/login"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "employeeId": employeeIdController.text.trim(),
          "password": passwordController.text,
          "companyId": companyIdController.text.trim(),
        }),
      );

      final data = jsonDecode(res.body);

      if (res.statusCode == 200) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString("token", data["token"]);

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data["message"] ?? "تم تسجيل الدخول")),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => DashboardScreen()),
        );
      } else {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data["message"] ?? "فشل تسجيل الدخول")),
        );
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("خطأ في الاتصال بالسيرفر")),
      );
    } finally {
      if (mounted) {
        setState(() => loading = false);
      }
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
      body: Container(
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
            constraints: BoxConstraints(maxWidth: 400),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(blurRadius: 10, color: Colors.black12)],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Color(0xFF2563EB),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.business, color: Colors.white, size: 40),
                ),
                SizedBox(height: 12),

                Text(
                  "تسجيل الدخول",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),

                SizedBox(height: 12),

                Text(
                  "نظام إدارة الموظفين - ESS",
                  style: TextStyle(color: Colors.grey),
                ),

                SizedBox(height: 12),

                buildInputField(
                  label: "رقم الشركة / الدومين",
                  hint: "مثال: COMP123",
                  icon: Icons.business,
                  controller: companyIdController,
                ),

                SizedBox(height: 12),

                buildInputField(
                  label: "رقم الموظف",
                  hint: "مثال: EMP001",
                  icon: Icons.person,
                  controller: employeeIdController,
                ),

                SizedBox(height: 12),

                buildInputField(
                  label: "كلمة المرور",
                  hint: "••••••••",
                  icon: Icons.lock,
                  controller: passwordController,
                  isPassword: true,
                ),

                SizedBox(height: 12),

                ElevatedButton(
                  onPressed: loading ? null : handleLogin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF2563EB),
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
                    "تسجيل الدخول",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Colors.black,
                    ),
                  ),
                ),

                SizedBox(height: 12),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("هل نسيت كلمة المرور؟ "),
                    GestureDetector(
                      onTap: () {},
                      child: Text(
                        "استعادة الحساب",
                        style: TextStyle(color: Color(0xFF2563EB)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}