import 'package:flourish/models/badges_model.dart';
import 'package:flourish/models/plant_collection_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rive/rive.dart';

class BadgesTab extends StatelessWidget {
  const BadgesTab({super.key});

  @override
  Widget build(BuildContext context) {
    final totalPlants =
        Provider.of<PlantCollectionModel>(context, listen: false).plants.length;
    final earnedBadges = getEarnedBadges(totalPlants);
    // For testing purposes you can change this variable to allBadges

    return Container(
      child: earnedBadges.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.eco_outlined,
                      size: 64,
                      color: Color.fromARGB(255, 74, 105, 62).withOpacity(0.8),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "No badges yet! Keep growing 🌱",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: Color.fromARGB(255, 48, 32, 17),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            )
          : Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: Color.fromARGB(255, 80, 52, 26),
                        width: 1,
                      ),
                    ),
                  ),
                  child: Text(
                    "Tap A Plant To Grow It 🌱",
                    style: TextStyle(
                      fontSize: 22.0,
                      fontWeight: FontWeight.w600,
                      color: Color.fromARGB(255, 79, 56, 35),
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                
                Expanded(
                  child: GridView.builder(
                    padding: const EdgeInsets.all(12),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                    ),
                    itemCount: earnedBadges.length,
                    itemBuilder: (context, index) {
                      final badge = earnedBadges[index];
                      return Card(
                        elevation: 6,
                        color: Color.fromARGB(255, 241, 247, 222),
                        surfaceTintColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(
                            color: Color.fromARGB(255, 103, 141, 88)
                                .withOpacity(0.3),
                            width: 5,
                          ),
                        ),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () =>
                              Provider.of<BadgeModel>(context, listen: false)
                                  .setBadge(badge),
                          splashColor: Color.fromARGB(255, 103, 141, 88)
                              .withOpacity(0.1),
                          highlightColor: Color.fromARGB(255, 103, 141, 88)
                              .withOpacity(0.05),
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Column(
                              children: [
                                Expanded(
                                  child: SizedBox(
                                    child: RiveAnimation.asset(
                                      badge.imageAssetPath,
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  badge.title,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    color: Color.fromARGB(255, 139, 107, 76),
                                    fontSize: 14,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}
