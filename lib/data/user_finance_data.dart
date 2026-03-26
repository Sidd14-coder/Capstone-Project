import '../globals.dart';

Future<Map<String, dynamic>> getUserFinanceData() async {
  double balance = totalCredit - totalDebit;
  double income = totalCredit;
  double expenses = totalDebit;
  double savings = income - expenses;

  return {
    "balance": balance,
    "income": income,
    "expenses": expenses,
    "savings": savings,
  };
}