import 'package:flutter/material.dart';
// import '../../models/emi_model.dart';
import '../../services/emi_service.dart';
import 'package:hive/hive.dart';

class AddEmiScreen extends StatefulWidget {
  const AddEmiScreen({super.key});

  @override
  State<AddEmiScreen> createState() => _AddEmiScreenState();
}

class _AddEmiScreenState extends State<AddEmiScreen> {

  final _formKey = GlobalKey<FormState>();

  final name = TextEditingController();
  final loan = TextEditingController();
  final emi = TextEditingController();
  final tenure = TextEditingController();
  final interest = TextEditingController();

  void saveEmi() {

  if (!_formKey.currentState!.validate()) return;

  var box = Hive.box('emiBox');

  box.add({
    "name": name.text,
    "loanAmount": double.tryParse(loan.text) ?? 0,
    "emi": double.tryParse(emi.text) ?? 0,
    "tenure": int.tryParse(tenure.text) ?? 0,
    "paidMonths": 0,
    "remainingMonths": int.tryParse(tenure.text) ?? 0,
    "keywords": name.text.toLowerCase(), // 🔥 IMPORTANT
    "nextDue": DateTime.now().toString(),
  });

  Navigator.pop(context);
}

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(title: const Text("Add New EMI")),

      body: Padding(
        padding: const EdgeInsets.all(16),

        child: Form(
          key: _formKey,
          child: Column(
            children: [

              TextFormField(
                controller: name,
                decoration: const InputDecoration(labelText: "Loan Name"),
                validator: (v)=>v!.isEmpty?"Enter loan name":null,
              ),

              TextFormField(
                controller: loan,
                decoration: const InputDecoration(labelText: "Loan Amount"),
                keyboardType: TextInputType.number,
              ),

              TextFormField(
                controller: emi,
                decoration: const InputDecoration(labelText: "Monthly EMI"),
                keyboardType: TextInputType.number,
              ),

              TextFormField(
                controller: tenure,
                decoration: const InputDecoration(labelText: "Loan Tenure (months)"),
                keyboardType: TextInputType.number,
              ),

              TextFormField(
                controller: interest,
                decoration: const InputDecoration(labelText: "Rate Of Interest"),
                keyboardType: TextInputType.number,
              ),

              const SizedBox(height: 20),

              ElevatedButton(
                onPressed: saveEmi,
                child: const Text("Add EMI"),
              )
            ],
          ),
        ),
      ),
    );
  }
}