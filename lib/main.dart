import 'package:flourish/models/badges_model.dart';
import 'package:http/http.dart' as http;
import 'package:flourish/models/plant_collection_model.dart';
import 'package:flourish/service/plant_info_service.dart';
import 'package:flourish/tabs/badges.dart';
import 'package:flourish/tabs/plant_collection.dart';
import 'package:flourish/tabs/timer.dart';
import 'package:flourish/util/local_storage.dart';
import 'package:flourish/util/stored_preferences.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await StoredPreferences.init();
  int selectedBadge = StoredPreferences.getSelectedBadge();
  final plants = await LocalStorage.loadPlantData(true);
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<PlantCollectionModel>(
          create: (_) => PlantCollectionModel(plants),
        ),
        Provider(
          create: (_) => PlantInfoService(http.Client()),
        ),
        ChangeNotifierProvider(
          create: (_) => BadgeModel(selectedBadge),
        )
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const Homepage(),
      theme: ThemeData(
        primarySwatch: Colors.green,
        appBarTheme: const AppBarTheme(
          backgroundColor: Color.fromARGB(255, 94, 104, 93),
          foregroundColor: Color.fromARGB(255, 46, 32, 32),
        ),
      ),
    );
  }
}

class Homepage extends StatelessWidget {
  const Homepage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
          backgroundColor:  const Color.fromARGB(255, 128, 141, 126), 
        appBar: AppBar(
          title: Text(
            "Flourish",
            style: GoogleFonts.inconsolata(
              fontWeight: FontWeight.bold,
            ),
          ),
          bottom: TabBar(
            labelColor: Color.fromARGB(255, 178, 221, 186),
            unselectedLabelColor: Color.fromARGB(255, 64, 53, 53),
            tabs: [
              Tab(
                text: "Timer",
                icon: Icon(
                  Icons.timer_sharp,
                ),
              ),
              Tab(
                text: "Plant Collection",
                icon: Icon(
                  Icons.grass,
                ),
              ),
              Tab(
                text: "Badges",
                icon: Icon(
                  Icons.emoji_events,
                ),
              ),
            ],
          ),
        ),
        body: SafeArea(
          child: TabBarView(
            children: [
              TimerPage(),
              PlantCollectionPage(),
              BadgesTab(),
            ],
          ),
        ),
      ),
    );
  }
}
