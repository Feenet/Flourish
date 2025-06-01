class PlantInfoRequest {
  final String image; // base 64 image

  PlantInfoRequest({required this.image});

  Map<String, dynamic> toJson() {
    return {
      'images': [image],
    };
  }
}
