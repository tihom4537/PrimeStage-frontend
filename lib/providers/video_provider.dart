import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';

class VideoSource {
  final String url;
  final bool isAsset;

  VideoSource({required this.url, this.isAsset = false});
}

final videoControllerProvider = Provider.family<VideoPlayerController, VideoSource>((ref, source) {
  final controller = source.isAsset
      ? VideoPlayerController.asset(source.url)
      : VideoPlayerController.networkUrl(Uri.parse(source.url));
  return controller;
});



class VideoState {
  final Map<String, VideoPlayerController> controllers;
  final Map<String, ChewieController?> chewieControllers;
  final Map<String, bool> initializedStates;

  VideoState({
    this.controllers = const {},
    this.chewieControllers = const {},
    this.initializedStates = const {},
  });

  VideoState copyWith({
    Map<String, VideoPlayerController>? controllers,
    Map<String, ChewieController?>? chewieControllers,
    Map<String, bool>? initializedStates,
  }) {
    return VideoState(
      controllers: controllers ?? this.controllers,
      chewieControllers: chewieControllers ?? this.chewieControllers,
      initializedStates: initializedStates ?? this.initializedStates,
    );
  }
}

class VideoStateNotifier extends StateNotifier<VideoState> {
  VideoStateNotifier() : super(VideoState());

  Future<void> initializeVideo(String videoUrl) async {
    if (state.initializedStates[videoUrl] == true) return;

    final controller = VideoPlayerController.networkUrl(Uri.parse(videoUrl));

    try {
      await controller.initialize();

      final chewieController = ChewieController(
        videoPlayerController: controller,
        aspectRatio: controller.value.aspectRatio,
        autoPlay: false,
        looping: false,
        allowMuting: true,
        allowPlaybackSpeedChanging: true,
        allowFullScreen: true,
      );

      state = state.copyWith(
        controllers: {...state.controllers, videoUrl: controller},
        chewieControllers: {...state.chewieControllers, videoUrl: chewieController},
        initializedStates: {...state.initializedStates, videoUrl: true},
      );
    } catch (e) {
      print('Error initializing video: $e');
      state = state.copyWith(
        initializedStates: {...state.initializedStates, videoUrl: false},
      );
    }
  }

  void dispose() {
    for (var controller in state.controllers.values) {
      controller.dispose();
    }
    for (var controller in state.chewieControllers.values) {
      controller?.dispose();
    }
  }
}

final videoStateProvider = StateNotifierProvider<VideoStateNotifier, VideoState>((ref) {
  return VideoStateNotifier();
});

// Provider for current video index
final currentVideoIndexProvider = StateProvider<int>((ref) => 0);

// Provider for video playing state
final isVideoPlayingProvider = StateProvider<bool>((ref) => false);