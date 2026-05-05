import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'NewExpenseScreen.dart';
import 'EditExpenseScreen.dart';

const Color kRed = Colors.red;
const Color kBgRed = Color(0xFFFFF0F0);
const Color kGray = Colors.grey;

class ExpensesScreen extends StatelessWidget {
  const ExpensesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBgRed,
      appBar: AppBar(
        backgroundColor: kRed,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('הוצאות', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('expenses').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: kRed));
          }
          if (snapshot.hasError) {
            return Center(child: Text('שגיאה: ${snapshot.error}', style: const TextStyle(color: kRed)));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('אין הוצאות להצגה', style: TextStyle(fontSize: 18, color: kGray)));
          }

          final docs = snapshot.data!.docs.toList();
          // Sort locally by date descending
          docs.sort((a, b) {
            final aData = a.data() as Map<String, dynamic>;
            final bData = b.data() as Map<String, dynamic>;
            final aDate = (aData['date'] as Timestamp?)?.toDate() ?? DateTime.fromMillisecondsSinceEpoch(0);
            final bDate = (bData['date'] as Timestamp?)?.toDate() ?? DateTime.fromMillisecondsSinceEpoch(0);
            return bDate.compareTo(aDate);
          });

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final doc = docs[index];
              final data = doc.data() as Map<String, dynamic>;
              final amount = data['amount'] ?? 0.0;
              final category = data['category'] ?? '';
              final note = data['note'] ?? '';
              final date = (data['date'] as Timestamp?)?.toDate() ?? DateTime.now();
              final dateStr = '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';

              return Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => EditExpenseScreen(
                      expenseId: doc.id,
                      amount: (amount is int) ? amount.toDouble() : amount,
                      category: category,
                      date: date,
                      note: note,
                    )));
                  },
                  leading: const CircleAvatar(
                    backgroundColor: kBgRed,
                    child: Icon(Icons.remove, color: kRed),
                  ),
                  title: Text(category, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('$dateStr ${note.isNotEmpty ? "- $note" : ""}'),
                  trailing: Text('₪${amount.toStringAsFixed(2)}', 
                    style: const TextStyle(color: kRed, fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NewExpenseScreen())),
        backgroundColor: kRed,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
