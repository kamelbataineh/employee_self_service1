import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api.dart';

class EmployeeDetailsPage extends StatefulWidget {
  final String employeeId;

   EmployeeDetailsPage({super.key, required this.employeeId});

  @override
  State<EmployeeDetailsPage> createState() => _EmployeeDetailsPageState();
}

class _EmployeeDetailsPageState extends State<EmployeeDetailsPage> {
  Map? employee;
  Map? department;
  Map? subDepartment;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadEmployee();
  }

  Future<void> loadEmployee() async {
    setState(() => loading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token");

      final url = getEmployeeById(widget.employeeId);

      final res = await http.get(
        Uri.parse(url),
        headers: {"Authorization": "Bearer $token"},
      );

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);

        setState(() {
          employee = data['employee'];
          department = data['department'];
          subDepartment = data['subDepartment'];
          loading = false;
        });
      } else {
        setState(() {
          employee = null;
          loading = false;
        });
      }
    } catch (e) {
      setState(() {
        employee = null;
        loading = false;
      });
    }
  }

  Widget sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Text(
        title,
        style:  TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget infoBox(String title, String value) {
    return Container(
      padding:  EdgeInsets.all(12),
      margin:  EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style:  TextStyle(fontSize: 12, color: Colors.grey),
          ),
           SizedBox(height: 5),
          Text(
            value.isEmpty ? "-" : value,
            style:  TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade200,
      appBar: AppBar(
        title:  Text("Employee Details"),
        backgroundColor: Colors.black,
      ),
      body: loading
          ?  Center(child: CircularProgressIndicator())
          : employee == null
          ?  Center(child: Text("No Employee Found"))
          : SingleChildScrollView(
        padding:  EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding:  EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.black,
                    child: Text(
                      (employee?['name'] ?? '')
                          .toString()
                          .isNotEmpty
                          ? employee!['name'][0]
                          : '?',
                      style:  TextStyle(color: Colors.white),
                    ),
                  ),
                   SizedBox(width: 15),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        employee?['name'] ?? '',
                        style:  TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        employee?['role'] ?? '',
                        style:  TextStyle(color: Colors.grey),
                      ),
                    ],
                  )
                ],
              ),
            ),

             SizedBox(height: 20),

            sectionTitle("Employee Info"),
            GridView.count(
              crossAxisCount: 3,
              shrinkWrap: true,
              physics:  NeverScrollableScrollPhysics(),
              childAspectRatio: 3,
              children: [
                infoBox("Employee ID",
                    employee?['employeeId'] ?? ''),
                infoBox("Phone", employee?['phone'] ?? ''),
                infoBox(
                    "Age", employee?['age']?.toString() ?? ''),
                infoBox("Role", employee?['role'] ?? ''),
              ],
            ),

            sectionTitle("Department"),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics:  NeverScrollableScrollPhysics(),
              childAspectRatio: 3,
              children: [
                infoBox("Name", department?['name'] ?? ''),
                infoBox("ID", department?['id'] ?? ''),
              ],
            ),

            sectionTitle("Sub Department"),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics:  NeverScrollableScrollPhysics(),
              childAspectRatio: 3,
              children: [
                infoBox("Name", subDepartment?['name'] ?? ''),
                infoBox("ID", subDepartment?['id'] ?? ''),
              ],
            ),
          ],
        ),
      ),
    );
  }
}