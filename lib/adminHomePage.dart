import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'main.dart';
import 'adminEditPage.dart';
import 'artikelPage.dart';

class AdminHomePage extends StatelessWidget {
  const AdminHomePage({super.key});

  void navigateToAddPlantPage(BuildContext context, String category) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddPlantPage(category: category)),
    );
  }

  Future<void> logout(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', false);

      // Menghapus seluruh stack halaman sebelumnya dan menggantinya dengan AppEntry
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const AppEntry()),
        (Route<dynamic> route) =>
            false, // Kondisi ini memastikan semua halaman sebelumnya dihapus
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal Logout: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final categories = ['Vegetables', 'Fruits', 'Grains', 'Nuts'];

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => logout(context),
        ),
        title: const Text(
          "Welcome Admin !!",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF99BC85),
      ),
      body: ListView.builder(
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              title: Text("Tambah tanaman ke kategori $category"),
              subtitle: Text("Klik untuk tambah / kelola tanaman"),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap:
                  () => showModalBottomSheet(
                    context: context,
                    builder:
                        (_) => Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ListTile(
                              leading: const Icon(Icons.add),
                              title: const Text('Tambah Tanaman'),
                              onTap: () {
                                Navigator.pop(context);
                                navigateToAddPlantPage(context, category);
                              },
                            ),
                            ListTile(
                              leading: const Icon(Icons.list),
                              title: const Text('Kelola Tanaman'),
                              onTap: () {
                                Navigator.pop(context);
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (_) => ManagePlantsPage(
                                          category: category,
                                        ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                  ),
            ),
          );
        },
      ),
    );
  }
}

class AddPlantPage extends StatefulWidget {
  final String category;

  const AddPlantPage({super.key, required this.category});

  @override
  State<AddPlantPage> createState() => _AddPlantPageState();
}

class _AddPlantPageState extends State<AddPlantPage> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  final _durationController = TextEditingController();
  final _scientificNameController = TextEditingController();
  final _wateringController = TextEditingController();
  final _sunlightController = TextEditingController();
  final _soilController = TextEditingController();
  final _careInstructionsController = TextEditingController();

  bool _isLoading = false;

  Future<void> _savePlant() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await FirebaseFirestore.instance.collection('plants').add({
        'name': _nameController.text.trim(),
        'description': _descController.text.trim(),
        'duration': int.parse(_durationController.text.trim()),
        'scientificName': _scientificNameController.text.trim(),
        'watering': _wateringController.text.trim(),
        'sunlight': _sunlightController.text.trim(),
        'soil': _soilController.text.trim(),
        'careInstructions': _careInstructionsController.text.trim(),
        'category': widget.category,
        'timestamp': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Tanaman berhasil ditambahkan ke ${widget.category}'),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal menyimpan tanaman: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(color: Colors.white),
        title: const Text(
          "Add Plant Information",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF99BC85),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                _buildTextField(_nameController, 'Plant Name'),
                _buildTextField(_descController, 'Description'),
                _buildTextField(
                  _durationController,
                  'Growth Duration',
                  keyboardType: TextInputType.number,
                ),
                _buildTextField(_scientificNameController, 'Scientific Name'),
                _buildTextField(_wateringController, 'Watering Needs'),
                _buildTextField(_sunlightController, 'Sunlight Requirements'),
                _buildTextField(_soilController, 'Soil Type'),
                _buildTextField(
                  _careInstructionsController,
                  'Plant Care Instructions',
                ),
                const SizedBox(height: 20),
                _isLoading
                    ? const CircularProgressIndicator()
                    : ElevatedButton(
                      onPressed: _savePlant,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF99BC85),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        "Submit",
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label, {
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
        ),
        keyboardType: keyboardType,
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return '$label must not be empty';
          }
          if (label == 'Growth Duration' &&
              int.tryParse(value.trim()) == null) {
            return 'The duration must be a number.';
          }
          return null;
        },
      ),
    );
  }
}
