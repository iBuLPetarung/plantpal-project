import 'loginPage.dart';
import 'profileUserPage.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'main.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // TODO: Ganti ini dengan status login sesungguhnya dari Firebase atau SharedPreferences
  bool isLoggedIn = true;

  List<Map<String, dynamic>> getAccountOptions(BuildContext context) {
    return [
      if (!isLoggedIn)
        {
          "title": "Login",
          "icon": FontAwesomeIcons.personChalkboard,
          "onTap":
              () => Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const LoginPage()),
              ),
        }
      else
        {
          "title": "Profile",
          "icon": FontAwesomeIcons.user,
          "onTap":
              () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProfileUserPage()),
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
  }

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Profile",
          style: TextStyle(color: Color(0xFF0D4715)),
        ),
        backgroundColor: const Color(0xFFEAF4E5),
      ),
      body: SingleChildScrollView(
        child: Container(
          decoration: const BoxDecoration(color: Colors.white),
          child: Column(
            children: [
              const SizedBox(height: 16),
              _buildSectionTitle('Account'),
              const SizedBox(height: 16),
              ...getAccountOptions(context).map((option) {
                return _buildProfileButton(
                  context,
                  option['title'],
                  option['icon'],
                  option['onTap'],
                );
              }),
              const SizedBox(height: 16),
              _buildSectionTitle('Other Information'),
              const SizedBox(height: 16),
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
        backgroundColor: const Color(0xFF0D4715),
        onPressed: () {
          print("Floating action button clicked");
        },
        child: const Icon(Icons.local_florist),
      ),
    );
  }

  ButtonStyle getButtonStyle() {
    return ElevatedButton.styleFrom(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(left: 16),
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF0D4715),
          ),
        ),
      ),
    );
  }

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
                Icon(icon, color: const Color(0xFF0D4715), size: 22),
                const SizedBox(width: 16),
                Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFF0D4715),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Icon(Icons.arrow_forward, color: Color(0xFF0D4715), size: 24),
          ],
        ),
      ),
    );
  }
}
