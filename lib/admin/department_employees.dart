import 'package:flutter/material.dart';
import 'add_employee.dart';

class DepartmentEmployeesPage extends StatefulWidget {
  final String department;
  const DepartmentEmployeesPage({super.key, required this.department});

  @override
  State<DepartmentEmployeesPage> createState() => _DepartmentEmployeesPageState();
}

class _DepartmentEmployeesPageState extends State<DepartmentEmployeesPage> {
  List<Map<String, String>> employees = [];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("الموظفين في قسم ${widget.department}",
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ElevatedButton.icon(
                icon: const Icon(Icons.add),
                label: const Text("إضافة موظف"),
                onPressed: () async {
                  final newEmployee = await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => AddEmployeePage(department: widget.department)),
                  );
                  if (newEmployee != null) {
                    setState(() {
                      employees.add(newEmployee);
                    });
                  }
                },
              )
            ],
          ),
          const SizedBox(height: 20),
          Expanded(
            child: employees.isEmpty
                ? const Center(child: Text("لا يوجد موظفين بعد"))
                : ListView.builder(
              itemCount: employees.length,
              itemBuilder: (context, index) {
                final emp = employees[index];
                return Card(
                  child: ListTile(
                    title: Text(emp['name']!),
                    subtitle: Text("ID: ${emp['id']} | دور: ${emp['role']}"),
                  ),
                );
              },
            ),
          )
        ],
      ),
    );
  }
}