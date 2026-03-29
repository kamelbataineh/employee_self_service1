import 'package:flutter/material.dart';
import 'package:employee_self_service/theme.dart';

class LeaveRequestScreen extends StatefulWidget {
  const LeaveRequestScreen({super.key});

  @override
  State<LeaveRequestScreen> createState() => _LeaveRequestScreenState();
}

class _LeaveRequestScreenState extends State<LeaveRequestScreen> {
  String? selectedReason;
  DateTime? startDate;
  DateTime? endDate;
  TextEditingController noteController = TextEditingController();

  List<String> reasons = [
    "إجازة سنوية",
    "إجازة مرضية",
    "إجازة طارئة",
  ];

  bool _isSelectableDay(DateTime day) {
    DateTime today = DateTime.now();
    if (day.isBefore(today.add( Duration(days: 1)))) return false;

    if (day.weekday == DateTime.thursday || day.weekday == DateTime.friday) {
      return false;
    }
    return true;
  }

  Future<void> pickStartDate() async {
    DateTime now = DateTime.now();
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: now.add( Duration(days: 1)),
      firstDate: now.add( Duration(days: 1)),
      lastDate: now.add( Duration(days: 365)),
      selectableDayPredicate: _isSelectableDay,
    );

    if (picked != null) {
      setState(() {
        startDate = picked;
        if (endDate != null && endDate!.isBefore(startDate!)) {
          endDate = null;
        }
      });
    }
  }

  Future<void> pickEndDate() async {
    if (startDate == null) {
      showSnack("يرجى اختيار تاريخ البداية أولاً");
      return;
    }

    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: startDate!,
      firstDate: startDate!,
      lastDate: startDate!.add( Duration(days: 30)),
      selectableDayPredicate: _isSelectableDay,
    );

    if (picked != null) {
      setState(() {
        endDate = picked;
      });
    }
  }

  void submitRequest() {
    if (selectedReason == null) {
      showSnack("يرجى اختيار نوع الإجازة");
      return;
    }
    if (startDate == null || endDate == null) {
      showSnack("يرجى اختيار تاريخ البداية والنهاية");
      return;
    }

    showSnack(
      "تم إرسال طلب ${selectedReason!} من ${formatDate(startDate!)} إلى ${formatDate(endDate!)}",
    );

    Navigator.pop(context);
  }

  void showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  String formatDate(DateTime date) {
    return "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:  Text("طلب إجازة"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(gradient: AppColors.primaryGradient),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            DropdownButtonFormField<String>(
              hint:  Text("اختر نوع الإجازة"),
              value: selectedReason,
              items: reasons.map((reason) {
                return DropdownMenuItem(value: reason, child: Text(reason));
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedReason = value;
                });
              },
            ),
             SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: pickStartDate,
                child: Text(startDate == null
                    ? "اختر تاريخ البداية"
                    : formatDate(startDate!)),
              ),
            ),
             SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: pickEndDate,
                child: Text(endDate == null
                    ? "اختر تاريخ النهاية"
                    : formatDate(endDate!)),
              ),
            ),
             SizedBox(height: 20),
            TextField(
              controller: noteController,
              maxLines: 3,
              decoration:  InputDecoration(
                labelText: "ملاحظة (اختياري)",
                border: OutlineInputBorder(),
              ),
            ),
             SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: submitRequest,
                child:  Text("إرسال الطلب"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}