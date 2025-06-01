import 'package:audioplayers/audioplayers.dart';
import 'package:flourish/data/plant_match.dart';
import 'package:flourish/models/badges_model.dart';
import 'package:flourish/models/plant_collection_model.dart';
import 'package:flourish/service/plant_info_service.dart';
import 'package:flourish/util/local_storage.dart';
import 'package:flourish/util/stored_preferences.dart';
import 'package:flourish/views/badge_popup.dart';
import 'package:flourish/views/match_selection_screen.dart';
import 'package:flourish/views/plant_details_view.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:flourish/data/plant_info.dart';
import 'package:provider/provider.dart';

class PlantCollectionPage extends StatefulWidget {
  const PlantCollectionPage({super.key});

  @override
  State<PlantCollectionPage> createState() => _PlantCollectionPageState();
}

class _PlantCollectionPageState extends State<PlantCollectionPage> {
  final _picker = ImagePicker();
  final _audioPlayer = AudioPlayer();

  Future<void> _takePicture() async {
    // Capture image
    final pickedFile = await _picker.pickImage(source: ImageSource.camera);
    if (pickedFile == null) {
      return;
    }

    final imageFile = File(pickedFile.path);

    if (!mounted) return;
    final shouldKeep = await showDialog<bool>(
          context: context,
          barrierColor: Colors.black.withOpacity(0.9),
          builder: (context) => Dialog(
            insetPadding: EdgeInsets.all(16),
            backgroundColor: Colors.transparent,
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: InteractiveViewer(
                    child: Image.file(
                      imageFile,
                      fit: BoxFit.contain,
                      width: double.infinity,
                      height: double.infinity,
                    ),
                  ),
                ),
                Positioned(
                  bottom: 20,
                  right: 20,
                  child: Row(
                    children: [
                      FloatingActionButton(
                        heroTag: 'delete',
                        backgroundColor: Colors.red,
                        child: const Icon(Icons.delete),
                        onPressed: () => Navigator.pop(context, false),
                      ),
                      const SizedBox(width: 16),
                      FloatingActionButton(
                        heroTag: 'confirm',
                        backgroundColor: Colors.green,
                        child: const Icon(Icons.check),
                        onPressed: () => Navigator.pop(context, true),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ) ??
        false;

    if (!shouldKeep) {
      await imageFile.delete();
      return;
    }

    try {
      if (!mounted) return;
      // final defaultPlants = await LocalStorage.loadDefaultPlants();
      // final random = defaultPlants.values.toList()[defaultPlants.length - 2];
      final plantInfo =
          await Provider.of<PlantInfoService>(context, listen: false)
              .fetchPlantInfo(imageFile);

      if (!mounted) return;
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => MatchSelectionScreen(
            image: imageFile,
            plantInfo: plantInfo,
            onMatchSelected: (PlantMatch selectedMatch) async {
              await Provider.of<PlantCollectionModel>(context, listen: false)
                  .addPlant(
                      imageFile,
                      PlantInfo(
                        bestMatchName: selectedMatch.commonNames.isNotEmpty
                            ? selectedMatch.commonNames[0]
                            : "Unknown",
                        matches: [selectedMatch],
                      ));
              await _checkForNewBadge();
            },
          ),
        ),
      );
    } catch (e) {
      await imageFile.delete();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  Future<void> _checkForNewBadge() async {
    final previousBadgeCount = StoredPreferences.getBadgeCount();

    final plantMap = await LocalStorage.loadPlantData(false);
    final currentPlantCount = plantMap.length;

    final currentBadgeList = getEarnedBadges(currentPlantCount);

    if (currentBadgeList.length != 1 &&
        currentBadgeList.length > previousBadgeCount) {
      final newBadge = currentBadgeList.last;

      StoredPreferences.setBadgeCount(currentBadgeList.length);
      if (!mounted) return;
      _audioPlayer.play(AssetSource('sounds/badge_unlock.mp3'));
      showDialog(
        context: context,
        builder: (_) => BadgePopup(newBadge: newBadge),
      );
    }
  }

  @override
  void dispose() {
    super.dispose();
    _audioPlayer.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          const Color.fromARGB(255, 128, 141, 126), // Light green background

      floatingActionButton: FloatingActionButton(
        onPressed: _takePicture,
        backgroundColor: const Color.fromARGB(255, 57, 84, 58),
        child: const Icon(Icons.add_a_photo,
            size: 30, color: Color.fromARGB(255, 65, 50, 50)),
      ),

      body: Consumer<PlantCollectionModel>(
        builder: (context, state, child) => Container(
          color: const Color.fromARGB(255, 128, 141, 126), // Same as Scaffold
          padding: const EdgeInsets.all(5.0),
          child: GridView.builder(
            itemCount: state.plants.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.75,
            ),
            itemBuilder: (context, index) {
              final image = state.plants.keys.elementAt(index);
              final plantInfo = state.plants[image]!;

              return GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PlantDetailsView(
                      image: image,
                      name: plantInfo.bestMatchName,
                      matches: plantInfo.matches,
                    ),
                  ),
                ),
                child: Card(
                  elevation: 6,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: plantInfo.matches.isNotEmpty &&
                                plantInfo.matches.first.imageUrl != null
                            ? Image.network(
                                plantInfo.matches.first.imageUrl!,
                                fit: BoxFit.cover,
                              )
                            : Image.file(
                                image,
                                fit: BoxFit.cover,
                              ),
                      ),
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          color: Color.fromARGB(255, 87, 72, 72),
                          padding: const EdgeInsets.symmetric(
                              vertical: 6, horizontal: 8),
                          child: Text(
                            plantInfo.bestMatchName,
                            style: const TextStyle(
                              color: Color.fromARGB(255, 133, 174, 133),
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                            textAlign: TextAlign.center,
                            softWrap: true,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
