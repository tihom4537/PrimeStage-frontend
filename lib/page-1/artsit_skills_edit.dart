import 'package:flutter/material.dart';
import 'package:test1/page-1/worksamples_edit.dart';
import '../config.dart';
import '../utils.dart';
import 'bottomNav_artist.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'account_managment.dart';

class ArtistCredentials33 extends StatefulWidget {
  @override
  _ArtistCredentials33State createState() => _ArtistCredentials33State();
}

class _ArtistCredentials33State extends State<ArtistCredentials33> {
  TextEditingController _subskillController = TextEditingController();
  TextEditingController _experienceController = TextEditingController();
  TextEditingController _hourlyPriceController = TextEditingController();
  TextEditingController _messageController = TextEditingController();
  TextEditingController _teamExperienceController= TextEditingController();
  TextEditingController _yearsController=TextEditingController();
  TextEditingController _pastController=TextEditingController();
  bool isTeam = false; // Default value
  late List<String> currentSubSkills;

  String _selectedSkill = ''; // Variable to store the selected skill
  List<String> _skills = [
    'Singer',
    'Instrumentalist',
    'DJ',
    'Dancer',
    'Chef',
    'Magician',
    'Sketch Artist',
    'Stand-Up Comedian',
    'Anchor/MC',
    'Photographer',
    'Kids Entertainer'
  ];

  // List of skills
  String _selectedSubSkill = ''; // Variable to store the selected sub-skill
  List<String> _subSkills = []; // List of sub-skills based on the selected skill

  final storage = FlutterSecureStorage();

  Future<String?> _getToken() async {
    return await storage.read(key: 'token'); // Assuming you stored the token with key 'token'
  }
  Future<String?> _getid() async {
    return await storage.read(key: 'artist_id'); // Assuming you stored the token with key 'token'
  }
  Future<String?> _getTeamid() async {
    return await storage.read(key: 'team_id'); // Assuming you stored the token with key 'token'
  }

  Future<String?> _getKind() async {
    return await storage.read(key: 'selected_value'); // Assuming you stored the token with key 'token'
  }

  void checkTeam() async {
    String? kind = await _getKind(); // Wait for the completion of _getKind()
    if (kind != null) {
      isTeam = (kind == 'team'); // Update isTeam based on the result of _getKind()
      print(isTeam); // Print the value of isTeam
    } else {
      // Handle the case when _getKind() returns null
      print('Error: _getKind() returned null');
    }
  }


//fetch skill data
  Future<void> fetchArtistSkillInformation() async {

    String? token = await _getToken();
    String? id = await _getid();
    String? team_id = await _getTeamid();
    String? kind = await _getKind();
    // print (kind);
    // print (token);
    // print (id);





    // Initialize API URLs for different kinds
    String apiUrl;
    if (kind == 'solo_artist') {
      apiUrl = '${Config().apiDomain}/artist/info/$id';
    } else if (kind == 'team') {
      apiUrl = '${Config().apiDomain}/artist/team_info/$team_id';
    } else {
      // Handle the case where kind is not recognized
      return;
    }

    try {
      var response = await http.get(
        Uri.parse(apiUrl),
        headers: <String, String>{
          'Content-Type': 'application/vnd.api+json',
          'Accept': 'application/vnd.api+json',
          'Authorization': 'Bearer $token', // Include the token in the header
        },
      );
      if (response.statusCode == 200) {
        // Parse the response JSON
        Map<String, dynamic> userData = json.decode(response.body);
        print(userData);

        // Update text controllers with fetched data
        setState(() {
          _experienceController.text = userData['data']['attributes']['about_yourself'] ?? '';
          _hourlyPriceController.text = (userData['data']['attributes']['original_price_per_hour']).toString() ?? '';
          _messageController.text = userData['data']['attributes']['special_message'] ?? '';
          _selectedSkill = userData['data']['attributes']['skill_category'] ?? '';
          _selectedSubSkill= userData['data']['attributes']['skills'] ?? '';
          _teamExperienceController.text = userData['data']['attributes']['about_team'] ?? '';
          // _pinCodeController.text = userData['data']['attributes']['pin'] ?? '';
        });
        bool useAboutController= _teamExperienceController.text.isNotEmpty;

        TextEditingController? selectedController =
        useAboutController ? _teamExperienceController : _experienceController;
       // Assuming the text follows the pattern "X years, Y"
        String text =  selectedController?.text ?? '';
        List<String> parts = text.split(',');

// Extract years of experience
        _yearsController.text = parts[0].trim(); // "5 years"
        // int yearsOfExperience = int.parse(yearsText.split(' ')[0]); // 5

// Extract number of bookings
        _pastController.text = (parts[1].trim()); // 8

        // // After setting the state, you can call the _updateSubSkills function if needed
        _updateSubSkills(_selectedSkill);
      } else {
        print('Failed to fetch user information. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching user information: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    _selectedSkill = _skills.first; // Initialize selected skill with the first item in the list
    _updateSubSkills(_selectedSkill); // Update sub-skills based on the selected skill
    // First, let's split the subskills into a list when we receive them
    currentSubSkills = _selectedSubSkill?.split(',').map((e) => e.trim()).toList() ?? [];
    // _selectedSubSkill = _subSkills.first;
    fetchArtistSkillInformation();
  }

  void _updateSubSkills(String skill) {
    setState(() {
      _subSkills.clear(); // Clear the previous sub-skills
      switch (skill) {
        case 'Singer':
          _subSkills.addAll(['Punjabi', 'Bollywood','Devotional' 'Ghazal/Sufi','Indie/Pop','English Covers']);
          break;
        case 'Instrumentalist':
          _subSkills.addAll(['Tabla Player','Sitarist', 'Violinist', 'Guitarist','Dhol Player','Sexophone Player','Harmonium Player','Piano Player','Electronic Keyboard','Harmonica']);
          break;
        case 'DJ':
          _subSkills.addAll(['House','Techno','EDM','Hip Hop','Retro','Punjabi','Wedding DJ']);
        case 'Dancer':
          _subSkills.addAll(['Bhangra', 'Giddha','Nati', 'Fusion','Classical','Contemporary','Hip Hop',]);
          break;
        case 'Chef':
          _subSkills.addAll(['Punjabi Cuisine', 'North Indian', 'Fusion Food','Chinese','Italian','Mexican','Continental','Thai Cuisine','Japanese','Dessert Chef']);
          break;
        case 'Magician':
          _subSkills.addAll(['Stage Magician', 'Close-Up Magician', 'Mentalist']);
          break;
        case 'Sketch Artist':
          _subSkills.addAll(['Portrait Artist','Live Painting Artist','Caricature','Henna Artist']);
          break;
        case 'Stand-Up':
          _subSkills.addAll(['Mimicry Artist','Roast Comedy','Family Friendly','Punjabi Stand-Up']);
          break;
        case 'Anchor/MC':
          _subSkills.addAll(['Wedding Anchor', 'Corporate Event Host','Emcees','Emcees for Kids Event']);
          break;
        case 'Photographer':
          _subSkills.addAll(['Wedding','Event','Short film Creator']);
          break;
        case 'Kids Entertainer':
          _subSkills.addAll(['Clown','Puppet Shows']);
          break;
      }
      _selectedSubSkill = _subSkills.first; // Initialize selected sub-skill with the first item in the list
    });
  }






  @override
  Widget build(BuildContext context) {

    double baseWidth = 390;
    double fem = MediaQuery.of(context).size.width / baseWidth;
    double ffem = fem * 0.97;


    // if (_getKind()=='team');


//
    // Call the function to check the team
    checkTeam();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Edit Skills',
          textAlign: TextAlign.center,
          style: SafeGoogleFont(
            'Be Vietnam Pro',
            fontSize: 19 * ffem,
            fontWeight: FontWeight.w700,
            height: 1.25 * ffem / fem,
            letterSpacing: -0.8000000119 * fem,
            color: Color(0xff1e0a11),
          ),
        ),
        backgroundColor: Color(0xffffffff),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  color: Colors.white,
                  padding: EdgeInsets.fromLTRB(16 * fem, 12 * fem, 16 * fem, 12 * fem),
                  width: double.infinity,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: double.infinity,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [

                            // Only show the Sub-Skill field if it's not a team

                          ],
                        ),
                      ),
                      SizedBox(
                        height: 19 * fem,
                      ),
                      Container(
                        width: double.infinity,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              margin: EdgeInsets.fromLTRB(0 * fem, 0 * fem, 0 * fem, 9 * fem),
                              child: Text(
                                'Edit About Section',
                                style: SafeGoogleFont(
                                  'Plus Jakarta Sans',
                                  fontSize: 18 * ffem,
                                  fontWeight: FontWeight.w500,
                                  height: 1.5 * ffem / fem,
                                  color: Color(0xff1e0a11),
                                ),
                              ),
                            ),
                            Container(
                              width: double.infinity,
                              // Adjusted height to match the height of the outer container
                              height: 80 * fem,
                              child: TextField(
                                controller: _yearsController,
                                maxLines: null,
                                decoration: InputDecoration(
                                  hintText: 'Summary of your experience',
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12 * fem),
                                    borderSide: BorderSide(width: 1.25, color: Color(0xffeac6d3)),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12 * fem),
                                    borderSide: BorderSide(width: 1.25, color: Color(0xffe5195e)),
                                  ),
                                ),
                              ),
                            ),
                            Container(
                              margin: EdgeInsets.fromLTRB(0 * fem, 0 * fem, 0 * fem, 9 * fem),
                              child: Text(
                                'No of Previous Booking ',
                                style: SafeGoogleFont(
                                  'Plus Jakarta Sans',
                                  fontSize: 18 * ffem,
                                  fontWeight: FontWeight.w500,
                                  height: 1.5 * ffem / fem,
                                  color: Color(0xff1e0a11),
                                ),
                              ),
                            ),
                            Container(

                              width: double.infinity,
                              // Adjusted height to match the height of the outer container
                              height: 60 * fem,

                              child: TextField(
                                controller: _pastController,
                                decoration: InputDecoration(
                                  hintText: 'Total no of bookings handled before?',
                                  hintStyle: TextStyle(color:  Color(0xFF9E9EB8)),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10 * fem),
                                    borderSide: BorderSide(width: 1.25, color:Color(0xFF9E9EB8),),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10 * fem),
                                    borderSide: BorderSide(width: 1.25, color: Colors.white ),
                                  ),
                                ),
                                style: TextStyle(color: Colors.black, fontSize: 16),
                              ),
                            ),

                          ],
                        ),
                      ),
                      SizedBox(
                        height: 24 * fem,
                      ),
                      Container(
                        width: double.infinity,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              margin: EdgeInsets.fromLTRB(0 * fem, 0 * fem, 0 * fem, 3 * fem),
                              child: Text(
                                'Charges Per Hour ?',
                                style: SafeGoogleFont(
                                  'Be Vietnam Pro',
                                  fontSize: 18 * ffem,
                                  fontWeight: FontWeight.w500,
                                  height: 1.5 * ffem / fem,
                                  color: Color(0xff1e0a11),
                                ),
                              ),
                            ),
                            Container(
                              margin: EdgeInsets.fromLTRB(0 * fem, 0 * fem, 0 * fem, 8 * fem),
                              child: Text(
                                '(Please Include Transportation Charges in this Price Only)',
                                style: SafeGoogleFont(
                                  'Be Vietnam Pro',
                                  fontSize: 15 * ffem,
                                  fontWeight: FontWeight.w400,
                                  height: 1.5 * ffem / fem,
                                  color: Colors.redAccent,
                                ),
                              ),
                            ),
                            Container(
                              width: double.infinity,
                              height: 56 * fem,
                              child: TextField(
                                controller: _hourlyPriceController,
                                decoration: InputDecoration(
                                  hintText: 'Your Total Per Hour Price ',
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12 * fem),
                                    borderSide: BorderSide(width: 1.25, color: Color(0xffeac6d3)),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12 * fem),
                                    borderSide: BorderSide(width: 1.25, color: Color(0xffe5195e)),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: double.infinity,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              color: Colors.white,
                              margin: EdgeInsets.fromLTRB(0 * fem, 25 * fem, 0 * fem, 24 * fem),
                              width: double.infinity,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    margin: EdgeInsets.fromLTRB(0 * fem, 0 * fem, 0 * fem, 8 * fem),
                                    child: Text(
                                      'Special message for the host',
                                      style: SafeGoogleFont(
                                        'Be Vietnam Pro',
                                        fontSize: 17 * ffem,
                                        fontWeight: FontWeight.w500,
                                        height: 1.5 * ffem / fem,
                                        color: Color(0xff1e0a11),
                                      ),
                                    ),
                                  ),
                                  Container(
                                    width: double.infinity,
                                    height: 80 * fem,
                                    child: TextField(
                                      controller: _messageController,
                                      maxLines: null,
                                      decoration: InputDecoration(
                                        hintText: 'I don\'t work after 11 !',
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(12 * fem),
                                          borderSide: BorderSide(width: 1.25, color: Color(0xffeac6d3)),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(12 * fem),
                                          borderSide: BorderSide(width: 1.25, color: Color(0xffe5195e)),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 20, right: 20),
                              child: ElevatedButton(
                                onPressed: () async {
                                  bool updated = await _saveUserInformation();
                                  if (updated) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Skills updated successfully'),
                                        duration: Duration(seconds: 2), // Adjust the duration as needed
                                      ),
                                    );
                                    Navigator.pop(context);

                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Update failed. Please try again.'),
                                        duration: Duration(seconds: 2), // Adjust the duration as needed
                                      ),
                                    );
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Color(0xffe5195e),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12 * fem),
                                  ),
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 16 * fem,
                                    vertical: 12 * fem,
                                  ),
                                  minimumSize: Size(double.infinity, 14 * fem),
                                ),
                                child: Center(
                                  child: Text(
                                    'Finish',
                                    style: SafeGoogleFont(
                                      'Be Vietnam Pro',
                                      fontSize: 16 * ffem,
                                      fontWeight: FontWeight.w700,
                                      height: 1.5 * ffem / fem,
                                      letterSpacing: 0.2399999946 * fem,
                                      color: Color(0xffffffff),
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
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<bool> _saveUserInformation() async {
    final storage = FlutterSecureStorage();

    // Future<String?> _getToken() async {
    //   return await storage.read(key: 'token'); // Assuming you stored the token with key 'token'
    // }
    //
    // Future<String?> _getid() async {
    //   return await storage.read(key: 'id'); // Assuming you stored the token with key 'token'
    // }


    String? token = await _getToken();
    String? id = await _getid();
    String? team_id = await _getTeamid();
    String? kind = await _getKind();
    print (token);
    print (kind);
    // Initialize API URLs for different kinds
    String apiUrl;
    if (kind == 'solo_artist') {
      apiUrl = '${Config().apiDomain}/artist/info/$id';
    } else {
      apiUrl = '${Config().apiDomain}/artist/team_info/$team_id';
    }
    // Prepare data to send to the backend
    Map<String, dynamic> userData = {
      'about_yourself': '${_yearsController.text},${_pastController.text}',
      'price_per_hour': _hourlyPriceController.text,
      'special_message': _messageController.text,
      'skill_category': _selectedSkill,
      'skills': _selectedSubSkill,
      'about_team': _teamExperienceController.text,
      // 'pin': _pinCodeController.text,
    };

    try {
      // Make PUT request to the API
      var response = await http.patch(
        Uri.parse(apiUrl),
        headers: <String, String>{
          'Content-Type': 'application/vnd.api+json',
          'Accept': 'application/vnd.api+json',
          'Authorization': 'Bearer $token', // Include the token in the header
        },
        body: jsonEncode(userData),
      );

      // Check if request was successful (status code 200)
      if (response.statusCode == 200) {
        // User information saved successfully, handle response if needed
        print('User information saved successfully');
        // Example response handling
        print('Response: ${response.body}');
        return true;
      } else {
        // Request failed, handle error
        print('Failed to save user information. Status code: ${response
            .statusCode}');
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

}
