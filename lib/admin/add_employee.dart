import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api.dart';

class AddEmployeePage extends StatefulWidget {
  final String departmentId;
  final String subDepartmentId;
  final String departmentName;

  const AddEmployeePage({
    super.key,
    required this.departmentId,
    required this.subDepartmentId,
    required this.departmentName,
  });

  @override
  State<AddEmployeePage> createState() => _AddEmployeePageState();
}

class _AddEmployeePageState extends State<AddEmployeePage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  final TextEditingController idController = TextEditingController();
  final TextEditingController roleController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isLoading = false;

  Future<void> submitEmployee() async {
    if (nameController.text.isEmpty || idController.text.isEmpty) return;

    setState(() => isLoading = true);

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token") ?? "";

    // 🟢 طباعة البيانات قبل الإرسال
    final bodyData = {
      "name": nameController.text,
      "phone": phoneController.text,
      "age": int.tryParse(ageController.text) ?? 0, // ⚡ تحويل العمر لرقم
      "employeeId": idController.text,
      "role": roleController.text,
      "password": passwordController.text,
      "departmentId": widget.departmentId,
      "subDepartmentId": widget.subDepartmentId,
    };
    print("Submitting employee: $bodyData");

    try {
      final response = await http.post(
        Uri.parse(addEmployeeToSubDepartment),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode(bodyData),
      );

      // 🟢 طباعة الرد من السيرفر
      print("Server response: ${response.statusCode} - ${response.body}");

      final data = jsonDecode(response.body);

      if (response.statusCode == 201) {
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
      print("Error connecting to server: $e"); // 🟢 طباعة الخطأ
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("خطأ بالاتصال بالسيرفر")));
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("إضافة موظف")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            TextField(controller: nameController, decoration: InputDecoration(labelText: "الاسم")),
            TextField(controller: phoneController, decoration: InputDecoration(labelText: "رقم الهاتف")),
            TextField(controller: ageController, decoration: InputDecoration(labelText: "العمر"), keyboardType: TextInputType.number),
            TextField(controller: idController, decoration: InputDecoration(labelText: "ID الموظف")),
            TextField(controller: roleController, decoration: InputDecoration(labelText: "الدور / الوظيفة")),
            TextField(controller: passwordController, decoration: InputDecoration(labelText: "كلمة السر"), obscureText: true),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: isLoading ? null : submitEmployee, child: isLoading ? CircularProgressIndicator() : Text("حفظ")),
          ],
        ),
      ),
    );
  }
}