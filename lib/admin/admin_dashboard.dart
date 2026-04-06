import 'dart:convert';
import 'package:employee_self_service/admin/sub_departments_page.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api.dart';
import 'add_department.dart';
import 'add_sub_department.dart';
import 'department_employees.dart';

class AdminDashboard extends StatefulWidget {
  AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  List<Map<String, dynamic>> departments = [];
  bool loading = true;
  String? token;

  @override
  void initState() {
    super.initState();
    loadAdminData();
  }

  Future<void> loadAdminData() async {
    final prefs = await SharedPreferences.getInstance();
    token = prefs.getString("token");
    fetchDepartments();
  }

  Future<void> fetchDepartments() async {
    setState(() => loading = true);
    try {
      final response = await http.get(
        Uri.parse(admindashboardAll),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token', // ✅ التوكن جاهز
        },
      );

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        setState(() {
          departments = List<Map<String, dynamic>>.from(data);
          loading = false;
        });
      } else {
        setState(() => loading = false);
      }
    } catch (e) {
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("لوحة التحكم"),
        backgroundColor: Colors.black,
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            DrawerHeader(
              child: Text("الشركة", style: TextStyle(fontSize: 24)),
            ),
            ...departments.map((dept) => ListTile(
              title: Text(dept['name'] ?? ''),
              subtitle: Text(
                  "الأقسام الفرعية: ${(dept['subDepartments'] as List<dynamic>?)?.length ?? 0}"),
              trailing: IconButton(
                icon: Icon(Icons.add),
                onPressed: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AddSubDepartmentPage(
                        departmentId: dept['_id'] ?? '',
                      ),
                    ),
                  );
                  fetchDepartments();
                },
              ),
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => SubDepartmentsPage(
                      departmentId: dept['_id'] ?? '',
                      departmentName: dept['name'] ?? '',
                    ),
                  ),
                );
              },
            )),
            Divider(),
            ListTile(
              leading: Icon(Icons.add),
              title: Text("إضافة قسم جديد"),
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => AddDepartmentPage()),
                );
                fetchDepartments();
              },
            ),
          ],
        ),
      ),
      body: loading
          ? Center(child: CircularProgressIndicator())
          : Padding(
        padding: EdgeInsets.all(16.0),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 1.5,
          ),
          itemCount: departments.length,
          itemBuilder: (context, index) {
            final dept = departments[index];
            final subDepartmentCount =
                (dept['subDepartments'] as List<dynamic>?)?.length ?? 0;
            return GestureDetector(
                onTap: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => SubDepartmentsPage(
                        departmentId: dept['_id'] ?? '',
                        departmentName: dept['name'] ?? '',
                      ),
                    ),
                  );
              },
              child: Card(
                elevation: 3,
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(dept['name'] ?? '',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16)),
                      SizedBox(height: 8),
                      Text("$subDepartmentCount قسم فرعي",
                          style: TextStyle(fontSize: 14)),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}