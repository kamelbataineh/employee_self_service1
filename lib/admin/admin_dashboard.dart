import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api.dart';
import 'sub_departments_page.dart';
import 'add_department.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  List<Map<String, dynamic>> departments = [];
  bool loading = true;
  String? token;

  Widget currentPage = const SizedBox();
  String currentTitle = "Dashboard";

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
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);

        setState(() {
          departments = List<Map<String, dynamic>>.from(data);
          loading = false;

          currentPage = buildDashboardGrid();
        });
      } else {
        setState(() => loading = false);
      }
    } catch (e) {
      setState(() => loading = false);
    }
  }

  Widget buildTopHeader() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Text(
        currentTitle,
        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget buildDashboardGrid() {
    if (loading) {
      return Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 20,
                mainAxisSpacing: 20,
                childAspectRatio: 1.6,
              ),
              itemCount: departments.length,
              itemBuilder: (context, index) {
                final dept = departments[index];
                final count = (dept['subDepartments'] as List?)?.length ?? 0;

                return InkWell(
                  onTap: () {
                    setState(() {
                      currentPage = SubDepartmentsPage(
                        departmentId: dept['_id'],
                        departmentName: dept['name'],
                      );
                      currentTitle = dept['name'];
                    });
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          dept['name'] ?? '',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 10),
                        Text("$count Sub Departments"),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget buildSidebarItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.white),
      title: Text(title, style: TextStyle(color: Colors.white)),
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Row(
        children: [
          Container(
            width: 250,
            color: Colors.black,
            child: Column(
              children: [
                SizedBox(height: 30),
                Text(
                  "Admin Panel",
                  style: TextStyle(color: Colors.white, fontSize: 20),
                ),
                SizedBox(height: 20),

                Expanded(
                  child: ListView(
                    children: [
                      buildSidebarItem(
                        icon: Icons.dashboard,
                        title: "Dashboard",
                        onTap: () {
                          fetchDepartments();
                          setState(() {
                            currentPage = buildDashboardGrid();
                            currentTitle = "Dashboard";
                          });
                        },
                      ),
                      buildSidebarItem(
                        icon: Icons.add,
                        title: "Add Department",
                        onTap: () {
                          setState(() {
                            currentPage = AddDepartmentPage(
                              onCreated: () {
                                fetchDepartments(); // تحديث بعد الإضافة فقط
                                setState(() {
                                  currentPage = buildDashboardGrid();
                                  currentTitle = "Dashboard";
                                });
                              },
                            );

                            currentTitle = "Add Department";
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: Column(
              children: [
                buildTopHeader(),
                Expanded(child: currentPage),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
