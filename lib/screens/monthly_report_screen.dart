// import 'package:flutter/material.dart';
// import '../../globals.dart';
// import '../../models/transaction_model.dart';
// import '../../widgets/debit_credit_chart.dart';

// class MonthlyReportScreen extends StatefulWidget {
//   const MonthlyReportScreen({super.key});

//   @override
//   State<MonthlyReportScreen> createState() => _MonthlyReportScreenState();
// }

// class _MonthlyReportScreenState extends State<MonthlyReportScreen> {
//   bool showCompare = false;

//   late DateTime reportMonth;
//   late List<TransactionModel> monthlyTransactions;

//   double totalIncome = 0;
//   double totalExpense = 0;
//   double openingBalance = 0;
//   double closingBalance = 0;

//   List<double> weeklyExpenses = List.filled(5, 0);

//   @override
//   void initState() {
//     super.initState();
//     _generateMonthlyReport();
//   }

//   void _generateMonthlyReport() {
//     final now = DateTime.now();
//     reportMonth = DateTime(now.year, now.month - 1);

//     monthlyTransactions = allTransactions.where((tx) {
//       return tx.date.year == reportMonth.year &&
//           tx.date.month == reportMonth.month;
//     }).toList();

//     monthlyTransactions.sort((a, b) => a.date.compareTo(b.date));

//     for (var tx in monthlyTransactions) {
//       if (tx.isCredit) {
//         totalIncome += tx.amount;
//       } else {
//         totalExpense += tx.amount;
//         final week = ((tx.date.day - 1) / 7).floor();
//         if (week < 5) weeklyExpenses[week] += tx.amount;
//       }
//     }

//     if (monthlyTransactions.isNotEmpty) {
//       openingBalance = monthlyTransactions.first.balance;
//       closingBalance = monthlyTransactions.last.balance;
//     }
//   }

//   List<TransactionModel> get topTransactions {
//     final debits = monthlyTransactions.where((t) => !t.isCredit).toList();
//     debits.sort((a, b) => b.amount.compareTo(a.amount));
//     return debits.take(3).toList();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final saving = totalIncome - totalExpense;
//     final percentUsed =
//         totalIncome == 0 ? 0 : (totalExpense / totalIncome) * 100;

//     return Scaffold(
//       backgroundColor: const Color(0xFFEAF7EA),
//       appBar: AppBar(
//         backgroundColor: const Color(0xFF1E6F5C),
//         title: const Text('Monthly Report'),
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back),
//           onPressed: () => Navigator.pop(context),
//         ),
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           children: [
//             /// HEADER
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Text(
//                   'Generated on ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
//                   style: const TextStyle(color: Colors.black54),
//                 ),
//                 Text(
//                   '${_monthName(reportMonth.month)} ${reportMonth.year}',
//                   style: const TextStyle(fontWeight: FontWeight.bold),
//                 ),
//               ],
//             ),

//             const SizedBox(height: 16),

//             /// TOGGLE
//             Row(
//               children: [
//                 _toggleButton('This Month', !showCompare),
//                 _toggleButton('Compare 5 Months', showCompare),
//               ],
//             ),

//             const SizedBox(height: 16),

//             /// THIS MONTH
//             if (!showCompare) ...[
//               Row(
//                 children: [
//                   _statCard('Total Income', totalIncome, Colors.blue),
//                   _statCard('Total Expense', totalExpense, Colors.red),
//                   _statCard('Total Saving', saving, Colors.green),
//                 ],
//               ),

//               const SizedBox(height: 16),

//               _section(
//                 'Summary',
//                 Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     _summaryText(
//                         'Net Change', closingBalance - openingBalance),
//                     _summaryText('Opening Balance', openingBalance),
//                     _summaryText('Closing Balance', closingBalance),
//                   ],
//                 ),
//               ),

//               _section(
//                 'Top Transactions',
//                 Column(
//                   children: topTransactions
//                       .map(
//                         (tx) => ListTile(
//                           leading: const CircleAvatar(
//                             backgroundColor: Colors.red,
//                             child: Icon(Icons.arrow_upward, color: Colors.white),
//                           ),
//                           title: Text(tx.description),
//                           subtitle:
//                               Text('${tx.date.day}/${tx.date.month}/${tx.date.year}'),
//                           trailing: Text(
//                             '-₹${tx.amount.toStringAsFixed(0)}',
//                             style: const TextStyle(color: Colors.red),
//                           ),
//                         ),
//                       )
//                       .toList(),
//                 ),
//               ),

//               _section(
//                 'Spending Trend',
//                 DebitCreditBarChart(
//                   totalDebit: weeklyExpenses.reduce((a, b) => a + b),
//                   totalCredit: totalIncome,
//                 ),
//               ),

//               if (percentUsed >= 75)
//                 Container(
//                   padding: const EdgeInsets.all(12),
//                   decoration: BoxDecoration(
//                     color: Colors.red.shade100,
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                   child: Row(
//                     children: [
//                       const Icon(Icons.warning, color: Colors.red),
//                       const SizedBox(width: 8),
//                       Expanded(
//                         child: Text(
//                           'Warning: You used ${percentUsed.toStringAsFixed(0)}% of your monthly budget!',
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//             ],

//             const SizedBox(height: 20),

//             /// BUTTONS
//             Row(
//               children: [
//                 Expanded(
//                   child: ElevatedButton.icon(
//                     icon: const Icon(Icons.download),
//                     label: const Text('Download'),
//                     onPressed: () {},
//                   ),
//                 ),
//                 const SizedBox(width: 12),
//                 Expanded(
//                   child: ElevatedButton.icon(
//                     icon: const Icon(Icons.share),
//                     label: const Text('Share Report'),
//                     onPressed: () {},
//                   ),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _toggleButton(String text, bool active) {
//     return Expanded(
//       child: GestureDetector(
//         onTap: () => setState(() => showCompare = text.contains('Compare')),
//         child: Container(
//           padding: const EdgeInsets.symmetric(vertical: 12),
//           margin: const EdgeInsets.symmetric(horizontal: 4),
//           decoration: BoxDecoration(
//             color: active ? const Color(0xFF1E6F5C) : Colors.white,
//             borderRadius: BorderRadius.circular(10),
//           ),
//           child: Center(
//             child: Text(
//               text,
//               style: TextStyle(
//                 color: active ? Colors.white : Colors.black,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _statCard(String title, double value, Color color) {
//     return Expanded(
//       child: Container(
//         margin: const EdgeInsets.symmetric(horizontal: 4),
//         padding: const EdgeInsets.all(14),
//         decoration: BoxDecoration(
//           color: color.withOpacity(0.15),
//           borderRadius: BorderRadius.circular(10),
//         ),
//         child: Column(
//           children: [
//             Text(title),
//             const SizedBox(height: 6),
//             Text(
//               '₹${value.toStringAsFixed(0)}',
//               style: TextStyle(
//                   fontWeight: FontWeight.bold, color: color),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _section(String title, Widget child) {
//     return Container(
//       margin: const EdgeInsets.only(top: 16),
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
//           const SizedBox(height: 10),
//           child,
//         ],
//       ),
//     );
//   }

//   Widget _summaryText(String label, double value) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 4),
//       child: Text('$label: ₹${value.toStringAsFixed(0)}'),
//     );
//   }

//   String _monthName(int m) =>
//       ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'][m - 1];
// }




// import 'package:flutter/material.dart';
// import '../globals.dart';
// import '../models/transaction_model.dart';

// class MonthlyReportScreen extends StatelessWidget {
//   const MonthlyReportScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final now = DateTime.now();
//     final startOfMonth = DateTime(now.year, now.month, 1);

//     final monthlyTransactions = allTransactions.where((tx) {
//       return tx.date.isAfter(
//         startOfMonth.subtract(const Duration(seconds: 1)),
//       );
//     }).toList();

//     monthlyTransactions.sort(
//       (a, b) => b.amount.compareTo(a.amount),
//     );

//     final topTransactions = monthlyTransactions.take(3).toList();

//     final netDifference = totalCredit - totalDebit;

//     final openingBalance =
//         bankBalances.isNotEmpty ? bankBalances.values.first : 0;

//     final closingBalance =
//         bankBalances.isNotEmpty ? bankBalances.values.last : 0;

//     final netChange = closingBalance - openingBalance;

//     final expensePercent = totalCredit == 0
//         ? 0
//         : (totalDebit / totalCredit) * 100;

//     return Scaffold(
//       appBar: AppBar(
//         title: Text(
//           '${now.month}-${now.year} Monthly Report',
//         ),
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             _card('Total Income', totalCredit),
//             _card('Total Expense', totalDebit),
//             _card('Difference', netDifference),

//             const SizedBox(height: 20),

//             _card('Opening Balance', openingBalance.toDouble()),
//             _card('Closing Balance', closingBalance.toDouble()),
//             _card('Net Change', netChange.toDouble()),

//             const SizedBox(height: 20),

//             const Text(
//               'Top Transactions',
//               style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//             ),

//             const SizedBox(height: 10),

//             for (final tx in topTransactions)
//               ListTile(
//                 title: Text(tx.bank),
//                 subtitle: Text(tx.description),
//                 trailing: Text(
//                   '₹${tx.amount.toStringAsFixed(0)}',
//                   style: const TextStyle(fontWeight: FontWeight.bold),
//                 ),
//               ),

//             const SizedBox(height: 20),

//             if (expensePercent >= 75)
//               Container(
//                 padding: const EdgeInsets.all(12),
//                 decoration: BoxDecoration(
//                   color: Colors.red.withOpacity(0.1),
//                   borderRadius: BorderRadius.circular(10),
//                 ),
//                 child: Text(
//                   '⚠ Warning: You spent ${expensePercent.toStringAsFixed(1)}% of your income this month',
//                   style: const TextStyle(color: Colors.red),
//                 ),
//               ),

//             const SizedBox(height: 30),

//             Row(
//               children: [
//                 Expanded(
//                   child: ElevatedButton.icon(
//                     icon: const Icon(Icons.download),
//                     label: const Text('Download PDF'),
//                     onPressed: () {},
//                   ),
//                 ),
//                 const SizedBox(width: 10),
//                 Expanded(
//                   child: ElevatedButton.icon(
//                     icon: const Icon(Icons.share),
//                     label: const Text('Share'),
//                     onPressed: () {},
//                   ),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _card(String title, double value) {
//     return Card(
//       child: ListTile(
//         title: Text(title),
//         trailing: Text(
//           '₹${value.toStringAsFixed(0)}',
//           style: const TextStyle(
//             fontWeight: FontWeight.bold,
//             fontSize: 16,
//           ),
//         ),
//       ),
//     );
//   }
// }






// import 'package:flutter/material.dart';
// import 'package:fl_chart/fl_chart.dart';
// import 'package:pdf/widgets.dart' as pw;
// import 'package:printing/printing.dart';
// import 'package:share_plus/share_plus.dart';
// import '../globals.dart';
// import '../models/transaction_model.dart';

// class MonthlyReportScreen extends StatefulWidget {
//   const MonthlyReportScreen({super.key});

//   @override
//   State<MonthlyReportScreen> createState() => _MonthlyReportScreenState();
// }

// class _MonthlyReportScreenState extends State<MonthlyReportScreen> {

//   bool showCompare = false;

//   @override
//   Widget build(BuildContext context) {

//     final now = DateTime.now();
//     final monthName = _monthName(now.month);

//     final startOfMonth = DateTime(now.year, now.month, 1);

//     final monthlyTransactions = allTransactions.where((tx) {
//       return tx.date.isAfter(
//         startOfMonth.subtract(const Duration(seconds: 1)),
//       );
//     }).toList();

//     double saving = totalCredit - totalDebit;

//     double openingBalance =
//         bankBalances.isNotEmpty ? bankBalances.values.first : 0;

//     double closingBalance =
//         bankBalances.isNotEmpty ? bankBalances.values.last : 0;

//     double netChange = closingBalance - openingBalance;

//     monthlyTransactions.sort((a, b) => b.amount.compareTo(a.amount));

//     final topTransactions = monthlyTransactions.take(3).toList();

//     double expensePercent =
//         totalCredit == 0 ? 0 : (totalDebit / totalCredit) * 100;

//     return Scaffold(
//       body: Stack(
//         children: [

//           /// BACKGROUND IMAGE
//           Container(
//             decoration: const BoxDecoration(
//               image: DecorationImage(
//                 image: AssetImage("assets/images/bg.png"),
//                 fit: BoxFit.cover,
//               ),
//             ),
//           ),

//           SafeArea(
//             child: SingleChildScrollView(
//               padding: const EdgeInsets.all(16),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [

//                   /// HEADER
//                   const Text(
//                     "Monthly Report",
//                     style: TextStyle(
//                         fontSize: 26,
//                         fontWeight: FontWeight.bold,
//                         color: Colors.white),
//                   ),

//                   const SizedBox(height: 4),

//                   Text(
//                     "Generated on April 1, ${now.year}",
//                     style: const TextStyle(color: Colors.white70),
//                   ),

//                   const SizedBox(height: 6),

//                   Text(
//                     "$monthName, ${now.year}",
//                     style: const TextStyle(
//                         color: Colors.white,
//                         fontWeight: FontWeight.bold),
//                   ),

//                   const SizedBox(height: 20),

//                   /// TOGGLE BUTTONS
//                   Row(
//                     children: [

//                       Expanded(
//                         child: ElevatedButton(
//                           style: ElevatedButton.styleFrom(
//                               backgroundColor: !showCompare
//                                   ? Colors.green
//                                   : Colors.grey.shade300),
//                           onPressed: () {
//                             setState(() {
//                               showCompare = false;
//                             });
//                           },
//                           child: const Text("This Month"),
//                         ),
//                       ),

//                       const SizedBox(width: 10),

//                       Expanded(
//                         child: ElevatedButton(
//                           style: ElevatedButton.styleFrom(
//                               backgroundColor: showCompare
//                                   ? Colors.green
//                                   : Colors.grey.shade300),
//                           onPressed: () {
//                             setState(() {
//                               showCompare = true;
//                             });
//                           },
//                           child: const Text("Compare 5 Months"),
//                         ),
//                       )
//                     ],
//                   ),

//                   const SizedBox(height: 20),

//                   /// INCOME EXPENSE SAVING BOXES
//                   Row(
//                     children: [

//                       Expanded(
//                         child: _infoBox(
//                             "Total Income",
//                             totalCredit,
//                             Colors.blue.shade100),
//                       ),

//                       const SizedBox(width: 10),

//                       Expanded(
//                         child: _infoBox(
//                             "Total Expense",
//                             totalDebit,
//                             Colors.red.shade100),
//                       ),

//                       const SizedBox(width: 10),

//                       Expanded(
//                         child: _infoBox(
//                             "Total Saving",
//                             saving,
//                             Colors.green.shade100),
//                       ),
//                     ],
//                   ),

//                   const SizedBox(height: 20),

//                   /// SUMMARY
//                   Container(
//                     padding: const EdgeInsets.all(12),
//                     decoration: BoxDecoration(
//                       color: Colors.white,
//                       borderRadius: BorderRadius.circular(10),
//                     ),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [

//                         const Text(
//                           "Summary",
//                           style: TextStyle(
//                               fontSize: 16,
//                               fontWeight: FontWeight.bold),
//                         ),

//                         const SizedBox(height: 8),

//                         Text("Net Change : ₹$netChange"),
//                         Text("Opening Balance : ₹$openingBalance"),
//                         Text("Closing Balance : ₹$closingBalance"),
//                       ],
//                     ),
//                   ),

//                   const SizedBox(height: 20),

//                   /// TOP TRANSACTIONS
//                   const Text(
//                     "Top Transactions",
//                     style:
//                         TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//                   ),

//                   const SizedBox(height: 10),

//                   for (final tx in topTransactions)
//                     Card(
//                       child: ListTile(
//                         leading: const Icon(Icons.arrow_upward,
//                             color: Colors.red),
//                         title: Text(tx.description),
//                         subtitle: Text(
//                             "${tx.bank}\nDebit • ${tx.date.day}/${tx.date.month}/${tx.date.year}"),
//                         trailing: Text(
//                           "- ₹${tx.amount}",
//                           style: const TextStyle(color: Colors.red),
//                         ),
//                       ),
//                     ),

//                   const SizedBox(height: 20),

//                   /// SPENDING TREND GRAPH
//                   const Text(
//                     "Spending Trend",
//                     style:
//                         TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//                   ),

//                   const SizedBox(height: 10),

//                   SizedBox(
//                     height: 200,
//                     child: BarChart(
//                       BarChartData(
//                         barGroups: _buildWeeklyBars(monthlyTransactions),
//                       ),
//                     ),
//                   ),

//                   const SizedBox(height: 20),

//                   /// WARNING MESSAGE
//                   if (expensePercent > 75)
//                     Container(
//                       padding: const EdgeInsets.all(12),
//                       decoration: BoxDecoration(
//                         color: Colors.orange.shade200,
//                         borderRadius: BorderRadius.circular(10),
//                       ),
//                       child: Text(
//                         "⚠ Warning: You used ${expensePercent.toStringAsFixed(0)}% of your monthly budget!",
//                       ),
//                     ),

//                   const SizedBox(height: 20),

//                   /// DOWNLOAD + SHARE
//                   Row(
//                     children: [

//                       Expanded(
//                         child: ElevatedButton.icon(
//                           icon: const Icon(Icons.download),
//                           label: const Text("Download"),
//                           onPressed: _downloadPDF,
//                         ),
//                       ),

//                       const SizedBox(width: 10),

//                       Expanded(
//                         child: ElevatedButton.icon(
//                           icon: const Icon(Icons.share),
//                           label: const Text("Share Report"),
//                           onPressed: _shareReport,
//                         ),
//                       )
//                     ],
//                   )
//                 ],
//               ),
//             ),
//           )
//         ],
//       ),
//     );
//   }

//   /// INFO BOX
//   Widget _infoBox(String title, double amount, Color color) {
//     return Container(
//       padding: const EdgeInsets.all(12),
//       decoration: BoxDecoration(
//         color: color,
//         borderRadius: BorderRadius.circular(10),
//       ),
//       child: Column(
//         children: [
//           Text(title),
//           const SizedBox(height: 6),
//           Text(
//             "₹${amount.toStringAsFixed(0)}",
//             style: const TextStyle(
//                 fontSize: 18,
//                 fontWeight: FontWeight.bold),
//           )
//         ],
//       ),
//     );
//   }

//   /// WEEKLY GRAPH DATA
//   List<BarChartGroupData> _buildWeeklyBars(List<TransactionModel> txs) {

//     List<double> weeks = [0,0,0,0,0];

//     for (var tx in txs) {
//       int week = ((tx.date.day - 1) / 7).floor();
//       if (!tx.isCredit) {
//         weeks[week] += tx.amount;
//       }
//     }

//     return List.generate(5, (i) {
//       return BarChartGroupData(
//         x: i,
//         barRods: [
//           BarChartRodData(
//             toY: weeks[i],
//           )
//         ],
//       );
//     });
//   }

//   /// PDF DOWNLOAD
//   void _downloadPDF() async {

//     final pdf = pw.Document();

//     pdf.addPage(
//       pw.Page(
//         build: (context) => pw.Center(
//           child: pw.Text("Monthly Report"),
//         ),
//       ),
//     );

//     await Printing.layoutPdf(
//       onLayout: (format) async => pdf.save(),
//     );
//   }

//   /// SHARE REPORT
//   void _shareReport() {
//     Share.share("Check my monthly BudgetBee report!");
//   }

//   /// MONTH NAME
//   String _monthName(int month) {
//     const months = [
//       "",
//       "January",
//       "February",
//       "March",
//       "April",
//       "May",
//       "June",
//       "July",
//       "August",
//       "September",
//       "October",
//       "November",
//       "December"
//     ];
//     return months[month];
//   }
// }






import 'dart:io';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:pdf/widgets.dart' as pw;
import '../globals.dart';
import 'package:permission_handler/permission_handler.dart';

class MonthlyReportScreen extends StatefulWidget {
  const MonthlyReportScreen({super.key});

  @override
  State<MonthlyReportScreen> createState() => _MonthlyReportScreenState();
}

class _MonthlyReportScreenState extends State<MonthlyReportScreen> {

  bool compareMode = false;

  late List<double> weeklyExpenses;

  @override
  void initState() {
    super.initState();
    weeklyExpenses = _calculateWeekly();
  }

  @override
  Widget build(BuildContext context) {

    double saving = totalCredit - totalDebit;

    return Scaffold(

      body: Stack(
        children: [

          /// BACKGROUND IMAGE
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/images/bd_whatapp"),
                fit: BoxFit.cover,
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [

                /// HEADER
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  color: const Color(0xff247155),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      const Text(
                        "Monthly Report",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold),
                      ),

                      const SizedBox(height: 4),

                      Text(
                        _currentMonth(),
                        style: const TextStyle(color: Colors.white70),
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [

                        /// BUTTONS
                        Row(
                          children: [

                            Expanded(
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: compareMode
                                      ? Colors.grey
                                      : const Color(0xff4CAF50),
                                ),
                                onPressed: () {
                                  setState(() {
                                    compareMode = false;
                                  });
                                },
                                child: const Text("This Month"),
                              ),
                            ),

                            const SizedBox(width: 10),

                            Expanded(
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: compareMode
                                      ? const Color(0xff4CAF50)
                                      : Colors.grey,
                                ),
                                onPressed: () {
                                  setState(() {
                                    compareMode = true;
                                  });
                                },
                                child: const Text("Compare 5 Months"),
                              ),
                            )
                          ],
                        ),

                        const SizedBox(height: 16),

                        /// INCOME EXPENSE SAVING
                        Row(
                          children: [

                            Expanded(
                                child: _infoBox(
                                    "Total Income",
                                    totalCredit,
                                    Colors.blue.shade100)),

                            const SizedBox(width: 10),

                            Expanded(
                                child: _infoBox(
                                    "Total Expense",
                                    totalDebit,
                                    Colors.red.shade100)),

                            const SizedBox(width: 10),

                            Expanded(
                                child: _infoBox(
                                    "Total Saving",
                                    saving,
                                    Colors.green.shade100)),
                          ],
                        ),

                        const SizedBox(height: 18),

                        /// SUMMARY
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(.9),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [

                              const Text(
                                "Summary",
                                style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold),
                              ),

                              const SizedBox(height: 6),

                              Text("Net Change : ₹${totalCredit-totalDebit}"),
                              const Text("Opening Balance : ₹0"),
                              const Text("Closing Balance : ₹0"),
                            ],
                          ),
                        ),

                        const SizedBox(height: 18),

                        /// TRANSACTIONS
                        const Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "Top Transactions",
                            style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold),
                          ),
                        ),

                        const SizedBox(height: 10),

                        ..._topTransactions(),

                        const SizedBox(height: 18),

                        /// SPENDING TREND
                        const Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "Spending Trend",
                            style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold),
                          ),
                        ),

                        const SizedBox(height: 10),

                        SizedBox(
                          height: 200,
                          child: BarChart(
                            BarChartData(
                              titlesData: FlTitlesData(

                                leftTitles: const AxisTitles(
                                    sideTitles: SideTitles(showTitles: false)),

                                rightTitles: const AxisTitles(
                                    sideTitles: SideTitles(showTitles: false)),

                                topTitles: const AxisTitles(
                                    sideTitles: SideTitles(showTitles: false)),

                                bottomTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    getTitlesWidget: (value, meta) {

                                      switch (value.toInt()) {
                                        case 0:
                                          return const Text("Week1");
                                        case 1:
                                          return const Text("Week2");
                                        case 2:
                                          return const Text("Week3");
                                        case 3:
                                          return const Text("Week4");
                                      }
                                      return const Text("");
                                    },
                                  ),
                                ),
                              ),

                              borderData: FlBorderData(show: false),

                              barGroups: List.generate(
                                weeklyExpenses.length,
                                (i) => BarChartGroupData(
                                  x: i,
                                  barRods: [
                                    BarChartRodData(
                                      toY: weeklyExpenses[i],
                                      width: 18,
                                      borderRadius: BorderRadius.circular(6),
                                    )
                                  ],
                                  showingTooltipIndicators: [0],
                                ),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        /// BUTTONS
                        Row(
                          children: [

                            Expanded(
                              child: ElevatedButton.icon(
                                icon: const Icon(Icons.download),
                                label: const Text("Download"),
                                onPressed: _downloadPdf,
                              ),
                            ),

                            const SizedBox(width: 10),

                            Expanded(
                              child: ElevatedButton.icon(
                                icon: const Icon(Icons.share),
                                label: const Text("Share Report"),
                                onPressed: _sharePdf,
                              ),
                            )
                          ],
                        )
                      ],
                    ),
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _infoBox(String title, double amount, Color color) {

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Text(title),
          const SizedBox(height: 4),
          Text(
            "₹${amount.toInt()}",
            style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  List<Widget> _topTransactions() {

    final sorted = [...allTransactions];

    sorted.sort((a,b)=>b.amount.compareTo(a.amount));

    return sorted.take(3).map((tx){

      return Card(
        child: ExpansionTile(
          leading: const Icon(Icons.arrow_upward,color: Colors.red),
          title: Text("₹${tx.amount.toInt()}"),
          children: [
            Padding(
              padding: const EdgeInsets.all(10),
              child: Text(tx.description),
            )
          ],
        ),
      );

    }).toList();
  }

  List<double> _calculateWeekly(){

    List<double> weeks=[0,0,0,0];

    for(final tx in allTransactions){

      if(!tx.isCredit){

        int week=((tx.date.day-1)/7).floor();

        if(week<4){
          weeks[week]+=tx.amount;
        }
      }
    }

    return weeks;
  }

  Future<File> _generatePdf() async {

    final pdf=pw.Document();

    pdf.addPage(
      pw.Page(
        build:(context){

          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children:[

              pw.Text("BudgetBee Monthly Report",
                  style: pw.TextStyle(fontSize:22)),

              pw.SizedBox(height:20),

              pw.Text("Total Income : ₹$totalCredit"),
              pw.Text("Total Expense : ₹$totalDebit"),
              pw.Text("Saving : ₹${totalCredit-totalDebit}"),
            ],
          );
        },
      ),
    );

    final dir=await getApplicationDocumentsDirectory();

    final file=File("${dir.path}/monthly_report.pdf");

    await file.writeAsBytes(await pdf.save());

    return file;
  }

  // Future<void> _downloadPdf() async {

  //   final file=await _generatePdf();

  //   ScaffoldMessenger.of(context).showSnackBar(
  //     SnackBar(content: Text("PDF saved at ${file.path}")),
  //   );
  // }

  Future<void> _downloadPdf() async {

  final pdf = pw.Document();

  pdf.addPage(
    pw.Page(
      build: (context) => pw.Column(
        children: [
          pw.Text("BudgetBee Monthly Report", style: pw.TextStyle(fontSize: 22)),
          pw.SizedBox(height: 20),
          pw.Text("Total Income : ₹$totalCredit"),
          pw.Text("Total Expense : ₹$totalDebit"),
          pw.Text("Saving : ₹${totalCredit - totalDebit}"),
        ],
      ),
    ),
  );

  final status = await Permission.storage.request();

  if (!status.isGranted) return;

  final directory = Directory('/storage/emulated/0/Download');

  final file = File('${directory.path}/BudgetBee_Report.pdf');

  await file.writeAsBytes(await pdf.save());

  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text("PDF saved in Downloads folder")),
  );
}

  // Future<void> _sharePdf() async {

  //   final file=await _generatePdf();

  //   await Share.shareXFiles(
  //     [XFile(file.path)],
  //     text: "My BudgetBee Monthly Report",
  //   );
  // }

  Future<void> _sharePdf() async {

    final directory = Directory('/storage/emulated/0/Download');
    final file = File('${directory.path}/BudgetBee_Report.pdf');

    await Share.shareXFiles(
      [XFile(file.path)],
      text: "My BudgetBee Monthly Report",
    );
  }
  String _currentMonth(){

    final now=DateTime.now();

    const months=[
      "",
      "January","February","March","April","May","June",
      "July","August","September","October","November","December"
    ];

    return "${months[now.month]} ${now.year}";
  }
}