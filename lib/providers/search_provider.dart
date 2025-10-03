import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config.dart';

// Add this provider for secure storage
final secureStorageProvider = Provider<FlutterSecureStorage>((ref) {
  return const FlutterSecureStorage();
});

final searchServiceProvider = Provider((ref) => SearchService(ref));

class SearchService {
  final Ref ref;
  SearchService(this.ref);

  Future<List<Map<String, dynamic>>> searchArtists(String searchTerm) async {
    final storage = ref.read(secureStorageProvider);
    String? latitude = await storage.read(key: 'latitude');
    String? longitude = await storage.read(key: 'longitude');

    final String apiUrl1 = '${Config().apiDomain}/artist/search';
    final String apiUrl2 = '${Config().apiDomain}/team/search';

    final Uri uri1 = Uri.parse(apiUrl1).replace(queryParameters: {
      'skill': searchTerm,
      'lat': latitude,
      'lng': longitude,
    });

    final Uri uri2 = Uri.parse(apiUrl2).replace(queryParameters: {
      'skill': searchTerm,
      'lat': latitude,
      'lng': longitude,
    });

    try {
      final responses = await Future.wait([
        http.get(uri1, headers: {
          'Content-Type': 'application/vnd.api+json',
          'Accept': 'application/vnd.api+json',
        }),
        http.get(uri2, headers: {
          'Content-Type': 'application/vnd.api+json',
          'Accept': 'application/vnd.api+json',
        }),
      ]);

      final response1 = responses[0];
      final response2 = responses[1];

      if (response1.statusCode == 200 && response2.statusCode == 200) {
        List<dynamic> data1 = jsonDecode(response1.body);
        List<dynamic> data2 = jsonDecode(response2.body);

        List<Map<String, dynamic>> mergedData = [
          ...data1.map((artist) => {
            ...artist as Map<String, dynamic>,
            'profile_photo': artist['profile_photo'],
            'isTeam': 'false',
          }),
          ...data2.map((artist) => {
            ...artist as Map<String, dynamic>,
            'profile_photo': artist['profile_photo'],
            'isTeam': 'true',
          }),
        ];
        return mergedData;
      }
    } catch (e) {
      print('Error occurred: $e');
    }
    return [];
  }
}