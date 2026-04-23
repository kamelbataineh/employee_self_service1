import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'login_page.dart'; // 🔥 لازم تستورد صفحة تسجيل الدخول

class LocationResultPage extends StatelessWidget {
  final LatLng location;
  final double radius;

  const LocationResultPage({
    super.key,
    required this.location,
    required this.radius,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text("الموقع المحدد"),
      ),

      body: Column(
        children: [
          Expanded(
            child: GoogleMap(
              initialCameraPosition: CameraPosition(
                target: location,
                zoom: 16,
              ),

              markers: {
                Marker(
                  markerId: const MarkerId("selected"),
                  position: location,
                ),
              },

              circles: {
                Circle(
                  circleId: const CircleId("zone"),
                  center: location,
                  radius: radius,
                  fillColor: Colors.blue.withOpacity(0.2),
                  strokeColor: Colors.blue,
                  strokeWidth: 2,
                ),
              },
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child:ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => LoginPage()),
                      (route) => false,
                );
              },
              icon: const Icon(Icons.login),
              label: const Text("Go to Login"),
            ),
          ),
        ],
      ),
    );
  }
}