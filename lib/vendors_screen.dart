import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

class VendorsScreen extends StatefulWidget {
  const VendorsScreen({super.key});

  @override
  State<VendorsScreen> createState() => _VendorsScreenState();
}

class _VendorsScreenState extends State<VendorsScreen> {
  GoogleMapController? mapController;
  LatLng initialPosition = const LatLng(31.5204, 74.3587); // Default Lahore
  bool locationLoaded = false;
  Set<Marker> markers = {};
  List vendors = [];
  String selectedType = "All";

  // Colors
  final Color primaryColor = const Color(0xFF4A4E69);
  final Color secondaryColor = const Color(0xFFC9ADA7);
  final Color lightColor = Colors.white;

  final String apiKey = "YOUR_GOOGLE_MAPS_API_KEY"; // <-- Put your API key here

  @override
  void initState() {
    super.initState();
    requestLocationPermission();
  }

  Future<void> requestLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse) {
      Position pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );
      if (!mounted) return;
      setState(() {
        initialPosition = LatLng(pos.latitude, pos.longitude);
        locationLoaded = true;
      });

      // Fetch vendors from Google Places API
      fetchNearbyVendors();

      if (mapController != null) {
        mapController!.animateCamera(CameraUpdate.newLatLng(initialPosition));
      }
    } else {
      if (!mounted) return;
      Future.delayed(Duration.zero, () {
        if (!mounted) return;
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text("Location Required"),
            content: const Text(
                "Please enable location to view vendors near you."),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text("OK"),
              ),
            ],
          ),
        );
      });
    }
  }

  Future<void> fetchNearbyVendors() async {
    final String url =
        "https://maps.googleapis.com/maps/api/place/nearbysearch/json"
        "?location=${initialPosition.latitude},${initialPosition.longitude}"
        "&radius=5000" // 5km radius
        "&type=event"
        "&keyword=wedding OR decoration OR banquet OR event hall"
        "&key=$apiKey";

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      if (data["status"] == "OK") {
        List results = data["results"];

        setState(() {
          vendors = results;
          markers = _createMarkers(results);
        });
      } else {
        debugPrint("Google Places API Error: ${data["status"]}");
      }
    } else {
      debugPrint("Failed to load vendors: ${response.statusCode}");
    }
  }

  void callVendor(String placeId) async {
    // Get phone number from Place Details API
    final String url =
        "https://maps.googleapis.com/maps/api/place/details/json"
        "?place_id=$placeId"
        "&fields=formatted_phone_number"
        "&key=$apiKey";

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final phone = data["result"]?["formatted_phone_number"];

      if (phone != null) {
        final Uri telUrl = Uri(scheme: 'tel', path: phone);
        if (await canLaunchUrl(telUrl)) {
          await launchUrl(telUrl);
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Phone number not available")),
        );
      }
    }
  }

  Set<Marker> _createMarkers(List vendorsList) {
    return vendorsList.map((v) {
      return Marker(
        markerId: MarkerId(v['place_id']),
        position: LatLng(
          v['geometry']['location']['lat'],
          v['geometry']['location']['lng'],
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
        infoWindow: InfoWindow(
          title: v['name'],
          snippet: v['vicinity'],
          onTap: () => callVendor(v['place_id']),
        ),
      );
    }).toSet();
  }

  void showVendorList() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          expand: false,
          builder: (context, scrollController) {
            return ListView.builder(
              controller: scrollController,
              itemCount: vendors.length,
              padding: const EdgeInsets.all(12),
              itemBuilder: (context, index) {
                final v = vendors[index];
                return Card(
                  color: lightColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  margin: const EdgeInsets.only(bottom: 12),
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          v['name'],
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: primaryColor,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          v['vicinity'] ?? "",
                          style: TextStyle(color: secondaryColor),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            ElevatedButton.icon(
                              onPressed: () => callVendor(v['place_id']),
                              icon: const Icon(Icons.call),
                              label: const Text("Call Vendor"),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primaryColor,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.location_pin,
                                  color: secondaryColor, size: 28),
                              onPressed: () {
                                Navigator.pop(context);
                                mapController?.animateCamera(
                                  CameraUpdate.newLatLng(
                                    LatLng(
                                      v['geometry']['location']['lat'],
                                      v['geometry']['location']['lng'],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: initialPosition,
              zoom: 12,
            ),
            markers: markers,
            onMapCreated: (controller) {
              mapController = controller;
              if (locationLoaded) {
                controller.animateCamera(
                    CameraUpdate.newLatLng(initialPosition));
              }
            },
            myLocationEnabled: true,
          ),

          // Floating list button
          Positioned(
            top: 40,
            right: 20,
            child: FloatingActionButton(
              onPressed: showVendorList,
              backgroundColor: primaryColor,
              child: const Icon(Icons.list, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
