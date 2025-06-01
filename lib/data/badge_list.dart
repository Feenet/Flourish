
import "../models/badge_structure.dart";

List<PlantBadge> allBadges = [
  PlantBadge(requiredCount: 5, title: 'Sprout Collector', imageAssetPath: 'default_plants/images/badge_placeholder.png'),
  PlantBadge(requiredCount: 15, title: 'Garden Starter', imageAssetPath: 'default_plants/images/badge_placeholder.png'),
  PlantBadge(requiredCount: 35, title: 'Leaf Lover', imageAssetPath: 'default_plants/images/badge_placeholder.png'),
  PlantBadge(requiredCount: 75, title: 'Botany Buff', imageAssetPath: 'default_plants/images/badge_placeholder.png'),
  PlantBadge(requiredCount: 155, title: 'Plant Professional', imageAssetPath: 'default_plants/images/badge_placeholder.png'),
  PlantBadge(requiredCount: 315, title: 'Jungle Architect', imageAssetPath: 'default_plants/images/badge_placeholder.png'),
  PlantBadge(requiredCount: 635, title: 'Nature Hero', imageAssetPath: 'default_plants/images/badge_placeholder.png'),
  PlantBadge(requiredCount: 1275, title: 'Flora Master', imageAssetPath: 'default_plants/images/badge_placeholder.png'),
];

List<PlantBadge> getEarnedBadges(int totalPlants) {
  return allBadges.where((badge) => totalPlants >= badge.requiredCount).toList();
}
