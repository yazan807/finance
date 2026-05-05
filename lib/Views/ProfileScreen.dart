import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'EditProfileScreen.dart';

const Color kBlue = Colors.blue;
const Color kBgBlue = Color(0xFFE3F2FD);

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  String get _userId => FirebaseAuth.instance.currentUser?.uid ?? 'default_user';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBgBlue,
      appBar: AppBar(
        backgroundColor: kBlue,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('פרופיל', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('users').doc(_userId).snapshots(),
        builder: (context, snapshot) {
          String name = 'מספר חסוי';
          String email = 'כאן תוכלו לנהל את הפרופיל שלכם';

          if (snapshot.hasData && snapshot.data!.exists) {
            final data = snapshot.data!.data() as Map<String, dynamic>?;
            if (data != null) {
              name = data['name'] ?? name;
              email = data['email'] ?? email;
            }
          }

          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 80, height: 80,
                  decoration: const BoxDecoration(color: kBlue, shape: BoxShape.circle),
                  child: const Icon(Icons.person, color: Colors.white, size: 40),
                ),
                const SizedBox(height: 14),
                Text(name,
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1A3A6E))),
                const SizedBox(height: 6),
                Text(email,
                    style: const TextStyle(fontSize: 13, color: Color(0xFF5DAAEE))),
                const SizedBox(height: 28),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: ElevatedButton(
                    onPressed: () => Navigator.push(context,
                        MaterialPageRoute(builder: (_) => const EditDetailsScreen())),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kBlue,
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: const Text('ערוך פרופיל',
                        style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600)),
                  ),
                ),
              ],
            ),
          );
        }
      ),
    );
  }
}
