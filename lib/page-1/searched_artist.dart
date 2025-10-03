import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;
import 'artist_showcase.dart';

class FilterDialog extends StatefulWidget {
  final Function(Map<String, dynamic>) onApplyFilters;
  final List<Map<String, dynamic>> artistData;

  FilterDialog({required this.onApplyFilters, required this.artistData});

  @override
  _FilterDialogState createState() => _FilterDialogState();
}

class _FilterDialogState extends State<FilterDialog> {
  String _selectedGenre = 'All Skills';
  int _selectedPriceIndex = 0;

  List<String> _genres = ['All Skills'];

  // Price intervals
  List<Map<String, dynamic>> _priceIntervals = [
    {'label': '₹0 - ₹5,000', 'min': 0, 'max': 5000},
    {'label': '₹5,000 - ₹10,000', 'min': 5000, 'max': 10000},
    {'label': '₹10,000 - ₹15,000', 'min': 10000, 'max': 15000},
    {'label': '₹15,000 - ₹20,000', 'min': 15000, 'max': 20000},
    {'label': '₹20,000 - ₹50,000', 'min': 20000, 'max': 50000},
    {'label': '₹50,000 - ₹1,00,000', 'min': 50000, 'max': 100000},
    {'label': '₹1,00,000 - ₹3,00,000', 'min': 100000, 'max': 300000},
    {'label': '₹3,00,000 - ₹10,00,000', 'min': 300000, 'max': 1000000},
  ];

  @override
  void initState() {
    super.initState();
    _mapArtistSkills();
  }

  void _mapArtistSkills() {
    Set<String> skillsSet = {};

    for (var artist in widget.artistData) {
      // Handle comma-separated skills string
      if (artist['skills'] != null && artist['skills'].toString().isNotEmpty) {
        String skillsString = artist['skills'].toString();
        List<String> skillsList = skillsString.split(',');
        for (var skill in skillsList) {
          String trimmedSkill = skill.trim();
          if (trimmedSkill.isNotEmpty) {
            skillsSet.add(trimmedSkill);
          }
        }
      }

      // Also check skill_category as fallback
      if (artist['skill_category'] != null && artist['skill_category'].toString().isNotEmpty) {
        skillsSet.add(artist['skill_category'].toString().trim());
      }
    }

    setState(() {
      _genres = ['All Skills', ...skillsSet.toList()..sort()];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: BoxDecoration(
        color: Color(0xFFF5F5F5),
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Filters',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: Colors.grey[400],
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 10),

                  // Filters label
                  Text(
                    'Filters',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),

                  SizedBox(height: 25),

                  // Skills Filter
                  Text(
                    'Skills',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedGenre,
                        isExpanded: true,
                        icon: Icon(Icons.keyboard_arrow_down, color: Colors.grey[600]),
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 16,
                        ),
                        items: _genres.map((String genre) {
                          return DropdownMenuItem<String>(
                            value: genre,
                            child: Text(genre),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            _selectedGenre = newValue!;
                          });
                        },
                      ),
                    ),
                  ),

                  SizedBox(height: 25),

                  // Pricing Filter
                  Text(
                    'Pricing',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 15),

                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      activeTrackColor: Color(0xFF2196F3),
                      inactiveTrackColor: Colors.grey[300],
                      thumbColor: Color(0xFF2196F3),
                      overlayColor: Color(0xFF2196F3).withOpacity(0.2),
                      thumbShape: RoundSliderThumbShape(enabledThumbRadius: 12),
                      trackHeight: 4,
                    ),
                    child: Slider(
                      value: _selectedPriceIndex.toDouble(),
                      min: 0,
                      max: (_priceIntervals.length - 1).toDouble(),
                      divisions: _priceIntervals.length - 1,
                      onChanged: (value) {
                        setState(() {
                          _selectedPriceIndex = value.round();
                        });
                      },
                    ),
                  ),

                  // Price range labels
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '₹0',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          '₹3,00,000',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 10),

                  // Selected price display
                  Center(
                    child: Text(
                      'Selected Price: ${_priceIntervals[_selectedPriceIndex]['label']}',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),

                  SizedBox(height: 40),
                ],
              ),
            ),
          ),

          // Apply Filters and Clear Filters Buttons
          Container(
            padding: EdgeInsets.all(20),
            child: Column(
              children: [
                // Apply Filters Button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      widget.onApplyFilters({
                        'skill': _selectedGenre,
                        'priceRange': _priceIntervals[_selectedPriceIndex],
                      });
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF1A365D),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      'Apply Filters',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),

                SizedBox(height: 12),

                // Clear Filters Button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: OutlinedButton(
                    onPressed: () {
                      widget.onApplyFilters({
                        'skill': 'All Skills',
                        'priceRange': _priceIntervals[0], // Reset to first price range
                        'clearFilters': true,
                      });
                      Navigator.pop(context);
                    },
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Color(0xFF1A365D), width: 2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      backgroundColor: Colors.white,
                    ),
                    child: Text(
                      'Clear Filters',
                      style: TextStyle(
                        color: Color(0xFF1A365D),
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Keep all your existing classes below (SimpleImageCacheManager, SearchedArtistState, etc.)
class SimpleImageCacheManager {
  static void clearMemoryCache() {
    PaintingBinding.instance.imageCache.clear();
    PaintingBinding.instance.imageCache.clearLiveImages();
  }

  static void configureImageCache() {
    PaintingBinding.instance.imageCache.maximumSize = 100;
    PaintingBinding.instance.imageCache.maximumSizeBytes = 50 * 1024 * 1024;
  }

  static void clearSpecificImage(String imageUrl) {
    PaintingBinding.instance.imageCache.evict(NetworkImage(imageUrl));
  }
}

class SearchedArtistState {
  final List<Map<String, dynamic>> artistData;
  final bool isLoading;

  SearchedArtistState({
    required this.artistData,
    this.isLoading = false,
  });

  SearchedArtistState copyWith({
    List<Map<String, dynamic>>? artistData,
    bool? isLoading,
  }) {
    return SearchedArtistState(
      artistData: artistData ?? this.artistData,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class SearchedArtistNotifier extends StateNotifier<SearchedArtistState> {
  SearchedArtistNotifier(List<Map<String, dynamic>> initialData)
      : super(SearchedArtistState(artistData: initialData));

  void clearUnusedImages() {
    for (var artist in state.artistData) {
      String? imageUrl = artist['profile_photo'];
      if (imageUrl != null && imageUrl.isNotEmpty) {
        SimpleImageCacheManager.clearSpecificImage(imageUrl);
      }
    }
  }
}

final searchedArtistProvider = StateNotifierProvider.family<
    SearchedArtistNotifier,
    SearchedArtistState,
    List<Map<String, dynamic>>>(
      (ref, initialData) => SearchedArtistNotifier(initialData),
);

class SearchedArtist extends ConsumerStatefulWidget {
  final List<Map<String, dynamic>> filteredArtistData;

  SearchedArtist({required this.filteredArtistData});

  @override
  ConsumerState<SearchedArtist> createState() => _SearchedArtistState();
}

class _SearchedArtistState extends ConsumerState<SearchedArtist>
    with AutomaticKeepAliveClientMixin<SearchedArtist> {
  List<Map<String, dynamic>> _filteredData = [];

  @override
  void initState() {
    super.initState();
    _filteredData = widget.filteredArtistData;
  }

  @override
  bool get wantKeepAlive => true;

  @override
  void dispose() {
    ref
        .read(searchedArtistProvider(widget.filteredArtistData).notifier)
        .clearUnusedImages();
    super.dispose();
  }

  void _showFilterDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => FilterDialog(
        artistData: widget.filteredArtistData,
        onApplyFilters: (filters) {
          setState(() {
            // Check if filters should be cleared
            if (filters['clearFilters'] == true) {
              _filteredData = widget.filteredArtistData; // Show all artists
            } else {
              _filteredData = widget.filteredArtistData.where((artist) {
                // Skills filter - Updated to handle comma-separated skills
                bool passesSkill = filters['skill'] == 'All Skills';

                if (!passesSkill && artist['skills'] != null) {
                  String skillsString = artist['skills'].toString();
                  if (skillsString.isNotEmpty) {
                    List<String> artistSkills = skillsString.split(',')
                        .map((skill) => skill.trim())
                        .toList();
                    passesSkill = artistSkills.contains(filters['skill']);
                  }
                }

                // Also check skill_category as fallback
                if (!passesSkill && artist['skill_category'] != null) {
                  passesSkill = artist['skill_category'].toString().trim() == filters['skill'];
                }

                // Price filter
                bool passesPrice = true;
                if (artist['price_per_hour'] != null) {
                  // Parse as double first, then convert to int to handle decimal values
                  double priceDouble = double.tryParse(artist['price_per_hour'].toString()) ?? 0.0;
                  int artistPrice = priceDouble.toInt();
                  passesPrice = artistPrice >= filters['priceRange']['min'] &&
                      artistPrice <= filters['priceRange']['max'];
                }

                return passesSkill && passesPrice;
              }).toList();
            }
          });
        },
      ),
    );
  }

  Widget _buildArtistCard(
      Map<String, dynamic> artist, double fem, double ffem) {
    return GestureDetector(
      onTap: () {
        final isTeam = artist['isTeam'];
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ArtistProfile(
              artist_id: artist['id'].toString(),
              isteam: isTeam,
            ),
          ),
        );
      },
      child: Theme(
        data: Theme.of(context).copyWith(cardColor: Colors.white),
        child: Card(
          color: Colors.white,
          margin: EdgeInsets.fromLTRB(27 * fem, 20 * fem, 27 * fem, 20 * fem),
          elevation: 22,
          shadowColor: Color(0xFFE9E8E6),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12 * fem),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 310.66 * fem,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(14 * fem),
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(14 * fem),
                    topRight: Radius.circular(14 * fem),
                  ),
                  child: buildSimpleImage(artist['profile_photo'], fem),
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(
                    16 * fem, 25 * fem, 16 * fem, 25 * fem),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      artist['name'] ?? artist['team_name'] ?? '',
                      style: TextStyle(
                        fontSize: 22 * ffem,
                        fontWeight: FontWeight.w400,
                        height: 1.25 * ffem / fem,
                        letterSpacing: 0.703 * fem,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: 8 * fem),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Skill: ${artist['skill_category']}',
                          style: TextStyle(
                            fontSize: 17 * ffem,
                            fontWeight: FontWeight.w400,
                            height: 1.5 * ffem / fem,
                            color: Color(0xFF8E8EAA),
                          ),
                        ),
                        Text(
                          'Rating: ${artist['average_rating']}/5',
                          style: TextStyle(
                            fontSize: 17 * ffem,
                            fontWeight: FontWeight.w400,
                            height: 1.5 * ffem / fem,
                            color: Color(0xFF8E8EAA),
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
  }

  Widget buildSimpleImage(String? imageUrl, double fem) {
    if (imageUrl == null || imageUrl.isEmpty) {
      return Center(
        child: Icon(
          Icons.person,
          color: Colors.grey,
          size: 50 * fem,
        ),
      );
    }

    return Image.network(
      imageUrl,
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Container(
          color: Colors.grey[200],
          child: Center(
            child: CircularProgressIndicator(
              strokeWidth: 2,
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded /
                  loadingProgress.expectedTotalBytes!
                  : null,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.grey),
            ),
          ),
        );
      },
      errorBuilder: (context, error, stackTrace) {
        return Center(
          child: Icon(
            Icons.error,
            color: Colors.red,
            size: 50 * fem,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    double baseWidth = 390;
    double fem = MediaQuery.of(context).size.width / baseWidth;
    double ffem = fem * 0.97;

    return Scaffold(
      backgroundColor: Color(0xFFF7F6F4),
      appBar: AppBar(
        title: Padding(
          padding: const EdgeInsets.fromLTRB(0, 0, 50, 0),
          child: Center(
            child: Text(
              'Artists',
              style: TextStyle(
                color: Colors.black,
                fontSize: 24,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
        backgroundColor: Color(0xFFFEFEFE),
        leading: IconButton(
          color: Colors.black,
          icon: Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: IconButton(
              icon: Icon(Icons.filter_list),
              color: Colors.black,
              onPressed: _showFilterDialog,
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: _filteredData.isNotEmpty
            ? ListView.builder(
          cacheExtent: 1000.0,
          addAutomaticKeepAlives: true,
          addRepaintBoundaries: true,
          itemCount: _filteredData.length,
          itemBuilder: (context, index) =>
              _buildArtistCard(_filteredData[index], fem, ffem),
        )
            : Center(
          child: Text(
            "No artists found matching your filters.",
            style: TextStyle(
              color: Colors.black,
              fontSize: 20 * ffem,
              fontWeight: FontWeight.w400,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}