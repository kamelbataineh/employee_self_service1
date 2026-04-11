import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api.dart';

class AddDepartmentPage extends StatefulWidget {
  final VoidCallback? onCreated;

   AddDepartmentPage({super.key, this.onCreated});

  @override
  State<AddDepartmentPage> createState() => _AddDepartmentPageState();
}

class _AddDepartmentPageState extends State<AddDepartmentPage> {
  final TextEditingController nameController = TextEditingController();
  bool loading = false;
  String? token;

  @override
  void initState() {
    super.initState();
    loadToken();
  }

  Future<void> loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    token = prefs.getString("token");
  }

  Future<void> createDepartment() async {
    final name = nameController.text.trim();

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
         SnackBar(content: Text("يرجى إدخال اسم القسم")),
      );
      return;
    }

    setState(() => loading = true);

    try {
      final response = await http.post(
        Uri.parse(admindashboardCreate),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: '{"name": "$name"}',
      );

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(content: Text("تمت الإضافة بنجاح")),
        );

        nameController.clear();

        if (widget.onCreated != null) {
          widget.onCreated!();
        }
      } else if (response.statusCode == 400) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("الاسم موجود مسبقًا")),
        );
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

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 450,
        padding: const EdgeInsets.all(25),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 15,
            )
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
             Text(
              "إضافة قسم جديد",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
             SizedBox(height: 20),

            TextField(
              controller: nameController,
              decoration:  InputDecoration(
                labelText: "اسم القسم",
                border: OutlineInputBorder(),
              ),
            ),

             SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  padding: const EdgeInsets.all(14),
                ),
                onPressed: loading ? null : createDepartment,
                child: loading
                    ?  SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
                    :  Text("إضافة"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}