// import 'package:flutter/material.dart';
// import '../../services/emi_service.dart';
// import 'add_emi_screen.dart';
// import 'emi_calculator_screen.dart';
// import 'payment_history_screen.dart';
// import 'reminder_settings_screen.dart';
// import 'package:hive/hive.dart';

// class ManageEmiScreen extends StatefulWidget {
//   const ManageEmiScreen({super.key});

//   @override
//   State<ManageEmiScreen> createState() => _ManageEmiScreenState();
// }

// class _ManageEmiScreen extends State<ManageEmiScreen> {

//   @override
//   Widget build(BuildContext context) {

//     var box = Hive.box('emiBox');
//     var emiData = box.values.toList();

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Manage EMI"),
//       ),
//       body: ListView(
//         padding: const EdgeInsets.all(16),
//         children: [

//           ElevatedButton.icon(
//             icon: const Icon(Icons.add),
//             label: const Text("Add New EMI"),
//             onPressed: () async {
//               await Navigator.push(
//                 context,
//                 MaterialPageRoute(
//                   builder: (_) => const AddEmiScreen(),
//                 ),
//               );
//               setState(() {}); // 🔥 UI refresh
//             },
//           ),

//           const SizedBox(height: 20),

//           const Text(
//             "Active EMIs",
//             style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//           ),

//           const SizedBox(height: 10),

//           ...emiData.map((e) {

//   double progress =
//       ((e['tenure'] - e['remainingMonths']) / e['tenure']);

//   return Card(
//     margin: const EdgeInsets.symmetric(vertical: 8),
//     shape: RoundedRectangleBorder(
//       borderRadius: BorderRadius.circular(16),
//     ),

//     child: Padding(
//       padding: const EdgeInsets.all(16),

//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [

//           Text(
//             e['name'],
//             style: const TextStyle(
//               fontSize: 16,
//               fontWeight: FontWeight.bold,
//             ),
//           ),

//           const SizedBox(height: 4),

//           Text(
//             "₹${e['emi']}/month",
//             style: const TextStyle(color: Colors.grey),
//           ),

//           const SizedBox(height: 10),

//           LinearProgressIndicator(
//             value: progress,
//             minHeight: 8,
//             borderRadius: BorderRadius.circular(10),
//           ),

//           const SizedBox(height: 10),

//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [

//               Text(
//                 "${e['remainingMonths']} months left",
//                 style: const TextStyle(fontSize: 13),
//               ),

//               Text(
//                 "${(progress * 100).toStringAsFixed(0)}% paid",
//                 style: const TextStyle(
//                   fontSize: 13,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     ),
//   );

// }).toList(),

//           ),

//           const SizedBox(height: 20),

//           _navCard(
//             context,
//             "EMI Calculator",
//             "Calculate your EMI before taking a loan",
//             EmiCalculatorScreen(),
//           ),

//           _navCard(
//             context,
//             "Payment History",
//             "View past EMI payments",
//             PaymentHistoryScreen(),
//           ),

//           _navCard(
//             context,
//             "Reminder Settings",
//             "Set reminders for upcoming EMI payments",
//             ReminderSettingsScreen(),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _navCard(
//       BuildContext context,
//       String title,
//       String subtitle,
//       Widget page,
//       ) {
//     return Card(
//       child: ListTile(
//         title: Text(title),
//         subtitle: Text(subtitle),
//         trailing: const Icon(Icons.arrow_forward_ios),
//         onTap: () {
//           Navigator.push(
//             context,
//             MaterialPageRoute(builder: (_) => page),
//           );
//         },
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

import 'add_emi_screen.dart';
import 'emi_calculator_screen.dart';
import 'payment_history_screen.dart';
import 'reminder_settings_screen.dart';

class ManageEmiScreen extends StatefulWidget {
  const ManageEmiScreen({super.key});

  @override
  State<ManageEmiScreen> createState() => _ManageEmiScreenState();
}

class _ManageEmiScreenState extends State<ManageEmiScreen> {

  @override
  Widget build(BuildContext context) {

    var box = Hive.box('emiBox');
    var emiData = box.values.toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Manage EMI"),
      ),

      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [

          /// ADD EMI BUTTON
          ElevatedButton.icon(
            icon: const Icon(Icons.add),
            label: const Text("Add New EMI"),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const AddEmiScreen(),
                ),
              );

              setState(() {}); // 🔥 refresh
            },
          ),

          const SizedBox(height: 20),

          const Text(
            "Active EMIs",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 10),

          /// EMI LIST FROM HIVE
          ...emiData.asMap().entries.map((entry) {

            int index = entry.key;
            var e = entry.value;

            double progress =
                ((e['tenure'] - e['remainingMonths']) / e['tenure']);

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

                    Row(
  mainAxisAlignment: MainAxisAlignment.spaceBetween,
  children: [

    Text(
      e['name'],
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),
    ),

    IconButton(
  icon: const Icon(Icons.delete, color: Colors.red),

  onPressed: () async {

    bool? confirm = await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Delete EMI"),
          content: const Text("Are you sure you want to delete this EMI?"),

          actions: [

            TextButton(
              onPressed: () {
                Navigator.pop(context, false); // cancel
              },
              child: const Text("Cancel"),
            ),

            TextButton(
              onPressed: () {
                Navigator.pop(context, true); // confirm
              },
              child: const Text("Delete"),
            ),
          ],
        );
      },
    );

    // 🔥 agar user ne YES click kiya
    if (confirm == true) {

      var box = Hive.box('emiBox');

      var deletedItem = e; // backup for undo

      box.deleteAt(index);

      setState(() {}); // refresh UI

      // 🎯 STEP 2 — UNDO SNACKBAR
      ScaffoldMessenger.of(context).showSnackBar(

        SnackBar(
          content: const Text("EMI deleted"),

          action: SnackBarAction(
            label: "UNDO",

            onPressed: () {
              box.add(deletedItem); // restore
              setState(() {});
            },
          ),
        ),
      );
    }
  },
),
  ],
),

                    const SizedBox(height: 4),

                    Text(
                      "₹${e['emi']}/month",
                      style: const TextStyle(color: Colors.grey),
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
                          "${e['remainingMonths']} months left",
                          style: const TextStyle(fontSize: 13),
                        ),

                        Text(
                          "${(progress * 100).toStringAsFixed(0)}% paid",
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

          }).toList(),

          const SizedBox(height: 20),

          _navCard(
            context,
            "EMI Calculator",
            "Calculate your EMI before taking a loan",
            const EmiCalculatorScreen(),
          ),

          _navCard(
            context,
            "Payment History",
            "View past EMI payments",
            const PaymentHistoryScreen(),
          ),

          _navCard(
            context,
            "Reminder Settings",
            "Set reminders for upcoming EMI payments",
            const ReminderSettingsScreen(),
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