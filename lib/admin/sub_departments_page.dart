import 'dart:convert';
import 'package:employee_self_service/admin/sub_department_employees.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api.dart';
import 'add_sub_department.dart';

class SubDepartmentsPage extends StatefulWidget {
  final String departmentId;
  final String departmentName;

  const SubDepartmentsPage({
    super.key,
    required this.departmentId,
    required this.departmentName,
  });

  @override
  State<SubDepartmentsPage> createState() => _SubDepartmentsPageState();
}

class _SubDepartmentsPageState extends State<SubDepartmentsPage> {
  List<Map<String, dynamic>> subDepartments = [];
  bool loading = true;
  String? token;

  @override
  void initState() {
    super.initState();
    loadSubDepartments();
  }

  Future<void> loadSubDepartments() async {
    setState(() => loading = true);
    final prefs = await SharedPreferences.getInstance();
    token = prefs.getString("token");

    try {
      final res = await http.get(
        Uri.parse('${getDepartmentById(widget.departmentId)}'),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);

        // null-safe للأقسام الفرعية
        setState(() {
          subDepartments = List<Map<String, dynamic>>.from(
              (data['subDepartments'] ?? []));
          loading = false;
        });
      } else {
        setState(() => loading = false);
      }
    } catch (e) {
      print("Exception: $e");
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("أقسام ${widget.departmentName}"),
        backgroundColor: Colors.black,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // إضافة قسم فرعي جديد
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AddSubDepartmentPage(
                departmentId: widget.departmentId,
              ),
            ),
          );
          loadSubDepartments(); // إعادة تحميل بعد الإضافة
        },
        child: Icon(Icons.add),
      ),
      body: loading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: subDepartments.length,
        itemBuilder: (context, index) {
          final sub = subDepartments[index];
          final subName = sub['name'] ?? '';

          return Card(
            margin: EdgeInsets.all(10),
            child: ListTile(
              title: Text(subName),
              trailing: Icon(Icons.arrow_forward),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => SubDepartmentEmployeesPage(
                      departmentId: widget.departmentId,
                      subDepartmentId: sub['_id'] ?? '',
                      subDepartmentName: subName,
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}