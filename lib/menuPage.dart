import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MenuPage extends StatefulWidget {
  final String category;

  const MenuPage({super.key, required this.category});

  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  String searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF99BC85),
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            Expanded(
              child: Container(
                height: 45,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: TextField(
                  onChanged: (value) {
                    setState(() {
                      searchQuery = value.trim();
                    });
                  },
                  decoration: const InputDecoration(
                    hintText: 'Search Plant...',
                    hintStyle: TextStyle(color: Color(0xFF0D4715)),
                    prefixIcon: Icon(Icons.search, color: Color(0xFF0D4715)),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream:
            FirebaseFirestore.instance
                .collection('plants')
                .where('category', isEqualTo: widget.category)
                .orderBy('timestamp', descending: true)
                .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text(
                'No plants yet for the category "${widget.category}"',
                style: const TextStyle(fontSize: 16),
              ),
            );
          }

          // Filter data berdasarkan search query
          final plants =
              snapshot.data!.docs.where((doc) {
                final name = doc['name'].toString().toLowerCase();
                return name.contains(searchQuery.toLowerCase());
              }).toList();

          if (plants.isEmpty) {
            return Center(
              child: Text(
                'No plants found for the search: "$searchQuery"',
                style: const TextStyle(fontSize: 16),
              ),
            );
          }

          return ListView.builder(
            itemCount: plants.length,
            itemBuilder: (context, index) {
              final plant = plants[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: ListTile(
                  title: Text(plant['name']),
                  subtitle: Text(
                    '${plant['description']}\nDurasi tumbuh: ${plant['duration']} hari',
                  ),
                  isThreeLine: true,
                  leading: const Icon(Icons.eco, color: Color(0xFF0D4715)),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
