import 'package:flutter/material.dart';

class NotificationPage extends StatelessWidget {
  const NotificationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Notifications",
          style: TextStyle(color: Color(0xFF0D4715)),
        ),
        backgroundColor: Colors.white,
      ),
      body: Center(child: Text("This is the Notification Page!")),
    );
  }
}