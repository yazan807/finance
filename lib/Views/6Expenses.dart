import 'package:flutter/material.dart';

// Mock data for demonstration
class Expense {
  final String description;
  final double amount;
  final DateTime date;
  final String category;

  Expense({
    required this.description,
    required this.amount,
    required this.date,
    required this.category,
  });
}

class ExpensesDetailScreen extends StatefulWidget {
  @override
  _ExpensesDetailScreenState createState() => _ExpensesDetailScreenState();
}

class _ExpensesDetailScreenState extends State<ExpensesDetailScreen> {
  DateTime selectedMonth = DateTime.now();
  final DateTime accountOpenDate = DateTime(2023, 1, 1); // Mock account opening date

  // Mock expenses data
  final List<Expense> allExpenses = [
    Expense(description: "קניות במרקט", amount: 250.50, date: DateTime(2024, 9, 15), category: "מזון"),
    Expense(description: "דלק לרכב", amount: 180.00, date: DateTime(2024, 9, 14), category: "תחבורה"),
    Expense(description: "חשבון חשמל", amount: 320.75, date: DateTime(2024, 9, 10), category: "חשבונות"),
    Expense(description: "ביגוד", amount: 450.00, date: DateTime(2024, 9, 8), category: "קניות"),
    Expense(description: "ארוחה במסעדה", amount: 120.00, date: DateTime(2024, 9, 5), category: "בילוי"),

    Expense(description: "קניות סופר", amount: 380.25, date: DateTime(2024, 8, 28), category: "מזון"),
    Expense(description: "תיקון רכב", amount: 850.00, date: DateTime(2024, 8, 22), category: "תחבורה"),
    Expense(description: "חשבון מים", amount: 95.50, date: DateTime(2024, 8, 15), category: "חשבונות"),
    Expense(description: "ספרים", amount: 280.00, date: DateTime(2024, 8, 12), category: "חינוך"),

    Expense(description: "קניות במרכז", amount: 520.80, date: DateTime(2024, 7, 25), category: "קניות"),
    Expense(description: "ביטוח רכב", amount: 450.00, date: DateTime(2024, 7, 20), category: "ביטוח"),
    Expense(description: "טיולים", amount: 680.00, date: DateTime(2024, 7, 18), category: "בילוי"),
  ];

  List<Expense> get filteredExpenses {
    return allExpenses.where((expense) {
      return expense.date.year == selectedMonth.year &&
          expense.date.month == selectedMonth.month;
    }).toList()..sort((a, b) => b.date.compareTo(a.date));
  }

  double get totalExpenses {
    return filteredExpenses.fold(0.0, (sum, expense) => sum + expense.amount);
  }

  List<DateTime> getAvailableMonths() {
    List<DateTime> months = [];
    DateTime current = DateTime(accountOpenDate.year, accountOpenDate.month);
    DateTime now = DateTime.now();

    while (current.isBefore(now) ||
        (current.year == now.year && current.month == now.month)) {
      months.add(DateTime(current.year, current.month));
      current = DateTime(current.year, current.month + 1);
    }

    return months.reversed.toList();
  }

  String getMonthName(int month) {
    const months = [
      'ינואר', 'פברואר', 'מרץ', 'אפריל', 'מאי', 'יוני',
      'יולי', 'אוגוסט', 'ספטמבר', 'אוקטובר', 'נובמבר', 'דצמבר'
    ];
    return months[month - 1];
  }

  String formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  IconData getCategoryIcon(String category) {
    switch (category) {
      case 'מזון':
        return Icons.restaurant;
      case 'תחבורה':
        return Icons.directions_car;
      case 'חשבונות':
        return Icons.receipt;
      case 'קניות':
        return Icons.shopping_bag;
      case 'בילוי':
        return Icons.movie;
      case 'חינוך':
        return Icons.school;
      case 'ביטוח':
        return Icons.security;
      default:
        return Icons.attach_money;
    }
  }

  Color getCategoryColor(String category) {
    switch (category) {
      case 'מזון':
        return Colors.orange;
      case 'תחבורה':
        return Colors.blue;
      case 'חשבונות':
        return Colors.red;
      case 'קניות':
        return Colors.purple;
      case 'בילוי':
        return Colors.green;
      case 'חינוך':
        return Colors.indigo;
      case 'ביטוח':
        return Colors.teal;
      default:
        return Colors.grey;
    }
  }

  void _showMonthPicker() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Container(
          height: 400,
          padding: EdgeInsets.all(20),
          child: Column(
            children: [
              Text(
                'בחר חודש',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 20),
              Expanded(
                child: ListView.builder(
                  itemCount: getAvailableMonths().length,
                  itemBuilder: (context, index) {
                    DateTime month = getAvailableMonths()[index];
                    bool isSelected = month.year == selectedMonth.year &&
                        month.month == selectedMonth.month;

                    return ListTile(
                      title: Text(
                        '${getMonthName(month.month)} ${month.year}',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          color: isSelected ? Colors.red : Colors.black,
                        ),
                      ),
                      selected: isSelected,
                      selectedTileColor: Colors.red.withOpacity(0.1),
                      onTap: () {
                        setState(() {
                          selectedMonth = month;
                        });
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.red[50],
      appBar: AppBar(
        title: Text('הוצאות'),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              // Add new expense functionality
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('הוסף הוצאה חדשה'),
                  backgroundColor: Colors.red,
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Date Picker Section
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                Text(
                  'בחר חודש לצפייה',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
                SizedBox(height: 10),
                InkWell(
                  onTap: _showMonthPicker,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.red),
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.red[50],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Icon(Icons.calendar_month, color: Colors.red),
                        Text(
                          '${getMonthName(selectedMonth.month)} ${selectedMonth.year}',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.red[800],
                          ),
                        ),
                        Icon(Icons.arrow_drop_down, color: Colors.red),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 15),
                // Total for month
                Container(
                  padding: EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Colors.red[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'סה"כ הוצאות החודש:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.red[800],
                        ),
                      ),
                      Text(
                        '₪${totalExpenses.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.red[900],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Expenses List
          Expanded(
            child: filteredExpenses.isEmpty
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.receipt_long,
                    size: 80,
                    color: Colors.grey[400],
                  ),
                  SizedBox(height: 20),
                  Text(
                    'אין הוצאות בחודש זה',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            )
                : ListView.builder(
              padding: EdgeInsets.all(20),
              itemCount: filteredExpenses.length,
              itemBuilder: (context, index) {
                Expense expense = filteredExpenses[index];
                return Card(
                  margin: EdgeInsets.only(bottom: 12),
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Row(
                      children: [
                        // Category Icon
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: getCategoryColor(expense.category).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(25),
                          ),
                          child: Icon(
                            getCategoryIcon(expense.category),
                            color: getCategoryColor(expense.category),
                            size: 24,
                          ),
                        ),
                        SizedBox(width: 15),

                        // Expense Details
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                expense.description,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                expense.category,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: getCategoryColor(expense.category),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                formatDate(expense.date),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Amount
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '₪${expense.amount.toStringAsFixed(2)}',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.red[700],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}