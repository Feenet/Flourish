import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flourish/env.dart';
import 'package:flourish/data/plant_info.dart';
import 'package:flourish/error/plant_info_errors.dart';
import 'package:path/path.dart';
import 'package:http_parser/http_parser.dart';

class PlantInfoService {
  final http.Client _client;
  final String _apiUrl = "${Env.apiUrl}?api-key=${Env.apiKey}";

  PlantInfoService(this._client);

  Future<PlantInfo> fetchPlantInfo(File plantImage) async {
    final uri = Uri.parse(_apiUrl);
    final request = http.MultipartRequest("POST", uri);
    request.files.add(
      await http.MultipartFile.fromPath(
        'images',
        plantImage.path,
        filename: plantImage.path,
        contentType: getMediaType(plantImage.path),
      ),
    );

    final responseStream = await _client.send(request);
    final response = await http.Response.fromStream(responseStream);
    switch (response.statusCode) {
      case 200:
        return PlantInfo.fromJson(jsonDecode(response.body));
      case 400:
        throw Exception('Bad request: ${response.body}');
      case 401:
        throw Exception('Unauthorized - check your API key');
      case 404:
        throw PlantNotFoundException('Plant not found');
      case 429:
        throw Exception('API rate limit exceeded');
      default:
        throw Exception('API Error ${response.statusCode}: ${response.body}');
    }
  }

  MediaType getMediaType(String filePath) {
    final ext = extension(filePath).toLowerCase();
    if (ext == '.png') {
      return MediaType('image', 'png');
    } else {
      return MediaType('image', 'jpeg');
    }
  }
}
