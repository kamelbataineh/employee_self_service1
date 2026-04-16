import 'package:easy_localization/easy_localization.dart';
import 'package:employee_self_service/LeaveEarly.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'LeaveRequestScreen.dart';
import 'ProfileScreen.dart';
import 'config/api.dart';

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

  Map<String, dynamic>? employee;
  String lang = "en";

  @override
  void initState() {
    super.initState();
    fetchEmployee();

    Timer.periodic(const Duration(minutes: 1), (timer) {
      setState(() {
        currentTime = DateTime.now();
      });
    });
  }

  Future<void> fetchEmployee() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token");

      if (token == null) return;

      final response = await http.get(
        Uri.parse(employeegetMyProfile),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        setState(() {
          employee = data["employee"];
        });
      } else {
        print("Error loading employee: ${response.body}");
      }
    } catch (e) {
      print("fetchEmployee error: $e");
    }
  }
  void handleCheckIn() {
    if (!isInZone) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("must_be_in_zone".tr())),
      );
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

  @override
  Widget build(BuildContext context) {
    lang = Localizations.localeOf(context).languageCode;

    return Scaffold(
      backgroundColor: const Color(0xfff5f7fb),
      body: SafeArea(child: getSelectedPage()),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: selectedIndex,
        onTap: (index) => setState(() => selectedIndex = index),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.indigo,
        unselectedItemColor: Colors.grey,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "home".tr()),
          BottomNavigationBarItem(icon: Icon(Icons.fingerprint), label: "attendance".tr()),
          BottomNavigationBarItem(icon: Icon(Icons.event), label: "leaves".tr()),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: "performance".tr()),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "profile".tr()),
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

        const SizedBox(height: 16),
        _buildStats(),
      ],
    );
  }

  Widget getSelectedPage() {
    switch (selectedIndex) {
      case 0:
        return _homeContent();
      case 1:
        return Center(child: Text("attendance".tr()));
      case 2:
        return Center(child: Text("leaves".tr()));
      case 3:
        return Center(child: Text("performance".tr()));
      case 4:
        return const ProfileScreen();
      default:
        return _homeContent();
    }
  }

  Widget _buildHeader() {
    return Stack(
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            gradient: LinearGradient(colors: [Colors.indigo, Colors.blue]),
            borderRadius: BorderRadius.all(Radius.circular(20)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "${"hello".tr()}, ${employee?['name']?[lang] ?? '...'}",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    "${employee?['role'] ?? ''}",
                    style: const TextStyle(color: Colors.white70),
                  ),
                ],
              ),
              Text(
                "${currentTime.hour}:${currentTime.minute.toString().padLeft(2, '0')}",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        Positioned(
          top: 40,
          right: 20,
          child: PopupMenuButton<Locale>(
            icon:  Icon(Icons.language, color: Colors.black),
            onSelected: (Locale locale) async {
              await context.setLocale(locale);
            },
            itemBuilder: (context) => const [
              PopupMenuItem(value: Locale('ar', 'SA'), child: Text("🇯🇴 عربي")),
              PopupMenuItem(value: Locale('en', 'US'), child: Text("🇺🇸 English")),
              PopupMenuItem(value: Locale('fr', 'FR'), child: Text("🇫🇷 Français")),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCheckInCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(colors: [Colors.green, Colors.teal]),
        borderRadius: BorderRadius.all(Radius.circular(20)),
      ),
      child: Column(
        children: [
          const Icon(Icons.fingerprint, size: 80, color: Colors.white),
          const SizedBox(height: 10),

          Text(
            "welcome_work".tr(),
            style: const TextStyle(color: Colors.white, fontSize: 20),
          ),

          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: handleCheckIn,
            child: Text("check_in".tr()),
          ),
        ],
      ),
    );
  }

  Widget _buildCheckedInCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(colors: [Colors.indigo, Colors.blue]),
        borderRadius: BorderRadius.all(Radius.circular(20)),
      ),
      child: Column(
        children: [
          const Icon(Icons.check_circle, color: Colors.white, size: 60),
          const SizedBox(height: 10),
          Text(
            "${"attendance_recorded".tr()}: $checkInTime",
            style: const TextStyle(color: Colors.white),
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: handleCheckOut,
            child: Text("check_out".tr()),
          ),
        ],
      ),
    );
  }

  Widget _buildOutOfZoneCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(colors: [Colors.red, Colors.deepOrange]),
        borderRadius: BorderRadius.all(Radius.circular(20)),
      ),
      child: Column(
        children: [
          const Icon(Icons.warning, color: Colors.white, size: 60),
          const SizedBox(height: 10),
          Text(
            "out_of_zone".tr(),
            style: const TextStyle(color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildStats() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      children: [
        _statCard(number: "20", label: "days_attendance".tr(), color: Colors.green),
        _statCard(number: "50", label: "weekly_hours".tr(), color: Colors.blue),
        _statCard(icon: Icons.directions_run, label: "leave_request".tr(), color: Colors.purple),
        _statCard(icon: Icons.event_available, label: "vacation_request".tr(), color: Colors.orange),
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
        if (label == "leave_request".tr()) {
          Navigator.push(context, MaterialPageRoute(builder: (_) => LeaveEarly()));
        }
        if (label == "vacation_request".tr()) {
          Navigator.push(context, MaterialPageRoute(builder: (_) => LeaveRequestScreen()));
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
            const SizedBox(height: 8),
            Text(label, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            if (number != null)
              Text(
                number,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color),
              ),
          ],
        ),
      ),
    );
  }
}