// ignore_for_file: use_build_context_synchronously

import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

/// A dialog that allows you to connect to Firestore
class FirestoreSetupDialog extends StatefulWidget {
  /// Creates a dialog that allows you to connect to Firestore
  const FirestoreSetupDialog({super.key});

  @override
  State<FirestoreSetupDialog> createState() => _FirestoreSetupDialogState();
}

class _FirestoreSetupDialogState extends State<FirestoreSetupDialog> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _projectIdController =
      TextEditingController(text: '');
  final TextEditingController _apiKeyController =
      TextEditingController(text: '');
  final TextEditingController _appIdController =
      TextEditingController(text: '');
  final TextEditingController _messagingSenderIdController =
      TextEditingController(text: '');

  Future<void> _initializeFirestore() async {
    try {
      await Firebase.initializeApp(
        name: 'dynamic_instance',
        options: FirebaseOptions(
          apiKey: _apiKeyController.text,
          appId: _appIdController.text,
          projectId: _projectIdController.text,
          messagingSenderId: _messagingSenderIdController.text,
        ),
      );
      final firestore =
          FirebaseFirestore.instanceFor(app: Firebase.app('dynamic_instance'));

      Navigator.of(context).pop(firestore);
      // ignore: avoid_catches_without_on_clauses
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to connect: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        child: contentBox(context),
      );

  Widget contentBox(BuildContext context) => Container(
        width: min(450, MediaQuery.of(context).size.width * 0.95),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              spreadRadius: 5,
              blurRadius: 7,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: SingleChildScrollView(
          // In case shit gets too tall
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                const Text(
                  'Connect To Firestore',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                _buildTextField(_projectIdController, 'Project ID'),
                _buildTextField(_apiKeyController, 'API Key'),
                _buildTextField(_appIdController, 'App ID'),
                _buildTextField(
                  _messagingSenderIdController,
                  'Messaging Sender ID',
                ),
                const SizedBox(height: 25),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      await _initializeFirestore();
                    }
                  },
                  child: const Text(
                    'Connect to Firestore',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
        ),
      );

  Widget _buildTextField(TextEditingController controller, String label) =>
      Padding(
        padding: const EdgeInsets.only(bottom: 15),
        child: TextFormField(
          controller: controller,
          decoration: InputDecoration(
            labelText: label,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            filled: true,
            fillColor: Colors.grey[100],
          ),
          validator: (value) =>
              value!.isEmpty ? 'This field is required' : null,
        ),
      );
}

/// Displays a dialog that allows you to connect to Firestore
Future<FirebaseFirestore?> connectToFirestoreDialog(
  BuildContext context,
) async {
  final result = await showDialog<FirebaseFirestore>(
    context: context,
    builder: (context) => const FirestoreSetupDialog(),
  );

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        result != null
            ? 'Firestore connected successfully!'
            : 'No Firestore for you!',
      ),
    ),
  );

  return result;
}
