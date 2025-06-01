import 'dart:io';

import 'package:flourish/data/plant_info.dart';
import 'package:flourish/data/plant_match.dart';
import 'package:flourish/views/plant_details_view.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/badges_model.dart';
import '../models/plant_collection_model.dart';

class MatchSelectionScreen extends StatelessWidget {
  final File image;
  final PlantInfo plantInfo;
  final Function(PlantMatch) onMatchSelected;

  const MatchSelectionScreen({
    super.key,
    required this.image,
    required this.plantInfo,
    required this.onMatchSelected,
  });

  @override
  Widget build(BuildContext context) {
    final topMatches = plantInfo.matches.take(3).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Select Your Match')),
      body: ListView.builder(
        itemCount: topMatches.length,
        itemBuilder: (context, index) {
          final match = topMatches[index];

          return ListTile(
            contentPadding: const EdgeInsets.all(6),
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: SizedBox(
                height: 100,
                width: 100, // limited width so it doesn't stretch
                child: match.imageUrl != null
                    ? Image.network(
                        match.imageUrl!,
                        fit: BoxFit.cover,
                      )
                    : Image.file(
                        image, // this is the image the user just took
                        height: 30,
                        fit: BoxFit.cover,
                      ),
              ),
            ),
            title: Wrap(
              spacing: 4,
              children: match.commonNames
                  .map((name) => Chip(
                        label: Text(name),
                        labelStyle: const TextStyle(fontSize: 12),
                        backgroundColor: Colors.green.shade100,
                      ))
                  .toList(),
            ),
            subtitle: Text(
              "Confidence: ${(match.score * 100).toStringAsFixed(1)}%",
              style: TextStyle(color: Colors.grey.shade600),
            ),
            trailing: ElevatedButton(
              onPressed: () {
                onMatchSelected(match);
                Navigator.pop(context);
              },
              child: const Text("Select"),
            ),
          );
        },
      ),
      bottomNavigationBar: TextButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => PlantDetailsView(
                image: image,
                name: plantInfo.bestMatchName,
                matches: plantInfo.matches,
              ),
            ),
          );
        },
        child: const Text("View More Matches"),
      ),
    );
  }
}
