
class User {
  final String description;
  final double amount;
  final String category;
  final String date;

  User({
    required this.description,
    required this.amount,
    required this.category,
    required this.date
  });

  // From JSON
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      description: json['description'],
      amount: json['amount'],
      category: json['email'],
      date: json['date'],
    );
  }

  // To JSON
  Map<String, dynamic> toJson() {
    return {
      'description': description,
      'amount': amount,
      'category': category,
      'date' : date,
    };
  }
}

