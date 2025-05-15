import 'loginPage.dart';
import 'userPage.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'main.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool isLoggedIn = false;

  _getLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    });
  }

  @override
  void initState() {
    super.initState();
    _getLoginStatus();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _getLoginStatus(); // tambahkan ini agar status login terupdate
  }

  List<Map<String, dynamic>> getAccountOptions(BuildContext context) {
    List<Map<String, dynamic>> options = [];

    if (!isLoggedIn) {
      options.add({
        "title": "Login",
        "icon": FontAwesomeIcons.personChalkboard,
        "onTap":
            () => Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const LoginPage()),
            ),
      });
    } else {
      options.add({
        "title": "Profile",
        "icon": FontAwesomeIcons.user,
        "onTap":
            () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ProfileUserPage()),
            ),
      });
    }

    options.addAll([
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
        "onTap": () => _showLanguageDialog(context),
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
    ]);

    return options;
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
          "Setting",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true, // Ini yang membuat judul di tengah
        backgroundColor: const Color(0xFF99BC85),
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
      floatingActionButton: SizedBox(
        width: 74, // Ukuran tombol (diameter)
        height: 74, // Ukuran tombol (diameter)
        child: FloatingActionButton(
          backgroundColor: const Color(0xFF99BC85),
          onPressed: () {
            print("Floating action button clicked");
          },
          shape: CircleBorder(), // Membuat tombol bulat
          elevation: 6,
          child: const Icon(
            Icons.local_florist_outlined, // Menggunakan ikon yang diinginkan
            color: Color.fromARGB(255, 255, 255, 255), // Warna ikon putih
            size: 34, // Ukuran ikon
          ), // Efek bayangan tombol
        ),
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

  void _showLanguageDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Pilih Bahasa / Choose Language"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text("Bahasa Indonesia"),
                onTap: () {
                  print("Tombol ditekan: Bahasa Indonesia dipilih");
                },
              ),
              ListTile(
                title: const Text("English"),
                onTap: () {
                  print("Button pressed: English selected");
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
