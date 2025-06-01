import 'package:flourish/data/badge_structure.dart' as badge;
import 'package:flourish/tabs/badges.dart';
import 'package:flutter/material.dart';
import 'package:rive/rive.dart';

class BadgePopup extends StatelessWidget {
  final badge.Badge newBadge;

  const BadgePopup({super.key, required this.newBadge});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('🎉 New Badge Unlocked!'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: 100,
            child: RiveAnimation.asset(
              newBadge.imageAssetPath,
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            newBadge.title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          const Text("Congratulations! You've unlocked a new badge."),
        ],
      ),
      actions: [
        // TextButton(
        //   onPressed: () {
        //     Navigator.of(context).pop();
        //     DefaultTabController.of(context).animateTo(2);
        //     Navigator.push(
        //       context,
        //       MaterialPageRoute(builder: (context) => BadgesTab()),
        //     );
        //   },
        //   child: const Text("View Badges"),
        // ),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Close"),
        ),
      ],
    );
  }
}
