import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api.dart';

class AddSubDepartmentPage extends StatefulWidget {
  final String departmentId;

   AddSubDepartmentPage({super.key, required this.departmentId});

  @override
  State<AddSubDepartmentPage> createState() => _AddSubDepartmentPageState();
}

class _AddSubDepartmentPageState extends State<AddSubDepartmentPage> {
  final TextEditingController nameController = TextEditingController();
  bool loading = false;

  Future<void> createSubDepartment() async {
    final name = nameController.text.trim();
    if (name.isEmpty) return;

    setState(() => loading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token") ?? "";

      final url =
          "${admindashboardCreate.replaceAll('create', 'add-sub-department')}/${widget.departmentId}";

      final response = await http.post(
        Uri.parse(url),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: '{"name": "$name"}',
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(content: Text("حدث خطأ")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
         SnackBar(content: Text("خطأ في الاتصال")),
      );
    } finally {
      setState(() => loading = false);
    }
  }

  Widget header() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(12),
      ),
      child:  Text(
        "Add Sub Department",
        style: TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget buildField() {
    return TextField(
      controller: nameController,
      decoration:  InputDecoration(
        labelText: "Sub Department Name",
        border: OutlineInputBorder(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title:  Text("Add Sub Department"),
        backgroundColor: Colors.black,
      ),
      body: Center(
        child: Container(
          width: 450,
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              header(),
              buildField(),
               SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    padding:  EdgeInsets.all(14),
                  ),
                  onPressed: loading ? null : createSubDepartment,
                  child: loading
                      ?  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                      :  Text("Create"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}