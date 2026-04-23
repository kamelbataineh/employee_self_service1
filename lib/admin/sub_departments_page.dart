import 'dart:convert';
import 'package:easy_localization/easy_localization.dart';
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

  String getName(dynamic name) {
    if (name is Map) {
      final locale = context.locale.languageCode;
      return name[locale] ?? name['en'] ?? '';
    }
    return name?.toString() ?? '';
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

      print("STATUS CODE: ${res.statusCode}");
      print("RAW BODY: ${res.body}");

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);

        print("DECODED DATA: $data");

        final raw = data['subDepartments'];

        print("SUB DEPARTMENTS RAW: $raw");

        setState(() {
          subDepartments = (raw as List)
              .map((e) => Map<String, dynamic>.from(e))
              .toList();

          loading = false;
        });

        print("FINAL LIST: $subDepartments");
      } else {
        print("ERROR RESPONSE: ${res.body}");
        setState(() => loading = false);
      }
    } catch (e) {
      print("CATCH ERROR: $e");
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
            getName(widget.departmentName),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 5),
          const Text(
            "Sub Departments",
            style: TextStyle(color: Colors.grey),
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
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
        ],
      ),
      child: ListTile(
        title: Text(
          getName(sub['name']),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => SubDepartmentEmployeesPage(
                departmentId: widget.departmentId,
                subDepartmentId: sub['_id'] ?? '',
                subDepartmentName: getName(sub['name']),
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
        child: const Icon(Icons.add),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
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