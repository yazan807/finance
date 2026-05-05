import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

const Color kRed = Colors.red;
const Color kBgRed = Color(0xFFFFF0F0);
const Color kGray = Colors.grey;

class NewExpenseScreen extends StatelessWidget {
  const NewExpenseScreen({super.key});

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
        title: const Text('הוצאה חדשה',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: _TransactionForm(
        isExpense: true,
        submitLabel: 'הוסף הוצאה',
        accentColor: kRed,
        onSubmit: (amount, category, date, note) async {
          try {
            await FirebaseFirestore.instance.collection('expenses').add({
              'amount': amount,
              'category': category,
              'date': Timestamp.fromDate(date),
              'note': note,
              'createdAt': FieldValue.serverTimestamp(),
            });
            if (context.mounted) {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('ההוצאה נוספה בהצלחה ✓')));
            }
          } catch (e) {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('שגיאה בהוספת הוצאה: $e')));
            }
          }
        },
      ),
    );
  }
}

class _TransactionForm extends StatefulWidget {
  final bool isExpense;
  final String submitLabel;
  final Color accentColor;
  final void Function(double amount, String category, DateTime date, String note) onSubmit;

  const _TransactionForm({
    required this.isExpense,
    required this.submitLabel,
    required this.accentColor,
    required this.onSubmit,
  });

  @override
  State<_TransactionForm> createState() => _TransactionFormState();
}

class _TransactionFormState extends State<_TransactionForm> {
  final _formKey = GlobalKey<FormState>();
  final _amountCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();
  String? _selectedCategory;
  DateTime _selectedDate = DateTime.now();

  final List<String> _expenseCategories = [
    'מזון', 'תחבורה', 'חשבונות', 'קניות', 'בילוי', 'חינוך', 'ביטוח', 'בריאות', 'אחר'
  ];

  @override
  void dispose() {
    _amountCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // סכום
            const Text('סכום', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            TextFormField(
              controller: _amountCtrl,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              textDirection: TextDirection.ltr,
              decoration: InputDecoration(
                hintText: '0.00',
                prefixText: '₪ ',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: widget.accentColor)),
              ),
              validator: (v) {
                if (v == null || v.isEmpty) return 'יש להזין סכום';
                if (double.tryParse(v) == null || double.parse(v) <= 0) return 'סכום לא תקין';
                return null;
              },
            ),
            const SizedBox(height: 16),

            // קטגוריה
            const Text('קטגוריה', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
              hint: const Text('בחר קטגוריה'),
              items: _expenseCategories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
              onChanged: (v) => setState(() => _selectedCategory = v),
              validator: (v) => v == null ? 'יש לבחור קטגוריה' : null,
            ),
            const SizedBox(height: 16),

            // תאריך
            const Text('תאריך', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            InkWell(
              onTap: _pickDate,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Icon(Icons.calendar_today, color: widget.accentColor, size: 20),
                    Text('${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                        style: const TextStyle(fontSize: 15)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // הערה
            const Text('הערה (אופציונלי)', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            TextFormField(
              controller: _noteCtrl,
              maxLines: 3,
              textDirection: TextDirection.rtl,
              decoration: InputDecoration(
                hintText: 'תיאור קצר...',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 28),

            // כפתור שמירה
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  widget.onSubmit(
                    double.parse(_amountCtrl.text),
                    _selectedCategory!,
                    _selectedDate,
                    _noteCtrl.text,
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: widget.accentColor,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: Text(widget.submitLabel,
                  style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
            ),
          ],
        ),
      ),
    );
  }
}
