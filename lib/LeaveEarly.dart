import 'package:employee_self_service/theme.dart';
import 'package:flutter/material.dart';

class LeaveEarly extends StatefulWidget {
   LeaveEarly({super.key});

  @override
  State<LeaveEarly> createState() => _LeaveEarlyState();
}

class _LeaveEarlyState extends State<LeaveEarly> {
  String? selectedReason;
  String selectedDay = "اليوم";

  TextEditingController noteController = TextEditingController();
  TimeOfDay? startTime;

  List<String> reasons = [
    "ظرف طارئ",
    "موعد طبي",
    "سبب شخصي",
    "مهمة خارج العمل",
  ];




  Future<void> pickTime() async {
    TimeOfDay initial = _getInitialTime();

    TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: initial,
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false),
          child: child!,
        );
      },
    );

    if (picked != null && _isValidTime(picked)) {
      setState(() {
        startTime = picked;
      });
    } else if (picked != null) {
      showSnack("الوقت خارج الدوام أو أقل من ساعة من الآن");
    }
  }

  TimeOfDay _getInitialTime() {
    final now = TimeOfDay.now();

    if (selectedDay == "اليوم") {
      int hour = now.hour + 1;
      if (hour < 10) hour = 10;
      if (hour >= 18) hour = 17;
      return TimeOfDay(hour: hour, minute: 0);
    } else {
      return  TimeOfDay(hour: 10, minute: 0);
    }
  }

  bool _isValidTime(TimeOfDay time) {
    int selectedMinutes = time.hour * 60 + time.minute;
    int startWork = 10 * 60;
    int endWork = 18 * 60;

    if (selectedMinutes < startWork || selectedMinutes >= endWork) {
      return false;
    }

    if (selectedDay == "اليوم") {
      final now = TimeOfDay.now();
      int nowMinutes = now.hour * 60 + now.minute;
      if (selectedMinutes < nowMinutes + 60) {
        return false;
      }
    }

    return true;
  }

  DateTime getSelectedDate() {
    final now = DateTime.now();
    if (selectedDay == "اليوم") return now;
    return now.add(const Duration(days: 1));
  }

  void submitRequest() {
    if (selectedReason == null) {
      showSnack("يرجى اختيار السبب");
      return;
    }

    if (startTime == null) {
      showSnack("يرجى اختيار الوقت");
      return;
    }

    DateTime finalDate = getSelectedDate();
    showSnack(
      "تم إرسال الطلب بتاريخ ${finalDate.toLocal().toString().split(' ')[0]} الساعة ${formatTime(startTime)}",
    );
    Navigator.pop(context);
  }

  void showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  String formatTime(TimeOfDay? time) {
    if (time == null) return "اختر الوقت";
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final period = time.period == DayPeriod.am ? "AM" : "PM";
    return "$hour:${time.minute.toString().padLeft(2, '0')} $period";
  }

  Widget buildDayButton(String day) {
    bool isSelected = selectedDay == day;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            selectedDay = day;
            startTime = null;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration:BoxDecoration(
            color: isSelected ? null : Colors.white,
            gradient: isSelected ? AppColors.primaryGradient : null,
            border: Border.all(color:Colors.indigo.shade100),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text(
              day,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.indigo,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("طلب مغادرة",style: TextStyle(fontSize: 20), ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(gradient: AppColors.primaryGradient),
        ),
      ),
      body: Padding(
        padding:  EdgeInsets.all(16),
        child: Column(
          children: [
            DropdownButtonFormField<String>(
              hint:  Text("اختر سبب المغادرة"),
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
            Row(
              children: [
                buildDayButton("اليوم"),
                SizedBox(width: 10),
                buildDayButton("غداً"),
              ],
            ),
            SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: pickTime,
                child: Text(formatTime(startTime)),
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
