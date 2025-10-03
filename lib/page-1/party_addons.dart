import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:test1/page-1/phone_varification.dart';
import 'package:test1/page-1/sound_booking.dart';
import '../config.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'artist_booking.dart';


class CustomizeSoundSystemPage extends StatefulWidget {
  final String? sourceScreen;
   CustomizeSoundSystemPage({
    this.sourceScreen,
   });
  @override
  _CustomizeSoundSystemPageState createState() =>
      _CustomizeSoundSystemPageState();
}

class _CustomizeSoundSystemPageState extends State<CustomizeSoundSystemPage> {
  final List<Map<String, dynamic>> items = [

  ];
 int totalSelectedKits=0;
  final storage = FlutterSecureStorage();
  final List<Map<String, dynamic>> selectedkits = [];
  List<Map<String, dynamic>> selectedItems = [];
  bool _isLoading = true; // To track the loading state

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    await fetchEquipmentsAndKits();
    setState(() {
      _isLoading = false; // Update the loading state once data is fetched
    });
  }

  final List<Map<String, dynamic>> plans = [

    // },
  ];

  Future<void> fetchEquipmentsAndKits() async {
     String apiUrl = '${Config().apiDomain}/equipments-and-kits'; // Replace with your API endpoint

    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // Extract and print equipments
        List<dynamic> equipments = data['equipments'];
        // print('Equipments: $equipments');
        // Update the `items` list
        items.addAll(equipments.map((equipment) {
          return {
            'name': equipment['name'],
            'price': equipment['price'],
            'quantity': equipment['quantity'],
            'image': equipment['image'],
          };
        }).toList());
         print(items);
        // Extract and print kits
        List<dynamic> kits = data['kits'];
        print('Kits:');
        // Update the `plans` list
        plans.addAll(kits.map((kit) {
          return {
            'name': kit['name'],
            'price': kit['price'],
            'image': kit['image'],
            'includedItems': kit['includedItems'].map((item) {
              return {
                'name': item['name'],
                'quantity': item['quantity'],
                'image': item['image'],
              };
            }).toList(),
          };
        }).toList());

        // TODO: Update the state of your Flutter app with this data
      } else {
        print('Failed to fetch data. Status Code: ${response.statusCode}');
      }
    } catch (error) {
      print('Error fetching data: $error');
    }
  }

  void showFullScreenImage(String imagePath) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: GestureDetector(
            onTap: () {
              Navigator.of(context).pop();
            },
            child: Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(imagePath),
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void showPlanDetailsDialog(Map<String, dynamic> plan) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  plan['name'],
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    plan['image'],
                    height: 150,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                SizedBox(height: 20),
                Expanded(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: plan['includedItems'].length,
                    itemBuilder: (context, index) {
                      final item = plan['includedItems'][index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8.0),
                              child: Image.network(
                                item['image'],
                                width: 80,
                                height: 90,
                                fit: BoxFit.cover,
                              ),
                            ),
                            SizedBox(width: 16),
                            Expanded(
                              child: Text(
                                '${item['name']} \n(${item['quantity']})',
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xffe5195e),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                  ),
                  child: Text(
                    'OK',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget buildPlanCard(Map<String, dynamic> plan) {
    return StatefulBuilder(
      builder: (context, setState) {
        bool isAdded = plan['isAdded'] ?? false;

        return GestureDetector(
          onTap: () => showPlanDetailsDialog(plan), // Dialog box functionality retained
          child: Container(
            width: 180,
            height: 270,
            child: Card(
              shadowColor: Color(0xFFE9E8E6),
              elevation: 5,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  ClipRRect(
                    borderRadius:
                    BorderRadius.vertical(top: Radius.circular(12.0)),
                    child: Image.network(
                      plan['image'],
                      height: 120,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    plan['name'],
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    '₹${plan['price']}',
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.grey,
                    ),
                  ),
                  SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () {
                      // setState(() {
                      //   plan['isAdded'] = !isAdded;
                      //   isAdded = plan['isAdded'];
                      // });

                      setState(() {
                        plan['isAdded'] = !isAdded;
                        isAdded = plan['isAdded'];

                        // Add or remove from selected plans list
                        if (isAdded) {
                          selectedkits.add(plan);

                        } else {
                          selectedkits.removeWhere(
                                  (selectedPlan) => selectedPlan['name'] == plan['name']);
                        }
                      });
                      // Update totalSelectedKits
                      setState(() {
                        totalSelectedKits = selectedkits.length;
                      });
                      print('kit ius $totalSelectedKits');
                      print(selectedkits);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                      isAdded ? Colors.green : Color(0xffe5195e),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      minimumSize: Size(100, 35), // Adjusted button dimensions
                      padding: EdgeInsets.symmetric(vertical: 5.0), // Padding
                    ),
                    child: Text(
                      isAdded ? 'Added' : 'Add',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15, // Adjust font size for better fit
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    int totalQuantity = selectedItems.fold(0, (sum, item) => sum + item['quantity'] as int);
    totalSelectedKits = selectedkits.length;
    return Scaffold(
      backgroundColor: Color(0xFFF7F6F4),
      appBar: AppBar(
        title: Text(
          'Event Addons',
          style: TextStyle(
            color: Colors.black,
            fontSize: 22,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios, // iOS back arrow icon
            color: Colors.black,   // Color of the back arrow
          ),
          onPressed: () {
            Navigator.pop(context); // Pop the current screen and go back
          },
        ),
      ),


      body: Column(
        children: [
          // Large image at the top
          Container(
            width: double.infinity,
            height: 180,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/page-1/images/83fa6f8303937819459f41b4e3e97ac3 2.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Heading for Horizontal Plan Cards
          Expanded(
            child: ListView(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(18, 20, 0, 5),
                  child: Text(
                    'Pick a Complete Setup for Your Event',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                // Horizontal Plan Cards
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: plans.map((plan) {
                      return Container(
                        margin: EdgeInsets.only(right: 0),
                        child: buildPlanCard(plan),
                      );
                    }).toList(),
                  ),
                ),
                // Heading for Vertical Item Cards
                Padding(
                  padding: const EdgeInsets.fromLTRB(18, 20, 0, 0),
                  child: Text(
                    'Select Only What You Need for Your Event',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                // Vertical Item Cards
                ...items.map((item) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 0, horizontal: 0),
                    child: Card(
                      shadowColor: Color(0xFFE9E8E6),
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      elevation: 5,
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Row(
                          children: [
                            GestureDetector(
                              onTap: () {
                                showFullScreenImage(item['image']);
                              },
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12.0),
                                child: Image.network(
                                  item['image'],
                                  width: 115,
                                  height: 125,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            SizedBox(width: 18),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item['name'],
                                    style: TextStyle(
                                      fontSize: 19,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  SizedBox(height: 3),
                                  Text(
                                    '₹${item['price']}',
                                    style: TextStyle(
                                      fontSize: 17,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  SizedBox(height: 9),
                                  Row(
                                    children: [
                                      ElevatedButton(
                                        onPressed: () {
                                          setState(() {
                                            if (item['quantity'] > 0) {
                                              item['quantity']--;
                                            }
                                            if (item['quantity'] == 0) {
                                              selectedItems.remove(item);
                                            }
                                          });
                                        },
                                        style: ElevatedButton.styleFrom(
                                          minimumSize: Size(32, 32),
                                          backgroundColor: Color(0xFFFFF0F2),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                            BorderRadius.circular(12),
                                          ),
                                        ),
                                        child: Text(
                                          '-',
                                          style: TextStyle(
                                            fontSize: 23,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xffe5195e),
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        width: 40,
                                        child: Center(
                                          child: Text(
                                            '${item['quantity']}',
                                            style: TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.w600),
                                          ),
                                        ),
                                      ),
                                      ElevatedButton(
                                        onPressed: () {
                                          setState(() {
                                            item['quantity']++;
                                            if (item['quantity'] > 0) {
                                              if (!selectedItems.contains(item)) {
                                                selectedItems.add(item);
                                              }
                                            }
                                          });
                                          print(selectedItems);
                                        },
                                        style: ElevatedButton.styleFrom(
                                          minimumSize: Size(32, 32),
                                          backgroundColor: Color(0xFFFFF0F2),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                            BorderRadius.circular(12),
                                          ),
                                        ),
                                        child: Text(
                                          '+',
                                          style: TextStyle(
                                            fontSize: 23,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xffe5195e),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(40, 10, 40, 30),
            child: ElevatedButton(
              onPressed: () async {
                String? isSignedUp=await storage.read(key: 'user_signup');
                print('mohit is cool $isSignedUp');
                if(isSignedUp=='true') {
                  if (widget.sourceScreen == 'bookingpage') {
                    Navigator.of(context).pop({
                      'selectedItems': selectedItems,
                      'selectedKits': selectedkits,
                    });
                  } else {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => sound_booking(
                          selectedItems: selectedItems,
                          selectedkits: selectedkits,
                        ),
                      ),
                    );
                  }
                } else {
                  await storage.write(key: 'soundpage', value:'true');

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          PhoneNumberInputScreen(
                            selectedItems: selectedItems,
                            selectedkits: selectedkits,
                          ),
                    ),
                  );
                }


                // if (widget.sourceScreen == 'bookingpage') {
                //   Navigator.of(context).pop({
                //     'selectedItems': selectedItems,
                //     'selectedKits': selectedkits,
                //   });
                // } else {
                //   Navigator.push(
                //     context,
                //     MaterialPageRoute(
                //       builder: (context) => sound_booking(
                //         selectedItems: selectedItems,
                //         selectedkits: selectedkits,
                //       ),
                //     ),
                //   );
                // }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xffe5195e),
                padding: EdgeInsets.symmetric(vertical: 10.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
              ),
              child: Center(
                child: Column(
                  children: [
                    // Row(
                    //   children: [
                        Text(
                          'ADD',
                          style: TextStyle(color: Colors.white, fontSize: 18),
                        ),
                    //   ],
                    // ),
                    // SizedBox(height: 5),
                    // Row(
                    //   children: [
                        Text(
                          'Individual Items: $totalQuantity',
                          style: TextStyle(color: Colors.white, fontSize: 14),
                        ),
                    //   ],
                    // ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
