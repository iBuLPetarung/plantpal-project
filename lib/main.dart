import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:async';
import 'splashScreen.dart';
import 'notificationPage.dart';
import 'menuPage.dart';
import 'chatBotPage.dart';
import 'settingProfilePage.dart';
import 'startPlantPage.dart';
import 'loginPage.dart';
import 'artikelPage.dart';
import 'myPlantPage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Memastikan binding Flutter sudah siap
  await Firebase.initializeApp(); // Inisialisasi Firebase
  await dotenv.load();
  print("API KEY = ${dotenv.env['API_KEY']}");
  await SharedPreferences.getInstance(); // ✅ Tidak ada warning
  runApp(AppEntry()); // Jalankan aplikasi
}

class AppEntry extends StatefulWidget {
  const AppEntry({super.key});
  @override
  _AppEntryState createState() => _AppEntryState();
}

class _AppEntryState extends State<AppEntry> {
  bool _isSplashDone = false;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home:
          _isSplashDone
              ? MyApp()
              : SplashScreen(
                onFinish: () {
                  setState(() {
                    _isSplashDone = true;
                  });
                },
              ),
    );
  }
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final PageController _pageController = PageController();
  late Timer _autoScrollTimer;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _autoScrollTimer = Timer.periodic(Duration(seconds: 4), (_) {
      if (_pageController.hasClients && mounted) {
        final nextPage = (_currentPage + 1) % 3;
        _pageController.animateToPage(
          nextPage,
          duration: Duration(milliseconds: 800),
          curve: Curves.easeInOut,
        );
        setState(() {
          _currentPage = nextPage;
        });
      }
    });
  }

  @override
  void dispose() {
    _autoScrollTimer.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: EdgeInsets.only(top: 0),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 0),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: double.infinity,
                      height: 237,
                      child: PageView(
                        controller: _pageController,
                        onPageChanged: (page) {
                          setState(() {
                            _currentPage = page;
                          });
                        },
                        children: [
                          Image.asset('assets/appBar1.jpg', fit: BoxFit.cover),
                          Image.asset('assets/appBar2.jpg', fit: BoxFit.cover),
                          Image.asset('assets/appBar3.jpg', fit: BoxFit.cover),
                        ],
                      ),
                    ),
                    SizedBox(height: 26),
                    buildKategoriRow(),
                    SizedBox(height: 26),
                    buildButton(
                      "Start Plant",
                      Icons.local_florist,
                      onPressed: () async {
                        // Cek status login pengguna
                        User? user = FirebaseAuth.instance.currentUser;
                        if (user == null) {
                          // Tampilkan peringatan bahwa harus login terlebih dahulu
                          showDialog(
                            context: context,
                            builder:
                                (context) => AlertDialog(
                                  title: Text("Access Denied"),
                                  content: Text(
                                    "Please log in first to start planting.",
                                  ),
                                  actions: [
                                    TextButton(
                                      child: Text("Cancel"),
                                      onPressed:
                                          () => Navigator.of(context).pop(),
                                    ),
                                    TextButton(
                                      child: Text("Login"),
                                      onPressed: () {
                                        Navigator.of(
                                          context,
                                        ).pop(); // Tutup dialog
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => LoginPage(),
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                          );
                        } else {
                          // Jika sudah login, arahkan ke halaman Start Plant
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => StartPlantPage()),
                          );
                        }
                      },
                    ),
                    SizedBox(height: 22),
                    buildButton(
                      "Ask Planty",
                      Icons.adb,
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => HomeScreen()),
                        );
                      },
                    ),
                    SizedBox(height: 36),
                    buildSectionTitle("For you"),
                    ArtikelMenu(),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: 32,
            left: 16,
            right: 16,
            child: Row(
              children: [
                Expanded(child: _buildFloatingSearchBar()),
                SizedBox(width: 12),
                buildNotificationButton(context),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: MyBottomAppBar(),
      floatingActionButton: MyFloatingActionButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget buildKategoriRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        buildKategoriTile("Vegetables", FontAwesomeIcons.carrot),
        buildKategoriTile("Fruits", FontAwesomeIcons.apple),
        buildKategoriTile("Grains", FontAwesomeIcons.seedling),
        buildKategoriTile("Nuts", Icons.grain),
      ],
    );
  }

  Widget buildKategoriTile(String title, IconData icon) {
    return Expanded(
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => MenuPage(category: title)),
          );
        },
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Color.fromARGB(255, 255, 255, 255),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10,
                    spreadRadius: 1,
                    offset: Offset(0, 0),
                  ),
                ],
              ),
              child: Icon(icon, color: Color(0xFF99BC85), size: 32),
            ),
            SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFF0D4715),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildButton(
    String label,
    IconData icon, {
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: 333,
      height: 64,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 10,
              spreadRadius: 0.5,
              offset: Offset(0, 0),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent, // Supaya tidak tumpang tindih
            surfaceTintColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            elevation: 0, // elevation 0 karena kita pakai BoxShadow
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(icon, color: Color(0xFF99BC85), size: 36),
                  SizedBox(width: 8),
                  Text(
                    label,
                    style: TextStyle(
                      color: Color(0xFF0D4715),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Icon(Icons.arrow_forward, color: Color(0xFF99BC85), size: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildSectionTitle(String title) {
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

  Widget _buildFloatingSearchBar() {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 15,
            spreadRadius: 3,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            Icon(Icons.search, color: Color(0xFF0D4715)),
            SizedBox(width: 8),
            Expanded(
              child: TextField(
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Search Plant...',
                  hintStyle: TextStyle(color: Color(0xFF0D4715)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildNotificationButton(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 15,
            spreadRadius: 3,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: IconButton(
        icon: Icon(Icons.notifications_outlined, color: Color(0xFF0D4715)),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => NotificationPage()),
          );
        },
      ),
    );
  }
}

class MyBottomAppBar extends StatelessWidget {
  const MyBottomAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 70,
      child: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        elevation: 16,
        color: const Color(0xFFEAF4E5),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: MediaQuery.of(context).size.width * 0.1,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(
                width: 72,
                height: 72,
                child: IconButton(
                  padding: EdgeInsets.zero,
                  alignment: Alignment.center,
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const MyApp()),
                    );
                  },
                  icon: const Icon(
                    Icons.home,
                    color: Color(0xFF99BC85),
                    size: 34,
                  ),
                ),
              ),
              SizedBox(
                width: 72,
                height: 72,
                child: IconButton(
                  padding: EdgeInsets.zero,
                  alignment: Alignment.center,
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const ProfilePage()),
                    );
                  },
                  icon: const Icon(
                    Icons.settings,
                    color: Color(0xFF99BC85),
                    size: 34,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MyFloatingActionButton extends StatelessWidget {
  const MyFloatingActionButton({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 74, // Ukuran tombol (diameter)
      height: 74, // Ukuran tombol (diameter)
      child: FloatingActionButton(
        backgroundColor: Color(0xFF99BC85),
        onPressed: () async {
          // Cek status login pengguna
          User? user = FirebaseAuth.instance.currentUser;
          if (user == null) {
            // Tampilkan peringatan bahwa harus login terlebih dahulu
            showDialog(
              context: context,
              builder:
                  (context) => AlertDialog(
                    title: Text("Access Denied"),
                    content: Text("Please log in first to see your plant."),
                    actions: [
                      TextButton(
                        child: Text("Cancel"),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                      TextButton(
                        child: Text("Login"),
                        onPressed: () {
                          Navigator.of(context).pop(); // Tutup dialog
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => LoginPage()),
                          );
                        },
                      ),
                    ],
                  ),
            );
          } else {
            // Jika sudah login, arahkan ke halaman Start Plant
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => MyPlantPage()),
            );
          }
        },
        shape: CircleBorder(), // Membuat tombol bulat
        elevation: 6,
        child: Icon(
          Icons.local_florist_outlined,
          color: Color.fromARGB(255, 255, 255, 255),
          size: 34, // Ukuran ikon
        ),
      ),
    );
  }
}
