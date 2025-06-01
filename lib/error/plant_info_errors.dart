class PlantNotFoundException implements Exception {
  final String message;
  PlantNotFoundException(this.message);

  @override
  String toString() => message;
}
