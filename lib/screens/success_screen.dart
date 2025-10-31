import 'package:flutter/material.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:confetti/confetti.dart';
import 'package:inclass13/screens/_badge_data.dart';

class SuccessScreen extends StatefulWidget {
  final String userName;
  final int avatarIndex;
  final bool isStrongPassword;
  final bool isEarlyBird;
  final bool isProfileComplete;

  const SuccessScreen({
    Key? key,
    required this.userName,
    required this.avatarIndex,
    this.isStrongPassword = false,
    this.isEarlyBird = false,
    this.isProfileComplete = false,
  }) : super(key: key);

  @override
  State<SuccessScreen> createState() => _SuccessScreenState();
}

class _SuccessScreenState extends State<SuccessScreen> {
  late ConfettiController _confettiController;
  final List<IconData> _avatarIcons = [
    Icons.emoji_emotions,
    Icons.pets,
    Icons.face,
    Icons.android,
    Icons.catching_pokemon,
  ];

  final List<BadgeData> _badges = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _badges.clear();
    if (widget.isStrongPassword) {
      _badges.add(BadgeData(
        icon: Icons.security,
        label: 'Strong Password Master',
        color: Colors.green,
      ));
    }
    if (widget.isEarlyBird) {
      _badges.add(BadgeData(
        icon: Icons.wb_sunny,
        label: 'Early Bird Special',
        color: Colors.orange,
      ));
    }
    if (widget.isProfileComplete) {
      _badges.add(BadgeData(
        icon: Icons.verified,
        label: 'Profile Completer',
        color: Colors.blue,
      ));
    }
  }

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 10));
    _confettiController.play();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.deepPurple[50],
      body: Stack(
        children: [
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false,
              colors: const [
                Colors.deepPurple,
                Colors.purple,
                Colors.blue,
                Colors.green,
                Colors.orange,
              ],
            ),
          ),
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AnimatedContainer(
                    duration: const Duration(seconds: 1),
                    curve: Curves.elasticOut,
                    width: 150,
                    height: 150,
                    decoration: BoxDecoration(
                      color: Colors.deepPurple,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.deepPurple.withOpacity(0.5),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: Icon(
                      _avatarIcons[widget.avatarIndex],
                      color: Colors.white,
                      size: 80,
                    ),
                  ),
                  const SizedBox(height: 40),
                  AnimatedTextKit(
                    animatedTexts: [
                      TypewriterAnimatedText(
                        'Welcome, ${widget.userName}! 🎉',
                        textAlign: TextAlign.center,
                        textStyle: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.deepPurple,
                        ),
                        speed: const Duration(milliseconds: 100),
                      ),
                    ],
                    totalRepeatCount: 1,
                  ),
                  if (_badges.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    Text('Achievements:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.deepPurple)),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: _badges.map((badge) => Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Column(
                          children: [
                            CircleAvatar(
                              backgroundColor: badge.color.withOpacity(0.2),
                              child: Icon(badge.icon, color: badge.color, size: 28),
                              radius: 24,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              badge.label,
                              style: TextStyle(fontSize: 12, color: badge.color, fontWeight: FontWeight.w600),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      )).toList(),
                    ),
                  ],
                  const SizedBox(height: 20),
                  const Text(
                    'Your adventure begins now!',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  const SizedBox(height: 50),
                  ElevatedButton(
                    onPressed: () {
                      _confettiController.play();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    child: const Text(
                      'More Celebration!',
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}