import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api.dart';
import 'add_employee.dart';

class SubDepartmentEmployeesPage extends StatefulWidget {
  final String departmentId;
  final String subDepartmentId;
  final String subDepartmentName;

  const SubDepartmentEmployeesPage({
    super.key,
    required this.departmentId,
    required this.subDepartmentId,
    required this.subDepartmentName,
  });

  @override
  State<SubDepartmentEmployeesPage> createState() =>
      _SubDepartmentEmployeesPageState();
}

class _SubDepartmentEmployeesPageState
    extends State<SubDepartmentEmployeesPage> {
  List employees = [];
  bool loading = true;
  String? token;

  @override
  void initState() {
    super.initState();
    fetchEmployees();
  }

  Future<void> fetchEmployees() async {
    setState(() => loading = true);

    final prefs = await SharedPreferences.getInstance();
    token = prefs.getString("token");

    try {
      final response = await http.get(
        Uri.parse(getEmployeesBySubDepartment(widget.departmentId, widget.subDepartmentId)),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);

        print("Fetched employees for subDept ${widget.subDepartmentName}: $data");

        setState(() {
          employees = data;
          loading = false;
        });
      } else {
        setState(() => loading = false);
        print("Failed to fetch employees: ${response.statusCode} - ${response.body}");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("حدث خطأ في جلب الموظفين")),
        );
      }
    } catch (e) {
      setState(() => loading = false);
      print("Error fetching employees: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("خطأ بالاتصال بالسيرفر")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.subDepartmentName),
        backgroundColor: Colors.black,
      ),
      body: loading
          ? Center(child: CircularProgressIndicator())
          : employees.isEmpty
          ? Center(child: Text("لا يوجد موظفين بعد"))
          : ListView.builder(
        itemCount: employees.length,
        itemBuilder: (context, index) {
          final emp = employees[index];
          return ListTile(
            title: Text(emp['name'] ?? ''),
            subtitle: Text("ID: ${emp['employeeId'] ?? ''}"),
            trailing: Text(emp['role'] ?? ''),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // فتح صفحة إضافة موظف
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AddEmployeePage(
                departmentId: widget.departmentId,
                subDepartmentId: widget.subDepartmentId,
                departmentName: widget.subDepartmentName,
              ),
            ),
          );
          if (result == true) fetchEmployees();
        },
        child: Icon(Icons.add),
      ),
    );
  }
}