import 'dart:convert';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api.dart';

class AddSubDepartmentPage extends StatefulWidget {
  final String departmentId;

  const AddSubDepartmentPage({super.key, required this.departmentId});

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

      if (token.isEmpty) {
        setState(() => loading = false);
        return;
      }

      final url =
          "${admindashboardCreate.replaceAll('create', 'add-sub-department')}/${widget.departmentId}";

      final body = {
        "name": {
          "en": name,
          "ar": name,
          "fr": name,
        }
      };

      final response = await http.post(
        Uri.parse(url),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode(body),
      );

      if (!mounted) return;

      if (response.statusCode == 200 || response.statusCode == 201) {
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("حدث خطأ")),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("خطأ في الاتصال")),
      );
    } finally {
      if (mounted) {
        setState(() => loading = false);
      }
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
      child: Text(
        "add_sub_department".tr(),
        style: const TextStyle(
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
      decoration: InputDecoration(
        labelText: "sub_department_name".tr(),
        border: const OutlineInputBorder(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text("add_sub_department".tr()),
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
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    padding: const EdgeInsets.all(14),
                  ),
                  onPressed: loading ? null : createSubDepartment,
                  child: loading
                      ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                      : Text("create".tr()),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}