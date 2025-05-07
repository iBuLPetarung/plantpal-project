import 'package:flutter/material.dart';

class AdminHomePage extends StatelessWidget {
  const AdminHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Welcome Admin !",
          style: TextStyle(color: Color(0xFF0D4715)),
        ),
        backgroundColor: Colors.white,
      ),
      body: Center(child: Text("This is the Notification Page!")),
    );
  }
}
