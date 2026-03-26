import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class AddTransactionScreen extends StatefulWidget {
  const AddTransactionScreen({super.key});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {

  String type = "Debit";
  String account = "UPI";
  String category = "Select Category";
  String amount = "";
  TextEditingController desc = TextEditingController();
  TextEditingController amountController = TextEditingController();

  List<String> categories = [
    "Food","Health","Grocery","Bills","Dining","Education",
    "Fuel","Gadgets","Shopping","Travel","Misc"
  ];

  Map<String, IconData> categoryIcons = {
  "Food": Icons.fastfood,
  "Health": Icons.health_and_safety,
  "Grocery": Icons.shopping_cart,
  "Bills": Icons.receipt,
  "Dining": Icons.restaurant,
  "Education": Icons.school,
  "Fuel": Icons.local_gas_station,
  "Gadgets": Icons.devices,
  "Shopping": Icons.shopping_bag,
  "Travel": Icons.flight,
  "Misc": Icons.category,
};

  /// SAVE TO HIVE
  void saveTransaction() {
  var box = Hive.box('customTransactions');
  print(box.values.toList());

  double amt = double.tryParse(amountController.text) ?? 0;

  if (amt <= 0) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Enter valid amount")),
    );
    return;
  }

  box.add({
    "type": type,
    "account": account,
    "category": category,
    "amount": amt,
    "note": desc.text,
    "date": DateTime.now().toString(),
  });

  print("Saved: $amt"); // debug

  Navigator.pop(context);
}

  /// CATEGORY PICKER
  void openCategoryPicker() {
    showModalBottomSheet(
      context: context,
      builder: (_) {
        return GridView.count(
          crossAxisCount: 3,
          padding: const EdgeInsets.all(16),
          children: categories.map((cat) {
            return GestureDetector(
              onTap: () {
                setState(() => category = cat);
                Navigator.pop(context);
              },
              child: Card(
  child: Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Icon(categoryIcons[cat], size: 30, color: Colors.green),
      const SizedBox(height: 5),
      Text(cat),
    ],
  ),
),
            );
          }).toList(),
        );
      },
    );
  }

  /// KEYPAD BUTTON
  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFBFD8C3),

      appBar: AppBar(
        backgroundColor: const Color(0xFF1E6F5C),
        title: const Text("Add Transaction"),
      ),

      body: Column(
        children: [

          /// TOP FORM
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [

                /// TYPE
                DropdownButtonFormField(
                  value: type,
                  items: ["Credit","Debit"]
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                  onChanged: (v) => setState(() => type = v!),
                  decoration: const InputDecoration(labelText: "Select type"),
                ),

                const SizedBox(height: 10),

                /// ACCOUNT
                DropdownButtonFormField(
                  value: account,
                  items: ["UPI","Cash"]
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                  onChanged: (v) => setState(() => account = v!),
                  decoration: const InputDecoration(labelText: "Select A/C"),
                ),

                const SizedBox(height: 10),

                /// DESCRIPTION
                TextField(
                  controller: desc,
                  decoration: const InputDecoration(
                    labelText: "Description",
                    hintText: "Shop, brand name",
                  ),
                ),

                const SizedBox(height: 10),

                /// CATEGORY
                ListTile(
                  leading: Icon(categoryIcons[category], color: Colors.green),
                  title: Text(category),
                  trailing: const Icon(Icons.arrow_drop_down),
                  onTap: openCategoryPicker,
                ),

                const SizedBox(height: 10),

                /// DATE + AMOUNT
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "${DateTime.now().day}/${DateTime.now().month}",
                    ),
                    SizedBox(
  width: 120,
  child: TextField(
    controller: amountController,
    keyboardType: const TextInputType.numberWithOptions(decimal: true), // 🔥 number keyboard
    decoration: const InputDecoration(
      prefixText: "₹ ",
      hintText: "0",
    ),
  ),
),
                  ],
                ),
              ],
            ),
          ),

          const Divider(),

          /// KEYPAD
          

          /// BUTTONS
          Row(
            children: [

              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey,
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: const Text("CANCEL"),
                ),
              ),

              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                  onPressed: saveTransaction,
                  child: const Text("OK"),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}