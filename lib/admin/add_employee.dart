import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api.dart';

class AddEmployeePage extends StatefulWidget {
  final String? departmentId;
  final String? departmentName;

  const AddEmployeePage({super.key, this.departmentId, this.departmentName});

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
  List<Map<String, dynamic>> departments = [];
  String? selectedDepartmentId;
  String? selectedDepartmentName;

  @override
  void initState() {
    super.initState();

    if (widget.departmentId != null) {
      selectedDepartmentId = widget.departmentId;
      selectedDepartmentName = widget.departmentName ?? "قسم غير معروف";
    } else {
      fetchDepartments();
    }
  }



  ////////////////////////////////
  ////////////////////////////////
  ////////////////////////////////
  ////////////////////////////////

  Future<void> fetchDepartments() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token") ?? "";

      final response = await http.get(
        Uri.parse(admindashboardAll),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        setState(() {
          departments = data.map((e) => e as Map<String, dynamic>).toList();
          if (departments.isNotEmpty && selectedDepartmentId == null) {
            selectedDepartmentId = departments[0]['_id'];
            selectedDepartmentName = departments[0]['name'];
          }
        });
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("فشل جلب الأقسام")));
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("خطأ بالاتصال بالسيرفر")));
    }
  }
  ////////////////////////////////
  ////////////////////////////////
  ////////////////////////////////
  ////////////////////////////////


  Future<void> submitEmployee() async {
    if (nameController.text.isEmpty ||
        idController.text.isEmpty ||
        passwordController.text.isEmpty ||
        selectedDepartmentId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("الرجاء ملء الحقول الأساسية")),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token") ?? "";

      final response = await http.post(
        Uri.parse(employeeAdd),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode({
          "name": nameController.text,
          "phone": phoneController.text,
          "age": ageController.text,
          "employeeId": idController.text,
          "role": roleController.text,
          "password": passwordController.text,
          "department": selectedDepartmentId,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data["message"] ?? "تمت الإضافة")),
        );
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(data["message"] ?? "حدث خطأ")));
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("خطأ بالاتصال بالسيرفر")));
    }

    setState(() => isLoading = false);
  }



  //////////////////////////////////////////////////////////////////////////////
  //////////////////////////////////////////////////////////////////////////////

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("إضافة موظف")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(labelText: "الاسم"),
            ),
            TextField(
              controller: phoneController,
              decoration: InputDecoration(labelText: "رقم الهاتف"),
            ),
            TextField(
              controller: ageController,
              decoration: InputDecoration(labelText: "العمر"),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: idController,
              decoration: InputDecoration(labelText: "ID الموظف"),
            ),
            TextField(
              controller: roleController,
              decoration: InputDecoration(labelText: "الدور / الوظيفة"),
            ),
            TextField(
              controller: passwordController,
              decoration: InputDecoration(labelText: "كلمة السر"),
              obscureText: true,
            ),
            SizedBox(height: 20),

            if (widget.departmentId != null) ...[
              TextField(
                enabled: false,
                decoration: InputDecoration(
                  labelText: "القسم",
                  hintText: selectedDepartmentName,
                ),
              ),
              SizedBox(height: 20),
            ],

            if (widget.departmentId == null) ...[
              DropdownButton<String>(
                value: selectedDepartmentId,
                isExpanded: true,
                hint: Text("اختر القسم"),
                items: departments.map((dept) {
                  return DropdownMenuItem<String>(
                    value: dept['_id'],
                    child: Text(dept['name']),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedDepartmentId = value;
                    selectedDepartmentName = departments.firstWhere(
                      (d) => d['_id'] == value,
                    )['name'];
                  });
                },
              ),
              SizedBox(height: 20),
            ],

            isLoading
                ? Center(child: CircularProgressIndicator())
                : ElevatedButton(onPressed: submitEmployee, child: Text("حفظ")),
          ],
        ),
      ),
    );
  }
}
