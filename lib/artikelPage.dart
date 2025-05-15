import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ArtikelMenu extends StatefulWidget {
  const ArtikelMenu({super.key});
  @override
  State<ArtikelMenu> createState() => _ArtikelMenu();
}

class _ArtikelMenu extends State<ArtikelMenu> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: StreamBuilder<QuerySnapshot>(
        stream:
            FirebaseFirestore.instance
                .collection('plants')
                .orderBy('timestamp', descending: true)
                .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('There are no plants yet.'));
          }
          final plantDocs = snapshot.data!.docs;
          return GridView.builder(
            itemCount: plantDocs.length,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemBuilder: (context, index) {
              final plant = plantDocs[index];
              final plantName =
                  plant.data().toString().contains('name')
                      ? plant['name']?.toString() ?? 'Tanpa Nama'
                      : 'Tanpa Nama';
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DetailPlantPage(plant: plant),
                    ),
                  );
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF99BC85),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      plantName,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class DetailPlantPage extends StatelessWidget {
  final DocumentSnapshot plant;

  const DetailPlantPage({super.key, required this.plant});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(plant['name'] ?? 'Detail Tanaman'),
        backgroundColor: const Color(0xFF99BC85),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            _buildDetailTile("Nama Ilmiah", plant['scientificName']),
            _buildDetailTile("Deskripsi", plant['description']),
            _buildDetailTile("Durasi Tumbuh", "${plant['duration']} hari"),
            _buildDetailTile("Kebutuhan Air", plant['watering']),
            _buildDetailTile("Cahaya Matahari", plant['sunlight']),
            _buildDetailTile("Jenis Tanah", plant['soil']),
            _buildDetailTile("Instruksi Perawatan", plant['careInstructions']),
            _buildDetailTile("Kategori", plant['category']),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailTile(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(value),
      ),
    );
  }
}
