import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../config.dart';
import 'location_service.dart';
import 'bottom_nav.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';


class ServiceCheckerPage extends StatefulWidget {
  @override
  _ServiceCheckerPageState createState() => _ServiceCheckerPageState();
}

class _ServiceCheckerPageState extends State<ServiceCheckerPage> {
  late Position _currentPosition;
  TextEditingController textEditingController = TextEditingController();
  late bool _serviceAvailable;
  LocationService _locationService = LocationService();

  @override
  void initState()  {
    super.initState();
    _currentPosition = Position(
      latitude: 0.0,
      longitude: 0.0,
      timestamp: DateTime.now(),
      accuracy: 0.0,
      altitude: 0.0,
      altitudeAccuracy: 0.0,
      heading: 0.0,
      headingAccuracy: 0.0,
      speed: 0.0,
      speedAccuracy: 0.0,
    ); // Initial position
    _serviceAvailable = false; // Initial service availability

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showInitialDialog();
    });


  }

  Future<void> useCurrentLocation() async {
    // Show loading spinner while fetching location
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(child: CircularProgressIndicator()),
    );

    try {
      _currentPosition = await _locationService.getCurrentLocation();
      print(_currentPosition);
      _serviceAvailable = await _locationService.isServiceAvailable(_currentPosition);
      print(_serviceAvailable);
      // Update the UI after the location and service check are completed
      setState(() {});

      // Dismiss the loading spinner
      Navigator.of(context).pop();

      // Navigate if the service is available
      if (_serviceAvailable) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => BottomNav()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Service not available in your regions.'),
        ));
      }
    } catch (error) {
      Navigator.of(context).pop(); // Dismiss the loading spinner
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Error: $error'),
      ));
    }
  }
  Future<bool> convertAddressToLatLng(String address) async {
    // Show loading spinner while converting address to LatLng
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(child: CircularProgressIndicator()),
    );

    try {
      // Hardcoded latitude and longitude values based on city
      Map<String, Map<String, double>> cityCoordinates = {
        'Chandigarh': {'latitude': 30.7333, 'longitude': 76.7794},
        'New Chandigarh': {'latitude': 30.7951, 'longitude': 76.8483},
        'Panchkula': {'latitude': 30.6942, 'longitude': 76.8606},
        'Mohali': {'latitude': 30.7046, 'longitude': 76.7179},
        'Zirakpur': {'latitude': 30.6425, 'longitude': 76.8173},
        'Landran': {'latitude': 30.6835, 'longitude': 76.6599},
        'Kharar': {'latitude': 30.7459, 'longitude': 76.6459},
      };

      // Use the hardcoded values instead of calling the service
      if (cityCoordinates.containsKey(address)) {
        double latitude = cityCoordinates[address]!['latitude']!;
        double longitude = cityCoordinates[address]!['longitude']!;

        print('Latitude: $latitude, Longitude: $longitude');
        print('moghit here');
        // You can still use your service availability check if needed
        LocationService locationService = LocationService();

        Position position = Position(
          latitude: latitude,
          longitude: longitude,
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

        _serviceAvailable = await locationService.isServiceAvailable(position);
        print(_serviceAvailable);

        Navigator.of(context).pop(); // Dismiss the loading spinner

        if (_serviceAvailable) {
          return true;
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Service not available in your region.'),
          ));
          return false;
        }
      } else {
        // If city is not in our hardcoded list
        Navigator.of(context).pop(); // Dismiss the loading spinner
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('City coordinates not available.'),
        ));
        return false;
      }
    } catch (e) {
      Navigator.of(context).pop(); // Dismiss the loading spinner
      print('Error processing coordinates: $e');
      return false;
    }
  }


  // Future<void> convertAddressToLatLng(String textEditingController) async {
  //   try {
  //     LocationService locationService = LocationService();
  //     Position position = await locationService.getLocationFromAddress(
  //         textEditingController);
  //     print('Latitude: ${position.latitude}, Longitude: ${position.longitude}');
  //     _serviceAvailable = await _locationService.isServiceAvailable(position);
  //     print(_serviceAvailable);
  //     if (_serviceAvailable) {
  //       Navigator.pushReplacement(
  //         context,
  //         MaterialPageRoute(builder: (context) => BottomNav(data: {},)),
  //       );
  //     } else {
  //       ScaffoldMessenger.of(context).showSnackBar(SnackBar(
  //         content: Text('Service not available in your region.'),
  //       ));
  //     }
  //     // Now you can use the latitude and longitude for further operations
  //   } catch (e) {
  //     print('Error converting address to coordinates: $e');
  //     // Handle error accordingly
  //   }
  // }

  void _showInitialDialog() {
    TextEditingController cityController = TextEditingController();
    List<String> citySuggestions = ['Chandigarh','New Chandigarh','Panchkula','Mohali', 'Zirakpur', 'Landran','Kharar']; // Add more cities as needed
    String? selectedCity;
    bool isLoading = false; // To control the loading state

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder( // Use StatefulBuilder to manage loading state inside dialog
          builder: (context, setState) {
            double fem = ScalingUtil.getFem(context);
            return AlertDialog(
              title: Padding(
                padding:  EdgeInsets.fromLTRB(5*fem, 20*fem, 5*fem, 0),
                child: Text(
                  'Let’s Find Out If We’re Near You!',
                  style: TextStyle(fontSize: 19*fem, fontWeight: FontWeight.w500, color: Colors.white),
                ),
              ),
              content: Container(
                constraints: BoxConstraints(
                  maxWidth: 350*fem, // Adjust width here
                  maxHeight: 200*fem, // Adjust height here
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    DropdownButtonFormField<String>(
                      value: selectedCity,
                      dropdownColor: Color(0xFF292938),
                      style: TextStyle(color: Colors.white, fontSize: 18*fem),
                      items: citySuggestions.map((String city) {
                        return DropdownMenuItem<String>(
                          value: city,
                          child: Text(city),
                        );
                      }).toList(),
                      decoration: InputDecoration(
                        hintText: 'Select City',
                        hintStyle: TextStyle(color: Color(0xFF9E9EB8)),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFF9E9EB8)),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                        ),
                      ),
                      onChanged: (String? newCity) {
                        setState(() {
                          selectedCity = newCity;
                          cityController.text = newCity ?? '';
                        });
                      },
                    ),
                    SizedBox(height: 18*fem),
                    // Center(child: Text('OR',style: TextStyle(fontSize: 18,color: Colors.white),)),
                    // SizedBox(height: 18*fem),
                    // Padding(
                    //   padding:  EdgeInsets.fromLTRB(0, 0, 0, 35*fem),
                    //   child: TextButton(
                    //     onPressed: () async {
                    //       await useCurrentLocation();
                    //       Navigator.pop(context); // Close dialog
                    //     },
                    //     style: TextButton.styleFrom(
                    //       backgroundColor: Colors.white, // Change color here
                    //       padding: EdgeInsets.symmetric(vertical: 11), // Adjust height here
                    //       shape: RoundedRectangleBorder(
                    //         borderRadius: BorderRadius.circular(11), // Adjust corner radius here
                    //       ),
                    //     ),
                    //     child: Text(
                    //       'Use Current Location',
                    //       style: TextStyle(fontSize: 16, color: Colors.black),
                    //     ),
                    //   ),
                    // ),
                  ],
                ),
              ),
              actions: <Widget>[
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context); // Close the current dialog
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white, // Button background color
                    padding: EdgeInsets.symmetric(vertical: 7*fem, horizontal: 30*fem), // Adjust padding
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12), // Rounded corners for button
                    ),
                  ),
                  child: Text('Cancel', style: TextStyle(color: Colors.black,fontSize: 16*fem)),
                ),
                SizedBox(width: 2,),

                ElevatedButton(
                  onPressed: () async {
                    if (mounted) {
                      setState(() {
                        isLoading = true; // Show loading spinner
                      });
                    }

                    bool serviceAvailable = await convertAddressToLatLng(cityController.text);

                    if (mounted) {
                      Navigator.pop(context, {'city': selectedCity}); // Close the dialog
                    }

                    if (serviceAvailable) {
                      if (mounted) {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => BottomNav()),
                        );
                      }
                    } else {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text('Service not available in your region.'),
                        ));
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xffe5195e), // Button background color
                    padding: EdgeInsets.symmetric(vertical: 10, horizontal: 30), // Adjust padding
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14), // Rounded corners for button
                    ),
                  ),
                  child: isLoading
                      ? SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      color: Colors.black,
                      strokeWidth: 2,
                    ),
                  )
                      : Text('OK', style: TextStyle(color: Color(0xffffffff),fontSize: 16)),
                ),
              ],
              backgroundColor: Color(0xFF292938), // Change dialog background color here
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(22), // Adjust corner radius of dialog here
              ),
            );
          },
        );
      },
    );
  }
  // void _showPincodeOrCityDialog() {
  //   TextEditingController pincodeController = TextEditingController();
  //   TextEditingController cityController = TextEditingController();
  //
  //   List<String> citySuggestions = ['Chandigarh', 'Delhi', 'Mumbai', 'Pune']; // Add more cities as needed
  //   String? selectedCity;
  //
  //   showDialog(
  //     context: context,
  //     builder: (BuildContext context) {
  //       return StatefulBuilder(
  //         builder: (BuildContext context, StateSetter setState) {
  //           return AlertDialog(
  //             title: Text(
  //               'Please Enter Your PINCODE or City Name',
  //               style: TextStyle(
  //                   fontWeight: FontWeight.w500, fontSize: 19, color: Colors.white),
  //             ),
  //             content: Container(
  //               width: 350, // Adjust width here
  //               height: 250, // Adjust height here to fit two text fields
  //               child: Column(
  //                 mainAxisSize: MainAxisSize.min,
  //                 children: [
  //                   // Pincode TextField
  //                   TextField(
  //                     controller: pincodeController,
  //                     decoration: InputDecoration(
  //                       hintText: 'Enter PINCODE',
  //                       hintStyle: TextStyle(color: Color(0xFF9E9EB8)),
  //                       enabledBorder: UnderlineInputBorder(
  //                         borderSide: BorderSide(color: Color(0xFF9E9EB8)), // Color when not focused
  //                       ),
  //                       focusedBorder: UnderlineInputBorder(
  //                         borderSide: BorderSide(color: Colors.white), // Color when focused
  //                       ),
  //                     ),
  //                     style: TextStyle(color: Colors.white, fontSize: 18),
  //                     textInputAction: TextInputAction.done,
  //                     onChanged: (value) {
  //                       setState(() {
  //                         pincodeController.text = value;
  //                       });
  //                     },
  //                   ),
  //                   SizedBox(height: 20), // Add spacing between input fields
  //                   // City Dropdown TextField
  //                   DropdownButtonFormField<String>(
  //                     value: selectedCity,
  //                     dropdownColor: Color(0xFF292938),
  //                     style: TextStyle(color: Colors.white, fontSize: 18),
  //                     items: citySuggestions.map((String city) {
  //                       return DropdownMenuItem<String>(
  //                         value: city,
  //                         child: Text(city),
  //                       );
  //                     }).toList(),
  //                     decoration: InputDecoration(
  //                       hintText: 'Select City',
  //                       hintStyle: TextStyle(color: Color(0xFF9E9EB8)),
  //                       enabledBorder: UnderlineInputBorder(
  //                         borderSide: BorderSide(color: Color(0xFF9E9EB8)),
  //                       ),
  //                       focusedBorder: UnderlineInputBorder(
  //                         borderSide: BorderSide(color: Colors.white),
  //                       ),
  //                     ),
  //                     onChanged: (String? newCity) {
  //                       setState(() {
  //                         selectedCity = newCity;
  //                         cityController.text = newCity ?? '';
  //                       });
  //                     },
  //                   ),
  //                 ],
  //               ),
  //             ),
  //             backgroundColor: Color(0xFF292938), // Change dialog background color here
  //             shape: RoundedRectangleBorder(
  //               borderRadius: BorderRadius.circular(22), // Rounded corners for dialog box
  //             ),
  //             actions: <Widget>[
  //               ElevatedButton(
  //                 onPressed: () {
  //                   setState(() {
  //                     pincodeController.clear();
  //                     cityController.clear(); // Clear both text fields
  //                   });
  //                   Navigator.pop(context); // Close the current dialog
  //                   _showInitialDialog(); // Show the previous dialog
  //                 },
  //                 style: ElevatedButton.styleFrom(
  //                   backgroundColor: Colors.white, // Button background color
  //                   padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20), // Adjust padding
  //                   shape: RoundedRectangleBorder(
  //                     borderRadius: BorderRadius.circular(14), // Rounded corners for button
  //                   ),
  //                 ),
  //                 child: Text('Cancel', style: TextStyle(color: Colors.black)),
  //               ),
  //               ElevatedButton(
  //                 onPressed: () {
  //                   // Handle validation or further actions here
  //                   // convertAddressToLatLng(pincodeController.text);
  //                   convertAddressToLatLng(cityController.text);
  //                   setState(() {
  //                     pincodeController.clear();
  //                     cityController.clear(); // Clear both text fields
  //                   });
  //                   Navigator.pop(context, {
  //                     'pincode': pincodeController.text,
  //                     'city': selectedCity,
  //                   }); // Pass both pincode and selected city
  //                 },
  //                 style: ElevatedButton.styleFrom(
  //                   backgroundColor: Colors.white, // Button background color
  //                   padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20), // Adjust padding
  //                   shape: RoundedRectangleBorder(
  //                     borderRadius: BorderRadius.circular(14), // Rounded corners for button
  //                   ),
  //                 ),
  //                 child: Text('OK', style: TextStyle(color: Colors.black)),
  //               ),
  //             ],
  //           );
  //         },
  //       );
  //     },
  //   );
  // }


  final storage = FlutterSecureStorage();




  // // Define your function here
  // Future<void> sendLocationToBackend() async {
  //   Future<String?> _getId() async {
  //     return await storage.read(
  //         key: 'user_id'); // Assuming you stored the token with key 'token'
  //   }
  //   Future<String?> _getLatitude() async {
  //     return await storage.read(
  //         key: 'latitude'); // Assuming you stored the token with key 'token'
  //   }
  //   Future<String?> _getLongitude() async {
  //     return await storage.read(
  //         key: 'longitude'); // Assuming you stored the token with key 'token'
  //   }
  //   String? id = await _getId();
  //   String? latitude = await _getLatitude();
  //   String? longitude = await _getLongitude();
  //
  //   Map<String, dynamic> requestBody = {
  //     'latitude': latitude,
  //     'longitude': longitude,
  //
  //   };
  //   print('request body is :$requestBody');
  //   String serverUrl = '${Config().apiDomain}/info/$id';
  //
  //   try {
  //     var response = await http.patch(
  //       Uri.parse(serverUrl),
  //       headers: {'Content-Type': 'application/vnd.api+json',
  //         'Accept': 'application/vnd.api+json',},
  //       body: json.encode(requestBody),
  //     );
  //
  //     if (response.statusCode == 200) {
  //       debugPrint('location stored successfully.');
  //     } else {
  //       debugPrint(
  //           'Failed to store location. Status code: ${response.statusCode}');
  //       debugPrint('Failed to store location. Status code: ${response.body}');
  //     }
  //   } catch (e) {
  //     debugPrint('Error storing location: $e');
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    double fem = ScalingUtil.getFem(context);
    return Scaffold(
      backgroundColor: Colors.black,

      body: Padding(
        padding: EdgeInsets.fromLTRB(38.0*fem,200*fem,38*fem,0*fem), // Adjust padding value as needed
        child: SingleChildScrollView(
          child: Column(

            children: [
              // Image above the text
              Image.asset(
                'assets/page-1/images/guitaristloc.jpg', // Path to your image
                height: 200*fem, // Adjust height as needed
                width: 220*fem, // Adjust width as needed
                fit: BoxFit.contain, // Adjust how the image fits
              ),
              SizedBox(height: 0), // Space between image and text

              // Text message
              Text(
                'Unfortunately, our service isn’t available in your area yet. We’re expanding soon!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18*fem,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 20*fem), // Space between text and button

              // "Continue Anyway" button
              ElevatedButton(
                onPressed: () async {
                  String cityController='Chandigarh';
                  bool serviceAvailable = await convertAddressToLatLng(cityController);


                  if (serviceAvailable) {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => BottomNav()),
                    );
                  }


                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white, // Change button color if needed
                  padding: EdgeInsets.symmetric(vertical: 11.5*fem, horizontal: 24*fem), // Adjust padding
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12), // Adjust corner radius
                  ),
                ),
                child: Text(
                  'Continue Anyway',
                  style: TextStyle(fontSize: 16*fem, color: Colors.black),
                ),
              ),
              SizedBox(height: 8*fem), // Space between buttons

              // "Check Location Again" button
              TextButton(
                onPressed: () {
                  _showInitialDialog(); // Reopen the initial dialog
                },
                style: TextButton.styleFrom(
                  foregroundColor: Colors.blue, // Change text color if needed
                ),
                child: Text('Check Location Again'),
              ),
            ],
          ),
        ),
      ),
    );
  }

}


class EnterPincodeOrCityPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Enter PINCODE or City Name'),
      ),
      // Implement your UI to allow entering PINCODE or CITY NAME here
      body: Center(
        child: Text('Enter PINCODE or CITY NAME screen'),
      ),
    );
  }
}

class ScalingUtil {
  // Define a base width for reference (e.g., 375 for iPhone X)
  static const double baseWidth = 375;

  // Method to calculate the scaling factor based on the screen width
  static double getFem(BuildContext context) {
    // Get the actual width of the screen
    double screenWidth = MediaQuery.of(context).size.width;
    // Calculate the scaling factor
    return screenWidth / baseWidth;
  }
}



