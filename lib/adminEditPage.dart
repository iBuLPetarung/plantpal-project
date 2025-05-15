import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ManagePlantsPage extends StatelessWidget {
  final String category;

  const ManagePlantsPage({super.key, required this.category});

  void _navigateToEditPage(BuildContext context, DocumentSnapshot doc) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => EditPlantPage(doc: doc)),
    );
  }

  Future<void> _deletePlant(String docId, BuildContext context) async {
    try {
      await FirebaseFirestore.instance.collection('plants').doc(docId).delete();

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tanaman berhasil dihapus')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Gagal menghapus tanaman: $e')));
      }
    }
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
        title: Text(
          "Manage Plants - $category",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF99BC85),
        elevation: 0,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream:
            FirebaseFirestore.instance
                .collection('plants')
                .where('category', isEqualTo: category)
                .orderBy('timestamp', descending: true)
                .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final plants = snapshot.data!.docs;

          if (plants.isEmpty) {
            return const Center(
              child: Text("Tidak ada tanaman di kategori ini"),
            );
          }

          return ListView.builder(
            itemCount: plants.length,
            itemBuilder: (context, index) {
              final doc = plants[index];
              return ListTile(
                title: Text(doc['name']),
                subtitle: Text('Durasi: ${doc['duration']} hari'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.blue),
                      onPressed: () => _navigateToEditPage(context, doc),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _deletePlant(doc.id, context),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class EditPlantPage extends StatefulWidget {
  final DocumentSnapshot doc;

  const EditPlantPage({super.key, required this.doc});

  @override
  State<EditPlantPage> createState() => _EditPlantPageState();
}

class _EditPlantPageState extends State<EditPlantPage> {
  late TextEditingController _nameController;
  late TextEditingController _descController;
  late TextEditingController _durationController;
  late TextEditingController _scientificNameController;
  late TextEditingController _wateringController;
  late TextEditingController _sunlightController;
  late TextEditingController _soilController;
  late TextEditingController _careInstructionsController;

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    final data = widget.doc;
    _nameController = TextEditingController(text: data['name']);
    _descController = TextEditingController(text: data['description']);
    _durationController = TextEditingController(
      text: data['duration'].toString(),
    );
    _scientificNameController = TextEditingController(
      text: data['scientificName'],
    );
    _wateringController = TextEditingController(text: data['watering']);
    _sunlightController = TextEditingController(text: data['sunlight']);
    _soilController = TextEditingController(text: data['soil']);
    _careInstructionsController = TextEditingController(
      text: data['careInstructions'],
    );
    super.initState();
  }

  Future<void> _updatePlant() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      await FirebaseFirestore.instance
          .collection('plants')
          .doc(widget.doc.id)
          .update({
            'name': _nameController.text.trim(),
            'description': _descController.text.trim(),
            'duration': int.parse(_durationController.text.trim()),
            'scientificName': _scientificNameController.text.trim(),
            'watering': _wateringController.text.trim(),
            'sunlight': _sunlightController.text.trim(),
            'soil': _soilController.text.trim(),
            'careInstructions': _careInstructionsController.text.trim(),
          });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Plant data has been successfully updated.'),
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to update: $e')));
    }
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
          "Edit Plants",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF99BC85),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
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
              _buildTextField(_careInstructionsController, 'Care Instructions'),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _updatePlant,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF99BC85),
                ),
                child: const Text("Simpan Perubahan"),
              ),
            ],
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
          border: const OutlineInputBorder(),
        ),
        keyboardType: keyboardType,
        validator: (value) {
          if (value == null || value.isEmpty) return 'Must not be empty';
          if (label == 'Growth Duration' && int.tryParse(value) == null) {
            return 'Must be a number';
          }
          return null;
        },
      ),
    );
  }
}
