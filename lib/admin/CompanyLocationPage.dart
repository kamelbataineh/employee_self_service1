import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class CompanyLocationPage extends StatefulWidget {
  final double latitude;
  final double longitude;
  final double maxDistance;

  const CompanyLocationPage({
    super.key,
    required this.latitude,
    required this.longitude,
    required this.maxDistance,
  });

  @override
  State<CompanyLocationPage> createState() => _CompanyLocationPageState();
}

class _CompanyLocationPageState extends State<CompanyLocationPage> {
  GoogleMapController? mapController;

  late final LatLng companyLocation;

  @override
  void initState() {
    super.initState();
    companyLocation = LatLng(widget.latitude, widget.longitude);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(


      body: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: companyLocation,
          zoom: 15,
        ),

        onMapCreated: (controller) {
          mapController = controller;
        },

        markers: {
          Marker(
            markerId: const MarkerId("company"),
            position: companyLocation,
            infoWindow: const InfoWindow(title: "Company Location"),
          ),
        },

        circles: {
          Circle(
            circleId: const CircleId("radius"),
            center: companyLocation,
            radius: widget.maxDistance, // ✅ بالمتر مباشرة
            fillColor: Colors.blue.withOpacity(0.2),
            strokeColor: Colors.blue,
            strokeWidth: 2,
          ),
        },
      ),
    );
  }
}