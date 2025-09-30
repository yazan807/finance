import 'package:flutter/material.dart';

class AddIncomeScreen extends StatefulWidget {
  @override
  _AddIncomeScreenState createState() => _AddIncomeScreenState();
}

class _AddIncomeScreenState extends State<AddIncomeScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();

  String? _selectedCategory;
  DateTime _selectedDate = DateTime.now();

  final List<Map<String, dynamic>> _categories = [
    {'name': 'משכורת', 'icon': Icons.account_balance_wallet, 'color': Colors.green},
    {'name': 'עבודה נוספת', 'icon': Icons.work, 'color': Colors.blue},
    {'name': 'מתנות', 'icon': Icons.card_giftcard, 'color': Colors.pink},
    {'name': 'החזרים', 'icon': Icons.receipt_long, 'color': Colors.orange},
    {'name': 'השכרה', 'icon': Icons.home, 'color': Colors.teal},
    {'name': 'בונוס', 'icon': Icons.stars, 'color': Colors.amber},
    {'name': 'מכירות', 'icon': Icons.point_of_sale, 'color': Colors.purple},
    {'name': 'השקעות', 'icon': Icons.trending_up, 'color': Colors.indigo},
  ];

  @override
  void dispose() {
    _descriptionController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      locale: const Locale('he', 'IL'),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  String formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _saveIncome() {
    if (_formKey.currentState!.validate()) {
      if (_selectedCategory == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('יש לבחור קטגוריה'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      // Here you would save the income to your database
      final income = {
        'description': _descriptionController.text,
        'amount': double.parse(_amountController.text),
        'category': _selectedCategory,
        'date': _selectedDate,
      };

      print('Income saved: $income');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('ההכנסה נשמרה בהצלחה'),
          backgroundColor: Colors.green,
        ),
      );

      // Navigate back after a short delay
      Future.delayed(Duration(seconds: 1), () {
        Navigator.pop(context);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green[50],
      appBar: AppBar(
        title: Text('הכנסה חדשה'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Icon
                Center(
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.green[100],
                      borderRadius: BorderRadius.circular(40),
                    ),
                    child: Icon(
                      Icons.add_circle,
                      size: 40,
                      color: Colors.green[700],
                    ),
                  ),
                ),
                SizedBox(height: 30),

                // Description Field
                Text(
                  'תיאור ההכנסה',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 8),
                TextFormField(
                  controller: _descriptionController,
                  textAlign: TextAlign.right,
                  decoration: InputDecoration(
                    hintText: 'לדוגמה: משכורת חודשית',
                    hintStyle: TextStyle(color: Colors.grey[400]),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.green, width: 2),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'יש להזין תיאור';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),

                // Amount Field
                Text(
                  'סכום',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 8),
                TextFormField(
                  controller: _amountController,
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  textAlign: TextAlign.right,
                  decoration: InputDecoration(
                    hintText: '0.00',
                    hintStyle: TextStyle(color: Colors.grey[400]),
                    prefixIcon: Padding(
                      padding: EdgeInsets.only(right: 12, top: 12),
                      child: Text(
                        '₪',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.green[700],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.green, width: 2),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'יש להזין סכום';
                    }
                    if (double.tryParse(value) == null) {
                      return 'יש להזין מספר תקין';
                    }
                    if (double.parse(value) <= 0) {
                      return 'הסכום חייב להיות חיובי';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),

                // Date Field
                Text(
                  'תאריך',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 8),
                InkWell(
                  onTap: () => _selectDate(context),
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Icon(Icons.calendar_today, color: Colors.green),
                        Text(
                          formatDate(_selectedDate),
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 20),

                // Category Selection
                Text(
                  'קטגוריה',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 12),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: _categories.map((category) {
                    final isSelected = _selectedCategory == category['name'];
                    return InkWell(
                      onTap: () {
                        setState(() {
                          _selectedCategory = category['name'];
                        });
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? category['color'].withOpacity(0.2)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSelected
                                ? category['color']
                                : Colors.grey[300]!,
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              category['icon'],
                              size: 20,
                              color: category['color'],
                            ),
                            SizedBox(width: 8),
                            Text(
                              category['name'],
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                color: isSelected ? category['color'] : Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
                SizedBox(height: 40),

                // Save Button
                ElevatedButton(
                  onPressed: _saveIncome,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 3,
                  ),
                  child: Text(
                    'שמור הכנסה',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}