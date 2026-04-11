import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api.dart';

class AddEmployeePage extends StatefulWidget {
  final String departmentId;
  final String subDepartmentId;
  final String departmentName;
  final String subDepartmentName;

  const AddEmployeePage({
    super.key,
    required this.departmentId,
    required this.subDepartmentId,
    required this.departmentName,
    required this.subDepartmentName,
  });

  @override
  State<AddEmployeePage> createState() => _AddEmployeePageState();
}

class _AddEmployeePageState extends State<AddEmployeePage> {
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final ageController = TextEditingController();
  final idController = TextEditingController();
  final roleController = TextEditingController();
  final passwordController = TextEditingController();

  bool loading = false;

  Future<void> submitEmployee() async {
    if (nameController.text.isEmpty || idController.text.isEmpty) return;

    setState(() => loading = true);

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token") ?? "";

    final body = {
      "name": nameController.text,
      "phone": phoneController.text,
      "age": int.tryParse(ageController.text) ?? 0,
      "employeeId": idController.text,
      "role": roleController.text,
      "password": passwordController.text,
      "departmentId": widget.departmentId,
      "subDepartmentId": widget.subDepartmentId,
    };

    try {
      final res = await http.post(
        Uri.parse(addEmployeeToSubDepartment),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode(body),
      );

      final data = jsonDecode(res.body);

      if (res.statusCode == 200 || res.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data["message"] ?? "تمت الإضافة")),
        );

        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data["message"] ?? "حدث خطأ")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("خطأ في الاتصال")),
      );
    } finally {
      setState(() => loading = false);
    }
  }

  Widget header() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      margin:  EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            widget.departmentName,
            style:  TextStyle(color: Colors.white, fontSize: 16),
          ),
           Icon(Icons.arrow_downward, color: Colors.white),
          Text(
            widget.subDepartmentName,
            style:  TextStyle(
              color: Colors.grey,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildField(TextEditingController c, String label,
      {bool obscure = false, TextInputType? type}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: c,
        obscureText: obscure,
        keyboardType: type,
        decoration: InputDecoration(
          labelText: label,
          border:  OutlineInputBorder(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title:  Text("Add Employee"),
        backgroundColor: Colors.black,
      ),
      body: Center(
        child: Container(
          width: 500,
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              header(),
              Expanded(
                child: ListView(
                  children: [
                    buildField(nameController, "Name"),
                    buildField(phoneController, "Phone"),
                    buildField(ageController, "Age",
                        type: TextInputType.number),
                    buildField(idController, "Employee ID"),
                    buildField(roleController, "Role"),
                    buildField(passwordController, "Password",
                        obscure: true),
                     SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          padding: const EdgeInsets.all(14),
                        ),
                        onPressed: loading ? null : submitEmployee,
                        child: loading
                            ?  SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                            :  Text("Save Employee"),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}