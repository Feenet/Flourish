import 'package:flutter/material.dart';
import 'package:flutter/services.dart';


class TimerSettingsPage extends StatefulWidget {
  final Map<String, int> currentIntervals;

  const TimerSettingsPage({super.key, required this.currentIntervals});

  @override
  State<TimerSettingsPage> createState() => _TimerSettingsPageState();
}

class _TimerSettingsPageState extends State<TimerSettingsPage> {
  late Map<String, int> _intervals;
  final _formKey = GlobalKey<FormState>();

  // Controllers for text fields
  final Map<String, TextEditingController> _controllers = {};

  // Default recommended values in minutes
  final Map<String, int> _recommendedValues = {
    'Study Time': 25,
    'Short Break': 5,
    'Long Break': 15,
  };

  // Icons for each timer type
  final Map<String, IconData> _timerIcons = {
    'Study Time': Icons.book,
    'Short Break': Icons.coffee,
    'Long Break': Icons.self_improvement,
  };

  @override
  void initState() {
    super.initState();
    // Create a copy of the current intervals to modify
    _intervals = Map.from(widget.currentIntervals);

    // Initialize controllers for each timer setting
    widget.currentIntervals.forEach((key, value) {
      _controllers[key] = TextEditingController(
        text: (value ~/ 60).toString(),
      );
    });
  }

  @override
  void dispose() {
    // Dispose of all controllers
    for (var controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _resetToDefaults() {
    setState(() {
      _recommendedValues.forEach((key, value) {
        _controllers[key]?.text = value.toString();
        _intervals[key] = value * 60;
      });
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.refresh, color: Color.fromARGB(255, 235, 245, 232)),
            const SizedBox(width: 8),
            const Text('Reset to defaults',
                style: TextStyle(fontWeight: FontWeight.w500)),
          ],
        ),
        backgroundColor: Color.fromARGB(255, 82, 105, 79),
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.symmetric(
          horizontal: MediaQuery.of(context).size.width * 0.05,
          vertical: 8,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Get screen size for responsive design
    final Size screenSize = MediaQuery.of(context).size;
    final bool isSmallScreen = screenSize.width < 360;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 93, 64, 55),
        foregroundColor: Color.fromARGB(255, 235, 245, 232),
        title: const Text('Timer Settings',
            style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Reset to defaults',
            onPressed: _resetToDefaults,
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color.fromARGB(255, 235, 245, 232),
             Color.fromARGB(255, 131, 163, 131).withOpacity(0.7),
            ],
          ),
        ),
        child: SafeArea(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Expanded(
                  child: ListView(
                    padding: EdgeInsets.fromLTRB(
                      screenSize.width * 0.04,
                      8,
                      screenSize.width * 0.04,
                      0,
                    ),
                    children: [
                     
                      ..._recommendedValues.keys.map((label) =>
                          _buildTimerSettingCard(label, isSmallScreen)),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    screenSize.width * 0.04,
                    4,
                    screenSize.width * 0.04,
                    screenSize.height * 0.02,
                  ),
                  child: ElevatedButton(
                    onPressed: _saveSettings,
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size.fromHeight(screenSize.height * 0.06),
                      backgroundColor: Color.fromARGB(255, 125, 140, 117),
                      foregroundColor: Color.fromARGB(255, 235, 245, 232),
                      elevation: 2,
                      shadowColor: Color.fromARGB(255, 93, 64, 55).withOpacity(0.3),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      'Save Settings',
                      style: TextStyle(
                        fontSize: isSmallScreen ? 14 : 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

 Widget _buildTimerSettingCard(String label, bool isSmallScreen) {
    Color accentColor = label == 'Study Time'
        ? const Color.fromARGB(255, 82, 105, 79)
        : label == 'Short Break'
            ? const Color.fromARGB(255, 125, 140, 117)
            : const Color.fromARGB(255, 91, 113, 101);

    return Card(
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 8.0),
      color: const Color.fromARGB(255, 235, 245, 232),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: accentColor.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: 12.0,
          vertical: isSmallScreen ? 10.0 : 14.0,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  _timerIcons[label] ?? Icons.access_time,
                  color: accentColor,
                  size: isSmallScreen ? 20 : 22,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: TextStyle(
                          fontSize: isSmallScreen ? 13 : 14,
                          fontWeight: FontWeight.bold,
                          color: const Color.fromARGB(255, 93, 64, 55),
                        ),
                      ),
                      Text(
                        'Recommended: ${_recommendedValues[label]} min',
                        style: TextStyle(
                          fontSize: isSmallScreen ? 10 : 11,
                          color: accentColor.withOpacity(0.8),
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              height: isSmallScreen ? 32 : 40,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6),
                color:
                    const Color.fromARGB(255, 131, 163, 131).withOpacity(0.2),
                border: Border.all(color: accentColor.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  InkWell(
                    onTap: () {
                      int currentValue =
                          int.tryParse(_controllers[label]?.text ?? '0') ?? 0;
                      if (currentValue > 1) {
                        setState(() {
                          _controllers[label]?.text =
                              (currentValue - 1).toString();
                        });
                      }
                    },
                    child: Container(
                      width: 40,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        border: Border(
                          right: BorderSide(
                            color: accentColor.withOpacity(0.2),
                            width: 1,
                          ),
                        ),
                      ),
                      child: Icon(Icons.remove,
                          size: isSmallScreen ? 14 : 18, color: accentColor),
                    ),
                  ),
                  Expanded(
                    child: TextFormField(
                      controller: _controllers[label],
                      textAlign: TextAlign.center,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                        isDense: true,
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      style: TextStyle(fontSize: isSmallScreen ? 13 : 15),
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Required';
                        int? minutes = int.tryParse(value);
                        if (minutes == null || minutes <= 0) return 'Invalid';
                        if (minutes > 120) return 'Max 120';
                        return null;
                      },
                      onSaved: (value) {
                        if (value != null && value.isNotEmpty) {
                          _intervals[label] = int.parse(value) * 60;
                        }
                      },
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      int currentValue =
                          int.tryParse(_controllers[label]?.text ?? '0') ?? 0;
                      if (currentValue < 120) {
                        setState(() {
                          _controllers[label]?.text =
                              (currentValue + 1).toString();
                        });
                      }
                    },
                    child: Container(
                      width: 40,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        border: Border(
                          left: BorderSide(
                            color: accentColor.withOpacity(0.2),
                            width: 1,
                          ),
                        ),
                      ),
                      child: Icon(Icons.add,
                          size: isSmallScreen ? 14 : 18, color: accentColor),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _saveSettings() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Color.fromARGB(255, 235, 245, 232)),
              const SizedBox(width: 8),
              const Text('Settings saved',
                  style: TextStyle(fontWeight: FontWeight.w500)),
            ],
          ),
          backgroundColor: Color.fromARGB(255, 125, 140, 117),
          duration: const Duration(seconds: 1),
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.symmetric(
            horizontal: MediaQuery.of(context).size.width * 0.05,
            vertical: 8,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      );

      Navigator.pop(context, _intervals);
    }
  }
}
