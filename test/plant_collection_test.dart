import 'dart:convert';
import 'dart:io';

import 'package:flourish/data/plant_info.dart';
import 'package:flutter_test/flutter_test.dart';

import 'util/test_util.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  group('Plant Collection Test', () {
    test('PlantCollection New Plant JSON Serialization/Deserialization',
        () async {
      final Map<String, dynamic> sampleResponse =
          await TestUtil.loadJsonFromAssets(
              'test/assets/responses/sample_plant_info_response.json');
      PlantInfo plantInfo = PlantInfo.fromJson(sampleResponse);
      String fakeImagePath = "fakeImagePath";

      String jsonString = jsonEncode(plantInfo.toJsonWithKey(fakeImagePath));

      Map<String, dynamic> json = jsonDecode(jsonString);

      Map<File, PlantInfo> collection = json.map((key, value) {
        PlantInfo p = PlantInfo.fromJson(value);
        return MapEntry(File(key), p);
      });

      expect(collection.length, 1);
      collection.forEach(
        (key, value) {
          expect(key, isA<File>());
          expect(value, isA<PlantInfo>());
        },
      );
    });
  });
}
