class PlantMatch {
  final double score;
  final List<String> commonNames;
  final String? imageUrl; // <-- Now nullable

  const PlantMatch({
    required this.score,
    required this.commonNames,
    this.imageUrl,
  });

  factory PlantMatch.fromJson(Map<String, dynamic> json) {
    final scoreRaw = json['score'];
    final score = scoreRaw is double
        ? scoreRaw
        : (scoreRaw is int ? scoreRaw.toDouble() : null);

    if (score == null) {
      throw FormatException(
          'Json Parse Error: required "score" field of type double in $json');
    }

    final commonNamesRaw = json['species']?['commonNames'] as List<dynamic>?;
    final commonNames = commonNamesRaw != null
        ? List<String>.from(commonNamesRaw)
        : <String>[];

    final images = json['images'] as List<dynamic>?;

    String? imageUrl;
    if (images != null && images.isNotEmpty) {
      final urlData = images[0]['url'];
      if (urlData is Map && urlData.containsKey('m')) {
        imageUrl = urlData['m'];
      }
    }

    return PlantMatch(
      score: score,
      commonNames: commonNames,
      imageUrl: imageUrl,
    );
  }

  Map<String, dynamic> toJson() => {
        "score": score,
        "species": {
          "commonNames": commonNames,
        },
        "images": [
          {
            "url": {
              "m": imageUrl,
            }
          }
        ]
      };
}
