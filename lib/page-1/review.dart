import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:test1/page-1/page_0.3_artist_home.dart';
import 'dart:io';
import 'package:video_player/video_player.dart';
import 'package:http/http.dart' as http;

import '../config.dart';

class ReviewPage extends StatefulWidget {
  final String artistId;
  String? isteam;
  ReviewPage ({ required this.artistId , this.isteam});
  @override
  _ReviewPageState createState() => _ReviewPageState();
}


class _ReviewPageState extends State<ReviewPage> {
  double rating = 0.0;
  String selectedPerformance = '';
  TextEditingController reviewController = TextEditingController();
  File? _selectedImage;
  File? _selectedVideo;
  VideoPlayerController? _videoPlayerController;
  bool _isLoading = false;


  final ImagePicker _picker = ImagePicker();

  Future<String?> _getid() async {
    return await storage.read(key: 'user_id'); // Assuming you stored the token with key 'token'
  }

  @override
  void initState() {
    super.initState();
    print('ajnsff');
    print(widget.isteam);
    print(widget.artistId);


  }

  // Method to upload image
  Future<void> _uploadImage(int Id) async {
    if (_selectedImage == null) return;

    if (!mounted) return; // Ensure widget is still mounted before starting
    setState(() {
      _isLoading = true;
    });

    final String backendUrl = '${Config().apiDomain}/review/$Id/media';

    try {
      var request = http.MultipartRequest('POST', Uri.parse(backendUrl));
      request.files.add(await http.MultipartFile.fromPath('photo', _selectedImage!.path));

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        var jsonResponse = json.decode(response.body);
        String imageUrl = jsonResponse['profile_photo'];
        print('Image uploaded successfully: $imageUrl');
      } else {
        print('Failed to upload image: ${response.body}');
      }
    } catch (e) {
      print('Error uploading image: $e');
    } finally {
      if (mounted) {  // Ensure widget is still mounted before calling setState
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void showFeedbackDialog(BuildContext context, String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                if (title == 'Success') {
                  setState(() {
                    starRating = 0; // Reset star rating
                    reviewController.clear(); // Clear the review text field
                    selectedPerformance = ""; // Clear the selected performance if applicable
                    // Reset any other fields you have
                  });
                }

              },
            ),
          ],
        );
      },
    );
  }



  void submitReview() async {
    setState(() {
      _isLoading = true; // Show loading bar
    });

    final String backendUrl = '${Config().apiDomain}/review/store';
    print(backendUrl);
    String? id = await _getid();
    print('rating is $starRating');

    String reviewText = '$selectedPerformance ${reviewController.text}';
    print('reviewtext is $reviewText');

    final String entityIdKey = widget.isteam != 'false' ? 'team_id' : 'artist_id';



    final response = await http.post(
      Uri.parse(backendUrl),
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({
        'rating': starRating.toString(),
        'review_text': reviewText,
        'user_id': id,
        entityIdKey: widget.artistId,
      }),
    );
    print('${entityIdKey}: widget.artistId');

    if (response.statusCode == 201) {
      print('Review submitted successfully');
      Map<String, dynamic> Data = json.decode(response.body);
      int id = Data['id'];

      await _uploadImage(id); // Wait for image upload to complete

      if (mounted) {
        showFeedbackDialog(context, 'Success', 'Feedback submitted successfully!');
      }
    } else {
      print('Failed to submit review: ${response.body}');

      if (mounted) {
        showFeedbackDialog(context, 'Failure', 'Failed to submit feedback. Please try again.');
      }
    }

    if (mounted) {
      setState(() {
        _isLoading = false; // Hide loading bar
      });
    }
  }


  // Dispose video player properly
  @override
  void dispose() {
    _videoPlayerController?.pause(); // Pause video to stop playback
    _videoPlayerController?.dispose(); // Dispose controller to release resources
    super.dispose();
  }


  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
        _selectedVideo = null;
        _videoPlayerController?.dispose();
        _videoPlayerController = null;
      });
    }
  }

  Future<void> _pickVideo() async {
    final pickedFile = await _picker.pickVideo(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedVideo = File(pickedFile.path);
        _selectedImage = null;
        _videoPlayerController = VideoPlayerController.file(File(pickedFile.path))
          ..initialize().then((_) {
            setState(() {});
            _videoPlayerController!.play();
          });
      });
    }
  }

  Widget _buildPerformanceOption(String text, double fem, double boxWidth, double boxHeight) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedPerformance = text;
        });
      },
      child: Container(
        width: 92*fem,
        height: 42*fem,
        margin: EdgeInsets.symmetric(horizontal: 6 * fem, vertical: 6 * fem),
        padding: EdgeInsets.symmetric(horizontal: 1 * fem, vertical: 1 * fem),
        decoration: BoxDecoration(
          color: selectedPerformance == text ? Color(0xffe5195e) : Color(0xfff2e8ea),
          borderRadius: BorderRadius.circular(12 * fem),
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              color: selectedPerformance == text ? Colors.white : Color(0xff1c0c11),
              fontSize: 14 * fem,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      ),
    );
  }
  int starRating = 0;

  @override
  Widget build(BuildContext context) {
    double baseWidth = 390;
    double fem = MediaQuery.of(context).size.width / baseWidth;
    double ffem = fem * 0.97;

    // Adjusting the width and height of the performance option boxes
    double boxWidth = (MediaQuery.of(context).size.width - 48 * fem) / 3; // To fit three items in a row
    double boxHeight = 50 * fem;

    return Scaffold(
      appBar: AppBar(
        title: Text('Review',style: TextStyle(color: Colors.black,fontWeight: FontWeight.w500,
        fontSize: 22),),
        leading: IconButton(color: Colors.black,
        icon: Icon(Icons.arrow_back_ios_new_rounded),
        onPressed: () {
          // Use Navigator.pop() to close the current screen (Scene2) and go back to the previous screen (Scene1)
          Navigator.pop(context);
        },
      ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 20),
                Padding(
                  padding: EdgeInsets.fromLTRB(20*fem,0,0,0),
                  child: Text(
                    'How was the artist\'s performance?',
                    style: TextStyle(
                      fontSize: 19 * ffem,
                      fontWeight: FontWeight.w500,
                      color: Color(0xff1c0c11),
                    ),
                  ),
                ),
                SizedBox(height: 16),
          
                // Using Wrap to display three in the first row and two below them
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12 * fem),
                  child: Wrap(
                    alignment: WrapAlignment.start,
                    spacing: 1 * fem, // Horizontal spacing between the boxes
                    runSpacing: 1 * fem, // Vertical spacing between the rows
                    children: [
                      _buildPerformanceOption('Incredible', fem, boxWidth, boxHeight),
                      _buildPerformanceOption('Great', fem, boxWidth, boxHeight),
                      _buildPerformanceOption('Good', fem, boxWidth, boxHeight),
                      _buildPerformanceOption('Fair', fem, boxWidth, boxHeight),
                      _buildPerformanceOption('Bad', fem, boxWidth, boxHeight),
                    ],
                  ),
                ),
          
                SizedBox(height: 16),
                Padding(
                  padding: EdgeInsets.fromLTRB(20 * fem,0,0,0),
                  child: Text(
                    'Rating:',
                    style: TextStyle(
                      fontSize: 19 * ffem,
                      fontWeight: FontWeight.w500,
                      color: Color(0xff1c0c11),
                    ),
                  ),
                ),
                // Slider with the same background color as the submit button
                // Star Rating Widget
                StarRating(
                  rating: starRating,
                  onRatingChanged: (newRating) {
                    setState(() {
                      starRating = newRating;
                    });
                  },
                ),

                Padding(
                  padding: EdgeInsets.fromLTRB( 16 * fem,20*fem,16*fem,0),
                  child: TextField(
                    controller: reviewController,
                    maxLines: 5,
                    decoration: InputDecoration(
                      hintText: 'Tell us more',
                      filled: true,
                      fillColor: Color(0xfff2e8ea),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12 * fem),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12 * fem),
                        borderSide: BorderSide(
                          color: Color(0xffe5195e), // Same color as submit button
                          width: 2.0,
                        ),
                      ),
                    ),
                  ),
                ),
          
                SizedBox(height: 24),
          
                // Upload photo or video section
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16 * fem),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextButton(
                        onPressed: _pickImage,
                        child: Text(
                          'Upload Photo',
                          style: TextStyle(
                            color: Color(0xffe5195e),
                            fontSize: 16 * ffem,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      // Text(
                      //   '|',
                      //   style: TextStyle(
                      //     color: Color(0xffe5195e),
                      //     fontSize: 18 * ffem,
                      //     fontWeight: FontWeight.w500,
                      //   ),
                      // ),
                      // TextButton(
                      //   onPressed: _pickVideo,
                      //   child: Text(
                      //     'Upload Video',
                      //     style: TextStyle(
                      //       color: Color(0xffe5195e),
                      //       fontSize: 16 * ffem,
                      //       fontWeight: FontWeight.w500,
                      //     ),
                      //   ),
                      // ),
                    ],
                  ),
                ),
                SizedBox(height: 16),
          
                // Display uploaded photo or video
                if (_selectedImage != null)
                  Container(
                    height: 200 * fem,
                    width: double.infinity,
                    margin: EdgeInsets.symmetric(horizontal: 16 * fem),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black),
                      borderRadius: BorderRadius.circular(12 * fem),
                    ),
                    child: Image.file(
                      _selectedImage!,
                      fit: BoxFit.cover,
                    ),
                  )
                else if (_selectedVideo != null && _videoPlayerController != null && _videoPlayerController!.value.isInitialized)
                  Container(
                    height: 200 * fem,
                    width: double.infinity,
                    margin: EdgeInsets.symmetric(horizontal: 16 * fem),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black),
                      borderRadius: BorderRadius.circular(12 * fem),
                    ),
                    child: VideoPlayer(_videoPlayerController!),
                  ),
                SizedBox(height: 20),

                Center(
                  child: _isLoading
                      ? CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xffe5195e)),
                  )
                      : ElevatedButton(
                    onPressed: submitReview,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xffe5195e),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12 * fem),
                      ),
                      padding: EdgeInsets.symmetric(
                        vertical: 12 * fem,
                        horizontal: 84 * fem,
                      ),
                    ),
                    child: Text(
                      'Submit Review',
                      style: TextStyle(
                        fontSize: 16 * fem,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }


}
// Star rating widget
class StarRating extends StatelessWidget {
  final int rating;
  final ValueChanged<int> onRatingChanged;
  final int starCount;

  StarRating({
    this.starCount = 5,
    required this.rating,
    required this.onRatingChanged,
  });


  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(starCount, (index) {
        return IconButton(
          icon: Icon(
            index < rating ? Icons.star : Icons.star_border, // Filled or empty star
            color: index < rating ? Colors.yellow : Colors.grey.shade300, // Yellow for filled stars, light grey for empty
            size: 32,
          ),
          onPressed: () => onRatingChanged(index + 1), // When tapped, set the rating
        );
      }),
    );
  }
}
