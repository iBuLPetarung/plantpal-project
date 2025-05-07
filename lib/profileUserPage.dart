import 'package:flutter/material.dart';

class ProfileUserPage extends StatelessWidget {
  const ProfileUserPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Profile', style: TextStyle(color: Color(0xFF0D4715))),
        backgroundColor: const Color(0xFFEAF4E5),
        iconTheme: const IconThemeData(color: Color(0xFF0D4715)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            CircleAvatar(
              radius: 40,
              backgroundColor: Color(0xFF0D4715),
              child: Icon(Icons.person, size: 40, color: Colors.white),
            ),
            SizedBox(height: 20),
            Text(
              'Nama Pengguna',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text('email@example.com'),
            SizedBox(height: 30),
            Text('Informasi lainnya akan ditampilkan di sini...'),
          ],
        ),
      ),
    );
  }
}
