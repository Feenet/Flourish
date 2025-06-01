import 'dart:async';
import 'package:flourish/models/badges_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:rive/rive.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'timer_settings_page.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:google_fonts/google_fonts.dart';

class TimerPage extends StatefulWidget {
  const TimerPage({super.key});

  @override
  State<TimerPage> createState() => _TimerPageState();
}

class _TimerPageState extends State<TimerPage> with WidgetsBindingObserver {
  Artboard? _riveArtboard;
  StateMachineController? _controller;
  SMIInput<double>? _progress;

  int _seconds = 60 * 25;
  int _totalSeconds = 60 * 25;
  bool _isRunning = false;
  Timer? _timer;
  int _animationStep = 0;
  DateTime? _endTime;
  final player = AudioPlayer();

  Map<String, int> _intervals = {
    'Study Time': 60 * 25,
    'Short Break': 60 * 5,
    'Long Break': 60 * 15,
  };

  int _selectedIndex = 0; // Index for bottom navigation bar
  int _studySessions = 0; // Counts study sessions before a long break

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadRiveAnimation();
  }

  // Load the Rive animation and initialize the state machine controller
  Future<void> _loadRiveAnimation() async {
    try {
      final data = await rootBundle.load(
          Provider.of<BadgeModel>(context, listen: false)
              .selectedBadge
              .imageAssetPath);
      await RiveFile.initialize();
      final file = RiveFile.import(data);
      final artboard = file.mainArtboard;
      var controller = StateMachineController.fromArtboard(artboard, 'Grow');
      if (controller != null) {
        artboard.addController(controller);
        _progress = controller.findInput('input');
        setState(() => _riveArtboard = artboard);

        await _loadSavedState();
        _updateAnimationProgress();
      }
    } catch (e) {
      debugPrint('Error loading Rive animation: $e');
    }
  }

  // Reset the session count
  void _resetSessionCount() {
    setState(() {
      _studySessions = 0;
    });

    _saveCurrentState();

    // Show confirmation to the user
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.refresh, color: Colors.white),
            const SizedBox(width: 8),
            const Text('Session count reset',
                style: TextStyle(fontWeight: FontWeight.w500)),
          ],
        ),
        backgroundColor: const Color.fromARGB(255, 124, 179, 66), // leaf
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.all(8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      if (_isRunning) {
        _saveCurrentState();
        _timer?.cancel();
      }
    } else if (state == AppLifecycleState.resumed) {
      _restoreTimerState();
    }
  }

  Future<void> _saveCurrentState() async {
    final prefs = await SharedPreferences.getInstance();

    if (_isRunning && _endTime != null) {
      await prefs.setString('endTime', _endTime!.toIso8601String());
      await prefs.setBool('isRunning', _isRunning);
    } else {
      await prefs.remove('endTime');
      await prefs.setBool('isRunning', false);
    }

    await prefs.setInt('totalSeconds', _totalSeconds);
    await prefs.setInt('selectedIndex', _selectedIndex);
    await prefs.setInt('studySessions', _studySessions);

    if (_totalSeconds > 0) {
      double elapsedPercentage = 1 - (_seconds / _totalSeconds);
      elapsedPercentage = elapsedPercentage.clamp(0.0, 1.0);
      _animationStep = (elapsedPercentage * 100).round();
    }
    await prefs.setInt('animationStep', _animationStep);
    await prefs.setInt('seconds', _seconds);
  }

  Future<void> _loadSavedState() async {
    final prefs = await SharedPreferences.getInstance();
    final savedEndTime = prefs.getString('endTime');
    final savedIsRunning = prefs.getBool('isRunning') ?? false;

    setState(() {
      _selectedIndex = prefs.getInt('selectedIndex') ?? _selectedIndex;
      _studySessions = prefs.getInt('studySessions') ?? _studySessions;
      _totalSeconds =
          prefs.getInt('totalSeconds') ?? _intervals[_getCurrentSession()]!;
      _animationStep = prefs.getInt('animationStep') ?? _animationStep;
      _seconds = prefs.getInt('seconds') ?? _intervals[_getCurrentSession()]!;
    });

    if (savedEndTime != null && savedIsRunning) {
      final endTime = DateTime.parse(savedEndTime);
      final now = DateTime.now();

      if (endTime.isAfter(now)) {
        setState(() {
          _endTime = endTime;
          _seconds = endTime.difference(now).inSeconds;
          _isRunning = true;
        });
        _startTimer();
      } else {
        _handleSessionEnd();
        await _clearSavedState(prefs);
      }
    } else {
      setState(() {
        if (!savedIsRunning) {
          _seconds =
              prefs.getInt('seconds') ?? _intervals[_getCurrentSession()]!;
          _totalSeconds = _intervals[_getCurrentSession()]!;
          _isRunning = false;
          _endTime = null;
        }
      });
    }
  }

  Future<void> _clearSavedState(SharedPreferences prefs) async {
    await prefs.remove('endTime');
    await prefs.remove('isRunning');
  }

  void _restoreTimerState() async {
    final prefs = await SharedPreferences.getInstance();
    final savedEndTime = prefs.getString('endTime');
    final savedIsRunning = prefs.getBool('isRunning') ?? false;

    setState(() {
      _totalSeconds = prefs.getInt('totalSeconds') ?? _totalSeconds;
      _selectedIndex = prefs.getInt('selectedIndex') ?? _selectedIndex;
      _studySessions = prefs.getInt('studySessions') ?? _studySessions;
      _animationStep = prefs.getInt('animationStep') ?? _animationStep;
      _seconds = prefs.getInt('seconds') ?? _intervals[_getCurrentSession()]!;
    });

    if (_progress != null) {
      _progress?.value = _animationStep.toDouble();
    }

    if (savedEndTime != null && savedIsRunning) {
      final endTime = DateTime.parse(savedEndTime);
      final now = DateTime.now();

      if (endTime.isAfter(now)) {
        setState(() {
          _endTime = endTime;
          _seconds = endTime.difference(now).inSeconds;
          _isRunning = true;
        });

        _updateAnimationProgress();
        _restartTimerWithEndTime();
      } else {
        _stopTimer();
        _handleSessionEnd();
        await _clearSavedState(prefs);
      }
    } else {
      setState(() {
        _isRunning = false;
        _endTime = null;
      });
    }
  }

  void _restartTimerWithEndTime() {
    _timer?.cancel();
    _timer = Timer.periodic(
      const Duration(seconds: 1),
      (Timer timer) {
        final currentTime = DateTime.now();

        if (_endTime!.isAfter(currentTime)) {
          setState(() {
            _seconds = _endTime!.difference(currentTime).inSeconds;
          });
          _updateAnimationProgress();
        } else {
          _stopTimer();
          _handleSessionEnd();
        }
      },
    );
  }

  void _navigateToSettings() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TimerSettingsPage(currentIntervals: _intervals),
      ),
    );

    if (result != null) {
      setState(() {
        _intervals = result;
        _resetTimer();
      });
    }
  }

  String _formatTime(int seconds) {
    int minutes = (seconds ~/ 60);
    int remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  void _updateAnimationProgress() {
    if (_progress == null) return;

    double elapsedPercentage = 1 - (_seconds / _totalSeconds);
    elapsedPercentage = elapsedPercentage.clamp(0.0, 1.0);

    int targetStep = (elapsedPercentage * 100).round();

    setState(() {
      _progress?.value = targetStep.toDouble();
      _animationStep = targetStep;
    });
  }

  void _startTimer() {
    _endTime ??= DateTime.now().add(Duration(seconds: _seconds));

    setState(() {
      _isRunning = true;
    });

    _saveCurrentState();

    _timer = Timer.periodic(
      const Duration(seconds: 1),
      (Timer timer) {
        final now = DateTime.now();

        if (_endTime!.isAfter(now)) {
          setState(() {
            _seconds = _endTime!.difference(now).inSeconds;
          });
          _updateAnimationProgress();
        } else {
          _stopTimer();
          _handleSessionEnd();
        }
      },
    );
  }

  void _stopTimer() {
    _timer?.cancel();
    setState(() {
      _isRunning = false;
      _endTime = null;
    });

    _saveCurrentState();
  }

  void _resetTimer() {
    _timer?.cancel();
    _endTime = null;

    setState(() {
      _seconds = _intervals[_getCurrentSession()]!;
      _totalSeconds = _seconds;
      _isRunning = false;
      if (_progress != null) {
        _progress!.value = 0;
      }
      _animationStep = 0;
    });

    _saveCurrentState();
  }

  void _handleSessionEnd() async {
    await player.play(AssetSource('sounds/chill_alert.mp3'));

    if (_selectedIndex == 0) {
      // Completed a study session
      _studySessions++;
      if (_studySessions >= 4) {
        _selectedIndex = 2; // Long Break
        _studySessions = 0; // Reset sessions after 4
      } else {
        _selectedIndex = 1; // Short Break
      }
    } else if (_selectedIndex == 1 || _selectedIndex == 2) {
      _selectedIndex = 0; // Back to Study Time
    }

    _resetTimer();
  }

  String _getCurrentSession() {
    switch (_selectedIndex) {
      case 1:
        return 'Short Break';
      case 2:
        return 'Long Break';
      default:
        return 'Study Time';
    }
  }

  Color _getSessionColor() {
    final currentSession = _getCurrentSession();
    switch (currentSession) {
      case 'Study Time':
        return const Color.fromARGB(255, 48, 77, 49);
      case 'Short Break':
        return const Color.fromARGB(255, 89, 69, 10);
      case 'Long Break':
        return const Color.fromARGB(255, 122, 65, 52); 
      default:
        return const Color.fromARGB(255, 22, 60, 24); 
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller?.dispose();
    player.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sessionColor = _getSessionColor();

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 128, 141, 126),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          decoration: BoxDecoration(
            color: sessionColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: sessionColor.withOpacity(0.3), width: 2),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _getSessionIcon(),
              const SizedBox(width: 8),
              Text(
                _getCurrentSession(),
                style: GoogleFonts.quicksand(
                  textStyle: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: sessionColor,
                  ),
                ),
              ),
            ],
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.settings,
                color: const Color.fromARGB(255, 93, 64, 55)), 
            onPressed: _navigateToSettings,
            iconSize: 32.0,
          ),
        ],
      ),
      body: SafeArea(
        child: _buildResponsiveLayout(),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildResponsiveLayout() {
    // Get screen dimensions for responsive layout
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.height < 700;

    return Column(
      children: [
        // Session counter for study mode with reset button
        if (_getCurrentSession() == 'Study Time')
          _buildSessionCounterWithReset(isSmallScreen),

        // Expanded area for timer and animation
        Expanded(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Timer display
                _buildTimerDisplay(isSmallScreen),

                // Rive animation
                _buildRiveAnimation(isSmallScreen),
              ],
            ),
          ),
        ),

        // Control buttons
        Padding(
          padding: EdgeInsets.fromLTRB(16, 0, 16, isSmallScreen ? 8 : 16),
          child: _buildControlButtons(),
        ),
      ],
    );
  }

  Widget _buildSessionCounterWithReset(bool isSmallScreen) {
    return Padding(
      padding:
          EdgeInsets.symmetric(horizontal: 16, vertical: isSmallScreen ? 4 : 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 155, 214, 112)
                  .withOpacity(0.15), 
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Session ${_studySessions + 1} of 4',
                  style: GoogleFonts.quicksand(
                    textStyle: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: const Color.fromARGB(255, 61, 97, 73),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                Tooltip(
                  message: 'Session Has Been Reset',
                  child: InkWell(
                    onTap: _resetSessionCount,
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 22, 60, 24)
                            .withOpacity(0.1), 
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.refresh,
                        size: 16,
                        color: const Color.fromARGB(255, 22, 60, 24), 
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimerDisplay(bool isSmallScreen) {
    final sessionColor = _getSessionColor();

    return Container(
      padding: EdgeInsets.symmetric(
          horizontal: isSmallScreen ? 24 : 32,
          vertical: isSmallScreen ? 12 : 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.4),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color:
                const Color.fromARGB(255, 93, 64, 55).withOpacity(0.1), // rock
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Text(
        _formatTime(_seconds),
        style: GoogleFonts.orbitron(
          textStyle: TextStyle(
            fontSize: isSmallScreen ? 48 : 64,
            fontWeight: FontWeight.w700,
            color: sessionColor,
          ),
        ),
      ),
    );
  }

  Widget _buildRiveAnimation(bool isSmallScreen) {
    final sessionColor = _getSessionColor();
    final animationSize = isSmallScreen ? 200.0 : 200.0;

    if (_riveArtboard == null) {
      return SizedBox(
        height: animationSize,
        width: animationSize,
        child: CircularProgressIndicator(color: sessionColor),
      );
    }

    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withOpacity(0.8),
        boxShadow: [
          BoxShadow(
            color: sessionColor.withOpacity(0.8),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
        border: Border.all(
          color: sessionColor.withOpacity(0.5),
          width: 3,
        ),
      ),
      child: SizedBox(
        height: animationSize,
        width: animationSize,
        child: Rive(artboard: _riveArtboard!),
      ),
    );
  }

  Widget _getSessionIcon() {
    final currentSession = _getCurrentSession();
    final sessionColor = _getSessionColor();

    IconData iconData;
    switch (currentSession) {
      case 'Study Time':
        iconData = Icons.menu_book;
        break;
      case 'Short Break':
        iconData = Icons.coffee;
        break;
      case 'Long Break':
        iconData = Icons.self_improvement;
        break;
      default:
        iconData = Icons.timer;
    }

    return Icon(iconData, color: sessionColor, size: 22);
  }

  Widget _buildControlButtons() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color.fromARGB(255, 93, 64, 55).withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildControlButton(
            onPressed: _isRunning ? null : _startTimer,
            icon: Icons.play_arrow,
            label: 'Start',
            color: const Color.fromARGB(255, 94, 117, 78),
          ),
          _buildControlButton(
            onPressed: _isRunning ? _stopTimer : null,
            icon: Icons.pause,
            label: 'Stop',
            color: const Color.fromARGB(255, 153, 110, 67),
          ),
          _buildControlButton(
            onPressed: _resetTimer,
            icon: Icons.refresh,
            label: 'Reset',
            color: const Color.fromARGB(255, 144, 135, 76),
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton({
    required VoidCallback? onPressed,
    required IconData icon,
    required String label,
    required Color color,
  }) {
    final isSmallScreen = MediaQuery.of(context).size.height < 700;

    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: FilledButton.icon(
          onPressed: onPressed,
          icon: Icon(icon, size: isSmallScreen ? 16 : 20),
          label: Text(
            label,
            style: GoogleFonts.quicksand(
              fontWeight: FontWeight.w600,
              fontSize: isSmallScreen ? 14 : 16,
            ),
          ),
          style: FilledButton.styleFrom(
            backgroundColor: onPressed == null ? color.withOpacity(0.3) : color,
            foregroundColor: Colors.white,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            padding: EdgeInsets.symmetric(vertical: isSmallScreen ? 8 : 10),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNavigationBar() {

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color:
                const Color.fromARGB(255, 93, 64, 55).withOpacity(0.1), 
            blurRadius: 6,
            offset: const Offset(0, -1),
          ),
        ],
      ),
      child: BottomNavigationBar(
        
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
            _resetTimer(); // Reset timer when switching modes
          });
        },
         backgroundColor: Color.fromARGB(255, 128, 141, 126), 
        selectedItemColor: const Color.fromARGB(255, 93, 64, 55),
        unselectedItemColor:
            const Color.fromARGB(255, 3, 62, 23).withOpacity(0.6), 
        selectedLabelStyle: GoogleFonts.quicksand(
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: GoogleFonts.quicksand(
          fontWeight: FontWeight.w500,
        ),
        elevation: 0,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.menu_book),
            label: 'Study',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.coffee),
            label: 'Short Break',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.self_improvement),
            label: 'Long Break',
          ),
        ],
      ),
    );
  }
}
