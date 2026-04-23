import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_typeahead/flutter_typeahead.dart';

import '../config/api.dart';
import 'LocationResultPage.dart';

class SetLocationPage extends StatefulWidget {
  final String adminId;
  final String token;

  const SetLocationPage({
    super.key,
    required this.adminId,
    required this.token,
  });

  @override
  State<SetLocationPage> createState() => _SetLocationPageState();
}

class _SetLocationPageState extends State<SetLocationPage> {
  GoogleMapController? mapController;
  CameraPosition? _lastCameraPosition;
  LatLng? selectedLocation;
  double radius = 100;
  LatLng? _mapCenter;
  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    getMyLocation();
  }

  // =========================
  // GET CURRENT LOCATION
  // =========================
  Future<void> getMyLocation() async {
    Position pos = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    final myPos = LatLng(pos.latitude, pos.longitude);

    setState(() {
      selectedLocation = myPos;
    });

    mapController?.animateCamera(CameraUpdate.newLatLngZoom(myPos, 15));
  }

  // =========================
  // GOOGLE PLACES SEARCH
  // =========================
  Future<List<dynamic>> searchPlaces(String query) async {
    print("🔍 Searching: $query");

    if (query.isEmpty) return [];

    final url = placesSearch(query);
    final res = await http.get(Uri.parse(url));

    print("📡 Status Code: ${res.statusCode}");
    print("📦 Body: ${res.body}");

    try {
      final decoded = jsonDecode(res.body);

      if (decoded is! Map) return [];

      if (decoded['status'] != "OK") {
        print("❌ API Error: ${decoded['status']}");
        return [];
      }

      if (decoded['predictions'] is List) {
        return decoded['predictions'];
      }

      return [];
    } catch (e) {
      print("❌ JSON ERROR: $e");
      return [];
    }
  }

  // =========================
  // GET PLACE DETAILS (LAT LNG)
  // =========================
  Future<LatLng?> getPlaceDetails(String placeId) async {
    final url = placesDetails(placeId);

    print("🌐 Details URL: $url");

    final res = await http.get(Uri.parse(url));

    print("📦 Response: ${res.body}");

    final data = jsonDecode(res.body);

    if (data['status'] != "OK") {
      return null;
    }

    final loc = data['location'];

    if (loc == null) return null;

    return LatLng(loc['lat'], loc['lng']);
  }

  // =========================
  // SAVE LOCATION
  // =========================
  Future<void> saveLocation() async {
    if (selectedLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("⚠ اختر موقع من الخريطة أولاً")),
      );
      return;
    }

    // 🔥 ناخذ نسخة ثابتة من الموقع وقت الضغط
    final LatLng fixedLocation = LatLng(
      selectedLocation!.latitude,
      selectedLocation!.longitude,
    );

    final res = await http.post(
      Uri.parse(adminsetCompanyLocationApi),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer ${widget.token}",
      },
      body: jsonEncode({
        "latitude": fixedLocation.latitude,
        "longitude": fixedLocation.longitude,
        "maxDistance": radius.toInt(),
      }),
    );

    if (res.statusCode == 200) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => LocationResultPage(
            location: fixedLocation, // 🔥 نستخدم النسخة الثابتة
            radius: radius < 5 ? 5 : radius,
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("❌ فشل الحفظ")),
      );
    }
  }

  // =========================
  // UI
  // =========================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor:Colors.black,
        title: const Text("تحديد موقع الشركة"),
        actions: [
          IconButton(
            icon: const Icon(Icons.my_location),
            onPressed: getMyLocation,
          ),
        ],
      ),
      body: Stack(
        children: [
          // ================= MAP =================
          GoogleMap(
            key: const ValueKey("map"),
            initialCameraPosition: const CameraPosition(
              target: LatLng(31.9539, 35.9106),
              zoom: 12,
            ),
            onMapCreated: (c) => mapController = c,
            onTap: (pos) {
              setState(() {
                selectedLocation = pos;
              });
            },
            markers: selectedLocation == null
                ? {}
                : {
                    Marker(
                      markerId: const MarkerId("m1"),
                      position: selectedLocation!,
                    ),
                  },
            circles: selectedLocation == null
                ? {}
                : {
                    Circle(
                      circleId: const CircleId("c1"),
                      center: selectedLocation!,
                      radius: radius,
                      fillColor: Colors.blue.withOpacity(0.2),
                      strokeColor: Colors.blue,
                      strokeWidth: 2,
                    ),
                  },
          ),

          // ================= SEARCH =================
          // ================= SEARCH (CLEAN UI) =================
          Positioned(
            top: 10,
            left: 12,
            right: 12,
            child: Material(
              elevation: 6,
              borderRadius: BorderRadius.circular(16),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: TypeAheadField<dynamic>(
                  controller: searchController,
                  suggestionsCallback: searchPlaces,

                  itemBuilder: (context, item) {
                    if (item is! Map) return const SizedBox();

                    return ListTile(
                      leading: const Icon(
                        Icons.location_on,
                        color: Colors.blue,
                      ),
                      title: Text(
                        item['description'] ?? "",
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                  },

                  onSelected: (item) async {
                    FocusScope.of(context).unfocus(); // 🔥 يقفل الكيبورد

                    final placeId = item['place_id'];
                    final location = await getPlaceDetails(placeId);

                    if (location == null) return;

                    setState(() => selectedLocation = location);

                    mapController?.animateCamera(
                      CameraUpdate.newLatLngZoom(location, 16),
                    );

                    searchController.clear(); // 🔥 يمسح البحث بعد الاختيار
                  },

                  builder: (context, controller, focusNode) {
                    return TextField(
                      controller: controller,
                      focusNode: focusNode,
                      decoration: const InputDecoration(
                        hintText: "ابحث عن مكان، شركة، شارع...",
                        prefixIcon: Icon(Icons.search, color: Colors.blue),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.all(14),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),

          // ================= BOTTOM PANEL (FIXED) =================
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
                boxShadow: [BoxShadow(blurRadius: 10, color: Colors.black26)],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    selectedLocation == null
                        ? "اضغط على الخريطة لتحديد الموقع"
                        : "تم تحديد الموقع ✔",
                  ),

                  Slider(
                    value: radius < 5 ? 5 : radius,
                    min: 5,
                    max: 1000,
                    onChanged: (v) {
                      setState(() {
                        radius = v;
                      });

                      // منع أي إعادة تمركز للخريطة
                      if (_mapCenter != null) {
                        mapController?.moveCamera(
                          CameraUpdate.newLatLng(_mapCenter!),
                        );
                      }
                    },
                  ),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: saveLocation,
                      child: const Text("حفظ الموقع"),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
