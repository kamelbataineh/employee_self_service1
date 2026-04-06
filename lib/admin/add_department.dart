import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api.dart';

class AddDepartmentPage extends StatefulWidget {
   AddDepartmentPage({super.key});

  @override
  State<AddDepartmentPage> createState() => _AddDepartmentPageState();
}

class _AddDepartmentPageState extends State<AddDepartmentPage> {
  TextEditingController controller = TextEditingController();
  bool isLoading = false;




  ////////////////////////////////
  ////////////////////////////////
  ////////////////////////////////
  ////////////////////////////////


  Future<void> addDepartment() async {
    if (controller.text.isEmpty) return;
    setState(() => isLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token") ?? "";
      if (token.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(content: Text("الرجاء تسجيل الدخول أولاً")),
        );
        setState(() => isLoading = false);
        return;
      }

      final response = await http.post(
        Uri.parse(admindashboard),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode({"name": controller.text}),
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(data["message"])));
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(data["message"] ?? "حدث خطأ")));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
         SnackBar(content: Text("خطأ بالاتصال بالسيرفر")),
      );
    }

    setState(() => isLoading = false);
  }


  //////////////////////////////////////////////////////////////////////////////
  //////////////////////////////////////////////////////////////////////////////
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title:  Text("إضافة قسم")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(controller: controller, decoration:  InputDecoration(labelText: "اسم القسم")),
             SizedBox(height: 20),
            isLoading
                ?  CircularProgressIndicator()
                : ElevatedButton(onPressed: addDepartment, child:  Text("حفظ")),
          ],
        ),
      ),
    );
  }
}