import 'dart:ffi';
import 'package:geolocator/geolocator.dart';
import 'package:test1/page-1/party_addons.dart';
import 'package:test1/page-1/user_bookings.dart';
import 'bottom_nav.dart';
import 'location_service.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import '../config.dart';
import '../utils.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'customer_support.dart';



class sound_booking extends StatefulWidget {

  String? isteam;
  late  List<Map<String, dynamic>> selectedItems;
  late  List<Map<String, dynamic>> selectedkits;
  sound_booking({this.isteam, this.selectedItems = const [], this.selectedkits= const[]});
  @override
  _SoundBookingState createState() => _SoundBookingState();
}

class _SoundBookingState extends State<sound_booking> {

  DateTime? selectedDate; // Define selectedDate variable here
  bool isContainerTapped = false;
  String? selectedFromTime;
  String? selectedFromTimeBack;
  String? selectedToTimeBack;
  String? name;
  String? team_name;
  String? price;
  String? amount;
  double? netAmount;
  String? image;
  String? orderId;
  int? hours;
  int? minutes;
  late String fcm_token;
  late double? latitude;
  late double? longitude;
  final FocusNode locationFocusNode = FocusNode();
  String? selectedToTime;
  double? artistPrice = 10.0;
  String? crowdSize;
  double? soundSystemPrice = 0.0;
  bool hasSoundSystem = true;
  final storage = FlutterSecureStorage();
  late Map<String, dynamic> equipments;
  double? totalAmount = 0.0;
  String? selectedAudienceSize;
  late double totalEquipmentCost;
  double? baseEquipmentPrice;
  late Map<String, dynamic> baseEquipment;
  LocationService _locationService = LocationService();
  bool _isButtonLoading=false;
  late Razorpay _razorpay;
  // bool remove = true;
  // Place this outside the build method in your widget tree

  // ValueNotifier<String?> selectedAudienceSize = ValueNotifier<String?>(null);

  // Define TextEditingController instances
  TextEditingController nameController = TextEditingController();

  // TextEditingController selectedAudienceSize = TextEditingController();
  TextEditingController durationController = TextEditingController();
  TextEditingController locationController = TextEditingController();
  TextEditingController specialRequestController = TextEditingController();
  TextEditingController fromTimeController = TextEditingController();
  TextEditingController toTimeController = TextEditingController();
  String? selectedCategory;
  String? razorpayKey;
  List<String> categories = [
    'House party',
    'Corporate event',
    'Wedding events',
    'School or College fest',
    'Cultural or Art Exhibitions',
    'Festival',
    'Birthday party',
    'Private booking',
    'Baby showers',
    'Private Dinners',
    'others'
  ]; // Replace with your actual categories


  @override
  void initState() {
    super.initState();
    _razorpay = Razorpay();

    // Set up listeners
    // Set up listeners with context closure
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, (PaymentSuccessResponse response) {
      _handlePaymentSuccess(context, response);
    });
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
    razorpayKeyFetch();
  }



  //rzp_test_Hb4hFCm46361XC
  void razorpayKeyFetch() async {

    // Example URL, replace with your actual API endpoint
    String apiUrl = '${Config().apiDomain}/razorpay/info';

    try {
      // Make PATCH request to the API
      var response = await http.post(
        Uri.parse(apiUrl),
        headers: <String, String>{
          'Content-Type': 'application/vnd.api+json',
          'Accept': 'application/vnd.api+json',

        },
      );

      // Check if request was successful (status code 200)
      if (response.statusCode == 200) {
        Map<String,dynamic> key=jsonDecode(response.body);
        setState(() {
          razorpayKey= key['razorpayKey'];
        });
        // User information saved successfully, handle response if needed
        print('razorpaykey fetched successfully $razorpayKey');
        // Example response handling
        print('Response: ${response.body}');
      } else {
        // Request failed, handle error
        print('Failed to fetch razorpaykey. Status code: ${response.statusCode}');
        // Example error handling
        print('Error response: ${response.body}');
      }
    } catch (e) {
      // Handle network errors
      print('Error fetching razorpaykey: $e');
    }
  }



  void _saveUserInformation() async {

    Future<String?> _getUserId() async {
      return await storage.read(key: 'user_id');
    }
    String? id = await _getUserId();

    print(id);
    // Example URL, replace with your actual API endpoint
    String apiUrl = '${Config().apiDomain}/info/$id';

    // Prepare data to send to the backend
    Map<String, dynamic> userData = {
      'first_name': nameController.text,
    };

    try {
      // Make PATCH request to the API
      var response = await http.patch(
        Uri.parse(apiUrl),
        headers: <String, String>{
          'Content-Type': 'application/vnd.api+json',
          'Accept': 'application/vnd.api+json',

        },
        body: jsonEncode(userData),
      );

      // Check if request was successful (status code 200)
      if (response.statusCode == 200) {
        // User information saved successfully, handle response if needed
        print('User information saved successfully');
        // Example response handling
        print('Response: ${response.body}');
      } else {
        // Request failed, handle error
        print('Failed to save user information. Status code: ${response.statusCode}');
        // Example error handling
        print('Error response: ${response.body}');
      }
    } catch (e) {
      // Handle network errors
      print('Error saving user information: $e');
    }
  }


  double? calculateTotalPrice() {
    // Start with base sound system price
    double? totalPrice = soundSystemPrice;

    if (widget.selectedkits != null && widget.selectedkits.isNotEmpty) {
      for (var kit in widget.selectedkits) {
        if (kit.containsKey('price')) {
          try {
            String priceString = kit['price'].toString();
            if (priceString.contains('/per piece')) {
              priceString = priceString.split('/per piece')[0];
            }
            print('mohit $priceString');
            totalPrice = totalPrice! + double.parse(priceString);
          } catch (e) {
            print('Error parsing price: ${kit['price']}');
            // Handle the error appropriately
          }
        }
      }
    }

    if (widget.selectedItems != null && widget.selectedItems.isNotEmpty) {
      for (var kit in widget.selectedItems) {
        if (kit.containsKey('price') && kit.containsKey('quantity')) {
          try {
            // Extract and clean the price string
            String priceString = kit['price'].toString();
            if (priceString.contains('/per piece')) {
              priceString = priceString.split('/per piece')[0];
            }

            // Parse the price to double
            double price = double.parse(priceString.trim());

            // Extract the quantity, ensuring it is a valid number
            int quantity = int.tryParse(kit['quantity'].toString()) ?? 1;

            // Calculate total price for the current item and add to totalPrice
            totalPrice =  totalPrice! + price * quantity;
          } catch (e) {
            print('Error parsing price or quantity: ${e.toString()}');
            // Handle the error appropriately
          }
        }
      }
    }
      totalPrice = totalPrice!;


    // // Update netAmount state
    setState(() {
      netAmount = totalPrice;
    });

    print(widget.selectedItems);
    print('njbjknkn ${widget.selectedkits}');

    return totalPrice;
  }


  void calculateDuration() {
    if (selectedFromTimeBack != null && selectedToTimeBack != null) {
      DateFormat dateFormat = DateFormat('yyyy-MM-dd HH:mm:ss');
      DateTime fromTime = dateFormat.parse(selectedFromTimeBack!);
      DateTime toTime = dateFormat.parse(selectedToTimeBack!);

      // If toTime is on the next day and before fromTime, add 24 hours to toTime
      if (toTime.isBefore(fromTime)) {
        toTime = toTime.add(Duration(days: 1));
      }

      Duration duration = toTime.difference(fromTime);

      // Additional validation to ensure we don't get negative duration
      if (duration.isNegative) {
        // Reset times and show error
        setState(() {
          selectedFromTimeBack = null;
          durationController.text = "Please select valid time range";
          hours = 0;
          minutes = 0;
        });

        // You might want to show a snackbar or alert to inform the user
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Please select a "From" time that is before the "To" time'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
      } else {
        // Valid duration - update the UI
        setState(() {
          durationController.text = "${duration.inHours} hours ${duration.inMinutes.remainder(60)} minutes";
          hours = duration.inHours;
          minutes = duration.inMinutes.remainder(60);
        });
      }

      print('Hours: $hours');
      print('Minutes: $minutes');
    }
  }

  Future<String> calculateTotalAmount(String pricePerHour, int? hours,
      int? minutes) async {
    // Convert total time to hours
    if (hours == null || minutes == null) return '0';

    double totalTimeInHours = hours + (minutes / 60.0);

    // Convert pricePerHour to double
    double pricePerHourDouble = double.tryParse(pricePerHour) ?? 0.0;

    // double? sound_price=sound_system_price?.toDouble();
    // Calculate the total amount
    double totalAmount = totalTimeInHours * pricePerHourDouble;

    // Format the amount to two decimal places
    String formattedAmount = totalAmount.toStringAsFixed(2);

    return formattedAmount;
  }




  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(DateTime
          .now()
          .year + 5),
      // Use builder to customize the date picker dialog
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(
              primary: Color(0xffe5195e), // Change primary color
              onPrimary: Colors.white, // Change text color on primary color
              surface: Colors.white, // Change background color
              onSurface: Colors.black, // Change text color on background color
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Color(0xffe5195e), // Change button text color
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (pickedDate != null && pickedDate != selectedDate) {
      setState(() {
        selectedDate = pickedDate;
        print(selectedDate);
      });
    }
  }

  void toggleSoundSystem() {
    setState(() {
      if (hasSoundSystem) {
        // If sound system is already added, subtract its price
        netAmount = netAmount!  - soundSystemPrice!;
      } else {
        // If sound system is not added, add its price
        netAmount = netAmount! + soundSystemPrice! ;
      }
      // Toggle the hasSoundSystem state
      hasSoundSystem = !hasSoundSystem;
    });
  }


  @override
  Widget build(BuildContext context) {
    double baseWidth = 390;
    double fem = MediaQuery
        .of(context)
        .size
        .width / baseWidth;
    double ffem = fem * 0.97;

    final kit = widget.selectedkits.isNotEmpty ? widget.selectedkits[0] : null;
    final items= widget.selectedItems.isNotEmpty ? widget.selectedItems[0] : null;

    final String name = kit?['name'] ?? items?['name'] ?? '';
    final String image = kit?['image'] ?? items?['image'] ?? '';
    // final int price = kit?['price'] ?? items?['price'] ?? 0;
    final bool hasMoreItems = (widget.selectedkits.length > 1 || widget.selectedItems.length > 1 || widget.selectedkits.length+widget.selectedItems.length > 1);

    return Scaffold(
      appBar: AppBar(
        title: Text('Book  Equipments',
          style: SafeGoogleFont('Be Vietnam Pro', color: Colors.black,
              fontWeight: FontWeight.w500, fontSize: 21 * fem),
        ),
        leading: IconButton(color: Colors.black,
          icon: Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () {
            // Use Navigator.pop() to close the current screen (Scene2) and go back to the previous screen (Scene1)
            Navigator.pop(context);
          },
        ),
      ),
      body: SafeArea(
        child: Container(
          width: double.infinity,
          child: Container(
            // depth0frame0uCT (9:1570)
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              color: Color(0xffffffff),
            ),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
              Container(
              padding: EdgeInsets.fromLTRB(16 * fem, 0 * fem, 0 * fem, 1 * fem),
              width: double.infinity,
              height: 148.66 * fem,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    margin: EdgeInsets.only(right: 10 * fem),
                    width: 110 * fem,
                    height: 130 * fem,
                    decoration: BoxDecoration(
                      color: Colors.grey,
                      shape: BoxShape.circle,
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10 * fem),
                      child: Image.network(
                        image,
                        width: 110 * fem,
                        height: 130 * fem,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),

                  Container(
                    margin: EdgeInsets.only(left: 10 * fem),
                    padding: EdgeInsets.only(top: 30 * fem),
                    width: 222.61 * fem,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: SafeGoogleFont(
                            'Be Vietnam Pro',
                            fontSize: 19 * ffem,
                            fontWeight: FontWeight.w500,
                            height: 1.5 * ffem / fem,
                            color: Color(0xff1e0a11),
                          ),
                        ),

                        // Text(
                        //   '₹ $price' ,
                        //   style: SafeGoogleFont(
                        //     'Be Vietnam Pro',
                        //     fontSize: 17 * ffem,
                        //     fontWeight: FontWeight.w400,
                        //     height: 1.5 * ffem / fem,
                        //     color: Color(0xffa53a5e),
                        //   ),
                        // ),
                        SizedBox(height: 4),
                        // "+more" Icon
                        if (hasMoreItems)
                          GestureDetector(
                            onTap: () {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: Text('Selected Equipment'),
                                    content: SingleChildScrollView(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          ...widget.selectedkits.map((kit) {
                                            final quantity = kit['quantity'] ?? 1;
                                            return ListTile(
                                              leading: Image.network(
                                                kit['image'] ?? '',
                                                width: 40,
                                                height: 40,
                                                fit: BoxFit.cover,
                                              ),
                                              title: Text('${kit['name'] ?? ''}'),
                                              subtitle: Text('Quantity: $quantity'),
                                            );
                                          }).toList(),
                                          ...widget.selectedItems.map((item) {
                                            final quantity = item['quantity'] ?? 1;
                                            return ListTile(
                                              leading: Image.network(
                                                item['image'] ?? '',
                                                width: 40,
                                                height: 40,
                                                fit: BoxFit.cover,
                                              ),
                                              title: Text('${item['name'] ?? ''}'),
                                              subtitle: Text('Quantity: $quantity'),
                                            );
                                          }).toList(),
                                        ],
                                      ),
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                        },
                                        child: Text('Close'),
                                      ),
                                    ],
                                  );
                                },
                              );
                              // Action to show more kits (e.g., navigate to a new page)
                            },
                            child: Row(
                              children: [
                                Icon(Icons.more_horiz, color: Colors.black),
                                SizedBox(width: 10),
                                Text(
                                  '+ More equipments',
                                  style: SafeGoogleFont(
                                    'Be Vietnam Pro',
                                    fontSize: 15 * ffem,
                                    fontWeight: FontWeight.w400,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        SizedBox(height: 4),
                        Text(
                          '₹${calculateTotalPrice()
                              ?.toStringAsFixed(2)}' ,
                          style: SafeGoogleFont(
                            'Be Vietnam Pro',
                            fontSize: 17 * ffem,
                            fontWeight: FontWeight.w400,
                            height: 1.5 * ffem / fem,
                            color: Color(0xffa53a5e),
                          ),
                        ),
                      ],
                    ),
                  ),

                ],
              ),
            ),
                  Container(
                    // autogroupe7afD43 (JkRkRPf57vHepTRWamE7AF)
                    padding: EdgeInsets.fromLTRB(
                        16 * fem, 20 * fem, 16 * fem, 12 * fem),
                    width: double.infinity,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          margin: EdgeInsets.fromLTRB(0 * fem, 0 * fem, 0 * fem,
                              16 * fem),
                          child: TextFormField(
                            controller: nameController,
                            // TextEditingController for name input
                            decoration: InputDecoration(
                              contentPadding: EdgeInsets.symmetric(
                                  vertical: 17.0, horizontal: 12.0),
                              hintText: 'Enter Your Name',
                              hintStyle: SafeGoogleFont(
                                'Be Vietnam Pro',
                                fontSize: 16 * ffem,
                                fontWeight: FontWeight.w400,
                                height: 1.5 * ffem / fem,
                                color: Color(0xff1e0a11),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12 * fem),
                                borderSide: BorderSide(
                                    width: 1.25, color: Color(0xffeac6d3)),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12 * fem),
                                borderSide: BorderSide(
                                    width: 1.25, color: Color(0xffe5195e)),
                              ),
                            ),
                            style: SafeGoogleFont(
                              'Be Vietnam Pro',
                              fontSize: 16 * ffem,
                              fontWeight: FontWeight.w500,
                              height: 1.5 * ffem / fem,
                              color: Color(0xff1e0a11),
                            ),
                          ),
                        ),

                        Container(
                          margin: EdgeInsets.fromLTRB(0 * fem, 0 * fem, 0 * fem,
                              16 * fem),
                          child: DropdownButtonFormField<String>(
                            value: selectedCategory,
                            hint: Text(
                              'Select Event Category',
                              style: SafeGoogleFont(
                                'Be Vietnam Pro',
                                fontSize: 16 * ffem,
                                fontWeight: FontWeight.w400,
                                height: 1.5 * ffem / fem,
                                color: Color(0xff1e0a11),
                              ),
                            ),
                            items: categories.map((String category) {
                              return DropdownMenuItem<String>(
                                value: category,
                                child: Text(
                                  category,
                                  style: SafeGoogleFont(
                                    'Be Vietnam Pro',
                                    fontSize: 16 * ffem,
                                    fontWeight: FontWeight.w400,
                                    height: 1.5 * ffem / fem,
                                    color: Color(0xff1e0a11),
                                  ),
                                ),
                              );
                            }).toList(),
                            onChanged: (newValue) {
                              setState(() {
                                selectedCategory = newValue;
                              });
                            },
                            decoration: InputDecoration(
                              contentPadding: EdgeInsets.symmetric(
                                  vertical: 17.0, horizontal: 12.0),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12 * fem),
                                borderSide: BorderSide(
                                    width: 1.25, color: Color(0xffeac6d3)),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12 * fem),
                                borderSide: BorderSide(
                                    width: 1.25, color: Color(0xffe5195e)),
                              ),
                            ),
                          ),
                        ),

                        Container(
                          margin: EdgeInsets.fromLTRB(0 * fem, 0 * fem, 0 * fem,
                              16 * fem),
                          child: DropdownButtonFormField<String>(
                            value: selectedAudienceSize,
                            // Store the selected audience size
                            hint: Text(
                              'Your Audience Size',
                              style: SafeGoogleFont(
                                'Be Vietnam Pro',
                                fontSize: 16 * ffem,
                                fontWeight: FontWeight.w400,
                                height: 1.5 * ffem / fem,
                                color: Color(0xff1e0a11),
                              ),
                            ),
                            items: [
                              '1-10',
                              '1-30',
                              '1-50',
                              '1-70',
                              '1-100',
                              'More than 100',
                              'More than 500'
                            ].map((String size) {
                              return DropdownMenuItem<String>(
                                value: size,
                                child: Text(
                                  size,
                                  style: SafeGoogleFont(
                                    'Be Vietnam Pro',
                                    fontSize: 16 * ffem,
                                    fontWeight: FontWeight.w500,
                                    height: 1.5 * ffem / fem,
                                    color: Color(0xff1e0a11),
                                  ),
                                ),
                              );
                            }).toList(),
                            onChanged: (newValue) {
                              setState(() {
                                selectedAudienceSize = newValue!;
                              });
                              // if (selectedAudienceSize != null) {
                              //   getSoundSystemPrice(selectedAudienceSize!);
                              // }
                            },
                            decoration: InputDecoration(
                              contentPadding: EdgeInsets.symmetric(
                                  vertical: 17.0, horizontal: 12.0),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12 * fem),
                                borderSide: BorderSide(
                                    width: 1.25, color: Color(0xffeac6d3)),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12 * fem),
                                borderSide: BorderSide(
                                    width: 1.25, color: Color(0xffe5195e)),
                              ),
                            ),
                          ),
                        ),

                      ],
                    ),
                  ),
                  Container(
                    // autogroupe7afD43 (JkRkRPf57vHepTRWamE7AF)
                    padding: EdgeInsets.fromLTRB(
                        16 * fem, 7 * fem, 16 * fem, 12 * fem),
                    width: double.infinity,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          // datetimevj9 (9:1606)
                          margin: EdgeInsets.fromLTRB(0 * fem, 0 * fem, 0 * fem,
                              15 * fem),
                          child: Text(
                            'Date & Time',
                            style: SafeGoogleFont(
                              'Be Vietnam Pro',
                              fontSize: 22 * ffem,
                              fontWeight: FontWeight.w700,
                              height: 1.25 * ffem / fem,
                              letterSpacing: -0.3300000131 * fem,
                              color: Color(0xff1e0a11),
                            ),
                          ),
                        ),
                        Container(
                          // depth3frame0ppX (9:1609)
                          margin: EdgeInsets.fromLTRB(0 * fem, 0 * fem, 0 * fem,
                              14 * fem),
                          width: double.infinity,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [

                              Container(
                                margin: EdgeInsets.fromLTRB(
                                    0 * fem, 0 * fem, 0 * fem, 8 * fem),
                                width: double.infinity,
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      isContainerTapped = !isContainerTapped;
                                    });
                                    _selectDate(context);
                                  },
                                  child: Container(
                                    height: 54 * fem,
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: isContainerTapped ? Color(
                                            0xffe5195e) : Color(0xffeac6d3),
                                      ),
                                      borderRadius: BorderRadius.circular(
                                          12 * fem),
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment
                                          .spaceBetween,
                                      children: [
                                        Padding(
                                          padding: EdgeInsets.fromLTRB(
                                              10 * fem, 0, 10 * fem, 0),
                                          child: Text(
                                            selectedDate != null
                                                ? '${selectedDate!
                                                .day}/${selectedDate!
                                                .month}/${selectedDate!.year}'
                                                : 'Choose Event Date',
                                            style: TextStyle(
                                              fontSize: 16 * ffem,
                                              color: Color(0xff1e0a11),
                                            ),
                                          ),
                                        ),
                                        Row(
                                          children: [
                                            SizedBox(width: 16 * fem),
                                            // Add some space to shift the icon to the left
                                            Icon(
                                              Icons.calendar_today,
                                              color: isContainerTapped ? Color(
                                                  0xffe5195e) : Color(
                                                  0xffeac6d3),
                                            ),
                                            SizedBox(width: 8 * fem),
                                            // Adjust space if needed to balance the layout
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: 14 * fem,
                              ),
                              Container(
                                margin: EdgeInsets.fromLTRB(
                                    0 * fem, 0 * fem, 0 * fem, 12 * fem),
                                child: Text(
                                  'Select Time   (From-To)',
                                  style: SafeGoogleFont(
                                    'Be Vietnam Pro',
                                    fontSize: 17 * ffem,
                                    fontWeight: FontWeight.w500,
                                    height: 1.5 * ffem / fem,
                                    color: Color(0xff1e0a11),
                                  ),
                                ),
                              ),

                              Row(
                                children: [
                                  Container(
                                    width: 165 * fem,
                                    height: 56 * fem,
                                    child: TextField(
                                      controller: fromTimeController,
                                      onTap: () async {
                                        final TimeOfDay? pickedTime = await showTimePicker(
                                          context: context,
                                          initialTime: TimeOfDay.now(),
                                          builder: (context, child) {
                                            return Theme(
                                              data: Theme.of(context).copyWith(
                                                colorScheme: ColorScheme.light(
                                                  primary: Color(0xffe5195e),
                                                  // Change primary color (clock hands and header)
                                                  onPrimary: Colors.white,
                                                  // Change text color on the primary color (header text)
                                                  surface: Colors.white,
                                                  // Change the clock background color
                                                  onSurface: Colors
                                                      .black, // Change the numbers color (clock text)
                                                ),
                                                textButtonTheme: TextButtonThemeData(
                                                  style: TextButton.styleFrom(
                                                    foregroundColor: Color(
                                                        0xffe5195e), // Change the button text color (OK/Cancel)
                                                  ),
                                                ),
                                              ),
                                              child: child!,
                                            );
                                          },
                                        );

                                        if (pickedTime != null) {
                                          setState(() {
                                            // Store the selected time in selectedFromTime variable
                                            selectedFromTime =
                                                pickedTime.format(context);
                                            String formattedDate = DateFormat(
                                                'yyyy-MM-dd').format(
                                                selectedDate!);
                                            selectedFromTimeBack =
                                            '$formattedDate ${pickedTime
                                                .hour}:${pickedTime.minute}:00';
                                            fromTimeController.text =
                                                selectedFromTime ??
                                                    ''; // Update the text field
                                          });
                                        }
                                        calculateDuration();
                                      },
                                      decoration: InputDecoration(
                                        contentPadding: EdgeInsets.symmetric(
                                            vertical: 17.0, horizontal: 12.0),
                                        suffixIcon: Icon(Icons.access_time,
                                            color: Color(0xffeac6d3)),
                                        hintText: 'From',
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                              12 * fem),
                                          borderSide: BorderSide(width: 1.25,
                                              color: Color(0xffeac6d3)),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                              12 * fem),
                                          borderSide: BorderSide(width: 1.25,
                                              color: Color(0xffe5195e)),
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 25,
                                  ),
                                  Container(
                                    width: 165 * fem,
                                    height: 56 * fem,
                                    child: TextField(
                                      controller: toTimeController,
                                      onTap: () async {
                                        final TimeOfDay? pickedTime = await showTimePicker(
                                          context: context,
                                          initialTime: TimeOfDay.now(),
                                          builder: (context, child) {
                                            return Theme(
                                              data: Theme.of(context).copyWith(
                                                colorScheme: ColorScheme.light(
                                                  primary: Color(0xffe5195e),
                                                  // Change primary color (clock hands and header)
                                                  onPrimary: Colors.white,
                                                  // Change text color on the primary color (header text)
                                                  surface: Colors.white,
                                                  // Change the clock background color
                                                  onSurface: Colors
                                                      .black, // Change the numbers color (clock text)
                                                ),
                                                textButtonTheme: TextButtonThemeData(
                                                  style: TextButton.styleFrom(
                                                    foregroundColor: Color(
                                                        0xffe5195e), // Change the button text color (OK/Cancel)
                                                  ),
                                                ),
                                              ),
                                              child: child!,
                                            );
                                          },
                                        );

                                        if (pickedTime != null) {
                                          setState(() {
                                            // Store the selected time in selectedToTime variable
                                            selectedToTime =
                                                pickedTime.format(context);
                                            // Format the selected date and time
                                            String formattedDate = DateFormat(
                                                'yyyy-MM-dd').format(
                                                selectedDate!);
                                            selectedToTimeBack =
                                            '$formattedDate ${pickedTime
                                                .hour}:${pickedTime.minute}:00';
                                            toTimeController.text =
                                                selectedToTime ??
                                                    ''; // Update the text field// Calculate duration whenever "To" time is selected
                                          });
                                          calculateDuration();
                                        }
                                      },
                                      decoration: InputDecoration(
                                        contentPadding: EdgeInsets.symmetric(
                                            vertical: 17.0, horizontal: 12.0),
                                        suffixIcon: Icon(Icons.access_time,
                                            color: Color(0xffeac6d3)),
                                        hintText: 'To',
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                              12 * fem),
                                          borderSide: BorderSide(width: 1.25,
                                              color: Color(0xffeac6d3)),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                              12 * fem),
                                          borderSide: BorderSide(width: 1.25,
                                              color: Color(0xffe5195e)),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                            ],
                          ),
                        ),
                        Container(
                          width: double.infinity,
                          height: 56 * fem,
                          child: TextField(
                            controller: durationController,
                            // Connect the controller here
                            decoration: InputDecoration(
                              contentPadding: EdgeInsets.symmetric(
                                  vertical: 17.0, horizontal: 12.0),
                              hintText: 'Event Duration',
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12 * fem),
                                borderSide: BorderSide(
                                    width: 1.25, color: Color(0xffeac6d3)),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12 * fem),
                                borderSide: BorderSide(
                                    width: 1.25, color: Color(0xffe5195e)),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 18 * fem),

                        Container(
                          margin: EdgeInsets.only(bottom: 10.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Event Location',
                                style: SafeGoogleFont(
                                  'Be Vietnam Pro',
                                  fontSize: 22 * ffem,
                                  fontWeight: FontWeight.w700,
                                  height: 1.25 * ffem / fem,
                                  letterSpacing: -0.3300000131 * fem,
                                  color: Color(0xff1e0a11),
                                ),
                              ),
                              IconButton(
                                icon: Icon(
                                    Icons.edit, color: Color(0xffe5195e)),
                                onPressed: () {
                                  // Focus on the TextField to allow editing
                                  locationFocusNode.requestFocus();
                                },
                              ),
                            ],
                          ),
                        ),
                        Stack(
                          children: [
                            Container(
                              width: double.infinity,
                              constraints: BoxConstraints(
                                // minHeight: 100.0, // Set a minimum height
                              ),
                              child: InkWell(
                                onTap: () {
                                  _showLocationDialog(context);
                                },
                                child: IgnorePointer(
                                  child: TextField(
                                    controller: locationController,
                                    focusNode: locationFocusNode,
                                    maxLines: null,
                                    // This allows the TextField to grow vertically
                                    decoration: InputDecoration(
                                      contentPadding: EdgeInsets.symmetric(
                                          vertical: 17.0, horizontal: 12.0),
                                      // Adjust padding
                                      hintText: 'Full Address',
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(
                                            12.0),
                                        borderSide: BorderSide(
                                          width: 1.25,
                                          color: Color(0xffeac6d3),
                                        ),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(
                                            12.0),
                                        borderSide: BorderSide(
                                          width: 1.25,
                                          color: Color(0xffe5195e),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),


                        SizedBox(height: 15 * fem),

                        Container(
                          margin: EdgeInsets.fromLTRB(0 * fem, 0 * fem, 0 * fem,
                              24 * fem),
                          width: double.infinity,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                margin: EdgeInsets.fromLTRB(
                                    0 * fem, 0 * fem, 0 * fem, 8 * fem),
                                constraints: BoxConstraints(
                                  maxWidth: 325 * fem,
                                ),
                                child: Text(
                                  'Special Message/Request For the Artist.',
                                  style: SafeGoogleFont(
                                    'Be Vietnam Pro',
                                    fontSize: 16 * ffem,
                                    fontWeight: FontWeight.w500,
                                    height: 1.5 * ffem / fem,
                                    color: Color(0xff1e0a11),
                                  ),
                                ),
                              ),
                              Container(
                                width: double.infinity,
                                height: 56 * fem,
                                child: TextField(
                                  controller: specialRequestController,
                                  // Connect the controller here
                                  decoration: InputDecoration(
                                    contentPadding: EdgeInsets.symmetric(
                                        vertical: 17.0, horizontal: 12.0),
                                    hintText: 'Optional',
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(
                                          12 * fem),
                                      borderSide: BorderSide(width: 1.25,
                                          color: Color(0xffeac6d3)),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(
                                          12 * fem),
                                      borderSide: BorderSide(width: 1.25,
                                          color: Color(0xffe5195e)),
                                    ),
                                  ),
                                ),
                              ),
                              Container(
                                // datetimevj9 (9:1606)
                                margin: EdgeInsets.fromLTRB(
                                    0 * fem, 25 * fem, 0 * fem, 0 * fem),
                                child: Text(
                                  'Payment Information',
                                  style: SafeGoogleFont(
                                    'Be Vietnam Pro',
                                    fontSize: 22 * ffem,
                                    fontWeight: FontWeight.w700,
                                    height: 1.25 * ffem / fem,
                                    letterSpacing: -0.3300000131 * fem,
                                    color: Color(0xff1e0a11),
                                  ),
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.fromLTRB(
                                    0, 10 * fem, 0, 20 * fem),
                                child: RichText(
                                  text: TextSpan(
                                    text: 'Questions on cancellations or refunds? See our ',
                                    style: TextStyle(
                                      fontStyle: FontStyle.italic,
                                      // Italic style for the entire text
                                      fontSize: 16.0,
                                      color: Colors.black,
                                    ),
                                    children: [
                                      TextSpan(
                                        text: 'FAQ',
                                        style: TextStyle(
                                          fontStyle: FontStyle.italic,
                                          color: Colors.blue,
                                          // Blue color for the button
                                          decoration: TextDecoration.underline,
                                        ),
                                        recognizer: TapGestureRecognizer()
                                          ..onTap = () {
                                            // Navigate to FAQ screen
                                            Navigator.push(context,
                                                MaterialPageRoute(builder:
                                                    (context) =>
                                                    SupportScreen())

                                            );
                                          },
                                      ),
                                      TextSpan(
                                        text: ' or ',
                                      ),
                                      TextSpan(
                                        text: 'Refund Policy',
                                        style: TextStyle(
                                          fontStyle: FontStyle.italic,
                                          color: Colors.blue,
                                          // Blue color for the button
                                          decoration: TextDecoration.underline,
                                        ),
                                        recognizer: TapGestureRecognizer()
                                          ..onTap = () {
                                            // storeSoundEquipment();
                                            // Navigate to Refund Policy screen
                                            Navigator.push(context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        SupportScreen()));
                                          },
                                      ),
                                      TextSpan(
                                        text: '.',
                                      ),
                                    ],
                                  ),
                                ),
                              ),


                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [

                                  // Row(
                                  //   mainAxisAlignment: MainAxisAlignment
                                  //       .spaceBetween,
                                  //   children: [
                                  //     Text(
                                  //       'Total Price for the artist:',
                                  //       style: TextStyle(fontSize: 17.0,
                                  //           fontWeight: FontWeight.w600),
                                  //     ),
                                  //     Text(
                                  //       '₹${totalAmount}',
                                  //       style: TextStyle(fontSize: 17.0,
                                  //           fontWeight: FontWeight.w600),
                                  //     ),
                                  //   ],
                                  // ),
                                  // SizedBox(height: 10.0),


                                  Column(
                                    children: [
                                      // Row for Sound System Price: Show only if `hasSoundSystem` is false
                                      if (hasSoundSystem)
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment
                                              .start,
                                          children: [
                                            // Sound System Price Row
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment
                                                  .spaceBetween,
                                              children: [
                                                Text(
                                                  'Sound system price:',
                                                  style: TextStyle(
                                                    fontSize: 17.0,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                                Text(
                                                  '₹${calculateTotalPrice()
                                                      ?.toStringAsFixed(2)}',
                                                  style: TextStyle(
                                                    fontSize: 17.0,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            SizedBox(height: 01.0),
                                            // Space between price and "See what's included"
                                            // See What's Included Row

                                          ],
                                        ),


                                      SizedBox(height: 3.0),

                                      // Row for toggle button and message

                                    ],
                                  ),
                                  SizedBox(height: 5.0),


                                  Divider(thickness: 1, color: Colors.grey),

                                  SizedBox(height: 10.0),

                                  Row(
                                    mainAxisAlignment: MainAxisAlignment
                                        .spaceBetween,
                                    children: [
                                      Text(
                                        'Total Amount Payable:',
                                        style: TextStyle(fontSize: 17.0,
                                            fontWeight: FontWeight.w600),
                                      ),
                                      Text(
                                        '₹${netAmount?.toStringAsFixed(2) ??
                                            '0.00'}',
                                        style: TextStyle(fontSize: 17.0,
                                            fontWeight: FontWeight.w600),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment
                                        .spaceBetween,
                                    children: [
                                      Text(
                                        '(Includes all the taxes)',
                                        style: TextStyle(fontSize: 16.0,),
                                      ),
                                    ],),
                                ],

                              )
                            ],


                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 25, right: 25),
                          child: ElevatedButton(
                            onPressed: () async {
                              // Validation checks
                              if (selectedCategory == null ||
                                  selectedAudienceSize == null ||
                                  selectedDate == null ||
                                  fromTimeController.text.isEmpty ||
                                  toTimeController.text.isEmpty ||
                                  durationController.text.isEmpty ||
                                  locationController.text.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Please fill in all the required fields')),
                                );
                                return;
                              }

                              try {
                                setState(() {
                                  _isButtonLoading = true;
                                });

                                String? orderId = await createOrder(netAmount!);

                                if (orderId == null) {
                                  throw Exception('Failed to create order');
                                }

                                var options = {
                                  'key': razorpayKey,
                                  'amount': netAmount! * 100, // amount should be in paise
                                  'name': 'PrimeStage',
                                  'order_id': orderId,
                                  'description': 'artist book',
                                  'timeout': 120,
                                  'prefill': {
                                    'contact': 'user_contact',  // Add user's phone if available
                                    'email': 'user_email',      // Add user's email if available
                                  },
                                  'theme': {
                                    'color': '#e5195e',
                                  }
                                };

                                WidgetsBinding.instance.addPostFrameCallback((_) {
                                  _razorpay.open(options);
                                  print('updated code');
                                });

                              } catch (e) {
                                print('Error during payment: $e');
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Payment initialization failed')),
                                );
                                setState(() {
                                  _isButtonLoading = false;
                                });
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xffe5195e),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            ),
                            child: _isButtonLoading
                                ? CircularProgressIndicator(
                              color: Colors.white,
                            )
                                : Center(
                              child: Text(
                                'Proceed To Payment',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),


                ],


              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showLocationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(backgroundColor: Color(0xfffff5f8),
          title: Text('Event Location'),
          content: Text('How would you like to enter the Event Location?',
            style: TextStyle(fontSize: 16),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                latitude = null;
                longitude = null;
                Navigator.of(context).pop();
                _showManualEntryDialog(context);
              },
              child: Text(
                'Enter Manually', style: TextStyle(color: Colors.black),),
            ),
            ElevatedButton(
              onPressed: () async {
                if (!mounted) return; // Check if the widget is still mounted

                // Show a loading indicator
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (context) =>
                      Center(
                        child: CircularProgressIndicator(), // Display a loading spinner
                      ),
                );

                try {
                  // Fetch current location and address
                  Map<String, dynamic> locationData = await _locationService
                      .getCurrentLocationAndAddress();
                  latitude = locationData['latitude'];
                  longitude = locationData['longitude'];
                  String address = locationData['address'];

                  // Update the state only if the widget is still mounted
                  if (mounted) {
                    setState(() {
                      locationController.text = address;
                    });
                  }

                  print("Latitude: $latitude");
                  print("Longitude: $longitude");
                  print("Current address: $address");
                } catch (e) {
                  // Handle any errors, and show a message if needed
                  print(e);
                } finally {
                  // Ensure the loading spinner is removed, only if the widget is still mounted
                  if (mounted && Navigator.canPop(context)) {
                    Navigator.of(context).pop(); // Close the loading spinner
                  }
                }
                // Close any modal that is open, such as a dialog
                if (Navigator.canPop(context)) {
                  Navigator.of(context).pop();
                }
              },
              child: const Text(
                'Use current location',
                style: TextStyle(color: Colors.black),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showManualEntryDialog(BuildContext context) {
    TextEditingController flatController = TextEditingController();
    TextEditingController areaController = TextEditingController();
    TextEditingController cityController = TextEditingController();
    TextEditingController stateController = TextEditingController();
    TextEditingController pincodeController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(backgroundColor: Color(0xfffff5f8),
          title: Text('Enter Address Manually'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: flatController,
                  decoration: InputDecoration(
                      hintText: 'Apartment/House No,  Building'),
                ),
                TextField(
                  controller: areaController,
                  decoration: InputDecoration(hintText: 'Area, Street, Sector'),
                ),
                TextField(
                  controller: cityController,
                  decoration: InputDecoration(hintText: 'City'),
                ),
                TextField(
                  controller: stateController,
                  decoration: InputDecoration(hintText: 'State'),
                ),
                TextField(
                  controller: pincodeController,
                  decoration: InputDecoration(hintText: 'Pincode'),
                ),
              ],
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () async {
                locationController.text =
                "${flatController.text}, ${areaController
                    .text}, ${cityController.text}, ${stateController
                    .text}, ${pincodeController.text}";
                Position position = await _locationService
                    .getLocationFromAddress(pincodeController.text);
                latitude = position.latitude;
                longitude = position.longitude;

                print('lat is layinh $latitude');
                print('lot is $longitude');
                Navigator.of(context).pop();
              },
              child: Text('OK', style: TextStyle(color: Colors.black),),
            ),
          ],
        );
      },
    );
  }

  Future<String?> createOrder(double totalAmount) async {
    // Convert totalAmount to int and multiply by 100
    int totalAmountInCents = (totalAmount * 100).toInt();
    // Initialize API URLs for different kinds
    String apiUrl = '${Config().apiDomain}/order';
    try {
      var uri = Uri.parse(apiUrl).replace(
          queryParameters: {'amount': totalAmountInCents.toString()});
      var response = await http.get(
        uri,
        headers: <String, String>{
          'Content-Type': 'application/vnd.api+json',
          'Accept': 'application/vnd.api+json',
          // 'Authorization': 'Bearer $token', // Include the token in the header
        },
      );
      if (response.statusCode == 201) {
        // Parse the response JSON
        Map<String, dynamic> orderResponse = json.decode(response.body);

        orderId = orderResponse['order_id'];
        print(orderId);
        return orderId;
      } else {
        print('Failed to create order. Status code: ${response.body}');
      }
    } catch (e) {
      print('Error creating order: $e');
    }
    return null;
  }


  Future<Object> _saveBookingInformation() async {
    final storage = FlutterSecureStorage();


    // Future<String?> _getArtist_id() async {
    //   return await storage.read(key: 'artist_id'); // Assuming you stored the token with key 'token'
    // }
// Separate lists for equipment details
    List<String> equipmentNames = [];
    List<int> equipmentPrices = [];
    List<dynamic> equipmentQuantities = [];

    // Process `selectedkits`
    for (var kit in widget.selectedkits) {
      equipmentNames.add(kit['name']);
      equipmentPrices.add(kit['price']);
      equipmentQuantities.add(kit['quantity']);
    }

    // Process `selectedItems`
    for (var item in widget.selectedItems) {
      equipmentNames.add(item['name']);
      equipmentPrices.add(item['price']);
      equipmentQuantities.add(1); // Default quantity as 1 for main items

      // If `includedItems` exists, process them
      if (item['includedItems'] != null) {
        for (var includedItem in item['includedItems']) {
          equipmentNames.add(includedItem['name']);
          equipmentPrices.add(0); // Assume price for included items is 0
          equipmentQuantities.add(includedItem['quantity']);
        }
      }
    }

    print('Equipment Names: $equipmentNames');
    print('Equipment Prices: $equipmentPrices');
    print('Equipment Quantities: $equipmentQuantities');


    Future<String?> _getToken() async {
      return await storage.read(key: 'token');
    }
    Future<String?> _getUserId() async {
      return await storage.read(key: 'user_id');
    }

    String? token = await _getToken();
    String? user_id = await _getUserId();

    // String? artist_id = await _getArtist_id();
    String? apiUrl='${Config().apiDomain}/book-equipments';

    Map<String, dynamic> bookingData = { // Only set team_id if isteam is true
    'item_names':jsonEncode(equipmentNames),
      'quantities':jsonEncode(equipmentQuantities),
      'per_unit_price':jsonEncode(equipmentPrices),
      'user_id': user_id,
      'booking_date': selectedDate != null ? selectedDate.toString() : null,
      'booked_from':  selectedFromTimeBack ?? '',
      'booked_to':  selectedToTimeBack ?? '',
      'duration': durationController.text,
      'audience_size': selectedAudienceSize,
      'location': locationController.text,
      'longitude': longitude,
      'latitude': latitude,
      'special_request': specialRequestController.text,
      'category':selectedCategory,
      'total_price': netAmount,
      'status':0,
      // 'audience_size':selectedAudienceSize,
    };



    try {
      // Make PATCH request to the API
      var response = await http.post(
        Uri.parse(apiUrl),
        headers: <String, String>{
          'Content-Type': 'application/vnd.api+json',
          'Accept': 'application/vnd.api+json',
          'Authorization': 'Bearer $token', // Include the token in the header
        },
        body: jsonEncode(bookingData),
      );
      print(bookingData);

      // Check if request was successful (status code 200)
      if (response.statusCode == 201) {
        // User information saved successfully, handle response if needed
        print('Booking information saved successfully');

        Map<String, dynamic> responseData = jsonDecode(response.body);
        int id = responseData['id'];

// Store the token securely
        await storage.write(key: 'booking_id', value: id.toString());
        print(id);
        // Example response handling
        print('Response: ${response.body}');
        return id;
      } else {
        // Request failed, handle error
        print('Failed to save booking information. Status code: ${response.statusCode}');
        // Example error handling
        print('Error response: ${response.body}');
        return false;
      }
    } catch (e) {
      // Handle network errors
      print('Error saving user information: $e');
    }
    return false;
  }


  void _handlePaymentError(PaymentFailureResponse response) {
    setState(() {
      _isButtonLoading = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Payment Failed: ${response.message ?? 'Error occurred'}')),
    );
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    setState(() {
      _isButtonLoading = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('External Wallet Selected: ${response.walletName}')),
    );
  }

  Future<void> _handlePaymentSuccess(BuildContext context,
      PaymentSuccessResponse response) async {
    try {

      setState(() {
        _isButtonLoading = false;
      });

      // Extract the payment details
      String razorpayPaymentId = response.paymentId!;
      String razorpayOrderId = response.orderId!;
      String razorpaySignature = response.signature!;
      String? bookingId;
      _saveUserInformation();

       try {
        bookingId = (await _saveBookingInformation()).toString();
         if (bookingId == null || bookingId.isEmpty) {
          throw Exception('Failed to save booking information');
         }
       } catch (e) {
         // Handle booking save error
         ScaffoldMessenger.of(context).showSnackBar(
             SnackBar(content: Text('Error saving booking: $e')));
         return;
       }

      // Send the payment details to the server
      // try {
      //   // await _sendPaymentDetailsToServer(razorpayPaymentId, razorpayOrderId, razorpaySignature, bookingId);
      // } catch (e) {
      //   // Handle payment sending error
      //   ScaffoldMessenger.of(context).showSnackBar(
      //       SnackBar(content: Text('Error sending payment details: $e')));
      //   return;
      // }

      // First reset the cache variables wherever they are defined (likely in your UserBookings page)
      isCacheLoaded = false;
      cachedData = null;
      // Navigate to the booked page on success
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              BottomNav(
                  initialPageIndex: 2, // Set the index to 2 for UserBookings
                  isteam: widget.isteam // Pass any required data if needed
              ),
        ),
      );


      // Send notification
      // sendNotification(context, fcm_token);

    } catch (e) {
      // Handle any other unexpected errors
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Payment handling error: $e')));
    }

    Future<void> selectDate(BuildContext context) async {
      final DateTime? pickedDate = await showDatePicker(
        context: context,
        initialDate: selectedDate ?? DateTime.now(),
        firstDate: DateTime.now(),
        lastDate: DateTime(DateTime
            .now()
            .year + 5),
      );
      if (pickedDate != null && pickedDate != selectedDate) {
        setState(() {
          selectedDate = pickedDate;
        });
      }
    }
  }
}