import 'dart:convert';
import 'dart:io';

import 'package:flourish/data/plant_info.dart';
import 'package:flourish/util/stored_preferences.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

class LocalStorage {
  static final _plantsFile = "plantCollection.json";

  static Future<Map<File, PlantInfo>> loadPlantData(bool includeDefaultIfAbsent) async {
    final Directory appDocumentsDirectory =
        await getApplicationDocumentsDirectory();

    if (!await appDocumentsDirectory.exists()) {
      return {};
    }
    final file = File("${appDocumentsDirectory.path}/$_plantsFile");
    if (!await file.exists()) {
      return includeDefaultIfAbsent ? await loadDefaultPlants() : {};
    }
    Map<String, dynamic> json = jsonDecode(await file.readAsString());
    return json.map((key, value) {
      PlantInfo p = PlantInfo.fromJson(value);
      return MapEntry(File(key), p);
    });
  }

  static Future<Map<String, dynamic>> readPlantDataJson() async {
    final Directory appDocumentsDirectory =
        await getApplicationDocumentsDirectory();

    if (!await appDocumentsDirectory.exists()) {
      return {};
    }
    final file = File("${appDocumentsDirectory.path}/$_plantsFile");
    if (!await file.exists()) {
      return {};
    }
    return jsonDecode(await file.readAsString());
  }

  static Future<void> writePlantData(PlantInfo plantInfo, String key) async {
    final Directory appDocumentsDirectory =
        await getApplicationDocumentsDirectory();

    if (!await appDocumentsDirectory.exists()) {
      appDocumentsDirectory.create();
    }
    final file = File("${appDocumentsDirectory.path}/$_plantsFile");
    if (!await file.exists()) {
      await file.writeAsString(
        jsonEncode(
          plantInfo.toJsonWithKey(key),
        ),
      );
    } else {
      Map<String, dynamic> json = jsonDecode(await file.readAsString());
      json[key] = plantInfo.toJson();
      await file.writeAsString(jsonEncode(json));
    }
  }

  static Future<File?> saveImage(String name, File image) async {
    final Directory appDocumentsDirectory =
        await getApplicationDocumentsDirectory();
    final file = File("${appDocumentsDirectory.path}/$name.png");
    image.copy(file.path);
    return file;
  }

  static Future<Map<File, PlantInfo>> loadDefaultPlants() async {
    PlantInfo leucojumVernum = PlantInfo.fromJson(jsonDecode(await rootBundle
        .loadString("default_plants/plantInfo/leucojum_vernum.json")));
    PlantInfo hibiscusRosaSinensis = PlantInfo.fromJson(jsonDecode(
        await rootBundle.loadString(
            "default_plants/plantInfo/hibiscus_rosa_sinensis.json")));
    File? leucojumVernumImage = await _getImageFileFromAssets(
        "default_plants/images", "leucojum_vernum.jpg");
    LocalStorage.saveImage(
      leucojumVernum.bestMatchName,
      leucojumVernumImage,
    );
    File? hibiscusRosaSinensisImage = await _getImageFileFromAssets(
        "default_plants/images", "hibiscus_rosa_sinensis.jpg");
    await LocalStorage.saveImage(
      leucojumVernum.bestMatchName,
      hibiscusRosaSinensisImage,
    );
    return {
      leucojumVernumImage: leucojumVernum,
      hibiscusRosaSinensisImage: hibiscusRosaSinensis,
    };
  }

  // Only used for default plants
  static Future<File> _getImageFileFromAssets(
      String assetPath, String assetName) async {
    try {
      final byteData = await rootBundle.load("$assetPath/$assetName");

      Directory? tempDir = await getTemporaryDirectory();

      final file = File("${tempDir.path}/$assetName");

      await file.writeAsBytes(byteData.buffer.asUint8List());

      if (await file.exists()) {
        return file;
      } else {
        throw Exception("Failed to create file for $assetName");
      }
    } catch (e) {
      rethrow;
    }
  }
}
