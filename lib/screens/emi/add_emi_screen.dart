import 'package:flutter/material.dart';
import '../../models/emi_model.dart';
import '../../services/emi_service.dart';

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

  void saveEmi() {

    if (!_formKey.currentState!.validate()) return;

    emiList.add(
      EmiModel(
        name: name.text,
        loanAmount: double.parse(loan.text),
        monthlyEmi: double.parse(emi.text),
        tenure: int.parse(tenure.text),
        remainingMonths: int.parse(tenure.text),
        paidMonths: 0,
        nextDue: DateTime.now(),
      ),
    );

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
                controller: tenure,
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