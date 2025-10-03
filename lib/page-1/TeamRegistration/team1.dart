import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:test1/page-1/TeamRegistration/team2.dart';
import '../../config.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';
import '../bottomNav_artist.dart';

class TeamMember {
  String? name;
  String? email;
  String? role;
  File? imageFile;

  TeamMember({this.name, this.email, this.role, this.imageFile});

  Map<String, dynamic> toJson() {
    return {
      'member_name': name,
      'email': email,
      'role': role,
      'profile_photo': imageFile != null ? base64Encode(imageFile!.readAsBytesSync()) : null,
    };
  }
}

class team1signup extends StatefulWidget {
  @override
  _team1signupState createState() => _team1signupState();
}

class _team1signupState extends State<team1signup> {
  TextEditingController teamController = TextEditingController();
  int selectedTeamMembers=0 ; // Default value
  List<TeamMember> teamMembersData = []; // Holds team member data
  List<File?> _imageFiles = []; // List to store image files

  final storage = FlutterSecureStorage();

  Future<String?> _getToken() async {
    return await storage.read(key: 'token');
  }

  Future<String?> _getid() async {
    return await storage.read(key: 'team_id');
  }

  Future<void> sendDataToBackend() async {
    String? token = await _getToken();
    String? team_id = await _getid();

    final String apiUrl = '${Config().apiDomain}/artist/team_member';

    try {
      var request = http.MultipartRequest('POST', Uri.parse(apiUrl));
      request.headers.addAll({
        'Accept': 'application/vnd.api+json',
        'Authorization': 'Bearer $token',
      });

      // Iterate over the team members and add them to the request
      for (int i = 0; i < teamMembersData.length; i++) {
        var member = teamMembersData[i];

        // Convert member data to a Map with proper array-like field names
        Map<String, String> memberData = {
          'team_members[$i][member_name]': member.name ?? '',
          'team_members[$i][email]': member.email ?? '',
          'team_members[$i][role]': member.role ?? '',
          'team_members[$i][team_id]': team_id ?? '',
        };

        // Add the fields to the request
        memberData.forEach((key, value) {
          request.fields[key] = value;
        });

        print('sending member data :$memberData');

        // Add image file (if exists) to the multipart request with the right array-like key
        if (member.imageFile != null) {
          request.files.add(await http.MultipartFile.fromPath(
            'team_members[$i][profile_photo]',
            // Ensure the file field matches the array structure
            member.imageFile!.path,
          ));
          print('sending file for ${member.name}: ${member.imageFile!.path}');
        }
      }

      print('request fields: ${request.fields}');
      print('request Files: ${request.files.map((file) => file.filename)}');

      // Send the request
      final response = await request.send();

      // Convert the response stream to a string
      final responseString = await response.stream.bytesToString();

      if (response.statusCode == 201) {
        print('Data sent successfully');
        print('Response: $responseString');
      } else {
        throw Exception('Failed to send data. Error $responseString');
      }
    } catch (e) {
      print('Error: $e');
    }
  }


  Future<void> _getImage(int index) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _imageFiles[index] = File(pickedFile.path);
        teamMembersData[index].imageFile = _imageFiles[index];
      });
    }
  }

  void buildTeamMemberFields() {
    // Rebuild the team members and image list based on the selected number of members
    setState(() {
      teamMembersData = List.generate(
        selectedTeamMembers,
            (index) => TeamMember(),
      );
      _imageFiles = List<File?>.filled(selectedTeamMembers, null);
    });
  }

  @override
  void dispose() {
    teamController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double baseWidth = 390;
    double fem = MediaQuery.of(context).size.width / baseWidth;
    double ffem = fem * 0.97;

    return Scaffold(
      backgroundColor: Color(0xFF121217),
      appBar: AppBar(
        title: Text(
          'Create Your Team',
          style: TextStyle(
            fontSize: 21 * ffem,
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
        ),
        backgroundColor: Color(0xFF121217),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.all(16 * fem),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'How Many People are on Your Team?',
                  style: TextStyle(
                    fontSize: 18 * ffem,
                    fontWeight: FontWeight.w400,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 16 * fem),
                TextField(
                  controller: teamController,
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    if (value.isNotEmpty) {
                      setState(() {
                        selectedTeamMembers = int.parse(value);
                        buildTeamMemberFields(); // Build fields when input changes
                      });
                    }
                  },
                  decoration: InputDecoration(
                    hintText: 'Enter Number',
                    hintStyle: TextStyle(color: Color(0xFF9E9EB8)),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12 * fem),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                      borderRadius: BorderRadius.circular(12 * fem),
                    ),
                  ),
                  style: TextStyle(color: Colors.white),
                ),
                SizedBox(height: 24 * fem),
                Column(
                  children: List.generate(selectedTeamMembers, (index) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 24 * fem),
                        Text(
                          'Team Member ${index + 1}',
                          style: TextStyle(
                            fontSize: 16 * ffem,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 16 * fem),
                        Row(
                          children: [
                            GestureDetector(
                              onTap: () {
                                _getImage(index);
                              },
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12 * fem),
                                child: Container(
                                  width: 160 * fem,
                                  height: 200 * fem,
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: Color(0xFF9E9EB8),
                                    ),
                                    borderRadius: BorderRadius.circular(12 * fem),
                                  ),
                                  child: _imageFiles[index] != null
                                      ? Image.file(
                                    _imageFiles[index]!,
                                    width: 160 * fem,
                                    height: 200 * fem,
                                    fit: BoxFit.cover,
                                  )
                                      : Icon(
                                    Icons.add_photo_alternate,
                                    size: 50 * fem,
                                    color: Color(0xFF9E9EB8),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: 13 * fem),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  TextField(
                                    onChanged: (value) {
                                      teamMembersData[index].name = value;
                                    },
                                    style: TextStyle(
                                      color: Colors.white, // Set the text color to white
                                    ),
                                    decoration: InputDecoration(
                                      hintText: 'Name..',
                                      hintStyle: TextStyle(
                                        color: Color(0xFF9E9EB8), // Hint text color
                                      ),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12 * fem),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(color: Colors.white),
                                        borderRadius: BorderRadius.circular(12 * fem),
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 10 * fem),
                                  TextField(
                                    onChanged: (value) {
                                      teamMembersData[index].email = value;
                                    },
                                    style: TextStyle(
                                      color: Colors.white, // Set the text color to white
                                    ),
                                    decoration: InputDecoration(
                                      hintText: 'Phone No',
                                      hintStyle: TextStyle(
                                        color: Color(0xFF9E9EB8),
                                      ),
                                      border: OutlineInputBorder(
                                        borderRadius:
                                        BorderRadius.circular(12 * fem),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide:
                                        BorderSide(color: Colors.white),
                                        borderRadius:
                                        BorderRadius.circular(12 * fem),
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 10 * fem),
                                  TextField(
                                    onChanged: (value) {
                                      teamMembersData[index].role = value;
                                    },
                                    style: TextStyle(
                                      color: Colors.white, // Set the text color to white
                                    ),
                                    decoration: InputDecoration(
                                      hintText: 'Role..',
                                      hintStyle: TextStyle(
                                        color: Color(0xFF9E9EB8),
                                      ),
                                      border: OutlineInputBorder(
                                        borderRadius:
                                        BorderRadius.circular(12 * fem),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide:
                                        BorderSide(color: Colors.white),
                                        borderRadius:
                                        BorderRadius.circular(12 * fem),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    );
                  }),
                ),
                SizedBox(height: 24 * fem),
                ElevatedButton(
                  onPressed: () async {
                    sendDataToBackend();
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => BottomNavart(data: {},)),
                    );
                  },
                  child: Text('Submit'),
                  style: ElevatedButton.styleFrom(
                    // primary: Colors.white,
                    // onPrimary: Color(0xFF121217),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12 * fem),
                    ),
                  ),
                ),
                SizedBox(height: 24 * fem),
              ],
            ),
          ),
        ),
      ),
    );
  }
}