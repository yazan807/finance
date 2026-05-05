import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'Views/Login.dart';
import 'Views/MainScreen.dart';
import 'Views/ExpensesScreen.dart';
import 'Views/IncomesScreen.dart';
import 'Views/ProfileScreen.dart';
import 'Views/NewExpenseScreen.dart';
import 'Views/NewIncomeScreen.dart';
import 'Views/EditProfileScreen.dart';

const Color kBlue = Colors.blue;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const SpendWiseApp());
}

class SpendWiseApp extends StatelessWidget {
  const SpendWiseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SpendWise',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Rubik',
        colorScheme: ColorScheme.fromSeed(seedColor: kBlue),
        useMaterial3: true,
      ),
      home: const LoginScreen(),
      routes: {
        '/home':        (_) => const HomeScreen(),
        '/expenses':    (_) => const ExpensesScreen(),
        '/income':      (_) => const IncomeScreen(),
        '/profile':     (_) => const ProfileScreen(),
        '/new-expense': (_) => const NewExpenseScreen(),
        '/new-income':  (_) => const NewIncomeScreen(),
        '/edit-details':(_) => const EditDetailsScreen(),
      },
    );
  }
}
