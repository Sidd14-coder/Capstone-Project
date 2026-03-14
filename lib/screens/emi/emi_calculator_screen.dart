import 'package:flutter/material.dart';
import 'dart:math';
import 'package:fl_chart/fl_chart.dart';

class EmiCalculatorScreen extends StatefulWidget {
  const EmiCalculatorScreen({super.key});

  @override
  State<EmiCalculatorScreen> createState() => _EmiCalculatorScreenState();
}

class _EmiCalculatorScreenState extends State<EmiCalculatorScreen> {

  final TextEditingController loanController = TextEditingController();
  final TextEditingController interestController = TextEditingController();
  final TextEditingController tenureController = TextEditingController();

  double emi = 0;
  double totalInterest = 0;
  double totalPayment = 0;

  void calculateEMI() {

    double loan = double.tryParse(loanController.text) ?? 0;
    double annualInterest = double.tryParse(interestController.text) ?? 0;
    int tenure = int.tryParse(tenureController.text) ?? 0;

    if (loan == 0 || annualInterest == 0 || tenure == 0) {
      return;
    }

    double monthlyInterest = annualInterest / 12 / 100;

    double emiValue = (loan * monthlyInterest * pow((1 + monthlyInterest), tenure)) /
        (pow((1 + monthlyInterest), tenure) - 1);

    double totalPay = emiValue * tenure;
    double interest = totalPay - loan;

    setState(() {
      emi = emiValue;
      totalPayment = totalPay;
      totalInterest = interest;
    });
  }

  void saveEmi() {

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("EMI Saved Successfully (connect with EMI tracker)"),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text("EMI Calculator"),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            const Text("Loan Amount"),
            const SizedBox(height: 5),

            TextField(
              controller: loanController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: "Enter loan amount",
              ),
            ),

            const SizedBox(height: 15),

            const Text("Interest Rate (%)"),
            const SizedBox(height: 5),

            TextField(
              controller: interestController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: "Annual interest rate",
              ),
            ),

            const SizedBox(height: 15),

            const Text("Loan Tenure (Months)"),
            const SizedBox(height: 5),

            TextField(
              controller: tenureController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: "Enter months",
              ),
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: calculateEMI,
                child: const Text("Calculate EMI"),
              ),
            ),

            const SizedBox(height: 30),

            if (emi > 0)
              Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(20),

                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      const Text(
                        "Loan Summary",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 15),

                      Text("Loan Amount: ₹${loanController.text}"),
                      Text("Interest Rate: ${interestController.text}%"),
                      Text("Tenure: ${tenureController.text} months"),

                      const Divider(height: 25),

                      Text(
                        "Monthly EMI: ₹${emi.toStringAsFixed(2)}",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      Text("Total Interest: ₹${totalInterest.toStringAsFixed(2)}"),
                      Text("Total Payment: ₹${totalPayment.toStringAsFixed(2)}"),

                      const SizedBox(height: 25),

                      const Text(
                        "Loan vs Interest",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 20),

                      SizedBox(
                        height: 200,
                        child: PieChart(
                          PieChartData(
                            sections: [

                              PieChartSectionData(
                                value: double.parse(loanController.text),
                                color: Colors.blue,
                                title: "Loan",
                              ),

                              PieChartSectionData(
                                value: totalInterest,
                                color: Colors.red,
                                title: "Interest",
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 25),

                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: saveEmi,
                          child: const Text("Save EMI"),
                        ),
                      )
                    ],
                  ),
                ),
              )
          ],
        ),
      ),
    );
  }
}