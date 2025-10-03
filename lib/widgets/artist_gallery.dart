// lib/widgets/artist_gallery.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/artist_provider.dart';

class ArtistGallery extends ConsumerWidget {
  final double fem;
  final double ffem;

  const ArtistGallery({
    Key? key,
    required this.fem,
    required this.ffem,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final artistState = ref.watch(artistStateProvider);
    final images = artistState.imagePathsFromBackend;

    return Container(
      margin: EdgeInsets.fromLTRB(7 * fem, 15, 0 * fem, 0),
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(8.0 * fem, 0, 0, 0),
            child: Text(
              'Gallery',
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
              itemCount: images.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => FullScreenGallery(
                          images: images,
                          initialIndex: index,
                          fem: fem,
                        ),
                      ),
                    );
                  },
                  child: Container(
                    width: 160 * fem,
                    margin: EdgeInsets.symmetric(horizontal: 5.5 * fem),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(9 * fem),
                      child: Image.network(
                        images[index],
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey[200],
                            child: Icon(Icons.error),
                          );
                        },
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class FullScreenGallery extends ConsumerStatefulWidget {
  final List<String> images;
  final int initialIndex;
  final double fem;

  const FullScreenGallery({
    Key? key,
    required this.images,
    required this.initialIndex,
    required this.fem,
  }) : super(key: key);

  @override
  ConsumerState<FullScreenGallery> createState() => _FullScreenGalleryState();
}

class _FullScreenGalleryState extends ConsumerState<FullScreenGallery> {
  late PageController _pageController;
  late int currentIndex;

  @override
  void initState() {
    super.initState();
    currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: currentIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          '${currentIndex + 1}/${widget.images.length}',
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: PageView.builder(
        controller: _pageController,
        itemCount: widget.images.length,
        onPageChanged: (index) {
          setState(() {
            currentIndex = index;
          });
        },
        itemBuilder: (context, index) {
          return InteractiveViewer(
            minScale: 0.5,
            maxScale: 3.0,
            child: Center(
              child: Image.network(
                widget.images[index],
                fit: BoxFit.contain,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Center(
                    child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                          loadingProgress.expectedTotalBytes!
                          : null,
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error, color: Colors.red, size: 48),
                        SizedBox(height: 8),
                        Text(
                          'Image failed to load',
                          style: TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}