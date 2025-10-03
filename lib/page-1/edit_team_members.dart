import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:test1/page-1/page_0.3_artist_home.dart';
import 'dart:convert';

import '../config.dart';

// Define the TeamMember class
class TeamMember {
  final int? id; // Make id nullable
  String name;
  String email;
  String role;
  String profilePictureUrl;

  TeamMember({
     this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.profilePictureUrl,
  });

  // Factory constructor to parse JSON
  factory TeamMember.fromJson(Map<String, dynamic> json) {
    return TeamMember(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      role: json['role'],
      profilePictureUrl: json['profile_picture_url'],
    );
  }
}

class EditTeamMembersPage extends StatefulWidget {
  @override
  _EditTeamMembersPageState createState() => _EditTeamMembersPageState();
}

class _EditTeamMembersPageState extends State<EditTeamMembersPage> {

  late Future<List<TeamMember>> _teamMembersFuture;
  final List<TextEditingController> _nameControllers = [];
  final List<TextEditingController> _idControllers = [];
  final List<TextEditingController> _emailControllers = [];
  final List<TextEditingController> _roleControllers = [];
  final List<TextEditingController> _profilePictureControllers = [];

  @override
  void initState() {
    super.initState();
    _teamMembersFuture = fetchTeamMembers(); // Fetch team members from API
  }

  Future<String?> _getid() async {
    return await storage.read(key: 'artist_id'); // Assuming you stored the token with key 'id'
  }

  Future<String?> _getTeamid() async {
    return await storage.read(key: 'team_id'); // Assuming you stored the token with key 'id'
  }

  Future<String?> _getKind() async {
    return await storage.read(key: 'selected_value'); // Assuming you stored the token with key 'selected_value'
  }

  // Mock API function to fetch team members
  Future<List<TeamMember>> fetchTeamMembers() async {
    List<TeamMember> members = []; // Initialize an empty list to store team members

    String? team_id = await _getTeamid();
    if (team_id == null) {
      print('Error: team_id is null');
      return members; // Return empty list or handle the null case as needed
    }

    String apiUrl = '${Config().apiDomain}/artist/team_member/$team_id';

    try {
      var response = await http.get(
        Uri.parse(apiUrl),
        headers: <String, String>{
          'Content-Type': 'application/vnd.api+json',
          'Accept': 'application/vnd.api+json',
        },
      );

      if (response.statusCode == 200) {
        List<dynamic> responseData = json.decode(response.body);

        // Print the raw response data for debugging
        print('team data is $responseData');

        // Loop through the responseData and convert each member to a TeamMember object
        for (var memberData in responseData) {
          if (memberData is Map<String, dynamic>) {
            TeamMember member = TeamMember(
              id: memberData['id'] ?? 0, // Default to 0 if id is null
              name: memberData['member_name'] ?? '', // Default to empty string if member_name is null
              email: memberData['email'] ?? '', // Default to empty string if email is null
              role: memberData['role'] ?? '', // Default to empty string if role is null
              profilePictureUrl: memberData['profile_photo'] ?? '', // Default to empty string if profile_photo is null
            );

            // Add the member to the list of members
            members.add(member);

            // Initialize controllers for the fetched team members
            _nameControllers.add(TextEditingController(text: member.name));
            _idControllers.add(TextEditingController(text: member.id.toString()));
            _emailControllers.add(TextEditingController(text: member.email));
            _roleControllers.add(TextEditingController(text: member.role));
            _profilePictureControllers.add(TextEditingController(text: member.profilePictureUrl));
          } else {
            print('Unexpected data format: $memberData');
          }
        }

      } else {
        print('Failed to fetch data. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching data: $e');
    }

    // Return the list of team members
    return members;
  }



  Future<bool> addTeamMembers(List<TeamMember> members) async {
    String? teamId = await _getTeamid();
    String apiUrl = '${Config().apiDomain}/artist/team_member';

    try {
      List<Map<String, dynamic>> data = members.map((member) {
        return {
          'team_id': teamId,
          'member_name': member.name,
          'email': member.email,
          'role': member.role,
          'profile_photo': member.profilePictureUrl,
        };
      }).toList();

      Map<String, dynamic> requestBody = {
        'team_members': data,
      };

      var response = await http.post(
        Uri.parse(apiUrl),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode(requestBody),
      );

      if (response.statusCode == 201) {
        print('Members added successfully');
        return true;
      } else {
        print('Failed to add members. Status code: ${response.statusCode}');
        print('Response body: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error adding team members: $e');
      return false;
    }
  }




  @override
  void dispose() {
    // Clean up the controllers when the widget is disposed
    for (var controller in _nameControllers) {
      controller.dispose();
    }
    for (var controller in _emailControllers) {
      controller.dispose();
    }
    for (var controller in _roleControllers) {
      controller.dispose();
    }
    for (var controller in _profilePictureControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _saveTeamMembers(List<TeamMember> teamMembers) {
    // Iterate through the team members and check if their fields have changed
    for (int i = 0; i < teamMembers.length; i++) {
      TeamMember member = teamMembers[i];

      // Check if any of the fields have changed
      bool hasChanged = member.name != _nameControllers[i].text ||
          member.email != _emailControllers[i].text ||
          member.role != _roleControllers[i].text ||
          member.profilePictureUrl != _profilePictureControllers[i].text;

      if (hasChanged) {
        // Create the updated member data
        Map<String, dynamic> updatedMember = {
          'name': _nameControllers[i].text,
          'email': _emailControllers[i].text,
          'role': _roleControllers[i].text,
          'profile_picture': _profilePictureControllers[i].text,
        };

        // Send the update to the backend using the member's ID in the URL
        String apiUrl = '${Config().apiDomain}/artist/team_member/${member.id}';

        print('Updating team member with ID ${member.id} with data $updatedMember');

        // Make the PATCH request for each updated member
        http.patch(
          Uri.parse(apiUrl),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
          body: json.encode(updatedMember),
        ).then((response) {
          if (response.statusCode == 200) {
            print("Team member ${member.id} updated successfully");
          } else {
            print("Failed to update team member ${member.id}. Status code: ${response.body}");
          }
        }).catchError((error) {
          print("Error updating team member ${member.id}: $error");
        });
      }
    }
  }


// Function to remove a team member
  void _removeTeamMember(int index) {
    setState(() {
      // Remove controllers associated with the team member being removed
      _nameControllers.removeAt(index);
      _emailControllers.removeAt(index);
      _roleControllers.removeAt(index);
      _profilePictureControllers.removeAt(index);

      // Remove the team member from the list
      _teamMembersFuture.then((teamMembers) {
        var removedMember = teamMembers.removeAt(index);  // Remove from the team members list

        // Use member.id in the API URL
        String apiUrl = '${Config().apiDomain}/artist/team_member/${removedMember.id}';
        http.delete(Uri.parse(apiUrl)).then((response) {
          if (response.statusCode == 204) {
            print("Team member removed successfully");
          } else {
            print("Failed to remove team member. Status code: ${response.statusCode}");
          }
        }).catchError((error) {
          print("Error removing team member: $error");
        });
      });
    });
  }

// Function to edit the profile picture for a team member
  void _editProfilePicture(int index) async {
    // Implement the logic to pick a new image (using an image picker)
    // For example, using the image_picker package:
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() async {
        // Update the profile picture URL in the controller
        _profilePictureControllers[index].text = pickedFile.path;

        // Optionally, upload the new profile picture to the server and get its URL
        String uploadUrl = '${Config().apiDomain}/artist/upload_profile_picture';  // Modify according to your API
        http.MultipartRequest request = http.MultipartRequest('POST', Uri.parse(uploadUrl));
        request.files.add(await http.MultipartFile.fromPath('profile_picture', pickedFile.path));

        request.send().then((response) {
        if (response.statusCode == 200) {
        // Update the profile picture URL in the team member object
        _teamMembersFuture.then((teamMembers) {
        teamMembers[index].profilePictureUrl = pickedFile.path;
        });
        print("Profile picture updated successfully");
        } else {
        print("Failed to upload profile picture. Status code: ${response.statusCode}");
        }
        }).catchError((error) {
        print("Error uploading profile picture: $error");
        });
      });
    } else {
      print("No image selected");
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Team Members', style: TextStyle(color: Colors.black)),
        leading: IconButton(
          icon: Icon(
            Icons.save,
            color: Colors.blue, // Set the desired color here
          ),
          onPressed: () {
            _teamMembersFuture.then((teamMembers) => _saveTeamMembers(teamMembers));
            Navigator.pop(context);
          },
        ),
      ),
      body: FutureBuilder<List<TeamMember>>(
        future: _teamMembersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
            List<TeamMember> teamMembers = snapshot.data!;
            return Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: teamMembers.length,
                    itemBuilder: (context, index) {
                      return buildTeamMemberContainer(context, teamMembers[index], index);
                    },
                  ),
                ),
                // Button to add a new team member
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ElevatedButton(
                    onPressed: () {
                      _showAddTeamMemberDialog(context);
                    },
                    child: Text("Add Team Member"),
                  ),
                ),
              ],
            );
          } else {
            return Center(child: Text('No team members found'));
          }
        },
      ),
    );
  }

  // Function to show the Add Team Member Dialog
  void _showAddTeamMemberDialog(BuildContext context) {
    TextEditingController nameController = TextEditingController();
    TextEditingController emailController = TextEditingController();
    TextEditingController roleController = TextEditingController();
    TextEditingController profilePictureController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add New Team Member'),
          content: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                TextField(
                  controller: profilePictureController,
                  decoration: InputDecoration(labelText: 'Profile Picture URL'),
                ),
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(labelText: 'Name'),
                ),
                TextField(
                  controller: emailController,
                  decoration: InputDecoration(labelText: 'Phone No'),
                ),
                TextField(
                  controller: roleController,
                  decoration: InputDecoration(labelText: 'Role'),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Add'),
              onPressed: () async {
                TeamMember newMember = TeamMember(
                  // id: 0, // ID will be assigned by the backend
                  name: nameController.text,
                  email: emailController.text,
                  role: roleController.text,
                  profilePictureUrl: profilePictureController.text,
                );

                // Call the function to add the new member to the backend
                bool success = await addTeamMembers([newMember]);

                if (success) {
                  // Refresh the list after adding members
                  setState(() {
                    _teamMembersFuture = fetchTeamMembers();
                  });

                  // Close the dialog
                  Navigator.of(context).pop();
                } else {
                  // Show an error message if the addition failed
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to add team member')),
                  );
                }
              },
            )

          ],
        );
      },
    );
  }


  Widget buildTeamMemberContainer(BuildContext context, TeamMember member, int index) {
    return Container(
      padding: EdgeInsets.all(16.0),
      margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Display Profile Picture
          Row(
            children: [
              CircleAvatar(
                radius: 30.0,
                backgroundImage: _profilePictureControllers[index].text.isNotEmpty
                    ? NetworkImage(_profilePictureControllers[index].text)
                    : AssetImage('assets/placeholder_image.png') as ImageProvider, // Provide a placeholder image if URL is empty
              ),
              SizedBox(width: 10.0),
              IconButton(
                icon: Icon(Icons.edit, color: Colors.blue),
                onPressed: () => _editProfilePicture(index), // Edit profile picture functionality
              ),
            ],
          ),

          SizedBox(height: 10.0),

          // Name Input
          TextField(
            controller: _nameControllers[index],
            decoration: InputDecoration(
              labelText: 'Name',
              prefixIcon: Icon(Icons.person),
            ),
          ),
          SizedBox(height: 10.0),

          // Email Input
          TextField(
            controller: _emailControllers[index],
            decoration: InputDecoration(
              labelText: 'Phone No',
              prefixIcon: Icon(Icons.email),
            ),
          ),
          SizedBox(height: 10.0),

          // Role Input
          TextField(
            controller: _roleControllers[index],
            decoration: InputDecoration(
              labelText: 'Role',
              prefixIcon: Icon(Icons.work),
            ),
          ),
          SizedBox(height: 10.0),

          // Remove Team Member Button
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              ElevatedButton(
                onPressed: () {
                  _removeTeamMember(index);

                },
                child: Text('Remove Member'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
