// lib/widgets/artist_videos.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import '../providers/video_provider.dart';
import '../providers/artist_provider.dart';

class ArtistVideos extends ConsumerWidget {
  final double fem;
  final double ffem;

  const ArtistVideos({
    Key? key,
    required this.fem,
    required this.ffem,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final artistState = ref.watch(artistStateProvider);
    final videos = artistState.videoPathsFromBackend;
    final thumbnails = artistState.thumbnailPathsFromBackend;

    return Container(
      margin: EdgeInsets.fromLTRB(7 * fem, 25 * fem, 0 * fem, 0),
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(8.0 * fem, 0, 0, 0),
            child: Text(
              'Video Samples',
              style: TextStyle(
                fontSize: 22 * ffem,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
          ),
          SizedBox(height: 12 * fem),
          SizedBox(
            height: 200 * fem,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: videos.length,
              itemBuilder: (context, index) {
                return CarouselVideoItem(
                  videoUrl: videos[index],
                  thumbnailUrl: index < thumbnails.length ? thumbnails[index] : '',
                  fem: fem,
                  index: index,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class CarouselVideoItem extends ConsumerWidget {
  final String videoUrl;
  final String thumbnailUrl;
  final double fem;
  final int index;

  const CarouselVideoItem({
    Key? key,
    required this.videoUrl,
    required this.thumbnailUrl,
    required this.fem,
    required this.index,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return VideoThumbnail(
      videoUrl: videoUrl,
      thumbnailUrl: thumbnailUrl,
      fem: fem,
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => FullScreenVideoView(
              videoUrl: videoUrl,
              allVideos: ref.read(artistStateProvider).videoPathsFromBackend,
              allThumbnails: ref.read(artistStateProvider).thumbnailPathsFromBackend,
              initialIndex: index,
            ),
          ),
        );
      },
    );
  }
}

class VideoThumbnail extends ConsumerWidget {
  final String videoUrl;
  final String thumbnailUrl;
  final double fem;
  final VoidCallback onTap;

  const VideoThumbnail({
    Key? key,
    required this.videoUrl,
    required this.thumbnailUrl,
    required this.fem,
    required this.onTap,
  }) : super(key: key);

  String? getYoutubeId(String url) {
    return YoutubePlayer.convertUrlToId(url);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final youtubeId = getYoutubeId(videoUrl);
    final isYouTube = youtubeId != null;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 170 * fem,
        margin: EdgeInsets.symmetric(horizontal: 5.0 * fem),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(9 * fem),
          child: Stack(
            alignment: Alignment.center,
            children: [
              if (isYouTube)
                Image.network(
                  'https://img.youtube.com/vi/$youtubeId/0.jpg',
                  fit: BoxFit.cover,
                  height: double.infinity,
                  width: double.infinity,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.black87,
                      height: double.infinity,
                      width: double.infinity,
                    );
                  },
                )
              else if (thumbnailUrl.isNotEmpty)
                Image.network(
                  thumbnailUrl,
                  fit: BoxFit.cover,
                  height: double.infinity,
                  width: double.infinity,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.black87,
                      height: double.infinity,
                      width: double.infinity,
                    );
                  },
                )
              else
                Container(
                  color: Colors.black87,
                  height: double.infinity,
                  width: double.infinity,
                ),
              Icon(
                Icons.play_circle_outline,
                color: Colors.white,
                size: 40 * fem,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class FullScreenVideoView extends ConsumerStatefulWidget {
  final String videoUrl;
  final List<String> allVideos;
  final List<String> allThumbnails;
  final int initialIndex;

  const FullScreenVideoView({
    Key? key,
    required this.videoUrl,
    required this.allVideos,
    required this.allThumbnails,
    required this.initialIndex,
  }) : super(key: key);

  @override
  ConsumerState<FullScreenVideoView> createState() => _FullScreenVideoViewState();
}

class _FullScreenVideoViewState extends ConsumerState<FullScreenVideoView> {
  late PageController _pageController;
  late int currentIndex;
  bool isVirtualLandscape = true;

  @override
  void initState() {
    super.initState();
    currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: currentIndex);
    ref.read(videoStateProvider.notifier).initializeVideo(widget.videoUrl);
  }

  @override
  void dispose() {
    _pageController.dispose();
    ref.read(videoStateProvider.notifier).dispose();
    super.dispose();
  }

  void toggleVirtualLandscape() {
    setState(() {
      isVirtualLandscape = !isVirtualLandscape;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: isVirtualLandscape
          ? null
          : AppBar(
        backgroundColor: Colors.transparent,
        iconTheme: IconThemeData(color: Colors.white),
        title: Text(
          '${currentIndex + 1}/${widget.allVideos.length}',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: SafeArea(
        child: Stack(
          children: [
            Center(
              child: isVirtualLandscape
                  ? RotatedBox(
                quarterTurns: 1,
                child: Container(
                  width: screenSize.height,
                  height: screenSize.width,
                  child: _buildVideoPlayer(),
                ),
              )
                  : _buildVideoPlayer(),
            ),
            _buildControls(),
          ],
        ),
      ),
    );
  }

  Widget _buildVideoPlayer() {
    final videoState = ref.watch(videoStateProvider);

    return PageView.builder(
      controller: _pageController,
      itemCount: widget.allVideos.length,
      onPageChanged: (index) {
        setState(() {
          currentIndex = index;
        });
        ref.read(videoStateProvider.notifier)
            .initializeVideo(widget.allVideos[index]);
      },
      scrollDirection: isVirtualLandscape ? Axis.vertical : Axis.horizontal,
      itemBuilder: (context, index) {
        final videoUrl = widget.allVideos[index];
        final isInitialized = videoState.initializedStates[videoUrl] ?? false;

        if (!isInitialized) {
          return Center(
            child: Stack(
              alignment: Alignment.center,
              children: [
                if (index < widget.allThumbnails.length &&
                    widget.allThumbnails[index].isNotEmpty)
                  Image.network(
                    widget.allThumbnails[index],
                    fit: BoxFit.contain,
                    width: double.infinity,
                    height: double.infinity,
                  ),
                CircularProgressIndicator(color: Colors.white),
              ],
            ),
          );
        }

        final youtubeId = YoutubePlayer.convertUrlToId(videoUrl);
        if (youtubeId != null) {
          return YoutubePlayer(
            controller: YoutubePlayerController(
              initialVideoId: youtubeId,
              flags: YoutubePlayerFlags(
                autoPlay: true,
                mute: false,
              ),
            ),
          );
        }

        return Chewie(
          controller: videoState.chewieControllers[videoUrl]!,
        );
      },
    );
  }

  Widget _buildControls() {
    return Stack(
      children: [
        Positioned(
          top: 16,
          right: 16,
          child: IconButton(
            icon: Icon(
              isVirtualLandscape ? Icons.screen_rotation : Icons.stay_current_portrait,
              color: Colors.white,
            ),
            onPressed: toggleVirtualLandscape,
          ),
        ),
        if (isVirtualLandscape)
          Positioned(
            top: 16,
            left: 16,
            child: IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
      ],
    );
  }
}