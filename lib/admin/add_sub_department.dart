// add_sub_department.dart
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api.dart';

class AddSubDepartmentPage extends StatefulWidget {
  final String departmentId;

  AddSubDepartmentPage({required this.departmentId});

  @override
  State<AddSubDepartmentPage> createState() => _AddSubDepartmentPageState();
}

class _AddSubDepartmentPageState extends State<AddSubDepartmentPage> {
  final TextEditingController nameController = TextEditingController();
  bool loading = false;

  Future<void> createSubDepartment() async {
    if (nameController.text.isEmpty) return;

    setState(() => loading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token") ?? "";

      final url = 'http://localhost:5000/api/departments/add-sub-department/${widget.departmentId}';
      print("URL: $url");
      print("Body: {\"name\": \"${nameController.text}\"}");
      print("Token: $token");

      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',  // ✅ مهم جداً
        },
        body: '{"name": "${nameController.text}"}',
      );

      print("Response status: ${response.statusCode}");
      print("Response body: ${response.body}");

      if (response.statusCode == 201) {
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("حدث خطأ")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("خطأ في الشبكة")));
    } finally {
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
      AppBar(title: Text("إضافة قسم فرعي"), backgroundColor: Colors.black),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(labelText: "اسم القسم الفرعي"),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: loading ? null : createSubDepartment,
              child: loading
                  ? CircularProgressIndicator(color: Colors.white)
                  : Text("إضافة"),
            ),
          ],
        ),
      ),
    );
  }
}