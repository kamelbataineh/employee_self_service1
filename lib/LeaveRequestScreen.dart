import 'package:flutter/material.dart';
import 'package:employee_self_service/theme.dart';

class LeaveRequestScreen extends StatefulWidget {
  const LeaveRequestScreen({super.key});

  @override
  State<LeaveRequestScreen> createState() => _LeaveRequestScreenState();
}

class _LeaveRequestScreenState extends State<LeaveRequestScreen> {
  final String requestDate =
      "${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}";
  final String requestTime =
      "${DateTime.now().hour}:${DateTime.now().minute.toString().padLeft(2, '0')}";

  final String name = "أحمد";
  final String department = "IT";
  final String jobTitle = "مدرب";

  String? selectedManager;
  List<String> managers = ["مدير أحمد", "مدير محمد", "مدير خالد"];

  List<String> employees = ["علي", "سارة", "يوسف", "لينا"];
  List<String> selectedEmployees = [];

  String? leaveType;
  List<String> leaveTypes = ["مرضية", "عرضية", "خاصة", "أسباب أخرى"];

  String? specialType;
  List<String> specialTypes = ["وفاة", "حج", "زواج", "أخرى"];

  String? relation;
  List<String> relations = ["أب", "أم", "أخ", "أخت", "أقارب"];

  TextEditingController noteController = TextEditingController();

  DateTime? startDate;
  DateTime? endDate;

  int sickLeaves = 14;
  int casualLeaves = 14;

  bool _isSelectableDay(DateTime day) {
    DateTime today = DateTime.now();
    if (day.isBefore(today.add( Duration(days: 1)))) return false;
    if (day.weekday == DateTime.thursday || day.weekday == DateTime.friday)
      return false;
    return true;
  }

  int getMaxDays() {
    if (leaveType == "خاصة") {
      if (specialType == "وفاة") {
        if (relation == "أب" ||
            relation == "أم" ||
            relation == "أخ" ||
            relation == "أخت")
          return 3;
        else
          return 2;
      }
      if (specialType == "حج") return 14;
      if (specialType == "زواج") return 3;
      if (specialType == "أخرى") return 2;
    }
    if (leaveType == "مرضية") return sickLeaves;
    if (leaveType == "عرضية") return casualLeaves;
    return 30;
  }

  int getMinDays() {
    if (leaveType == "خاصة") {
      if (specialType == "وفاة") return 1;
      if (specialType == "حج") return 10;
      if (specialType == "زواج") return 3;
      if (specialType == "أخرى") return 1;
    }
    return 1;
  }

  int calculateDaysRange(DateTime start, DateTime end) {
    int count = 0;
    DateTime current = start;
    while (!current.isAfter(end)) {
      if (_isSelectableDay(current)) count++;
      current = current.add( Duration(days: 1));
  }
    return count;
  }

  Future<void> pickStartDate() async {
    DateTime now = DateTime.now();
    DateTime initial = now.add( Duration(days: 1));
    while (!_isSelectableDay(initial)) {
      initial = initial.add( Duration(days: 1));
    }
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: initial,
      lastDate: now.add( Duration(days: 365)),
      selectableDayPredicate: _isSelectableDay,
    );
    if (picked != null) {
      setState(() {
        startDate = picked;
        endDate = null;
      });
    }
  }

  Future<void> pickEndDate() async {
    if (startDate == null) {
      showSnack("اختر تاريخ البداية أولاً");
      return;
    }

    int minDays = getMinDays();
    int maxDays = getMaxDays();

    DateTime maxEnd = startDate!;
    int added = 0;
    while (added < maxDays - 1) {
      maxEnd = maxEnd.add( Duration(days: 1));
      if (_isSelectableDay(maxEnd)) added++;
    }

    DateTime? initial;
    DateTime temp = startDate!;
    while (!temp.isAfter(maxEnd)) {
      if (_isSelectableDay(temp)) {
        int daysCount = calculateDaysRange(startDate!, temp);
        if (daysCount >= minDays) {
          initial = temp;
          break;
        }
      }
      temp = temp.add( Duration(days: 1));
    }

    if (initial == null) {
      showSnack("لا يوجد أيام مسموحة ضمن المدى المحدد");
      return;
    }

    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: startDate!,
      lastDate: maxEnd,
      selectableDayPredicate: (day) {
        if (!_isSelectableDay(day)) return false;
        int days = calculateDaysRange(startDate!, day);
        return days >= minDays && days <= maxDays;
      },
    );

    if (picked != null) {
      setState(() {
        endDate = picked;
      });
    }
  }

  int calculateDays() {
    if (startDate == null || endDate == null) return 0;
    return calculateDaysRange(startDate!, endDate!);
  }

  void submitRequest() {
    if (selectedManager == null || leaveType == null) {
      showSnack("عبّي الحقول المطلوبة");
      return;
    }

    int days = calculateDays();

    if (days < getMinDays() || days > getMaxDays()) {
      showSnack("عدد الأيام غير مطابق للشروط");
      return;
    }

    if (leaveType == "مرضية") {
      if (days > sickLeaves) {
        showSnack("رصيد المرضية غير كافي");
        return;
      }
      sickLeaves -= days;
    } else {

      if (days > casualLeaves) {
        showSnack("رصيد العرضية غير كافي لهذه الإجازة");
        return;
      }
      casualLeaves -= days;
    }

    showSnack("تم إرسال الطلب بنجاح");
    Navigator.pop(context);
  }

  void showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  String formatDate(DateTime date) {
    return "${date.day}/${date.month}/${date.year}";
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
          child: ListView(
            children: [
              Table(
                border: TableBorder.all(color: Colors.grey.shade300),
                columnWidths:  {
                  0: FlexColumnWidth(1),
                  1: FlexColumnWidth(1),
                },
                defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                children: [
                  TableRow(children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(requestDate, textAlign: TextAlign.left), // القيمة على اليسار
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text("تاريخ التقديم", style: TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.right), // العنوان على اليمين
                    ),
                  ]),
                  TableRow(children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(requestTime, textAlign: TextAlign.left),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text("وقت التقديم", style: TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.right),
                    ),
                  ]),
                  TableRow(children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(name, textAlign: TextAlign.left),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text("الاسم", style: TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.right),
                    ),
                  ]),
                  TableRow(children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(department, textAlign: TextAlign.left),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text("القسم", style: TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.right),
                    ),
                  ]),
                  TableRow(children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(jobTitle, textAlign: TextAlign.left),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text("المسمى الوظيفي", style: TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.right),
                    ),
                  ]),
                ],
              ),
               SizedBox(height: 20),
              DropdownButtonFormField(
                hint:  Text("اختر المدير"),
                value: selectedManager,
                items: managers.map((e) {
                  return DropdownMenuItem(value: e, child: Text(e));
                }).toList(),
                onChanged: (val) => setState(() => selectedManager = val),
              ),
               SizedBox(height: 20),
               Text("اختر موظف بديل"),
              ...employees.map((emp) => CheckboxListTile(
                title: Text(emp),
                value: selectedEmployees.contains(emp),
                onChanged: (val) {
                  setState(() {
                    val! ? selectedEmployees.add(emp) : selectedEmployees.remove(emp);
                  });
                },
              )),
             SizedBox(height: 20),
            DropdownButtonFormField(
              hint:  Text("نوع الإجازة"),
              value: leaveType,
              items: leaveTypes.map((e) {
                return DropdownMenuItem(value: e, child: Text(e));
              }).toList(),
              onChanged: (val) {
                setState(() {
                  leaveType = val;
                  specialType = null;
                  relation = null;
                });
              },
            ),
             SizedBox(height: 20),
            if (leaveType == "خاصة") ...[
              DropdownButtonFormField(
                hint:  Text("نوع الإجازة الخاصة"),
                value: specialType,
                items: specialTypes.map((e) {
                  return DropdownMenuItem(value: e, child: Text(e));
                }).toList(),
                onChanged: (val) => setState(() {
                  specialType = val;
                  relation = null;
                }),
              ),
              if (specialType == "وفاة")
                DropdownButtonFormField(
                  hint:  Text("صلة القرابة"),
                  value: relation,
                  items: relations.map((e) {
                    return DropdownMenuItem(value: e, child: Text(e));
                  }).toList(),
                  onChanged: (val) => setState(() => relation = val),
                ),
              if (specialType == "أخرى")
                TextField(
                  controller: noteController,
                  decoration:  InputDecoration(labelText: "اكتب السبب"),
                ),
            ],
             SizedBox(height: 20),
              buildDateButton(
                startDate == null ? "تاريخ البداية" : formatDate(startDate!),
                pickStartDate,
              ),
              const SizedBox(height: 10),
              buildDateButton(
                endDate == null ? "تاريخ النهاية" : formatDate(endDate!),
                pickEndDate,
              ),
              const SizedBox(height: 10),
              Text("عدد الأيام: ${calculateDays()}"),
              const SizedBox(height: 20),
              Text("رصيد المرضية: $sickLeaves"),
              Text("رصيد العرضية: $casualLeaves"),
              const SizedBox(height: 20),
              buildDateButton(
                "إرسال الطلب",
                submitRequest,
              ),
          ],
        ),
      ),
    );
  }

  Widget buildDateButton(String text, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity/2,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient,
          border: Border.all(color: Colors.indigo.shade100),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: Text(
            text,
            style:  TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
