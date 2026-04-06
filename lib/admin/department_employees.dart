import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api.dart';
import 'employee_details.dart';
import 'add_employee.dart';

class DepartmentEmployeesPage extends StatefulWidget {
  final String departmentId;
  final String departmentName;

  DepartmentEmployeesPage({
    super.key,
    required this.departmentId,
    required this.departmentName,
  });

  @override
  State<DepartmentEmployeesPage> createState() =>
      _DepartmentEmployeesPageState();
}

class _DepartmentEmployeesPageState extends State<DepartmentEmployeesPage> {
  List<Map<String, dynamic>> employees = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadEmployees();
  }

  ////////////////////////////////
  ////////////////////////////////
  ////////////////////////////////
  ////////////////////////////////

  Future<void> loadEmployees() async {
    setState(() => loading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token");

      print("Fetching employees for department: ${widget.departmentId}");
      print("Using token: $token");

      final res = await http.get(
        Uri.parse(employeeByDepartment(widget.departmentId)),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      print("Response status: ${res.statusCode}");
      print("Response body: ${res.body}");

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        setState(() {
          employees = List<Map<String, dynamic>>.from(data);
          loading = false;
        });
      } else {
        setState(() => loading = false);
        print("Failed to load employees. Status: ${res.statusCode}");
      }
    } catch (e) {
      print("Error: $e");
      setState(() => loading = false);
    }
  }

  //////////////////////////////////////////////////////////////////////////////
  //////////////////////////////////////////////////////////////////////////////

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("قسم ${widget.departmentName}"),
        actions: [
          IconButton(
            icon: Icon(Icons.person_add),
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      AddEmployeePage(departmentId: widget.departmentId),
                ),
              );

              if (result == true) {
                loadEmployees();
              }
            },
          ),
        ],
      ),
      body: loading
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  color: Colors.grey[200],
                  child: Text(
                    "عدد الموظفين: ${employees.length}",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  child: employees.isEmpty
                      ? Center(child: Text("لا يوجد موظفين"))
                      : RefreshIndicator(
                          onRefresh: loadEmployees,
                          child: ListView.builder(
                            itemCount: employees.length,
                            itemBuilder: (context, index) {
                              final emp = employees[index];
                              return Card(
                                margin: EdgeInsets.all(10),
                                child: ListTile(
                                  leading: Icon(Icons.person),
                                  title: Text(emp['name'] ?? ''),
                                  subtitle: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text("الوظيفة: ${emp['role'] ?? ''}"),
                                      Text("الهاتف: ${emp['phone'] ?? ''}"),
                                    ],
                                  ),
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => EmployeeDetailsPage(
                                          employeeId: emp['_id'],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              );
                            },
                          ),
                        ),
                ),
              ],
            ),
    );
  }
}
