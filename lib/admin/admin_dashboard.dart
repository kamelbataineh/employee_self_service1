import 'dart:convert';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api.dart';
import 'CompanyLocationPage.dart';
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
  Locale selectedLocale = const Locale('en', 'US');
  Widget currentPage = const SizedBox();
  String currentTitle = "dashboard";

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

  Future<Map<String, dynamic>?> getCompanyLocation() async {
    try {
      final response = await http.get(
        Uri.parse(admingetCompanyLocation),
        headers: {
          "Authorization": "Bearer $token",
          "Cache-Control": "no-cache",
        },
      );

      print("STATUS: ${response.statusCode}");
      print("BODY: ${response.body}");

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }

    } catch (e) {
      print("Exception: $e");
    }

    return null;
  }

  Future<void> openCompanyLocation() async {
    setState(() => loading = true);

    final data = await getCompanyLocation();

    if (data != null && data['companyLocation'] != null) {
      try {
        // 🛡️ حماية من أي نوع غلط أو null
        final lat = (data['companyLocation']['latitude'] as num).toDouble();
        final lng = (data['companyLocation']['longitude'] as num).toDouble();

        final maxDistance = (data['maxDistance'] is num)
            ? (data['maxDistance'] as num).toDouble()
            : 10.0; // fallback

        setState(() {
          currentPage = CompanyLocationPage(
            latitude: lat,
            longitude: lng,
            maxDistance: maxDistance,
          );
          currentTitle = "company_location".tr();
          loading = false;
        });
      } catch (e) {
        setState(() => loading = false);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("خطأ في بيانات الموقع")),
        );

        print("Parsing Error: $e");
      }
    } else {
      setState(() => loading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("لم يتم تحديد موقع الشركة")),
      );
    }
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
                          departmentName: dept['name'][context.locale.languageCode] ?? '',
                      );
                      currentTitle = dept['name'][context.locale.languageCode] ?? '';
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
                          dept['name'][context.locale.languageCode] ?? '',                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 10),
                        Text("$count sub_departments".tr()),
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
                  "admin_panel".tr(),
                  style: TextStyle(color: Colors.white, fontSize: 20),
                ),
                SizedBox(height: 20),

                Expanded(
                  child: ListView(
                    children: [
                      buildSidebarItem(
                        icon: Icons.dashboard,
                        title:"dashboard".tr(),
                        onTap: () {
                          fetchDepartments();
                          setState(() {
                            currentPage = buildDashboardGrid();
                            currentTitle = "dashboard".tr();
                          });
                        },
                      ),
                      buildSidebarItem(
                        icon: Icons.add,
                        title: "add_department".tr(),
                        onTap: () {
                          setState(() {
                            currentPage = AddDepartmentPage(
                              onCreated: () {
                                fetchDepartments();
                                setState(() {
                                  currentPage = buildDashboardGrid();
                                  currentTitle = "dashboard".tr();
                                });
                              },
                            );

                            currentTitle = "add_department".tr();
                          });
                        },
                      ),
                    ],
                  ),
                ),
                buildSidebarItem(
                  icon: Icons.location_on,
                  title: "company_location".tr(),
                    onTap: openCompanyLocation,

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
  Widget buildTopHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [

          Text(
            currentTitle,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),

          Row(
            children: [
              DropdownButtonHideUnderline(
                child: DropdownButton<Locale>(
                  value: selectedLocale,
                  icon: const Icon(Icons.arrow_drop_down),
                  onChanged: (Locale? newLocale) async {
                    if (newLocale == null) return;

                    setState(() {
                      selectedLocale = newLocale;
                    });

                    final prefs = await SharedPreferences.getInstance();
                    await prefs.setString('locale', newLocale.languageCode);

                    context.setLocale(newLocale);
                  },
                  items: const [
                    DropdownMenuItem(
                      value: Locale('en', 'US'),
                      child: Text("🇺🇸 EN"),
                    ),
                    DropdownMenuItem(
                      value: Locale('ar', 'SA'),
                      child: Text("🇸🇦 AR"),
                    ),
                    DropdownMenuItem(
                      value: Locale('fr', 'FR'),
                      child: Text("🇫🇷 FR"),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

}
