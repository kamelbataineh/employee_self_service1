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

   SubDepartmentsPage({
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
        Uri.parse(getDepartmentById(widget.departmentId)),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);

        setState(() {
          subDepartments = List<Map<String, dynamic>>.from(
            data['subDepartments'] ?? [],
          );
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
            widget.departmentName,
            style:  TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
           SizedBox(height: 5),
          Text(
            "Sub Departments",
            style: TextStyle(color: Colors.grey.shade300),
          ),
        ],
      ),
    );
  }

  Widget subCard(Map sub) {
    return Container(
      margin: const EdgeInsets.all(10),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
          )
        ],
      ),
      child: ListTile(
        title: Text(
          sub['name'] ?? '',
          style:  TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text("ID: ${sub['_id'] ?? ''}"),
        trailing:  Icon(Icons.arrow_forward_ios),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => SubDepartmentEmployeesPage(
                departmentId: widget.departmentId,
                subDepartmentId: sub['_id'] ?? '',
                subDepartmentName: sub['name'] ?? '',
                departmentName: widget.departmentName,
              ),
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
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.black,
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AddSubDepartmentPage(
                departmentId: widget.departmentId,
              ),
            ),
          );
          loadSubDepartments();
        },
        child:  Icon(Icons.add),
      ),
      body: loading
          ?  Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        child: Column(
          children: [
            header(),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: subDepartments.length,
              itemBuilder: (context, index) {
                return subCard(subDepartments[index]);
              },
            ),
          ],
        ),
      ),
    );
  }
}