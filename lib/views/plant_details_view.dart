import 'dart:io';
import 'package:flourish/data/plant_match.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PlantDetailsView extends StatelessWidget {
  final File image;
  final String name;
  final List<PlantMatch> matches;

  const PlantDetailsView({
    super.key,
    required this.image,
    required this.name,
    required this.matches,
  });

  @override
  Widget build(BuildContext context) {
    // Get top 3 matches sorted by score descending
    final topMatches = List<PlantMatch>.from(matches)
      ..sort((a, b) => b.score.compareTo(a.score));
    final limitedMatches = topMatches.take(3).toList();

    return Scaffold(
      backgroundColor: Color.fromARGB(255, 94, 104, 93),
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 94, 104, 93),
        title: Text(
          name,
          style: GoogleFonts.inconsolata(
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
      ),
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 8,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Stack(
                children: [
                  Image.file(
                    image,
                    fit: BoxFit.cover,
                    height: 250,
                    width: double.infinity,
                  ),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 8, horizontal: 12),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.black45, Colors.transparent],
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                        ),
                      ),
                      child: Text(
                        name,
                        style: GoogleFonts.inconsolata(
                          fontSize: 20,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            "This is a $name!",
            style: GoogleFonts.roboto(
              textStyle: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(255, 178, 221, 186),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            "Top 3 Matches",
            style: GoogleFonts.roboto(
              textStyle: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color.fromARGB(255, 178, 221, 186),
              ),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.all(12),
        height: MediaQuery.of(context).size.height * 0.50,
        decoration: BoxDecoration(
          color: Color.fromARGB(255, 65, 50, 50),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 8,
              offset: Offset(0, -2),
            )
          ],
        ),
        child: SingleChildScrollView(
          child: ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: limitedMatches.length,
              itemBuilder: (context, index) {
                final match = limitedMatches[index];

                // Determine score color by rank
                Color scoreColor;
                final percent = match.score * 100;

                if (percent >= 85) {
                  scoreColor = const Color.fromARGB(
                      255, 133, 177, 134); 
                } else if (percent >= 60) {
                  scoreColor = const Color.fromARGB(
                      255, 235, 188, 126);
                } else {
                  scoreColor = const Color.fromARGB(
                      255, 243, 138, 138);
                }

                return Card(
                  color: Color.fromARGB(255, 94, 104, 93),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 3,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: match.imageUrl != null
                              ? Image.network(
                                  match.imageUrl!,
                                  height: 100,
                                  width: 100,
                                  fit: BoxFit.cover,
                                )
                              : Image.asset(
                                  'assets/default_images/placeholder.jpg',
                                  height: 100,
                                  width: 100,
                                  fit: BoxFit.cover,
                                ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ...match.commonNames.map(
                                (m) => Text(
                                  m,
                                  style: GoogleFonts.roboto(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: Color.fromARGB(255, 178, 221, 186),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                "Score: ${match.score}",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: scoreColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
        ),
      ),
    );
  }
}
