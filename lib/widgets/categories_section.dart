import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../page-1/searched_artist.dart';
import '../providers/search_provider.dart'; // Add this import

class CategoriesSection extends ConsumerWidget {
  final List<dynamic> categories;
  final double fem;
  final double ffem;

  const CategoriesSection({
    required this.categories,
    required this.fem,
    required this.ffem,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchService = ref.watch(searchServiceProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.fromLTRB(12 * fem, 10 * fem, 0 * fem, 18 * fem),
          child: Text(
            'Categories',
            style: TextStyle(
              fontSize: 22 * ffem,
              fontWeight: FontWeight.w400,
              color: Colors.white,
            ),
          ),
        ),
        GridView.builder(
          padding: EdgeInsets.fromLTRB(12 * fem, 0 * fem, 12 * fem, 30 * fem),
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 15.0 * fem,
            mainAxisSpacing: 15.0 * fem,
            childAspectRatio: 2.5 * fem,
          ),
          itemCount: categories.length,
          itemBuilder: (context, index) {
            final category = categories[index];
            if (category == null) {
              return SizedBox();
            }

            return GestureDetector(
              onTap: () async {
                if (category['name'] != null) {
                  final filteredData = await searchService.searchArtists(category['name']);
                  if (context.mounted) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SearchedArtist(filteredArtistData: filteredData),
                      ),
                    );
                  }
                }
              },
              child: Container(
                height: 83.0,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  gradient: LinearGradient(
                    begin: Alignment(0, 1),
                    end: Alignment(0, -1),
                    colors: <Color>[
                      Color(0x66000000),
                      Color(0x00000000),
                      Color(0x1A000000),
                      Color(0x00000000),
                    ],
                    stops: <double>[0, 1, 1, 1],
                  ),
                  image: category['image'] != null
                      ? DecorationImage(
                    fit: BoxFit.cover,
                    image: NetworkImage(category['image']),
                  )
                      : DecorationImage(
                    fit: BoxFit.cover,
                    image: AssetImage('assets/page-1/images/depth-4-frame-0-Kvf.png'),
                  ),
                ),
                child: Align(
                  alignment: Alignment.bottomLeft,
                  child: Container(
                    margin: EdgeInsets.all(16),
                    child: Text(
                      category['name'] ?? '',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        height: 1.3,
                        color: Color(0xFFFFFFFF),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}