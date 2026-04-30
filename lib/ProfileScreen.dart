import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:easy_localization/easy_localization.dart';

import 'LoginScreen.dart';
import 'config/api.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? data;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    fetchProfile();
  }

  String safe(dynamic v) => v?.toString() ?? "N/A";

  Future<void> fetchProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token");

      if (token == null || token.isEmpty) {
        if (!mounted) return;
        setState(() => loading = false);
        return;
      }

      final res = await http
          .get(
        Uri.parse(employeegetMyProfile),
        headers: {"Authorization": "Bearer $token"},
      )
          .timeout(const Duration(seconds: 10));

      if (!mounted) return;

      if (res.statusCode == 200) {
        final decoded = jsonDecode(res.body);

        setState(() {
          data = decoded is Map<String, dynamic> ? decoded : {};
          loading = false;
        });
      } else {
        setState(() => loading = false);
      }
    } catch (e) {
      debugPrint("Profile error: $e");
      if (!mounted) return;
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading || data == null) {
      return const Scaffold(
        backgroundColor: Color(0xfff4f6fb),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final emp = (data?["employee"] is Map)
        ? data!["employee"]
        : {};

    final dept = (data?["department"] is Map)
        ? data!["department"]
        : {};

    final sub = (data?["subDepartment"] is Map)
        ? data!["subDepartment"]
        : {};

    String name = "User";
    if (emp["name"] is Map) {
      name = emp["name"]["en"]?.toString() ?? "User";
    }

    String role = safe(emp["role"]);
    String email = safe(emp["email"]);
    String phone = safe(emp["phone"]);
    String employeeId = safe(emp["employeeId"]);

    String deptName = "N/A";
    if (dept["name"] is Map) {
      deptName = dept["name"]["en"]?.toString() ?? "N/A";
    }

    String subName = "N/A";
    if (sub["name"] is Map) {
      subName = sub["name"]["en"]?.toString() ?? "N/A";
    }

    String firstLetter =
    name.isNotEmpty ? name[0].toUpperCase() : "U";

    return Scaffold(
      backgroundColor: const Color(0xfff4f6fb),
      body: SingleChildScrollView(
        child: Column(
          children: [
            /// HEADER
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.indigo, Colors.blue],
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.white,
                    child: Text(
                      firstLetter,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.indigo,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    role,
                    style: const TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            /// INFO
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildCard(Icons.email, "email".tr(), email, Colors.blue),
                  _buildCard(Icons.phone, "phone".tr(), phone, Colors.green),
                  _buildCard(Icons.badge, "employee_id".tr(), employeeId, Colors.orange),
                  _buildCard(Icons.apartment, "department".tr(), deptName, Colors.purple),
                  _buildCard(Icons.account_tree, "sub_department".tr(), subName, Colors.teal),

                  const SizedBox(height: 30),

                  /// LOGOUT
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.logout),
                      label: Text("logout".tr()),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () async {
                        final prefs = await SharedPreferences.getInstance();
                        await prefs.remove("token");

                        if (!context.mounted) return;

                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const LoginScreen(),
                          ),
                              (route) => false,
                        );
                      },
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildCard(
      IconData icon,
      String title,
      String value,
      Color color,
      ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, 5),
          )
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: color.withOpacity(0.1),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}