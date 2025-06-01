import 'package:flourish/data/plant_info.dart';
import 'package:flourish/data/plant_match.dart';
import 'package:flutter_test/flutter_test.dart';

import 'util/test_util.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  group('Plant Info Test', () {
    test('PlantInfo fromJson parses JSON', () async {
      final Map<String, dynamic> sampleResponse =
          await TestUtil.loadJsonFromAssets(
              'test/assets/responses/sample_plant_info_response.json');
      PlantInfo plantInfo = PlantInfo.fromJson(sampleResponse);
      expect(plantInfo, isNotNull);
      expect(plantInfo.bestMatchName, isNotNull);
      expect(plantInfo.bestMatchName, "Leucojum vernum L.");
      expect(plantInfo.matches, isNotNull);
      expect(plantInfo.matches[0], isNotNull);
      PlantMatch match = plantInfo.matches[0];
      expect(match.commonNames[0], "Spring snowflake");
      expect(match.commonNames[1], "Teardrop");
      expect(match.score, 0.90651);
    });
  });
}
