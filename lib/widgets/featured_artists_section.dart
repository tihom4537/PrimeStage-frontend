import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../page-1/artist_showcase.dart';

class FeaturedArtistsSection extends ConsumerWidget {
  final List<dynamic> artists;
  final double fem;
  final double ffem;

  const FeaturedArtistsSection({
    required this.artists,
    required this.fem,
    required this.ffem,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.fromLTRB(15 * fem, 38 * fem, 0 * fem, 0 * fem),
          child: Text(
            'Master Performers',
            style: TextStyle(
              fontSize: 22 * ffem,
              fontWeight: FontWeight.w400,
              color: Colors.white,
            ),
          ),
        ),
        Container(
          height: 350 * fem,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: artists.length,
            itemBuilder: (context, index) {
              final artist = artists[index];
              return Container(
                margin: EdgeInsets.only(right: 0 * fem),
                width: 180 * fem,
                padding: EdgeInsets.fromLTRB(12 * fem, 16 * fem, 0 * fem, 10 * fem),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: () {
                        String id = artist['id'].toString();
                        String isTeam = artist['team'] ?? 'false';
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ArtistProfile(
                              artist_id: id,
                              isteam: isTeam,
                            ),
                          ),
                        );
                      },
                      child: Container(
                        margin: EdgeInsets.only(bottom: 12 * fem),
                        width: 175 * fem,
                        height: 223 * fem,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12 * fem),
                          child: Image.network(
                            artist['image'] ?? '',
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                    Text(
                      artist['name'] ?? '',
                      style: TextStyle(
                        fontSize: 17 * ffem,
                        fontWeight: FontWeight.w600,
                        height: 1.5 * ffem / fem,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 3 * fem),
                    Row(
                      children: [
                        Text(
                          artist['skill'] ?? '',
                          style: TextStyle(
                            fontSize: 16 * ffem,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF9E9EB8),
                          ),
                        ),
                        Spacer(),
                        Padding(
                          padding: EdgeInsets.fromLTRB(0, 0, 5 * fem, 0),
                          child: Text(
                            '${artist['average_rating']}/5',
                            style: TextStyle(
                              fontSize: 16 * ffem,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF9E9EB8),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}