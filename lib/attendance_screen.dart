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

  static const LatLng companyLocation =
  LatLng(32.5315927, 35.8530889);

  Future<void> handleCheckIn() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token");
      if (token == null) return;

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      final response = await http.post(
        Uri.parse(checkInUrl),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode({
          "latitude": position.latitude,
          "longitude": position.longitude,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 201) {
        setState(() {
          isCheckedIn = true;
          checkInTime =
          "${DateTime.now().hour}:${DateTime.now().minute.toString().padLeft(2, '0')}";
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data["message"])),
        );
      }
    } catch (e) {}
  }

  Future<void> handleCheckOut() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token");
      if (token == null) return;

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      final response = await http.post(
        Uri.parse(checkOutUrl),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode({
          "latitude": position.latitude,
          "longitude": position.longitude,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        setState(() {
          isCheckedIn = false;
          checkInTime = null;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data["message"])),
        );
      }
    } catch (e) {}
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
        _buildCheckInButton(),
        const SizedBox(height: 10),
        _buildCheckOutButton(),
      ],
    );
  }

  Widget _buildMap() {
    return Container(
      height: 250,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: GoogleMap(
          initialCameraPosition: const CameraPosition(
            target: companyLocation,
            zoom: 17,
          ),
          markers: {
            const Marker(
              markerId: MarkerId("company"),
              position: companyLocation,
            ),
          },
          zoomControlsEnabled: false,
          myLocationEnabled: false,
        ),
      ),
    );
  }

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

  Widget _buildCheckInButton() {
    return ElevatedButton(
      onPressed: isCheckedIn ? null : handleCheckIn,
      child: Text("check_in".tr()),
    );
  }

  Widget _buildCheckOutButton() {
    return ElevatedButton(
      onPressed: isCheckedIn ? handleCheckOut : null,
      style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
      child: Text("check_out".tr()),
    );
  }
}