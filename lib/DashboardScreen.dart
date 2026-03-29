import 'package:employee_self_service/LeaveEarly.dart';
import 'package:flutter/material.dart';
import 'dart:async';

import 'LeaveRequestScreen.dart';
import 'ProfileScreen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  DateTime currentTime = DateTime.now();
  bool isInZone = true;
  bool isCheckedIn = false;
  String? checkInTime;
  int selectedIndex = 0;

  @override
  void initState() {
    super.initState();

    Timer.periodic(Duration(minutes: 1), (timer) {
      setState(() {
        currentTime = DateTime.now();
      });
    });
  }

  void handleCheckIn() {
    if (!isInZone) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("يجب أن تكون داخل منطقة العمل")));
      return;
    }

    setState(() {
      isCheckedIn = true;
      checkInTime =
          "${currentTime.hour}:${currentTime.minute.toString().padLeft(2, '0')}";
    });
  }

  void handleCheckOut() {
    setState(() {
      isCheckedIn = false;
      checkInTime = null;
    });
  }

  //
  //
  /////////////////////////////////////////
  /////////////////////////////////////////
  /////////////////////////////////////////
  //
  //
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xfff5f7fb),
      body: SafeArea(child: getSelectedPage()),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: selectedIndex,
        onTap: (index) {
          setState(() {
            selectedIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.indigo,
        unselectedItemColor: Colors.grey,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "الرئيسية"),
          BottomNavigationBarItem(
            icon: Icon(Icons.fingerprint),
            label: "الحضور",
          ),
          BottomNavigationBarItem(icon: Icon(Icons.event), label: "الإجازات"),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: "الإنجاز",
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "البروفايل"),
        ],
      ),
    );
  }

  Widget _homeContent() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildHeader(),
        const SizedBox(height: 16),

        if (isInZone && !isCheckedIn) _buildCheckInCard(),

        if (isCheckedIn) _buildCheckedInCard(),

        if (!isInZone) _buildOutOfZoneCard(),

        SizedBox(height: 16),
        _buildStats(),
      ],
    );
  }

  Widget getSelectedPage() {
    switch (selectedIndex) {
      case 0:
        return _homeContent();
      case 1:
        return Center(child: Text("الحضور"));
      case 2:
        return Center(child: Text("الإجازات"));
      case 3:
        return Center(child: Text("الإنجاز"));
      case 4:
        return ProfileScreen();
      default:
        return _homeContent();
    }
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [Colors.indigo, Colors.blue]),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "مرحباً، أحمد",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text("مطور برمجيات", style: TextStyle(color: Colors.white70)),
            ],
          ),
          Text(
            "${currentTime.hour}:${currentTime.minute.toString().padLeft(2, '0')}",
            style: TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCheckInCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [Colors.green, Colors.teal]),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Icon(Icons.fingerprint, size: 80, color: Colors.white),
          SizedBox(height: 10),
          Text(
            "أهلاً بك في العمل!",
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
          SizedBox(height: 10),
          ElevatedButton(
            onPressed: handleCheckIn,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.green,
            ),
            child: Text("تسجيل حضور"),
          ),
        ],
      ),
    );
  }

  Widget _buildCheckedInCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [Colors.indigo, Colors.blue]),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Icon(Icons.check_circle, color: Colors.white, size: 60),
          SizedBox(height: 10),
          Text(
            "تم تسجيل الحضور: $checkInTime",
            style: TextStyle(color: Colors.white),
          ),
          SizedBox(height: 10),
          ElevatedButton(
            onPressed: handleCheckOut,
            child: Text("تسجيل انصراف"),
          ),
        ],
      ),
    );
  }

  Widget _buildOutOfZoneCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [Colors.red, Colors.deepOrange]),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Icon(Icons.warning, color: Colors.white, size: 60),
          SizedBox(height: 10),
          Text("أنت خارج منطقة العمل", style: TextStyle(color: Colors.white)),
        ],
      ),
    );
  }

  Widget _buildStats() {
    return GridView.count(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      children: [
        _statCard(number: "20",label: "أيام الحضور", color: Colors.green),
        _statCard(number: "50", label: "ساعات الأسبوع", color: Colors.blue),
        _statCard(
          icon: Icons.directions_run,
          label: "طلب مغادرة",
          color: Colors.purple,
        ),
        _statCard(
          icon: Icons.event_available,
          label: "طلب إجازة",
          color: Colors.orange,
        ),
      ],
    );
  }




  Widget _statCard({
    String? number,
    IconData? icon,
    required String label,
    required Color color,
  }) {
    return GestureDetector(
      onTap: () {
        if (label == "طلب مغادرة") {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => LeaveEarly()),
          );
        }
        if (label == "طلب إجازة") {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => LeaveRequestScreen()),
          );
        }
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) Icon(icon, size: 30, color: color),



            SizedBox(height: (icon != null || number != null) ? 8 : 0),

            Text(label, textAlign: TextAlign.center),
            SizedBox(height: 12,),

            if (number != null)
              Text(
                number,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
          ],

        ),
      ),
    );
  }
}
