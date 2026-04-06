import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api.dart';

class EmployeeDetailsPage extends StatefulWidget {
  final String employeeId;

   EmployeeDetailsPage({super.key, required this.employeeId});

  @override
  State<EmployeeDetailsPage> createState() => _EmployeeDetailsPageState();
}

class _EmployeeDetailsPageState extends State<EmployeeDetailsPage> {
  Map? employee;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadEmployee();
  }
  Future<void> loadEmployee() async {
    setState(() => loading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token");

      final url = getEmployeeById(widget.employeeId);
      print("Fetching URL: $url");

      final res = await http.get(
        Uri.parse(url),
        headers: {"Authorization": "Bearer $token"},
      );

      print("Response code: ${res.statusCode}");
      print("Response body: ${res.body}");

      if (res.statusCode == 200) {
        setState(() {
          employee = jsonDecode(res.body);
          loading = false;
        });
      } else if (res.statusCode == 404) {
        setState(() {
          loading = false;
          employee = null;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("الموظف غير موجود")),
        );
      } else {
        setState(() => loading = false);
        ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(content: Text("حدث خطأ")),
        );
      }
    } catch (e) {
      setState(() => loading = false);
      print("Exception: $e");
      ScaffoldMessenger.of(context).showSnackBar(
         SnackBar(content: Text("فشل في الاتصال بالخادم")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title:  Text("تفاصيل الموظف")),
      body: loading
          ?  Center(child: CircularProgressIndicator())
          : employee == null
          ? Center(child: Text("لا توجد بيانات للموظف"))
          : Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("الاسم: ${employee!['name']}"),
            Text("الوظيفة: ${employee!['role']}"),
            Text("الهاتف: ${employee!['phone']}"),
            Text("العمر: ${employee!['age']}"),
            Text("القسم: ${employee!['department']['name']}"),
          ],
        ),
      ),
    );
  }
}