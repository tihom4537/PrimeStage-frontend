import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../config.dart'; // Adjust the import path as needed

class MediaUploadSection extends StatefulWidget {
  // Callback functions to pass data back to parent
  final Function(List<File>) onImagesSelected;
  final Function(List<File>, List<String?>) onVideosSelected;

  const MediaUploadSection({
    Key? key,
    required this.onImagesSelected,
    required this.onVideosSelected,
  }) : super(key: key);

  @override
  State<MediaUploadSection> createState() => _MediaUploadSectionState();
}

class _MediaUploadSectionState extends State<MediaUploadSection> {
  // Image variables
  File? _image1;
  File? _image2;
  File? _image3;
  File? _image4;

  // Video variables
  File? _video1;
  File? _video2;
  File? _video3;
  File? _video4;

  // Video controllers
  VideoPlayerController? _controller1;
  VideoPlayerController? _controller2;
  VideoPlayerController? _controller3;
  VideoPlayerController? _controller4;

  // Loading states
  bool _isLoading1 = false;
  bool _isLoading2 = false;
  bool _isLoading3 = false;
  bool _isLoading4 = false;

  // Upload progress
  double _uploadProgress1 = 0.0;
  double _uploadProgress2 = 0.0;
  double _uploadProgress3 = 0.0;
  double _uploadProgress4 = 0.0;

  // Uploaded video URLs
  String? _uploadedVideoUrl1;
  String? _uploadedVideoUrl2;
  String? _uploadedVideoUrl3;
  String? _uploadedVideoUrl4;

  final ImagePicker _picker = ImagePicker();
  final storage = const FlutterSecureStorage();

  // Image picker methods
  Future<void> _pickImage1() async {
    try {
      final pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 100,
      );

      if (pickedFile != null) {
        File imageFile = File(pickedFile.path);
        // Ensure portrait orientation
        // imageFile = await ensurePortraitMode(imageFile);

        setState(() {
          _image1 = imageFile;
        });
        _updateSelectedImages();
      }
    } catch (e) {
      print('Error picking image: $e');
    }
  }

  Future<void> _pickImage2() async {
    try {
      final pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 100,
      );

      if (pickedFile != null) {
        File imageFile = File(pickedFile.path);
        // Ensure portrait orientation
        // imageFile = await ensurePortraitMode(imageFile);

        setState(() {
          _image2 = imageFile;
        });
        _updateSelectedImages();
      }
    } catch (e) {
      print('Error picking image: $e');
    }
  }

  Future<void> _pickImage3() async {
    try {
      final pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 100,
      );

      if (pickedFile != null) {
        File imageFile = File(pickedFile.path);
        // Ensure portrait orientation
        // imageFile = await ensurePortraitMode(imageFile);

        setState(() {
          _image3 = imageFile;
        });
        _updateSelectedImages();
      }
    } catch (e) {
      print('Error picking image: $e');
    }
  }

  Future<void> _pickImage4() async {
    try {
      final pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 100,
      );

      if (pickedFile != null) {
        File imageFile = File(pickedFile.path);
        // Ensure portrait orientation
        // imageFile = await ensurePortraitMode(imageFile);

        setState(() {
          _image4 = imageFile;
        });
        _updateSelectedImages();
      }
    } catch (e) {
      print('Error picking image: $e');
    }
  }

  // Video picker methods
  Future<void> _pickVideo1() async {
    try {
      final pickedFile = await _picker.pickVideo(
          source: ImageSource.gallery,
          maxDuration: const Duration(seconds: 30)
      );

      if (pickedFile != null) {
        // Set loading state
        setState(() {
          _isLoading1 = true;
          _video1 = File(pickedFile.path);
        });

        // Validate video duration
        final videoPlayerController = VideoPlayerController.file(File(pickedFile.path));
        await videoPlayerController.initialize();
        final duration = videoPlayerController.value.duration;

        if (duration.inSeconds > 30) {
          await _showErrorDialog('Video must be 30 seconds or less');
          setState(() => _isLoading1 = false);
          return;
        }
        print('upload started');
        // Start upload to S3
        await _uploadVideoToS3(
            file: File(pickedFile.path),
            videoSlot: 1,
            onProgress: (progress) {
              setState(() {
                _uploadProgress1 = progress;
              });
            },
            onComplete: (success, url) {
              setState(() {
                _isLoading1 = false;
                _uploadedVideoUrl1 = success ? url : null;
                _controller1 = VideoPlayerController.file(File(pickedFile.path))
                  ..initialize().then((_) {
                    setState(() {});
                    // _controller1?.play();
                    // _controller1?.setLooping(true);
                    _updateSelectedVideos();
                  });
              });
            }
        );
      }
    } catch (e) {
      setState(() => _isLoading1 = false);
      await _showErrorDialog('Error picking video: $e');
    }
  }

  Future<void> _pickVideo2() async {
    try {
      final pickedFile = await _picker.pickVideo(
          source: ImageSource.gallery,
          maxDuration: const Duration(seconds: 30)
      );

      if (pickedFile != null) {
        // Set loading state
        setState(() {
          _isLoading2 = true;
          _video2 = File(pickedFile.path);
        });

        // Validate video duration
        final videoPlayerController = VideoPlayerController.file(File(pickedFile.path));
        await videoPlayerController.initialize();
        final duration = videoPlayerController.value.duration;

        if (duration.inSeconds > 30) {
          await _showErrorDialog('Video must be 30 seconds or less');
          setState(() => _isLoading2 = false);
          return;
        }
        print('upload 2 started');
        // Start upload to S3
        await _uploadVideoToS3(
            file: File(pickedFile.path),
            videoSlot: 2,
            onProgress: (progress) {
              setState(() {
                _uploadProgress2 = progress;
              });
            },
            onComplete: (success, url) {
              setState(() {
                _isLoading2 = false;
                _uploadedVideoUrl2 = success ? url : null;
                _controller2 = VideoPlayerController.file(File(pickedFile.path))
                  ..initialize().then((_) {
                    setState(() {});
                    // _controller2?.play();
                    // _controller2?.setLooping(true);
                    _updateSelectedVideos();
                  });
              });
            }
        );
      }
    } catch (e) {
      setState(() => _isLoading2 = false);
      await _showErrorDialog('Error picking video: $e');
    }
  }

  Future<void> _pickVideo3() async {
    try {
      final pickedFile = await _picker.pickVideo(
          source: ImageSource.gallery,
          maxDuration: const Duration(seconds: 30)
      );

      if (pickedFile != null) {
        // Set loading state
        setState(() {
          _isLoading3 = true;
          _video3 = File(pickedFile.path);
        });

        // Validate video duration
        final videoPlayerController = VideoPlayerController.file(File(pickedFile.path));
        await videoPlayerController.initialize();
        final duration = videoPlayerController.value.duration;

        if (duration.inSeconds > 30) {
          await _showErrorDialog('Video must be 30 seconds or less');
          setState(() => _isLoading2 = false);
          return;
        }
        print('upload 3 started');
        // Start upload to S3
        await _uploadVideoToS3(
            file: File(pickedFile.path),
            videoSlot: 3,
            onProgress: (progress) {
              setState(() {
                _uploadProgress3 = progress;
              });
            },
            onComplete: (success, url) {
              setState(() {
                _isLoading3 = false;
                _uploadedVideoUrl3 = success ? url : null;
                _controller3 = VideoPlayerController.file(File(pickedFile.path))
                  ..initialize().then((_) {
                    setState(() {});
                    // _controller3?.play();
                    // _controller3?.setLooping(true);
                    _updateSelectedVideos();
                  });
              });
            }
        );
      }
    } catch (e) {
      setState(() => _isLoading3 = false);
      await _showErrorDialog('Error picking video: $e');
    }
  }

  // S3 Upload function
  Future<void> _uploadVideoToS3({
    required File file,
    required Function(double) onProgress,
    required Function(bool, String?) onComplete,
    required int videoSlot // New parameter to track which video slot is being updated
  }) async {
    try {
      print('upload started for video$videoSlot');
      // Get temporary artist ID (assume it's stored somewhere)
      String? artistId = await storage.read(key: 'artist_id');
      if (artistId == null) {
        throw Exception('No artist ID found');
      }

      // Prepare the multipart request
      var uploadUrl = Uri.parse('${Config().apiDomain}/upload-direct-video/$artistId');
      var request = http.MultipartRequest('POST', uploadUrl);

      // Add the usertype parameter
      request.fields['usertype'] = 'artist';

      // Add the video slot parameter to indicate which slot is being updated
      request.fields['videoSlot'] = 'video$videoSlot';

      // Create a stream for the file
      var length = await file.length();
      var stream = http.ByteStream(file.openRead());

      var multipartFile = http.MultipartFile(
        'video',
        stream,
        length,
        filename: file.path.split('/').last,
      );

      request.files.add(multipartFile);

      // Send the request but DON'T listen to the stream yet
      var response = await request.send();

      // Convert the response stream to bytes ONCE and collect them
      List<int> totalBytes = [];
      int bytesReceived = 0;

      // Now listen to the stream
      await for (var bytes in response.stream) {
        bytesReceived += bytes.length;
        totalBytes.addAll(bytes);

        // Calculate progress
        onProgress(bytesReceived / length);
      }

      print('completed response');

      // Process the complete response data
      if (response.statusCode == 201) {
        var responseBody = utf8.decode(totalBytes);
        var decodedResponse = json.decode(responseBody);
        print(decodedResponse);
        String? videoUrl = decodedResponse['path'];
        onComplete(true, videoUrl);
      } else {
        var responseBody = utf8.decode(totalBytes);
        var decodedResponse = json.decode(responseBody);
        print('Error: ${decodedResponse['message']}');
        onComplete(false, null);
      }
    } catch (e) {
      onComplete(false, null);
      print('Upload error: $e');
    }
  }


  // Error dialog
  Future<void> _showErrorDialog(String message) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(message),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  // Update parent with selected media
  void _updateSelectedImages() {
    final selectedImages = <File>[];
    if (_image1 != null) selectedImages.add(_image1!);
    if (_image2 != null) selectedImages.add(_image2!);
    if (_image3 != null) selectedImages.add(_image3!);
    if (_image4 != null) selectedImages.add(_image4!);
    widget.onImagesSelected(selectedImages);
  }

  void _updateSelectedVideos() {
    final selectedVideos = <File>[];
    final selectedUrls = <String?>[];

    if (_video1 != null) {
      selectedVideos.add(_video1!);
      selectedUrls.add(_uploadedVideoUrl1);
    }
    if (_video2 != null) {
      selectedVideos.add(_video2!);
      selectedUrls.add(_uploadedVideoUrl2);
    }
    if (_video3 != null) {
      selectedVideos.add(_video3!);
      selectedUrls.add(_uploadedVideoUrl3);
    }
    if (_video4 != null) {
      selectedVideos.add(_video4!);
      selectedUrls.add(_uploadedVideoUrl4);
    }

    widget.onVideosSelected(selectedVideos, selectedUrls);
  }

  @override
  void dispose() {
    _controller1?.dispose();
    _controller2?.dispose();
    _controller3?.dispose();
    _controller4?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double fem = MediaQuery.of(context).size.width / 375;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Photos section
        const SizedBox(
          height: 60,
          child: Text(
            'Upload your photos to showcase talent and boost bookings!',
            textAlign: TextAlign.left,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.white,
              fontFamily: 'Be Vietnam Pro',
            ),
          ),
        ),

        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: _pickImage1,
                child: Container(
                  width: 150 * fem,
                  height: 170 * fem,
                  margin: const EdgeInsets.only(right: 16.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10 * fem),
                    border: Border.all(color: Colors.grey),
                  ),
                  child: _image1 != null
                      ? ClipRRect(
                    borderRadius: BorderRadius.circular(10 * fem),
                    child: Image.file(_image1!, fit: BoxFit.cover),
                  )
                      : const Icon(Icons.add, color: Colors.white),
                ),
              ),
              GestureDetector(
                onTap: _pickImage2,
                child: Container(
                  width: 150 * fem,
                  height: 170 * fem,
                  margin: const EdgeInsets.only(right: 16.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10 * fem),
                    border: Border.all(color: Colors.grey),
                  ),
                  child: _image2 != null
                      ? ClipRRect(
                    borderRadius: BorderRadius.circular(10 * fem),
                    child: Image.file(_image2!, fit: BoxFit.cover),
                  )
                      : const Icon(Icons.add, color: Colors.white),
                ),
              ),
              GestureDetector(
                onTap: _pickImage3,
                child: Container(
                  width: 150 * fem,
                  height: 170 * fem,
                  margin: const EdgeInsets.only(right: 16.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10 * fem),
                    border: Border.all(color: Colors.grey),
                  ),
                  child: _image3 != null
                      ? ClipRRect(
                    borderRadius: BorderRadius.circular(10 * fem),
                    child: Image.file(_image3!, fit: BoxFit.cover),
                  )
                      : const Icon(Icons.add, color: Colors.white),
                ),
              ),
            ],
          ),
        ),

        // Videos section
        const Padding(
          padding: EdgeInsets.fromLTRB(0, 20, 0, 0),
          child: SizedBox(
            height: 25,
            child: Text(
              'Upload your videos here',
              textAlign: TextAlign.left,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.white,
                fontFamily: 'Be Vietnam Pro',
              ),
            ),
          ),
        ),

        const Padding(
          padding: EdgeInsets.fromLTRB(0, 10, 0, 10),
          child: Text(
            'Keep the video duration within 30 seconds.',
            textAlign: TextAlign.left,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: Color(0xffe5195e),
              fontFamily: 'Be Vietnam Pro',
            ),
          ),
        ),

        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: _isLoading1 ? null : _pickVideo1,
                child: Container(
                  width: 150 * fem,
                  height: 170 * fem,
                  margin: const EdgeInsets.only(right: 16.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10 * fem),
                    border: Border.all(color: Colors.grey),
                  ),
                  child: _isLoading1
                      ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(
                        value: _uploadProgress1,
                      ),
                      const SizedBox(height: 10),
                      Text('${(_uploadProgress1 * 100).toStringAsFixed(0)}%',
                          style: const TextStyle(color: Colors.white))
                    ],
                  )
                      : _controller1 != null && _controller1!.value.isInitialized
                      ? ClipRRect(
                    borderRadius: BorderRadius.circular(10 * fem),
                    child: VideoPlayer(_controller1!),
                  )
                      : const Icon(Icons.add, color: Colors.white),
                ),
              ),
              GestureDetector(
                onTap: (_isLoading1 || _isLoading2) ? null : _pickVideo2,
                child: Opacity(
                  opacity: (_isLoading1 || _isLoading2) ? 0.5 : 1.0,
                  child: Container(
                    width: 150 * fem,
                    height: 170 * fem,
                    margin: const EdgeInsets.only(right: 16.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10 * fem),
                      border: Border.all(color: Colors.grey),
                    ),
                    child: _isLoading2
                        ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(
                          value: _uploadProgress2,
                        ),
                        const SizedBox(height: 10),
                        Text('${(_uploadProgress2 * 100).toStringAsFixed(0)}%',
                            style: const TextStyle(color: Colors.white))
                      ],
                    )
                        : _controller2 != null && _controller2!.value.isInitialized
                        ? ClipRRect(
                      borderRadius: BorderRadius.circular(10 * fem),
                      child: VideoPlayer(_controller2!),
                    )
                        : const Icon(Icons.add, color: Colors.white),
                  ),
                ),
              ),
              GestureDetector(
                onTap: (_isLoading1 || _isLoading2 || _isLoading3) ? null : _pickVideo3,
                child: Opacity(
                  opacity: (_isLoading1 || _isLoading2 || _isLoading3) ? 0.5 : 1.0,
                  child: Container(
                    width: 150 * fem,
                    height: 170 * fem,
                    margin: const EdgeInsets.only(right: 16.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10 * fem),
                      border: Border.all(color: Colors.grey),
                    ),
                    child: _isLoading3
                        ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(
                          value: _uploadProgress3,
                        ),
                        const SizedBox(height: 10),
                        Text('${(_uploadProgress3 * 100).toStringAsFixed(0)}%',
                            style: const TextStyle(color: Colors.white))
                      ],
                    )
                        : _controller3 != null && _controller3!.value.isInitialized
                        ? ClipRRect(
                      borderRadius: BorderRadius.circular(10 * fem),
                      child: VideoPlayer(_controller3!),
                    )
                        : const Icon(Icons.add, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}