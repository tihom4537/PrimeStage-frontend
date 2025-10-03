import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_player/video_player.dart';
import 'package:visibility_detector/visibility_detector.dart';
import '../providers/video_provider.dart';

class CustomVideoPlayer extends ConsumerStatefulWidget {
  final String source;
  final bool isAsset;

  CustomVideoPlayer({
    required this.source,
    this.isAsset = false,
  });

  @override
  _CustomVideoPlayerState createState() => _CustomVideoPlayerState();
}

class _CustomVideoPlayerState extends ConsumerState<CustomVideoPlayer> {
  late VideoPlayerController _controller;
  bool _isInitialized = false;
  bool _isPlaying = false;
  bool _isDisposed = false;
  DateTime? _lastVisibilityChange;

  @override
  void initState() {
    super.initState();
    _controller = ref.read(videoControllerProvider(
      VideoSource(url: widget.source, isAsset: widget.isAsset),
    ));
    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    try {
      await _controller.initialize();
      _controller.setLooping(true);
      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }
    } catch (e) {
      print("Error initializing video: $e");
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    _controller.dispose();
    super.dispose();
  }

  void _playPauseVideo(bool visible) async {
    if (_isDisposed || !_isInitialized) return;

    await Future.delayed(Duration(milliseconds: 100));

    if (visible && !_isPlaying) {
      _controller.play();
      setState(() {
        _isPlaying = true;
      });
    } else if (!visible && _isPlaying) {
      _controller.pause();
      setState(() {
        _isPlaying = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: Key(widget.source),
      onVisibilityChanged: (visibilityInfo) {
        var now = DateTime.now();
        if (_lastVisibilityChange != null &&
            now.difference(_lastVisibilityChange!) < Duration(milliseconds: 200)) {
          return;
        }
        _lastVisibilityChange = now;

        var visiblePercentage = visibilityInfo.visibleFraction * 100;
        _playPauseVideo(visiblePercentage > 30);
      },
      child: _isInitialized
          ? AspectRatio(
        aspectRatio: _controller.value.aspectRatio,
        child: VideoPlayer(_controller),
      )
          : Center(child: CircularProgressIndicator()),
    );
  }
}