import 'package:flutter/material.dart';
import '../../services/emi_service.dart';
import 'manage_emi_screen.dart';

class EmiTrackerCard extends StatelessWidget {
  final double income;

  const EmiTrackerCard({super.key, required this.income});

  @override
  Widget build(BuildContext context) {
    double emi = totalEmi;
    double remaining = income - emi;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  blurRadius: 10,
                  color: Colors.black.withOpacity(0.08),
                )
              ],
            ),
            child: Column(
              children: [
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Monthly EMI Payments",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 12),

                _row("Monthly Income", income),
                _row("Total EMI", emi),
                _row("Remaining Balance After EMI", remaining),
              ],
            ),
          ),

          const SizedBox(height: 12),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.trending_up),
              label: const Text("Manage EMI"),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ManageEmiScreen(),
                  ),
                );
              },
            ),
          )
        ],
      ),
    );
  }

  Widget _row(String title, double value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title),
          Text("₹${value.toStringAsFixed(0)}",
              style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}