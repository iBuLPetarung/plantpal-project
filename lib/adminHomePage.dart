import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminHomePage extends StatelessWidget {
  const AdminHomePage({super.key});

  void navigateToAddPlantPage(BuildContext context, String category) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddPlantPage(category: category)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<String> categories = ['Vegetable', 'Fruits', 'Grains', 'Nuts'];

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context); // Kembali ke halaman sebelumnya
          },
        ),
        title: const Text(
          "Welcome Admin !!",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF99BC85),
        elevation: 0,
      ),
      body: ListView.builder(
        itemCount: categories.length,
        itemBuilder: (context, index) {
          String category = categories[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              title: Text("Tambah tanaman ke kategori $category"),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () => navigateToAddPlantPage(context, category),
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
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  final TextEditingController _durationController = TextEditingController();

  Future<void> _savePlant() async {
    final name = _nameController.text.trim();
    final desc = _descController.text.trim();
    final duration = int.tryParse(_durationController.text.trim()) ?? 0;

    if (name.isEmpty || desc.isEmpty || duration <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Harap isi semua data dengan benar')),
      );
      return;
    }

    await FirebaseFirestore.instance.collection('plants').add({
      'name': name,
      'description': desc,
      'duration': duration,
      'category': widget.category,
      'timestamp': FieldValue.serverTimestamp(),
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Tanaman berhasil ditambahkan ke ${widget.category}'),
      ),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context); // Kembali ke halaman sebelumnya
          },
        ),
        title: const Text(
          "Add Plant Information",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF99BC85),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Plant Name'),
            ),
            TextField(
              controller: _descController,
              decoration: const InputDecoration(labelText: 'Description'),
            ),
            TextField(
              controller: _durationController,
              decoration: const InputDecoration(labelText: 'Growth Duration'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _savePlant,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF99BC85),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text("Submit", style: TextStyle(fontSize: 18)),
            ),
          ],
        ),
      ),
    );
  }
}
