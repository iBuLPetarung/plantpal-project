import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';

class MyPlantPage extends StatelessWidget {
  const MyPlantPage({super.key});

  Future<void> _deletePlant(BuildContext context, String plantId) async {
    // Simpan messenger sebelum proses async
    final messenger = ScaffoldMessenger.of(context);

    final shouldDelete = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Delete Plant'),
            content: const Text('Are you sure you want to delete this plant?'),
            actions: [
              TextButton(
                child: const Text('Cancel'),
                onPressed: () => Navigator.pop(context, false),
              ),
              TextButton(
                child: const Text(
                  'Delete',
                  style: TextStyle(color: Colors.red),
                ),
                onPressed: () => Navigator.pop(context, true),
              ),
            ],
          ),
    );

    if (shouldDelete ?? false) {
      try {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .collection('plants')
            .doc(plantId)
            .delete();

        messenger.showSnackBar(
          const SnackBar(content: Text('Plant deleted successfully.')),
        );
      } catch (e) {
        messenger.showSnackBar(SnackBar(content: Text('Failed to delete: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final userPlantsStream =
        FirebaseFirestore.instance
            .collection('users')
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .collection('plants')
            .orderBy('createdAt', descending: true)
            .snapshots();

    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(color: Colors.white),
        title: const Text(
          "My Plant",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF99BC85),
        elevation: 0,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: userPlantsStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final plants = snapshot.data?.docs ?? [];

          if (plants.isEmpty) {
            return const Center(child: Text('No plants added yet.'));
          }

          return ListView.builder(
            itemCount: plants.length,
            itemBuilder: (context, index) {
              final plant = plants[index];
              final data = plant.data() as Map<String, dynamic>;
              final startDate = (data['startDate'] as Timestamp?)?.toDate();
              if (startDate == null) {
                return const SizedBox(); // Skip if no startDate
              }

              return Card(
                margin: const EdgeInsets.all(8),
                child: ListTile(
                  title: Text(data['plantName'] ?? 'Unknown'),
                  subtitle: Text(
                    "Type: ${data['plantType'] ?? 'Unknown'}\nVariety: ${data['variety'] ?? 'Unknown'}",
                  ),
                  onTap:
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (_) => PlantDetailPage(
                                plantId: plant.id,
                                plantName: data['plantName'] ?? '-',
                                plantType: data['plantType'] ?? '-',
                                variety: data['variety'] ?? '-',
                                plantingMethod: data['plantingMethod'] ?? '-',
                                startDate: startDate,
                              ),
                        ),
                      ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _deletePlant(context, plant.id),
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

class PlantDetailPage extends StatefulWidget {
  final String plantId;
  final String plantName;
  final String plantType;
  final String variety;
  final String plantingMethod;
  final DateTime startDate;

  const PlantDetailPage({
    super.key,
    required this.plantId,
    required this.plantName,
    required this.plantType,
    required this.variety,
    required this.plantingMethod,
    required this.startDate,
  });

  @override
  State<PlantDetailPage> createState() => _PlantDetailPageState();
}

class _PlantDetailPageState extends State<PlantDetailPage> {
  static const int estimatedHarvestDays = 90;
  late DateTime selectedDay;
  late int duration;

  final Set<int> wateredDays = {};
  final Set<int> fertilizedDays = {};
  final Set<int> checkedLeavesDays = {};

  bool isWatered = false;
  bool isFertilized = false;
  bool isCheckedLeaves = false;

  String get formattedDate => DateFormat('yyyy-MM-dd').format(selectedDay);
  final userId = FirebaseAuth.instance.currentUser!.uid;
  final _firestore = FirebaseFirestore.instance;

  String _getGrowthStage(int day) {
    if (day <= 5) {
      return '🌱 Germination';
    } else if (day <= 20) {
      return '🌿 Pertumbuhan Awal';
    } else if (day <= 60) {
      return '🌳 Early Growth';
    } else if (day <= 80) {
      return '🌾 Harvest Preparation';
    } else {
      return '🌾 Harvest';
    }
  }

  Future<void> loadRoutineStatus() async {
    final doc =
        await _firestore
            .collection('users')
            .doc(userId)
            .collection('plants')
            .doc(widget.plantId)
            .collection('routines')
            .doc(formattedDate)
            .get();

    final data = doc.data();
    setState(() {
      isWatered = data?['watered'] ?? false;
      isFertilized = data?['fertilized'] ?? false;
      isCheckedLeaves = data?['checkedLeaves'] ?? false;

      if (isWatered) wateredDays.add(duration);
      if (isFertilized) fertilizedDays.add(duration);
      if (isCheckedLeaves) checkedLeavesDays.add(duration);
    });
  }

  Future<void> updateRoutineStatus() async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('plants')
        .doc(widget.plantId)
        .collection('routines')
        .doc(formattedDate)
        .set({
          'watered': isWatered,
          'fertilized': isFertilized,
          'checkedLeaves': isCheckedLeaves,
          'timestamp': FieldValue.serverTimestamp(),
        });
  }

  Future<void> _addNotification(String action) async {
    final now = DateTime.now();

    await _firestore
        .collection('users')
        .doc(userId)
        .collection('notifications')
        .add({
          'plantId': widget.plantId,
          'plantName': widget.plantName,
          'action': action,
          'date': now,
          'timestamp': FieldValue.serverTimestamp(),
        });
  }

  Future<void> _showConfirmationDialog(
    BuildContext context,
    String action,
  ) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmation'),
          content: Text('Are you sure you have done the $action?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  switch (action) {
                    case 'Watered':
                      isWatered = !isWatered;
                      break;
                    case 'Fertilized':
                      isFertilized = !isFertilized;
                      break;
                    case 'Checked Leaves':
                      isCheckedLeaves = !isCheckedLeaves;
                      break;
                  }
                });

                updateRoutineStatus();
                _addNotification(action); // <-- Tambahkan ini
                Navigator.of(context).pop();
              },

              child: const Text('Confirm'),
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    selectedDay = DateTime.now();
    duration = selectedDay.difference(widget.startDate).inDays;
    loadRoutineStatus();
  }

  Widget buildGrowthCircle(double growthPercent) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            // Menggunakan SizedBox untuk mengatur diameter lingkaran
            SizedBox(
              width: 150, // Lebar lingkaran
              height: 150, // Tinggi lingkaran
              child: CircularProgressIndicator(
                value: growthPercent,
                strokeWidth: 10,
                valueColor: AlwaysStoppedAnimation<Color>(
                  growthPercent == 1.0
                      ? Colors.lightGreen
                      : const Color.fromARGB(255, 0, 255, 34),
                ),
              ),
            ),
            Text(
              '${(growthPercent * 100).toStringAsFixed(1)}%',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: growthPercent == 1.0 ? Colors.green : Colors.black,
              ),
            ),
          ],
        ),
        Text('Growth', style: TextStyle(fontSize: 16, color: Colors.black)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final remaining = estimatedHarvestDays - duration;
    final growthPercent = (duration / estimatedHarvestDays).clamp(0.0, 1.0);
    final checklistDoneToday =
        [isWatered, isFertilized, isCheckedLeaves].where((e) => e).length;
    final checklistPercent = (checklistDoneToday / 3).clamp(0.0, 1.0);
    final totalPercent = (growthPercent + checklistPercent) / 2;

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              Navigator.pop(context); // Kembali ke halaman sebelumnya
            },
          ),
          title: Text(
            widget.plantName,
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          backgroundColor: const Color(0xFF99BC85),
          elevation: 0,
        ),
        body: Column(
          children: [
            TableCalendar(
              firstDay: DateTime.utc(2000, 1, 1),
              lastDay: DateTime.utc(2100, 12, 31),
              focusedDay: selectedDay,
              selectedDayPredicate: (day) => isSameDay(day, selectedDay),
              onDaySelected: (selected, _) {
                setState(() {
                  selectedDay = selected;
                  duration = selected.difference(widget.startDate).inDays;
                });
                loadRoutineStatus();
              },
              headerStyle: const HeaderStyle(
                titleCentered: true,
                formatButtonVisible: false,
              ),
              calendarStyle: const CalendarStyle(
                todayDecoration: BoxDecoration(
                  color: Colors.orange,
                  shape: BoxShape.circle,
                ),
                selectedDecoration: BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                ),
              ),
            ),
            const SizedBox(height: 12),
            const TabBar(
              tabs: [
                Tab(text: "🌱 Status"),
                Tab(text: "🧑‍🌾 Routine"),
                Tab(text: "📈 Timeline"),
              ],
              labelColor: Colors.green,
              indicatorColor: Colors.green,
            ),
            Expanded(
              child: TabBarView(
                children: [
                  // 🌱 Status
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      buildGrowthCircle(growthPercent),
                      Text(
                        'Checklist: ${(checklistPercent * 100).toStringAsFixed(1)}%',
                      ),
                      Text(
                        'Total: ${(totalPercent * 100).toStringAsFixed(1)}%',
                      ),
                      Text('Days since planted: $duration'),
                      Text('Estimated days to harvest: $remaining'),
                    ],
                  ),

                  // 🧑‍🌾 Routine
                  Column(
                    children: [
                      CheckboxListTile(
                        title: const Text("Watered"),
                        value: isWatered,
                        onChanged: (value) {
                          _showConfirmationDialog(context, "Watered");
                        },
                      ),
                      CheckboxListTile(
                        title: const Text("Fertilized"),
                        value: isFertilized,
                        onChanged: (value) {
                          _showConfirmationDialog(context, "Fertilized");
                        },
                      ),
                      CheckboxListTile(
                        title: const Text("Checked Leaves"),
                        value: isCheckedLeaves,
                        onChanged: (value) {
                          _showConfirmationDialog(context, "Checked Leaves");
                        },
                      ),
                    ],
                  ),

                  // 📈 Timeline
                  // 📈 Timeline
                  ListView(
                    children: List.generate(estimatedHarvestDays, (i) {
                      final date = widget.startDate.add(Duration(days: i));
                      String growthStage = _getGrowthStage(i);

                      return Card(
                        margin: const EdgeInsets.symmetric(
                          vertical: 6,
                          horizontal: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 4,
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                DateFormat('yyyy-MM-dd').format(date),
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                growthStage,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontStyle: FontStyle.italic,
                                  color: Colors.green,
                                ),
                              ),
                              const SizedBox(height: 6),
                              // Statuses
                              Column(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        wateredDays.contains(i)
                                            ? "✅ Watered"
                                            : "❌ Watered",
                                        style: TextStyle(fontSize: 12),
                                      ),
                                      const SizedBox(width: 10),
                                      Text(
                                        fertilizedDays.contains(i)
                                            ? "✅ Fertilized"
                                            : "❌ Fertilized",
                                        style: TextStyle(fontSize: 12),
                                      ),
                                      const SizedBox(width: 10),
                                      Text(
                                        checkedLeavesDays.contains(i)
                                            ? "✅ Checked"
                                            : "❌ Checked",
                                        style: TextStyle(fontSize: 12),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
