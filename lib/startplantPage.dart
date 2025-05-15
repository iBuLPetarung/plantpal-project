import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class StartPlantPage extends StatefulWidget {
  const StartPlantPage({super.key});

  @override
  State<StartPlantPage> createState() => _StartPlantPageState();
}

class _StartPlantPageState extends State<StartPlantPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _plantNameController = TextEditingController();
  final TextEditingController _varietyController = TextEditingController();
  final TextEditingController _plantingMethodController =
      TextEditingController();

  String? _selectedType;
  DateTime? _selectedDate;

  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedDate == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please select a date')));
      return;
    }

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception("User not logged in");
      }

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('plants')
          .add({
            'plantName': _plantNameController.text,
            'plantType': _selectedType,
            'variety': _varietyController.text,
            'startDate': Timestamp.fromDate(_selectedDate!),
            'plantingMethod': _plantingMethodController.text,
            'createdAt': FieldValue.serverTimestamp(),
          });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Plant added successfully!')),
      );

      _formKey.currentState!.reset();
      setState(() {
        _selectedType = null;
        _selectedDate = null;
      });
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Start Plant",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF99BC85),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Plant Name",
                style: TextStyle(color: Color(0xFF0D4715)),
              ),
              TextFormField(
                controller: _plantNameController,
                decoration: _inputDecoration("Enter plant name"),
                style: const TextStyle(color: Color(0xFF0D4715)),
                validator: (value) => value!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),

              const Text(
                "Plant Type",
                style: TextStyle(color: Color(0xFF0D4715)),
              ),
              DropdownButtonFormField<String>(
                value: _selectedType,
                decoration: _inputDecoration("Select type"),
                style: const TextStyle(color: Color(0xFF0D4715)),
                items:
                    ['Vegetable', 'Fruits', 'Grains', 'Nuts'].map((type) {
                      return DropdownMenuItem(value: type, child: Text(type));
                    }).toList(),
                onChanged: (value) => setState(() => _selectedType = value),
                validator:
                    (value) => value == null ? 'Please select a type' : null,
              ),
              const SizedBox(height: 16),

              const Text("Variety", style: TextStyle(color: Color(0xFF0D4715))),
              TextFormField(
                controller: _varietyController,
                decoration: _inputDecoration("Enter variety"),
                style: const TextStyle(color: Color(0xFF0D4715)),
                validator: (value) => value!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              const Text(
                "Planting Start Date",
                style: TextStyle(color: Color(0xFF0D4715)),
              ),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      _selectedDate == null
                          ? 'No date selected'
                          : '${_selectedDate!.toLocal()}'.split(' ')[0],
                      style: const TextStyle(color: Color(0xFF0D4715)),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: _pickDate,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFEAF4E5),
                      foregroundColor: const Color(0xFF0D4715),
                      elevation: 5,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                    ),
                    child: const Text('Select Date'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text(
                "Planting Method",
                style: TextStyle(color: Color(0xFF0D4715)),
              ),
              TextFormField(
                controller: _plantingMethodController,
                decoration: _inputDecoration("Enter planting method"),
                style: const TextStyle(color: Color(0xFF0D4715)),
                validator: (value) => value!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF99BC85),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text("Submit", style: TextStyle(fontSize: 18)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Color(0xFF0D4715)),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF0D4715), width: 2.0),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF0D4715), width: 1.0),
      ),
    );
  }
}
