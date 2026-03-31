import 'package:flutter/material.dart';

class AddEmployeePage extends StatelessWidget {
  final String department;
  const AddEmployeePage({super.key, required this.department});

  @override
  Widget build(BuildContext context) {
    TextEditingController nameController = TextEditingController();
    TextEditingController phoneController = TextEditingController();
    TextEditingController ageController = TextEditingController();
    TextEditingController idController = TextEditingController();
    TextEditingController roleController = TextEditingController();
    TextEditingController passwordController = TextEditingController();

    return Scaffold(
      appBar: AppBar(title: const Text("إضافة موظف")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            TextField(controller: nameController, decoration: const InputDecoration(labelText: "الاسم")),
            TextField(controller: phoneController, decoration: const InputDecoration(labelText: "رقم الهاتف")),
            TextField(controller: ageController, decoration: const InputDecoration(labelText: "العمر")),
            TextField(controller: idController, decoration: const InputDecoration(labelText: "ID الموظف")),
            TextField(controller: roleController, decoration: const InputDecoration(labelText: "الدور / الوظيفة")),
            TextField(controller: passwordController, decoration: const InputDecoration(labelText: "كلمة السر"), obscureText: true),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (nameController.text.isEmpty || idController.text.isEmpty) return;
                Map<String, String> newEmployee = {
                  'name': nameController.text,
                  'phone': phoneController.text,
                  'age': ageController.text,
                  'id': idController.text,
                  'role': roleController.text,
                  'password': passwordController.text,
                  'department': department,
                };
                Navigator.pop(context, newEmployee);
              },
              child: const Text("حفظ"),
            )
          ],
        ),
      ),
    );
  }
}