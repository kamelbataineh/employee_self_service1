import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'config/api.dart';

class AttendanceScreen extends StatefulWidget {
  final Map<String, dynamic>? employee;

  const AttendanceScreen({super.key, this.employee});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  bool isCheckedIn = false;
  String? checkInTime;

  bool mapLoaded = false;
  bool isLoading = false;

  // 📍 موقع الشركة
  static const LatLng companyLocation =
  LatLng(32.5315927, 35.8530889);

  // 📏 نصف القطر المسموح (100 متر)
  static const double allowedRadius = 100;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(() {
        mapLoaded = true;
      });
    });
  }

  // 🔐 التحقق من الصلاحيات
  Future<bool> _checkPermission() async {
    if (!await Geolocator.isLocationServiceEnabled()) return false;

    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    return !(permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever);
  }

  // 📏 حساب المسافة بين الموظف والشركة
  double _calculateDistance(double lat, double lng) {
    return Geolocator.distanceBetween(
      lat,
      lng,
      companyLocation.latitude,
      companyLocation.longitude,
    );
  }

  // 🚀 تسجيل الحضور
  Future<void> handleCheckIn() async {
    if (isLoading) return;

    setState(() => isLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token");

      if (token == null) return;

      // 1️⃣ التحقق من GPS
      bool permission = await _checkPermission();
      if (!permission) {
        _showMsg("location_disabled".tr());
        return;
      }

      // 2️⃣ جلب الموقع
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 8),
      );

      // 🚨 3️⃣ منع Fake GPS
      if (position.isMocked) {
        _showMsg("Fake GPS detected ❌");
        return;
      }

      // 📏 4️⃣ التحقق من المسافة
      double distance = _calculateDistance(
        position.latitude,
        position.longitude,
      );

      if (distance > allowedRadius) {
        _showMsg("You are خارج نطاق الشركة ❌");
        return;
      }

      // 🌐 5️⃣ إرسال للسيرفر
      final response = await http.post(
        Uri.parse(checkInUrl),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode({
          "latitude": position.latitude,
          "longitude": position.longitude,
          "distance": distance,
        }),
      );

      if (response.statusCode == 201) {
        setState(() {
          isCheckedIn = true;
          checkInTime =
          "${DateTime.now().hour}:${DateTime.now().minute.toString().padLeft(2, '0')}";
        });
      } else {
        _showMsg("Server error ❌");
      }
    } catch (e) {
      _showMsg("Error: $e");
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  void _showMsg(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildMap(),
        const SizedBox(height: 16),
        _buildStatusCard(),
        const SizedBox(height: 20),
        _buildButton(),
      ],
    );
  }

  // 🗺️ الخريطة
  Widget _buildMap() {
    if (!mapLoaded) {
      return const SizedBox(
        height: 250,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    return SizedBox(
      height: 250,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: GoogleMap(
          initialCameraPosition: const CameraPosition(
            target: companyLocation,
            zoom: 15,
          ),
          markers: {
            const Marker(
              markerId: MarkerId("company"),
              position: companyLocation,
            ),
          },
          circles: {
            Circle(
              circleId: const CircleId("allowed_zone"),
              center: companyLocation,
              radius: allowedRadius,
              fillColor: Colors.green.withOpacity(0.2),
              strokeColor: Colors.green,
              strokeWidth: 2,
            ),
          },
          myLocationEnabled: false,
          zoomControlsEnabled: false,
        ),
      ),
    );
  }

  // 📊 الحالة
  Widget _buildStatusCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isCheckedIn
              ? [Colors.green, Colors.teal]
              : [Colors.red, Colors.deepOrange],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Icon(
            isCheckedIn ? Icons.check_circle : Icons.cancel,
            color: Colors.white,
            size: 60,
          ),
          const SizedBox(height: 10),
          Text(
            isCheckedIn ? "checked_in".tr() : "not_checked_in".tr(),
            style: const TextStyle(color: Colors.white),
          ),
          if (checkInTime != null)
            Text(
              checkInTime!,
              style: const TextStyle(color: Colors.white70),
            ),
        ],
      ),
    );
  }

  // 🔘 زر الحضور
  Widget _buildButton() {
    return ElevatedButton(
      onPressed: isCheckedIn || isLoading ? null : handleCheckIn,
      child: isLoading
          ? const SizedBox(
        height: 18,
        width: 18,
        child: CircularProgressIndicator(strokeWidth: 2),
      )
          : Text("check_in".tr()),
    );
  }
}