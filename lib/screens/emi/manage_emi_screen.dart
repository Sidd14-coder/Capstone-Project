import 'package:flutter/material.dart';
import '../../services/emi_service.dart';
import 'add_emi_screen.dart';
import 'emi_calculator_screen.dart';
import 'payment_history_screen.dart';
import 'reminder_settings_screen.dart';

class ManageEmiScreen extends StatelessWidget {
  const ManageEmiScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Manage EMI"),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [

          ElevatedButton.icon(
            icon: const Icon(Icons.add),
            label: const Text("Add New EMI"),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const AddEmiScreen(),
                ),
              );
            },
          ),

          const SizedBox(height: 20),

          const Text(
            "Active EMIs",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 10),

          ...emiList.map((e) {

  double progress =
      (e.tenure - e.remainingMonths) / e.tenure;

  return Card(
    margin: const EdgeInsets.symmetric(vertical: 8),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
    ),

    child: Padding(
      padding: const EdgeInsets.all(16),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          Text(
            e.name,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 4),

          Text(
            "₹${e.monthlyEmi}/month",
            style: const TextStyle(
              color: Colors.grey,
            ),
          ),

          const SizedBox(height: 10),

          LinearProgressIndicator(
            value: progress,
            minHeight: 8,
            borderRadius: BorderRadius.circular(10),
          ),

          const SizedBox(height: 10),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [

              Text(
                "${e.remainingMonths} months left",
                style: const TextStyle(fontSize: 13),
              ),

              Text(
                "${((progress) * 100).toStringAsFixed(0)}% paid",
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}),

          const SizedBox(height: 20),

          _navCard(
            context,
            "EMI Calculator",
            "Calculate your EMI before taking a loan",
            EmiCalculatorScreen(),
          ),

          _navCard(
            context,
            "Payment History",
            "View past EMI payments",
            PaymentHistoryScreen(),
          ),

          _navCard(
            context,
            "Reminder Settings",
            "Set reminders for upcoming EMI payments",
            ReminderSettingsScreen(),
          ),
        ],
      ),
    );
  }

  Widget _navCard(
      BuildContext context,
      String title,
      String subtitle,
      Widget page,
      ) {
    return Card(
      child: ListTile(
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => page),
          );
        },
      ),
    );
  }
}