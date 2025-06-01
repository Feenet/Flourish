import 'package:flourish/data/plant_match.dart';

class PlantInfo {
  final String bestMatchName;
  final List<PlantMatch> matches;

  const PlantInfo({required this.bestMatchName, required this.matches});

  factory PlantInfo.fromJson(Map<String, dynamic> json) {
    final bestMatch = json['bestMatch'];
    if (bestMatch is! String) {
      throw FormatException(
          'Json Parse Error: required "bestMatch" field of type String in $json');
    }
    final matches = json['results'] as List<dynamic>?;

    return PlantInfo(
        bestMatchName: bestMatch,
        matches: matches == null
            ? <PlantMatch>[]
            : matches
                .map((match) =>
                    PlantMatch.fromJson(match as Map<String, dynamic>))
                .toList());
  }

  Map<String, dynamic> toJson() => {
        'bestMatch': bestMatchName,
        'results': matches.map((m) => m.toJson()).toList(),
      };

  Map<String, dynamic> toJsonWithKey(String key) => {
        key: toJson(),
      };
}
