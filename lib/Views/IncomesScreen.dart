import 'package:flutter/material.dart';

// Mock data for demonstration
class Income {
  final String description;
  final double amount;
  final DateTime date;
  final String category;

  Income({
    required this.description,
    required this.amount,
    required this.date,
    required this.category,
  });
}

class IncomeDetailScreen extends StatefulWidget {
  @override
  _IncomeDetailScreenState createState() => _IncomeDetailScreenState();
}

class _IncomeDetailScreenState extends State<IncomeDetailScreen> {
  DateTime selectedMonth = DateTime.now();
  final DateTime accountOpenDate = DateTime(2023, 1, 1); // Mock account opening date

  // Mock income data
  final List<Income> allIncomes = [
    Income(description: "משכורת חודשית", amount: 12500.00, date: DateTime(2024, 9, 30), category: "משכורת"),
    Income(description: "פרויקט פרילנס", amount: 3500.00, date: DateTime(2024, 9, 20), category: "עבודה נוספת"),
    Income(description: "מתנה לחג", amount: 500.00, date: DateTime(2024, 9, 15), category: "מתנות"),
    Income(description: "החזר מס", amount: 1200.00, date: DateTime(2024, 9, 10), category: "החזרים"),
    Income(description: "השכרת נכס", amount: 2800.00, date: DateTime(2024, 9, 5), category: "השכרה"),

    Income(description: "משכורת חודשית", amount: 12500.00, date: DateTime(2024, 8, 30), category: "משכורת"),
    Income(description: "בונוס ביצועים", amount: 5000.00, date: DateTime(2024, 8, 25), category: "בונוס"),
    Income(description: "השכרת נכס", amount: 2800.00, date: DateTime(2024, 8, 5), category: "השכרה"),
    Income(description: "ייעוץ פרטי", amount: 1500.00, date: DateTime(2024, 8, 18), category: "עבודה נוספת"),

    Income(description: "משכורת חודשית", amount: 12500.00, date: DateTime(2024, 7, 30), category: "משכורת"),
    Income(description: "מכירת ציוד", amount: 2200.00, date: DateTime(2024, 7, 22), category: "מכירות"),
    Income(description: "השכרת נכס", amount: 2800.00, date: DateTime(2024, 7, 5), category: "השכרה"),
    Income(description: "דיבידנדים", amount: 850.00, date: DateTime(2024, 7, 15), category: "השקעות"),
  ];

  List<Income> get filteredIncomes {
    return allIncomes.where((income) {
      return income.date.year == selectedMonth.year &&
          income.date.month == selectedMonth.month;
    }).toList()..sort((a, b) => b.date.compareTo(a.date));
  }

  double get totalIncomes {
    return filteredIncomes.fold(0.0, (sum, income) => sum + income.amount);
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
      case 'משכורת':
        return Icons.account_balance_wallet;
      case 'עבודה נוספת':
        return Icons.work;
      case 'מתנות':
        return Icons.card_giftcard;
      case 'החזרים':
        return Icons.receipt_long;
      case 'השכרה':
        return Icons.home;
      case 'בונוס':
        return Icons.stars;
      case 'מכירות':
        return Icons.point_of_sale;
      case 'השקעות':
        return Icons.trending_up;
      default:
        return Icons.attach_money;
    }
  }

  Color getCategoryColor(String category) {
    switch (category) {
      case 'משכורת':
        return Colors.green;
      case 'עבודה נוספת':
        return Colors.blue;
      case 'מתנות':
        return Colors.pink;
      case 'החזרים':
        return Colors.orange;
      case 'השכרה':
        return Colors.teal;
      case 'בונוס':
        return Colors.amber;
      case 'מכירות':
        return Colors.purple;
      case 'השקעות':
        return Colors.indigo;
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
                          color: isSelected ? Colors.green : Colors.black,
                        ),
                      ),
                      selected: isSelected,
                      selectedTileColor: Colors.green.withOpacity(0.1),
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
      backgroundColor: Colors.green[50],
      appBar: AppBar(
        title: Text('הכנסות'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              // Add new income functionality
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('הוסף הכנסה חדשה'),
                  backgroundColor: Colors.green,
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
                      border: Border.all(color: Colors.green),
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.green[50],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Icon(Icons.calendar_month, color: Colors.green),
                        Text(
                          '${getMonthName(selectedMonth.month)} ${selectedMonth.year}',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.green[800],
                          ),
                        ),
                        Icon(Icons.arrow_drop_down, color: Colors.green),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 15),
                // Total for month
                Container(
                  padding: EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Colors.green[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'סה"כ הכנסות החודש:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.green[800],
                        ),
                      ),
                      Text(
                        '₪${totalIncomes.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.green[900],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Incomes List
          Expanded(
            child: filteredIncomes.isEmpty
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.account_balance_wallet,
                    size: 80,
                    color: Colors.grey[400],
                  ),
                  SizedBox(height: 20),
                  Text(
                    'אין הכנסות בחודש זה',
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
              itemCount: filteredIncomes.length,
              itemBuilder: (context, index) {
                Income income = filteredIncomes[index];
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
                            color: getCategoryColor(income.category).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(25),
                          ),
                          child: Icon(
                            getCategoryIcon(income.category),
                            color: getCategoryColor(income.category),
                            size: 24,
                          ),
                        ),
                        SizedBox(width: 15),

                        // Income Details
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                income.description,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                income.category,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: getCategoryColor(income.category),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                formatDate(income.date),
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
                              '₪${income.amount.toStringAsFixed(2)}',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.green[700],
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