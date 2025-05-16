import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class NotificationPage extends StatelessWidget {
  const NotificationPage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Scaffold(body: Center(child: Text("Not logged in.")));
    }

    final notificationsStream =
        FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('notifications')
            .orderBy('timestamp', descending: true)
            .snapshots();

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Notifications',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF99BC85),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: notificationsStream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text("Something went wrong"));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final notifications = snapshot.data!.docs;

          if (notifications.isEmpty) {
            return const Center(child: Text("No notifications found."));
          }

          return ListView.builder(
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final data = notifications[index].data() as Map<String, dynamic>;

              final plantName = data['plantName'] ?? '';
              final action = data['action'] ?? '';
              final title = data['title'] ?? '';
              final message = data['message'] ?? '';
              final timestamp = data['timestamp'] as Timestamp?;

              final formattedDate =
                  timestamp != null
                      ? DateFormat(
                        'yyyy-MM-dd – kk:mm',
                      ).format(timestamp.toDate())
                      : 'Unknown Date';

              return ListTile(
                leading: const Icon(
                  Icons.notifications_active,
                  color: Colors.green,
                ),
                title: Text(
                  title.isNotEmpty
                      ? title
                      : (plantName.isNotEmpty && action.isNotEmpty
                          ? "$plantName - $action"
                          : "No Title"),
                ),
                subtitle: Text(message.isNotEmpty ? message : formattedDate),
                trailing: Text(
                  formattedDate,
                  style: const TextStyle(fontSize: 12),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
