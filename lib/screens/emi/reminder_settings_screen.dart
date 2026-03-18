import 'package:flutter/material.dart';
import '../../services/notification_service.dart';
import '../../services/emi_service.dart';
import 'package:hive/hive.dart';

class ReminderSettingsScreen extends StatefulWidget {
  const ReminderSettingsScreen({super.key});

  @override
  State<ReminderSettingsScreen> createState() => _ReminderSettingsScreenState();
}

class _ReminderSettingsScreenState extends State<ReminderSettingsScreen> {

  bool reminderEnabled = true;
  String selectedOption = "1 day before due date";

  final List<String> reminderOptions = [
    "On due date",
    "1 day before due date",
    "2 days before due date",
    "Custom date",
  ];

  @override
  Widget build(BuildContext context) {

    var box = Hive.box('emiBox');
    var emiData = box.values.toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F7),

      appBar: AppBar(
        backgroundColor: Colors.green,
        elevation: 0,
        title: const Text("Reminder Settings"),
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [

            /// EMI CARD
            ...emiData.map((e) {

  return Container(
    margin: const EdgeInsets.only(bottom: 12),
    padding: const EdgeInsets.all(16),

    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      boxShadow: const [
        BoxShadow(
          blurRadius: 8,
          color: Colors.black12,
        )
      ],
    ),

    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        Text(
          e['name'],
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 10),

        Text("₹${e['emi']}/month"),

        Text("${e['remainingMonths']} months left"),

      ],
    ),
  );

}).toList(),

            const SizedBox(height: 20),

            /// REMINDER SETTINGS CARD
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: const [
                  BoxShadow(
                    blurRadius: 8,
                    color: Colors.black12,
                  )
                ],
              ),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  /// Enable reminder switch
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [

                      const Text(
                        "Enable Reminder",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      Switch(
                        value: reminderEnabled,
                        activeColor: Colors.green,
                        onChanged: (value) {
                          setState(() {
                            reminderEnabled = value;
                          });
                        },
                      )

                    ],
                  ),

                  const SizedBox(height: 10),

                  const Text(
                    "Remind Me",
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 10),

                  /// Reminder options
                  Column(
                    children: reminderOptions.map((option) {

                      return ListTile(

                        contentPadding: EdgeInsets.zero,

                        title: Text(option),

                        trailing: selectedOption == option
                            ? const Icon(Icons.check, color: Colors.green)
                            : null,

                        onTap: () {

                          setState(() {
                            selectedOption = option;
                          });

                        },
                      );

                    }).toList(),
                  )

                ],
              ),
            ),

            const Spacer(),

            /// SAVE BUTTON
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(

                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),

                onPressed: () {

  DateTime dueDate = DateTime(2026, 5, 10); // example EMI due date

  DateTime reminderDate = dueDate;

  if (selectedOption == "1 day before due date") {
    reminderDate = dueDate.subtract(const Duration(days: 1));
  }

  if (selectedOption == "2 days before due date") {
    reminderDate = dueDate.subtract(const Duration(days: 2));
  }

  NotificationService.scheduleNotification(
    id: 1,
    title: "EMI Reminder",
    body: "Your EMI is due soon",
    scheduledDate: reminderDate,
  );

  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text("Reminder Scheduled"),
    ),
  );

},

                child: const Text(
                  "Save Changes",
                  style: TextStyle(fontSize: 16),
                ),
              ),
            )

          ],
        ),
      ),
    );
  }
}