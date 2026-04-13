import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api.dart';
import '../utils/locale_helper.dart';
import 'add_employee.dart';
import 'employee_details.dart';

class SubDepartmentEmployeesPage extends StatefulWidget {
  final String departmentId;
  final String subDepartmentId;
  final String subDepartmentName;
  final String departmentName;

  const SubDepartmentEmployeesPage({
    super.key,
    required this.departmentId,
    required this.subDepartmentId,
    required this.subDepartmentName,
    required this.departmentName,
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
        Uri.parse(
          getEmployeesBySubDepartment(
            widget.departmentId,
            widget.subDepartmentId,
          ),
        ),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);

        setState(() {
          employees = data;
          loading = false;
        });
      } else {
        setState(() => loading = false);
      }
    } catch (e) {
      setState(() => loading = false);
    }
  }

  Widget header() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.subDepartmentName,
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 5),
          Text(
            widget.departmentName,
            style: TextStyle(color: Colors.grey.shade300),
          ),
        ],
      ),
    );
  }

  Widget employeeCard(Map emp) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
        ],
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.black,
          child: Text(
              getLocalizedName(emp['name'], context).isNotEmpty
                  ? getLocalizedName(emp['name'], context)[0]
                  : '?',
            style: TextStyle(color: Colors.white),
          ),
        ),
        title: Text(
            getLocalizedName(emp['name'], context),
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("ID: ${emp['employeeId'] ?? ''}"),
            Text(emp['role'] ?? ''),
          ],
        ),
        trailing: Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => EmployeeDetailsPage(employeeId: emp['_id']),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade200,
      appBar: AppBar(
        title: Text(widget.subDepartmentName),
        backgroundColor: Colors.black,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.black,
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AddEmployeePage(
                departmentId: widget.departmentId,
                subDepartmentId: widget.subDepartmentId,
                departmentName: widget.departmentName,
                subDepartmentName: widget.subDepartmentName,
              ),
            ),
          );

          if (result == true) fetchEmployees();
        },
        child: Icon(Icons.add),
      ),
      body: loading
          ? Center(child: CircularProgressIndicator())
          : employees.isEmpty
          ? Center(child: Text("لا يوجد موظفين"))
          : SingleChildScrollView(
              child: Column(
                children: [
                  header(),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: employees.length,
                    itemBuilder: (context, index) {
                      return employeeCard(employees[index]);
                    },
                  ),
                ],
              ),
            ),
    );
  }
}
