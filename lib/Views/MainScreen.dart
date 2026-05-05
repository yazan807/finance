import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'ExpensesScreen.dart';
import 'IncomesScreen.dart';
import 'ProfileScreen.dart';

const Color kBgLight = Color(0xFFF8F9FA);
const Color kGray = Colors.grey;
const Color kRed = Colors.red;
const Color kGreen = Colors.green;
const Color kBlue = Colors.blue;

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBgLight,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text('ניהול פיננסי',
          style: TextStyle(color: Color(0xFF222222), fontWeight: FontWeight.bold, fontSize: 18)),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text('ברוכים הבאים',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF222222))),
              const SizedBox(height: 4),
              const Text('בחרו את הקטגוריה המתאימה',
                style: TextStyle(fontSize: 13, color: kGray)),
              const SizedBox(height: 20),

              // Summary cards - dynamic from Firestore
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('expenses').snapshots(),
                builder: (context, expenseSnapshot) {
                  return StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance.collection('incomes').snapshots(),
                    builder: (context, incomeSnapshot) {
                      double totalExpenses = 0;
                      double totalIncomes = 0;

                      if (expenseSnapshot.hasData) {
                        for (var doc in expenseSnapshot.data!.docs) {
                          totalExpenses += (doc.data() as Map<String, dynamic>)['amount'] ?? 0;
                        }
                      }

                      if (incomeSnapshot.hasData) {
                        for (var doc in incomeSnapshot.data!.docs) {
                          totalIncomes += (doc.data() as Map<String, dynamic>)['amount'] ?? 0;
                        }
                      }

                      double balance = totalIncomes - totalExpenses;

                      return Row(children: [
                        _summaryCard('הוצאות', '₪${totalExpenses.toStringAsFixed(0)}', kRed, const Color(0xFFFFF0F0)),
                        const SizedBox(width: 10),
                        _summaryCard('הכנסות', '₪${totalIncomes.toStringAsFixed(0)}', kGreen, const Color(0xFFF0FFF0)),
                        const SizedBox(width: 10),
                        _summaryCard('יתרה', '₪${balance.toStringAsFixed(0)}', kBlue, const Color(0xFFF0F6FF)),
                      ]);
                    },
                  );
                },
              ),
              const SizedBox(height: 20),

              // Menu card
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: const Color(0xFFEEEEEE)),
                ),
                child: Column(
                  children: [
                    _menuItem(context, 'הוצאות', 'נהל את ההוצאות שלך',
                      Icons.remove_circle_outline, kRed, const Color(0xFFFFF0F0),
                      () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ExpensesScreen()))),
                    const Divider(height: 1),
                    _menuItem(context, 'הכנסות', 'נהל את ההכנסות שלך',
                      Icons.add_circle_outline, kGreen, const Color(0xFFF0FFF0),
                      () => Navigator.push(context, MaterialPageRoute(builder: (_) => const IncomeScreen()))),
                    const Divider(height: 1),
                    _menuItem(context, 'פרופיל', 'נהל את הפרופיל שלך',
                      Icons.person_outline, kBlue, const Color(0xFFF0F6FF),
                      () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen()))),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _summaryCard(String label, String value, Color textColor, Color bg) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(14)),
        child: Column(
          children: [
            Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textColor)),
            const SizedBox(height: 4),
            Text(label, style: const TextStyle(fontSize: 10, color: kGray)),
          ],
        ),
      ),
    );
  }

  Widget _menuItem(BuildContext context, String title, String subtitle,
      IconData icon, Color color, Color bg, VoidCallback onTap) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        width: 42, height: 42,
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12)),
        child: Icon(icon, color: color, size: 22),
      ),
      title: Text(title,
        textDirection: TextDirection.rtl,
        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: color)),
      subtitle: Text(subtitle,
        textDirection: TextDirection.rtl,
        style: const TextStyle(fontSize: 11, color: kGray)),
      trailing: const Icon(Icons.chevron_left, color: kGray),
    );
  }
}
