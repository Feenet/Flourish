import 'package:flourish/data/badge_structure.dart';
import 'package:flourish/util/stored_preferences.dart';
import 'package:flutter/widgets.dart';

class BadgeModel extends ChangeNotifier {
  Badge _selectedBadge = allBadges[0];
  Badge get selectedBadge => _selectedBadge;

  BadgeModel(int selectedBadge) {
    _selectedBadge =
        allBadges.firstWhere((b) => b.requiredCount == selectedBadge);
  }

  setBadge(badge) {
    _selectedBadge = badge;
    StoredPreferences.setSelectedBadge(badge);
    notifyListeners();
  }
}

List<Badge> allBadges = [
  Badge(
      requiredCount: 0,
      title: 'Sprout Collector',
      imageAssetPath: 'badges/plant_1.riv'),
  Badge(
      requiredCount: 5,
      title: 'Nursery Apprentice',
      imageAssetPath: 'badges/plant_2.riv'),
  Badge(
      requiredCount: 15,
      title: 'Garden Starter',
      imageAssetPath: 'badges/plant_3.riv'),
  Badge(
      requiredCount: 35,
      title: 'Leaf Lover',
      imageAssetPath: 'badges/plant_4.riv'),
  Badge(
      requiredCount: 75,
      title: 'Botany Buff',
      imageAssetPath: 'badges/plant_5.riv'),
  Badge(
      requiredCount: 155,
      title: 'Plant Professional',
      imageAssetPath: 'badges/plant_6.riv'),
  Badge(
      requiredCount: 315,
      title: 'Jungle Architect',
      imageAssetPath: 'badges/plant_7.riv'),
  Badge(
      requiredCount: 635,
      title: 'Nature Hero',
      imageAssetPath: 'badges/plant_8.riv'),
  Badge(
      requiredCount: 1275,
      title: 'Flora Master',
      imageAssetPath: 'badges/plant_9.riv'),
];

List<Badge> getEarnedBadges(int totalPlants) {
  return allBadges
      .where((badge) => totalPlants >= badge.requiredCount)
      .toList();
}
