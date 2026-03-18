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

  List<String> categories = [
    "Food","Health","Grocery","Bills","Dining","Education",
    "Fuel","Gadgets","Shopping","Travel","Misc"
  ];

  /// SAVE TO HIVE
  void saveTransaction() {
    var box = Hive.box('customTransactions');

    box.add({
      "type": type,
      "account": account,
      "category": category,
      "amount": double.tryParse(amount) ?? 0,
      "note": desc.text,
      "date": DateTime.now().toString(),
    });

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
                child: Center(child: Text(cat)),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  /// KEYPAD BUTTON
  Widget numBtn(String n) {
    return GestureDetector(
      onTap: () {
        setState(() => amount += n);
      },
      child: Container(
        alignment: Alignment.center,
        child: Text(n, style: const TextStyle(fontSize: 22)),
      ),
    );
  }

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
                    Text(
                      "₹ $amount",
                      style: const TextStyle(fontSize: 18),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const Divider(),

          /// KEYPAD
          Expanded(
            child: GridView.count(
              crossAxisCount: 3,
              children: [
                numBtn("1"), numBtn("2"), numBtn("3"),
                numBtn("4"), numBtn("5"), numBtn("6"),
                numBtn("7"), numBtn("8"), numBtn("9"),
                numBtn("0"), numBtn("."),

                GestureDetector(
                  onTap: () {
                    if (amount.isNotEmpty) {
                      setState(() {
                        amount = amount.substring(0, amount.length - 1);
                      });
                    }
                  },
                  child: const Icon(Icons.backspace),
                ),
              ],
            ),
          ),

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