import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';

import '../config.dart';

class LocationService {
  Future<Position> getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error('Location permissions are permanently denied.');
    }

    return await Geolocator.getCurrentPosition();
  }

  Future<Map<String, dynamic>> getCurrentLocationAndAddress() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Check if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    // Check location permissions
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error('Location permissions are permanently denied.');
    }

    // Get current position (latitude and longitude)
    Position position = await Geolocator.getCurrentPosition();

    // Get the address from the coordinates
    List<Placemark> placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);

    String currentAddress = 'No address available';
    if (placemarks.isNotEmpty) {
      Placemark place = placemarks[0];

      // Construct the address
      currentAddress =
      '${place.street}, ${place.locality}, ${place.administrativeArea} ${place.postalCode}, ${place.country}';
    }

    // Return latitude, longitude, and the current address
    return {
      'latitude': position.latitude,
      'longitude': position.longitude,
      'address': currentAddress,
    };
  }






  Future<Position> getLocationFromAddress(String address) async {
    final response = await http.get(Uri.parse('https://nominatim.openstreetmap.org/search?q=$address&format=json&limit=1'));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      if (data.isNotEmpty) {
        double lat = double.parse(data[0]['lat']);
        double lon = double.parse(data[0]['lon']);
        // Example of creating a Position object using the constructor
        Position position = Position(
          latitude: lat,
          longitude: lon,
          timestamp: DateTime.now(),
          accuracy: 0.0, // Provide appropriate values based on your use case
          altitude: 0.0, // Provide appropriate values based on your use case
          altitudeAccuracy: 0.0, // Provide appropriate values based on your use case
          heading: 0.0, // Provide appropriate values based on your use case
          headingAccuracy: 0.0, // Provide appropriate values based on your use case
          speed: 0.0, // Provide appropriate values based on your use case
          speedAccuracy: 0.0, // Provide appropriate values based on your use case
          floor: null, // Optional parameter, can be null if not needed
          isMocked: false, // Optional parameter, default is false
        );

        return position;
      } else {
        throw Exception('Location not found for address: $address');
      }
    } else {
      throw Exception('Failed to fetch location data');
    }
  }


  Future<bool> isServiceAvailable(Position position) async {
    // Make an HTTP request to your server to check service availability
    // Example URL: https://example.com/check_service?lat=${position.latitude}&lng=${position.longitude}
    // Assume the server returns a boolean indicating service availability

    final storage = FlutterSecureStorage();

    await storage.write(key: 'latitude', value: position.latitude.toString());
    await storage.write(key: 'longitude', value: position.longitude.toString());


    final response = await http.get(Uri.parse('${Config().apiDomain}/check_service?lat=${position.latitude}&lng=${position.longitude}'));

    if (response.statusCode == 200) {
      print('Response Body: ${response.body}');
      final Map<String, dynamic> responseBody = json.decode(response.body);
      if (responseBody.containsKey('serviceAvailable')) {
        return responseBody['serviceAvailable'];
      } else {
        throw Exception('Unexpected response format');
      }
    } else {
      throw Exception('Failed to check service availability');
    }
  }
}
