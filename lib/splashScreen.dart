import 'dart:async';
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  final VoidCallback onFinish;

  const SplashScreen({super.key, required this.onFinish});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  String displayedText = '';
  final String fullText = 'PlantPal';
  int _charIndex = 0;

  @override
  void initState() {
    super.initState();
    Timer.periodic(Duration(milliseconds: 150), (timer) {
      if (_charIndex < fullText.length) {
        setState(() {
          displayedText += fullText[_charIndex];
        });
        _charIndex++;
      } else {
        timer.cancel();
        Future.delayed(Duration(seconds: 1), widget.onFinish);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final plantText = displayedText.contains("Plant") ? "Plant" : displayedText;
    final palText = displayedText.replaceFirst(plantText, "");

    return Scaffold(
      backgroundColor: Color(0xFFEAF4E5),
      body: Center(
        child: RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: plantText,
                style: TextStyle(
                  color: Color(0xFF0D4715),
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextSpan(
                text: palText,
                style: TextStyle(
                  color: Color(0xFF99BC85),
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}