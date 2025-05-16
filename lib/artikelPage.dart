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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          _getFieldValue('name'),
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF99BC85),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            _buildDetailTile(
              "Scientific Name",
              _getFieldValue('scientificName'),
            ),
            _buildDetailTile("Description", _getFieldValue('description')),
            _buildDetailTile(
              "Growth Duration",
              "${_getFieldValue('duration')} hari",
            ),
            _buildDetailTile("Water Needs", _getFieldValue('watering')),
            _buildDetailTile("Sunlight", _getFieldValue('sunlight')),
            _buildDetailTile("Soil Type", _getFieldValue('soil')),
            _buildDetailTile(
              "Care Instructions",
              _getFieldValue('careInstructions'),
            ),
            _buildDetailTile("Category", _getFieldValue('category')),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailTile(String? title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        title: Text(
          title ?? '-',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(value.isNotEmpty ? value : '-'),
      ),
    );
  }

  /// Fungsi untuk mengambil nilai field dari dokumen secara aman.
  String _getFieldValue(String key) {
    final data = plant.data() as Map<String, dynamic>;
    if (data.containsKey(key) && data[key] != null) {
      return data[key].toString();
    }
    return '-';
  }
}
