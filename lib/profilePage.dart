import 'loginPage.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'main.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> accountOptions = [
      {
        "title": "Login",
        "icon": FontAwesomeIcons.personChalkboard,
        "onTap":
            () => Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => LoginPage()),
            ),
      },
      {
        "title": "Activity",
        "icon": FontAwesomeIcons.chartLine,
        "onTap": () => print("Activity Clicked"),
      },
      {
        "title": "Help Center",
        "icon": FontAwesomeIcons.circleInfo,
        "onTap": () => print("Help Center Clicked"),
      },
      {
        "title": "Change Language",
        "icon": FontAwesomeIcons.language,
        "onTap": () => print("Language Clicked"),
      },
      {
        "title": "Notification",
        "icon": FontAwesomeIcons.bell,
        "onTap": () => print("Notification Clicked"),
      },
      {
        "title": "Account Security",
        "icon": FontAwesomeIcons.shieldHalved,
        "onTap": () => print("Account Security Clicked"),
      },
      {
        "title": "Set up an account",
        "icon": FontAwesomeIcons.fileInvoice,
        "onTap": () => print("Set up an account Clicked"),
      },
    ];

    final List<Map<String, dynamic>> otherOptions = [
      {
        "title": "Privacy Policy",
        "icon": FontAwesomeIcons.handcuffs,
        "onTap": () => print("Privacy Policy Clicked"),
      },
      {
        "title": "Terms of Service",
        "icon": FontAwesomeIcons.teamspeak,
        "onTap": () => print("Terms of Service Clicked"),
      },
      {
        "title": "Rate",
        "icon": FontAwesomeIcons.star,
        "onTap": () => print("Rate Clicked"),
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text("Profile", style: TextStyle(color: Color(0xFF0D4715))),
        backgroundColor: Color(0xFFEAF4E5),
      ),
      body: SingleChildScrollView(
        child: Container(
          decoration: BoxDecoration(color: Colors.white),
          child: Column(
            children: [
              SizedBox(height: 16),
              _buildSectionTitle('Account'),
              SizedBox(height: 16),
              ...accountOptions.map((option) {
                return _buildProfileButton(
                  context,
                  option['title'],
                  option['icon'],
                  option['onTap'],
                );
              }),
              SizedBox(height: 16),
              _buildSectionTitle('Other Information'),
              SizedBox(height: 16),
              ...otherOptions.map((option) {
                return _buildProfileButton(
                  context,
                  option['title'],
                  option['icon'],
                  option['onTap'],
                );
              }),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const MyBottomAppBar(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        backgroundColor: Color(0xFF0D4715),
        onPressed: () {
          print("Floating action button clicked");
        },
        child: Icon(Icons.local_florist),
      ),
    );
  }

  ButtonStyle getButtonStyle() {
    return ElevatedButton.styleFrom(
      backgroundColor: Color.fromARGB(255, 255, 255, 255),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: EdgeInsets.only(left: 16),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF0D4715),
          ),
        ),
      ),
    );
  }

  // Function to avoid repetition of button code
  Widget _buildProfileButton(
    BuildContext context,
    String title,
    IconData icon,
    VoidCallback onPressed,
  ) {
    return SizedBox(
      width: double.infinity,
      height: 64,
      child: ElevatedButton(
        onPressed: onPressed,
        style: getButtonStyle(),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(icon, color: Color(0xFF0D4715), size: 22),
                SizedBox(width: 16),
                Text(
                  title,
                  style: TextStyle(
                    color: Color(0xFF0D4715),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            Icon(Icons.arrow_forward, color: Color(0xFF0D4715), size: 24),
          ],
        ),
      ),
    );
  }
}
