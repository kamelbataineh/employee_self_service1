import 'package:flutter/material.dart';

class AddDepartmentPage extends StatelessWidget {
  const AddDepartmentPage({super.key});

  @override
  Widget build(BuildContext context) {
    TextEditingController controller = TextEditingController();

    return Scaffold(
      appBar: AppBar(title: const Text("إضافة قسم")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: controller,
              decoration: const InputDecoration(labelText: "اسم القسم"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (controller.text.isNotEmpty) {
                  Navigator.pop(context, controller.text);
                }
              },
              child: const Text("حفظ"),
            )
          ],
        ),
      ),
    );
  }
}