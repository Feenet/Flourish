import 'package:flourish/data/badge_structure.dart';
import 'package:flourish/models/badges_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StoredPreferences {
  static const String _badgeCountKey = "badgeCount";
  static const String _selectedBadgeKey = "selectedBadge";

  static late final SharedPreferences _prefs;

  static Future init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static void setBadgeCount(int badgeCount) {
    _prefs.setInt(_badgeCountKey, badgeCount);
  }

  static int getBadgeCount() {
    return _prefs.getInt(_badgeCountKey) ?? 0;
  }

  static void setSelectedBadge(Badge badge) {
    _prefs.setInt(_selectedBadgeKey, badge.requiredCount);
  }

  static int getSelectedBadge() {
    return _prefs.getInt(_selectedBadgeKey) ?? allBadges[0].requiredCount;
  }
}
