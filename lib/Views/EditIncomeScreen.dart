import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

const Color kGreen = Colors.green;
const Color kBgGreen = Color(0xFFF0FFF0);
const Color kGray = Colors.grey;

class EditIncomeScreen extends StatelessWidget {
  final String incomeId;
  final double amount;
  final String category;
  final DateTime date;
  final String note;

  const EditIncomeScreen({
    super.key,
    required this.incomeId,
    required this.amount,
    required this.category,
    required this.date,
    required this.note,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBgGreen,
      appBar: AppBar(
        backgroundColor: kGreen,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('עריכת הכנסה',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: _EditTransactionForm(
        accentColor: kGreen,
        submitLabel: 'שמור שינויים',
        deleteLabel: 'מחק הכנסה',
        initialAmount: amount,
        initialCategory: category,
        initialDate: date,
        initialNote: note,
        categories: const ['משכורת', 'עבודה נוספת', 'מתנות', 'החזרים', 'השכרה', 'בונוס', 'מכירות', 'השקעות', 'אחר'],
        onSubmit: (newAmount, newCategory, newDate, newNote) async {
          try {
            await FirebaseFirestore.instance.collection('incomes').doc(incomeId).update({
              'amount': newAmount,
              'category': newCategory,
              'date': Timestamp.fromDate(newDate),
              'note': newNote,
            });
            if (context.mounted) {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('ההכנסה עודכנה בהצלחה ✓')));
            }
          } catch (e) {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('שגיאה בעדכון: $e')));
            }
          }
        },
        onDelete: () async {
          try {
            await FirebaseFirestore.instance.collection('incomes').doc(incomeId).delete();
            if (context.mounted) {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('ההכנסה נמחקה ✓')));
            }
          } catch (e) {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('שגיאה במחיקה: $e')));
            }
          }
        },
      ),
    );
  }
}

class _EditTransactionForm extends StatefulWidget {
  final Color accentColor;
  final String submitLabel;
  final String deleteLabel;
  final double initialAmount;
  final String initialCategory;
  final DateTime initialDate;
  final String initialNote;
  final List<String> categories;
  final void Function(double, String, DateTime, String) onSubmit;
  final VoidCallback onDelete;

  const _EditTransactionForm({
    required this.accentColor,
    required this.submitLabel,
    required this.deleteLabel,
    required this.initialAmount,
    required this.initialCategory,
    required this.initialDate,
    required this.initialNote,
    required this.categories,
    required this.onSubmit,
    required this.onDelete,
  });

  @override
  State<_EditTransactionForm> createState() => _EditTransactionFormState();
}

class _EditTransactionFormState extends State<_EditTransactionForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _amountCtrl;
  late final TextEditingController _noteCtrl;
  late String _selectedCategory;
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    _amountCtrl = TextEditingController(text: widget.initialAmount.toStringAsFixed(2));
    _noteCtrl = TextEditingController(text: widget.initialNote);
    _selectedCategory = widget.initialCategory;
    _selectedDate = widget.initialDate;
  }

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
            const Text('סכום', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            TextFormField(
              controller: _amountCtrl,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              textDirection: TextDirection.ltr,
              decoration: InputDecoration(
                prefixText: '₪ ',
                filled: true, fillColor: Colors.white,
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

            const Text('קטגוריה', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              decoration: InputDecoration(
                filled: true, fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
              items: widget.categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
              onChanged: (v) => setState(() => _selectedCategory = v!),
            ),
            const SizedBox(height: 16),

            const Text('תאריך', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            InkWell(
              onTap: _pickDate,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Icon(Icons.calendar_today, color: widget.accentColor, size: 20),
                    Text('${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            const Text('הערה', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            TextFormField(
              controller: _noteCtrl,
              maxLines: 3,
              textDirection: TextDirection.rtl,
              decoration: InputDecoration(
                filled: true, fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 28),

            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  widget.onSubmit(double.parse(_amountCtrl.text), _selectedCategory, _selectedDate, _noteCtrl.text);
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
            const SizedBox(height: 12),

            OutlinedButton(
              onPressed: widget.onDelete,
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                side: const BorderSide(color: Colors.red),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: Text(widget.deleteLabel,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            ),
          ],
        ),
      ),
    );
  }
}
