import 'dart:convert';
import 'dart:io';

import 'package:flourish/error/plant_info_errors.dart';
import 'package:flourish/service/plant_info_service.dart';
import 'package:flourish/data/plant_info.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/mockito.dart';

import 'fetch_plant_info_test.mocks.dart';
import 'util/test_util.dart';

@GenerateMocks([http.Client])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  group("PlantInfoService Tests", () {
    late MockClient mockClient;
    late PlantInfoService plantInfoService;

    setUp(() {
      mockClient = MockClient();
      plantInfoService = PlantInfoService(mockClient);
    });

    test(
        "fetchPlantInfo returns PhotoInfo when HTTP call completes successfully",
        () async {
      final File imageFile = File("test/assets/images/test_plant.jpg");
      final Map<String, dynamic> sampleResponse =
          await TestUtil.loadJsonFromAssets(
              "test/assets/responses/sample_plant_info_response.json");
      final sampleResponseBytes = utf8.encode(jsonEncode(sampleResponse));
      final mockStreamResponse =
          http.StreamedResponse(Stream.value(sampleResponseBytes), 200);

      when(mockClient.send(any)).thenAnswer((_) async => mockStreamResponse);

      final plantInfo = await plantInfoService.fetchPlantInfo(imageFile);

      expect(plantInfo, isA<PlantInfo>());
      verify(
        mockClient.send(any),
      ).called(1);
    });

    test("fetchPlantInfo returns Plant Not Found(404) when HTTP call fails",
        () async {
      final File imageFile = File("test/assets/images/dog.jpg");

      when(mockClient.send(any)).thenAnswer(
        (_) async => http.StreamedResponse(
            Stream.value(
              utf8.encode("Plant Not Found"),
            ),
            404),
      );

      await expectLater(
        () => plantInfoService.fetchPlantInfo(imageFile),
        throwsA(isA<PlantNotFoundException>()),
      );
      verify(
        mockClient.send(any),
      ).called(1);
    });
  });
}
