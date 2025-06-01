import 'dart:io';

import 'package:flourish/data/plant_info.dart';
import 'package:flourish/util/local_storage.dart';
import 'package:flutter/widgets.dart';

class PlantCollectionModel extends ChangeNotifier {

  Map<File, PlantInfo> _plants = {};

  Map<File, PlantInfo> get plants => _plants;

  PlantCollectionModel(Map<File, PlantInfo> plants) {
    _plants = plants;
  }

  Future<void> addPlant(File plantImage, PlantInfo plantInfo) async {
    // Save image and info to local storage
    final imageFile = await LocalStorage.saveImage(
        plantInfo.bestMatchName, plantImage);
    if (imageFile != null) {
      await LocalStorage.writePlantData(plantInfo, plantImage.path);

      plants[imageFile] = plantInfo;
    }

    notifyListeners();
  }
}
