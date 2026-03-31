import 'package:flutter/material.dart';
import 'add_department.dart';
import 'department_employees.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  List<String> departments = ["IT", "HR", "Finance"];
  String? selectedDepartment;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title:  Text("Admin Dashboard"),backgroundColor: Colors.black,),
      drawer: Drawer(
        child: ListView(
          children: [
             DrawerHeader(child: Text("الشركة", style: TextStyle(fontSize: 24))),
            ...departments.map((dept) {
              return ListTile(
                title: Text(dept),
                onTap: () {
                  setState(() {
                    selectedDepartment = dept;
                  });
                  Navigator.pop(context);
                },
              );
            }).toList(),
             Divider(),
            ListTile(
              leading:  Icon(Icons.add),
              title:  Text("إضافة قسم جديد"),
              onTap: () async {
                final newDept = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AddDepartmentPage()),
                );
                if (newDept != null) {
                  setState(() {
                    departments.add(newDept);
                  });
                }
              },
            ),
          ],
        ),
      ),
      body: selectedDepartment == null
          ?  Center(child: Text("اختر قسم من القائمة"))
          : DepartmentEmployeesPage(department: selectedDepartment!),
    );
  }
}