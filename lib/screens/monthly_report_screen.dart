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





// Download option with file saving and sharing
// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:fl_chart/fl_chart.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:share_plus/share_plus.dart';
// import 'package:pdf/widgets.dart' as pw;
// import '../globals.dart';
// import 'package:pdf/pdf.dart';
// import 'package:permission_handler/permission_handler.dart';

// class MonthlyReportScreen extends StatefulWidget {
//   const MonthlyReportScreen({super.key});

//   @override
//   State<MonthlyReportScreen> createState() => _MonthlyReportScreenState();
// }

// class _MonthlyReportScreenState extends State<MonthlyReportScreen> {

//   bool compareMode = false;

//   // late List<double> weeklyExpenses;
//   late List<double> chartData;

//   @override
//   void initState() {
//     super.initState();
//     chartData = _calculateWeekly();
//   }

//   @override
//   Widget build(BuildContext context) {

//     double income;
// double expense;
// double saving;

// if (compareMode) {
//   final data = _calculate3MonthTotals();
//   income = data["income"]!;
//   expense = data["expense"]!;
//   saving = data["saving"]!;
// } else {
//   income = totalCredit;
//   expense = totalDebit;
//   saving = totalCredit - totalDebit;
// }

// double opening = 0;
// double closing = opening + saving;

//     return Scaffold(

//       body: Stack(
//         children: [

//           /// BACKGROUND IMAGE
//           Container(
//             decoration: const BoxDecoration(
//               image: DecorationImage(
//                 image: AssetImage("assets/images/bd_whatsapp.jpeg"),
//                 fit: BoxFit.cover,
//               ),
//             ),
//           ),

//           SafeArea(
//             child: Column(
//               children: [

//                 /// HEADER
//                 Container(
//                   width: double.infinity,
//                   padding: const EdgeInsets.all(18),
//                   color: const Color(0xff247155),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [

//                       const Text(
//                         "Monthly Report",
//                         style: TextStyle(
//                             color: Colors.white,
//                             fontSize: 22,
//                             fontWeight: FontWeight.bold),
//                       ),

//                       const SizedBox(height: 4),

//                       Text(
//                         _currentMonth(),
//                         style: const TextStyle(color: Colors.white70),
//                       ),
//                     ],
//                   ),
//                 ),

//                 Expanded(
//                   child: SingleChildScrollView(
//                     padding: const EdgeInsets.all(16),
//                     child: Column(
//                       children: [

//                         /// BUTTONS
//                         Row(
//                           children: [

//                             Expanded(
//                               child: ElevatedButton(
//                                 style: ElevatedButton.styleFrom(
//                                   backgroundColor: compareMode
//                                       ? Colors.grey
//                                       : const Color(0xff4CAF50),
//                                 ),
//                                 onPressed: () {
//                                   setState(() {
//                                     compareMode = false;
//                                     chartData = _calculateWeekly(); // 🔥 important
//                                   });
//                                 },
//                                 child: const Text("This Month"),
//                               ),
//                             ),

//                             const SizedBox(width: 10),

//                             Expanded(
//                               child: ElevatedButton(
//                                 style: ElevatedButton.styleFrom(
//                                   backgroundColor: compareMode
//                                       ? const Color(0xff4CAF50)
//                                       : Colors.grey,
//                                 ),
//                                 onPressed: () {
//   setState(() {
//     compareMode = true;
//     chartData = _calculateLast3Months(); // 🔥 important
//   });
// },
//                                 child: const Text("Compare 3 Months"),
//                               ),
//                             )
//                           ],
//                         ),

//                         const SizedBox(height: 16),

//                         /// INCOME EXPENSE SAVING
//                         Row(
//                           children: [

//                             Expanded(
//                                 child: _infoBox(
//                                     "Total Income",
//                                     income,
//                                     Colors.blue.shade100)),

//                             const SizedBox(width: 10),

//                             Expanded(
//                                 child: _infoBox(
//                                     "Total Expense",
//                                     expense,
//                                     Colors.red.shade100)),

//                             const SizedBox(width: 10),

//                             Expanded(
//                                 child: _infoBox(
//                                     "Total Saving",
//                                     saving,
//                                     Colors.green.shade100)),
//                           ],
//                         ),

//                         const SizedBox(height: 18),

//                         /// SUMMARY
//                         Container(
//                           width: double.infinity,
//                           padding: const EdgeInsets.all(14),
//                           decoration: BoxDecoration(
//                             color: Colors.white.withOpacity(.9),
//                             borderRadius: BorderRadius.circular(10),
//                           ),
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [

//                               const Text(
//                                 "Summary",
//                                 style: TextStyle(
//                                     fontSize: 16,
//                                     fontWeight: FontWeight.bold),
//                               ),

//                               const SizedBox(height: 6),

// Text("Net Change : ₹${saving.toStringAsFixed(2)}"),
// Text("Opening Balance : ₹${opening.toStringAsFixed(2)}"),
// Text("Closing Balance : ₹${closing.toStringAsFixed(2)}"),
//                             ],
//                           ),
//                         ),

//                         const SizedBox(height: 18),

//                         /// TRANSACTIONS
//                         const Align(
//                           alignment: Alignment.centerLeft,
//                           child: Text(
//                             "Recent Transactions",
//                             style: TextStyle(
//                                 fontSize: 17,
//                                 fontWeight: FontWeight.bold),
//                           ),
//                         ),

//                         const SizedBox(height: 10),

//                         ..._topTransactions(),

//                         const SizedBox(height: 18),

//                         /// SPENDING TREND
//                         const Align(
//                           alignment: Alignment.centerLeft,
//                           child: Text(
//                             "Spending Trend",
//                             style: TextStyle(
//                                 fontSize: 17,
//                                 fontWeight: FontWeight.bold),
//                           ),
//                         ),

//                         const SizedBox(height: 10),

//                         SizedBox(
//                           height: 200,
//                           child: BarChart(
//                             BarChartData(
//                               titlesData: FlTitlesData(

//                                 leftTitles: const AxisTitles(
//                                     sideTitles: SideTitles(showTitles: false)),

//                                 rightTitles: const AxisTitles(
//                                     sideTitles: SideTitles(showTitles: false)),

//                                 topTitles: const AxisTitles(
//                                     sideTitles: SideTitles(showTitles: false)),

//                                 bottomTitles: AxisTitles(
//                                   sideTitles: SideTitles(
//                                     showTitles: true,
//                                     getTitlesWidget: (value, meta) {

//   if(compareMode){
//     return Text("M${value.toInt()+1}");
//   }else{
//     return Text("Week${value.toInt()+1}");
//   }

// },
//                                   ),
//                                 ),
//                               ),

//                               /// 🔥 YAHAN ADD KARNA HAI
//     gridData: FlGridData(
//       show: true,
//       drawVerticalLine: false,
//     ),


//                               borderData: FlBorderData(show: false),

//                               barGroups: List.generate(
//                                 chartData.length,
//                                 (i) => BarChartGroupData(
//                                   x: i,
//                                   barRods: [
//                                     BarChartRodData(
//   toY: chartData[i],
//   width: 16,
//   borderRadius: BorderRadius.circular(8),
//   gradient: const LinearGradient(
//     colors: [
//       Color(0xff4CAF50),
//       Color(0xff81C784),
//     ],
//     begin: Alignment.bottomCenter,
//     end: Alignment.topCenter,
//   ),
// ),
//                                   ],
//                                   showingTooltipIndicators: [0],
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ),

//                         const SizedBox(height: 20),

//                         /// BUTTONS
//                         Row(
//                           children: [

//                             Expanded(
//                               child: ElevatedButton.icon(
//                                 icon: const Icon(Icons.download),
//                                 label: const Text("Download"),
//                                 onPressed: () async {
//   await _downloadPdf();
// },
//                               ),
//                             ),

//                             const SizedBox(width: 10),

//                             Expanded(
//                               child: ElevatedButton.icon(
//                                 icon: const Icon(Icons.share),
//                                 label: const Text("Share Report"),
//                                 onPressed: () async {
//   await _sharePdf();
// },
//                               ),
//                             )
//                           ],
//                         )
//                       ],
//                     ),
//                   ),
//                 )
//               ],
//             ),
//           )
//         ],
//       ),
//     );
//   }

// 🔥 ONLY CHANGE: Download button removed + Share centered

// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:fl_chart/fl_chart.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:share_plus/share_plus.dart';
// import 'package:pdf/widgets.dart' as pw;
// import '../globals.dart';
// import 'package:pdf/pdf.dart';
// import 'package:permission_handler/permission_handler.dart';

// class MonthlyReportScreen extends StatefulWidget {
//   const MonthlyReportScreen({super.key});

//   @override
//   State<MonthlyReportScreen> createState() => _MonthlyReportScreenState();
// }

// class _MonthlyReportScreenState extends State<MonthlyReportScreen> {

//   bool compareMode = false;
//   late List<double> chartData;

//   @override
//   void initState() {
//     super.initState();
//     chartData = _calculateWeekly();
//   }

//   @override
// Widget build(BuildContext context) {

//   double income;
//   double expense;
//   double saving;

//   if (compareMode) {
//     final data = _calculate3MonthTotals();
//     income = data["income"]!;
//     expense = data["expense"]!;
//     saving = data["saving"]!;
//   } else {
//     income = totalCredit;
//     expense = totalDebit;
//     saving = totalCredit - totalDebit;
//   }

//   double opening = 0;
//   double closing = opening + saving;

//   double percentUsed = expense == 0 ? 0 : (expense / income) * 100;

//   return Scaffold(
//     body: Stack(
//       children: [

//         /// BACKGROUND
//         Container(
//           decoration: const BoxDecoration(
//             image: DecorationImage(
//               image: AssetImage("assets/images/bd_whatsapp.jpeg"),
//               fit: BoxFit.cover,
//             ),
//           ),
//         ),

//         SafeArea(
//           child: Column(
//             children: [

//               /// 🔥 HEADER
//               Container(
//                 padding: const EdgeInsets.all(16),
//                 color: const Color(0xff2E7D5B),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Row(
//                       children: [
//                         IconButton(
//                           icon: const Icon(Icons.arrow_back, color: Colors.white),
//                           onPressed: () => Navigator.pop(context),
//                         ),
//                         const Text(
//                           "Monthly Report",
//                           style: TextStyle(
//                               color: Colors.white,
//                               fontSize: 20,
//                               fontWeight: FontWeight.bold),
//                         ),
//                       ],
//                     ),
//                     const SizedBox(height: 4),
//                     Text(
//                       "Generated on ${DateTime.now().day} ${_currentMonth()}",
//                       style: const TextStyle(color: Colors.white70),
//                     ),
//                   ],
//                 ),
//               ),

//               Expanded(
//                 child: SingleChildScrollView(
//                   padding: const EdgeInsets.all(16),
//                   child: Column(
//                     children: [

//                       /// 🔥 TOGGLE BUTTONS
//                       Container(
//                         decoration: BoxDecoration(
//                           color: Colors.white,
//                           borderRadius: BorderRadius.circular(30),
//                         ),
//                         child: Row(
//                           children: [

//                             Expanded(
//                               child: GestureDetector(
//                                 onTap: () {
//                                   setState(() {
//                                     compareMode = false;
//                                     chartData = _calculateWeekly();
//                                   });
//                                 },
//                                 child: Container(
//                                   padding: const EdgeInsets.all(12),
//                                   decoration: BoxDecoration(
//                                     color: compareMode ? Colors.transparent : Colors.green,
//                                     borderRadius: BorderRadius.circular(30),
//                                   ),
//                                   child: Center(
//                                     child: Text(
//                                       "This Month",
//                                       style: TextStyle(
//                                         color: compareMode ? Colors.black : Colors.white,
//                                         fontWeight: FontWeight.bold,
//                                       ),
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                             ),

//                             Expanded(
//                               child: GestureDetector(
//                                 onTap: () {
//                                   setState(() {
//                                     compareMode = true;
//                                     chartData = _calculateLast3Months();
//                                   });
//                                 },
//                                 child: Container(
//                                   padding: const EdgeInsets.all(12),
//                                   decoration: BoxDecoration(
//                                     color: compareMode ? Colors.green : Colors.transparent,
//                                     borderRadius: BorderRadius.circular(30),
//                                   ),
//                                   child: Center(
//                                     child: Text(
//                                       "Compare 3 Months",
//                                       style: TextStyle(
//                                         color: compareMode ? Colors.white : Colors.black,
//                                         fontWeight: FontWeight.bold,
//                                       ),
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),

//                       const SizedBox(height: 16),

//                       /// 🔥 CARDS
//                       Row(
//                         children: [
//                           Expanded(child: _modernCard("Total Income", income, Colors.blue)),
//                           const SizedBox(width: 8),
//                           Expanded(child: _modernCard("Total Expense", expense, Colors.red)),
//                           const SizedBox(width: 8),
//                           Expanded(child: _modernCard("Total Saving", saving, Colors.green)),
//                         ],
//                       ),

//                       const SizedBox(height: 16),

//                       /// SUMMARY
//                       _sectionCard(
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             const Text("Summary", style: TextStyle(fontWeight: FontWeight.bold)),
//                             const SizedBox(height: 6),
//                             Text("Net Change: ₹${saving.toInt()}"),
//                             Text("Opening Balance: ₹${opening.toInt()}"),
//                             Text("Closing Balance: ₹${closing.toInt()}"),
//                           ],
//                         ),
//                       ),

//                       const SizedBox(height: 16),

//                       /// TRANSACTIONS
//                       _sectionCard(
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             const Text("Recent Transactions", style: TextStyle(fontWeight: FontWeight.bold)),
//                             const SizedBox(height: 10),
//                             ..._topTransactions(),
//                           ],
//                         ),
//                       ),

//                       const SizedBox(height: 16),

//                       /// CHART
//                       _sectionCard(
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text(
//   compareMode ? "3 Months Comparison" : "Weekly Spending",
//   style: const TextStyle(fontWeight: FontWeight.bold),
// ),
//                             const SizedBox(height: 10),
//                             SizedBox(height: 200, child: _buildChart()),
//                           ],
//                         ),
//                       ),

//                       const SizedBox(height: 16),

//                       /// 🔥 WARNING BOX
//                       /// 🔥 DYNAMIC WARNING BOX

// Container(
//   padding: const EdgeInsets.all(12),
//   decoration: BoxDecoration(
//     color: percentUsed > 80
//         ? Colors.red.shade100
//         : percentUsed > 50
//             ? Colors.orange.shade100
//             : Colors.green.shade100,
//     borderRadius: BorderRadius.circular(10),
//   ),
//   child: Text(
//     percentUsed > 80
//         ? "⚠️ Warning: You used ${percentUsed.toStringAsFixed(0)}% of your monthly budget!"
//         : percentUsed > 50
//             ? "⚡ You used ${percentUsed.toStringAsFixed(0)}% of your budget"
//             : "✅ Good! Only ${percentUsed.toStringAsFixed(0)}% used",
//     style: TextStyle(
//       color: percentUsed > 80 ? Colors.red : Colors.black,
//       fontWeight: FontWeight.bold,
//     ),
//   ),
// ),

//                       const SizedBox(height: 20),

//                       /// 🔥 SHARE BUTTON
//                       ElevatedButton.icon(
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: Colors.blue,
//                           padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
//                           shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(30)),
//                         ),
//                         icon: const Icon(Icons.share),
//                         label: const Text("Share Report"),
//                         onPressed: () async {
//                           await _sharePdf();
//                         },
//                       )
//                     ],
//                   ),
//                 ),
//               )
//             ],
//           ),
//         )
//       ],
//     ),
//   );
// }

//   // 🔥 बाकी पूरा code SAME है (unchanged)

//   Widget _infoBox(String title, double amount, Color color) {

//     return Container(
//       padding: const EdgeInsets.symmetric(vertical: 14),
//       decoration: BoxDecoration(
//         color: color,
//         borderRadius: BorderRadius.circular(10),
//       ),
//       child: Column(
//         children: [
//           Text(title),
//           const SizedBox(height: 4),
//           Text(
//             "₹${amount.toInt()}",
//             style: const TextStyle(
//                 fontSize: 18,
//                 fontWeight: FontWeight.bold),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _modernCard(String title, double amount, Color color) {
//   return Container(
//     padding: const EdgeInsets.all(12),
//     decoration: BoxDecoration(
//       color: color.withOpacity(0.2),
//       borderRadius: BorderRadius.circular(12),
//     ),
//     child: Column(
//       children: [
//         Text(title),
//         const SizedBox(height: 6),
//         Text("₹${amount.toInt()}",
//             style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
//       ],
//     ),
//   );
// }

// Widget _sectionCard({required Widget child}) {
//   return Container(
//     width: double.infinity,
//     padding: const EdgeInsets.all(12),
//     decoration: BoxDecoration(
//       color: Colors.white.withOpacity(.95),
//       borderRadius: BorderRadius.circular(12),
//     ),
//     child: child,
//   );
// }

// Widget _buildChart() {
//   return BarChart(
//     BarChartData(
//       borderData: FlBorderData(show: false),

//       /// 🔥 LABELS ADD KIYE
//       titlesData: FlTitlesData(
//         leftTitles: const AxisTitles(
//             sideTitles: SideTitles(showTitles: false)),
//         rightTitles: const AxisTitles(
//             sideTitles: SideTitles(showTitles: false)),
//         topTitles: const AxisTitles(
//             sideTitles: SideTitles(showTitles: false)),

//         bottomTitles: AxisTitles(
//           sideTitles: SideTitles(
//             showTitles: true,
//             getTitlesWidget: (value, meta) {

//               if (compareMode) {
//                 return Text("M${value.toInt() + 1}",
//                     style: const TextStyle(fontSize: 10));
//               } else {
//                 return Text("W${value.toInt() + 1}",
//                     style: const TextStyle(fontSize: 10));
//               }

//             },
//           ),
//         ),
//       ),

//       barGroups: List.generate(
//         chartData.length,
//         (i) => BarChartGroupData(
//           x: i,
//           barRods: [
//             BarChartRodData(
//               toY: chartData[i],
//               width: 14,
//               borderRadius: BorderRadius.circular(6),
//               color: compareMode ? Colors.blue : Colors.green,
//             ),
//           ],
//         ),
//       ),
//     ),
//   );
// }

//   List<Widget> _topTransactions() {

//     final sorted = [...allTransactions];

//     sorted.sort((a,b)=>b.amount.compareTo(a.amount));

//     return sorted.take(3).map((tx){

//       return Card(
//         child: ExpansionTile(
//           leading: const Icon(Icons.arrow_upward,color: Colors.red),
//           title: Text("₹${tx.amount.toInt()}"),
//           children: [
//             Padding(
//               padding: const EdgeInsets.all(10),
//               child: Text(tx.description),
//             )
//           ],
//         ),
//       );

//     }).toList();
//   }

//   List<double> _calculateWeekly(){

//     List<double> weeks=[0,0,0,0];

//     for(final tx in allTransactions){

//       if(!tx.isCredit){

//         int week=((tx.date.day-1)/7).floor();

//         if(week<4){
//           weeks[week]+=tx.amount;
//         }
//       }
//     }

//     return weeks;
//   }

//   List<double> _calculateLast3Months() {
//   Map<int, double> monthly = {};

//   final now = DateTime.now();

//   for (int i = 0; i < 3; i++) {
//     int month = now.month - i;
//     monthly[month] = 0;
//   }

//   for (var tx in allTransactions) {
//     if (!tx.isCredit) {
//       int m = tx.date.month;

//       if (monthly.containsKey(m)) {
//         monthly[m] = monthly[m]! + tx.amount;
//       }
//     }
//   }

//   return monthly.values.toList().reversed.toList();
// }

// Map<String, double> _calculate3MonthTotals() {

//   double income = 0;
//   double expense = 0;

//   final now = DateTime.now();

//   for (var tx in allTransactions) {

//     if (tx.date.isAfter(DateTime(now.year, now.month - 3, now.day))) {

//       if (tx.isCredit) {
//         income += tx.amount;
//       } else {
//         expense += tx.amount;
//       }
//     }
//   }

//   return {
//     "income": income,
//     "expense": expense,
//     "saving": income - expense,
//   };
// }

//   Future<File> _generatePdf() async {
//   final pdf = pw.Document();

//   final data = compareMode
//       ? _calculate3MonthTotals()
//       : {
//           "income": totalCredit,
//           "expense": totalDebit,
//           "saving": totalCredit - totalDebit
//         };

//   pdf.addPage(
//     pw.MultiPage(
//       build: (context) => [
//         pw.Text("BudgetBee Monthly Report",
//             style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),

//         pw.SizedBox(height: 20),

//         pw.Text("Income: ₹${data["income"]}"),
//         pw.Text("Expense: ₹${data["expense"]}"),
//         pw.Text("Saving: ₹${data["saving"]}"),

//         pw.SizedBox(height: 20),

//         pw.Text("Spending Trend"),

//         pw.Row(
//           mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
//           children: chartData.map((e) {
//             return pw.Container(
//               width: 20,
//               height: (e / 5).clamp(10, 100),
//               color: PdfColor(0, 0.7, 0),
//             );
//           }).toList(),
//         ),
//       ],
//     ),
//   );

//   /// 🔥 REAL DOWNLOAD PATH
//   final directory = Directory("/storage/emulated/0/Download");

//   if (!await directory.exists()) {
//     await directory.create(recursive: true);
//   }

//   final file = File(
//       "${directory.path}/BudgetBee_${DateTime.now().millisecondsSinceEpoch}.pdf");

//   await file.writeAsBytes(await pdf.save());

//   return file;
// }

//   // Future<void> _downloadPdf() async {

//   //   final file=await _generatePdf();

//   //   ScaffoldMessenger.of(context).showSnackBar(
//   //     SnackBar(content: Text("PDF saved at ${file.path}")),
//   //   );
//   // }

//   Future<void> _downloadPdf() async {
//   try {
//     var status = await Permission.storage.request();

//     if (!status.isGranted) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text("Permission denied")),
//       );
//       return;
//     }

//     final file = await _generatePdf();

//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text("Saved in Downloads ✅"),
//         action: SnackBarAction(
//           label: "OPEN",
//           onPressed: () async {
//             await Share.shareXFiles([XFile(file.path)]);
//           },
//         ),
//       ),
//     );
//   } catch (e) {
//     print("ERROR: $e");

//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(content: Text("Crash happened ❌")),
//     );
//   }
// }

//   // Future<void> _sharePdf() async {

//   //   final file=await _generatePdf();

//   //   await Share.shareXFiles(
//   //     [XFile(file.path)],
//   //     text: "My BudgetBee Monthly Report",
//   //   );
//   // }

//   Future<void> _sharePdf() async {
//   try {
//     final file = await _generatePdf();

//     print("PDF PATH: ${file.path}"); // 🔥 debug

//     await Share.shareXFiles(
//       [XFile(file.path)],
//       text: "My BudgetBee Monthly Report",
//     );

//   } catch (e) {
//     print("ERROR: $e");

//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(content: Text("Error sharing PDF")),
//     );
//   }
// }

//   String _currentMonth(){

//     final now=DateTime.now();

//     const months=[
//       "",
//       "January","February","March","April","May","June",
//       "July","August","September","October","November","December"
//     ];

//     return "${months[now.month]} ${now.year}";
//   }
// }

// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:fl_chart/fl_chart.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:share_plus/share_plus.dart';
// import 'package:pdf/widgets.dart' as pw;
// import '../globals.dart';
// import 'package:pdf/pdf.dart';
// import 'package:permission_handler/permission_handler.dart';

// class MonthlyData {
//   final DateTime date;
//   final String label;
//   final double income;
//   final double expense;
//   MonthlyData(this.date, this.label, this.income, this.expense);
//   double get saving => income - expense;
//   int get healthScore {
//     if (income == 0) return expense == 0 ? 100 : 0;
//     double per = (expense / income) * 100;
//     int score = (100 - per).round();
//     return score.clamp(0, 100);
//   }
// }

// class MonthlyReportScreen extends StatefulWidget {
//   const MonthlyReportScreen({super.key});

//   @override
//   State<MonthlyReportScreen> createState() => _MonthlyReportScreenState();
// }

// class _MonthlyReportScreenState extends State<MonthlyReportScreen> {
//   bool compareMode = false;

//   @override
//   Widget build(BuildContext context) {
//     // Current month calculations
//     double tmIncome = totalCredit;
//     double tmExpense = totalDebit;
//     double tmSaving = totalCredit - totalDebit;

//     // 3 Months Calculations
//     final now = DateTime.now();
//     List<MonthlyData> mDataList = [];
    
//     for (int i = 2; i >= 0; i--) {
//       int targetMonth = now.month - i;
//       int targetYear = now.year;
//       if (targetMonth <= 0) {
//         targetMonth += 12;
//         targetYear -= 1;
//       }
      
//       double mIncome = 0;
//       double mExpense = 0;

//       for (var tx in allTransactions) {
//         if (tx.date.year == targetYear && tx.date.month == targetMonth) {
//           if (tx.isCredit) {
//             mIncome += tx.amount;
//           } else {
//             mExpense += tx.amount;
//           }
//         }
//       }

//       final months = ["", "Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];
//       String label = "${months[targetMonth]}";
      
//       mDataList.add(MonthlyData(DateTime(targetYear, targetMonth, 1), label, mIncome, mExpense));
//     }

//     double compIncome = mDataList.fold(0, (sum, item) => sum + item.income);
//     double compExpense = mDataList.fold(0, (sum, item) => sum + item.expense);
//     double compSaving = compIncome - compExpense;

//     double activeIncome = compareMode ? compIncome : tmIncome;
//     double activeExpense = compareMode ? compExpense : tmExpense;
//     double activeSaving = compareMode ? compSaving : tmSaving;

//     return Scaffold(
//       backgroundColor: const Color(0xFFF4F8FB),
//       appBar: AppBar(
//         iconTheme: const IconThemeData(color: Colors.white),
//         backgroundColor: const Color(0xFF1E6F5C),
//         elevation: 0,
//         title: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const Text(
//               "Monthly Report",
//               style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
//             ),
//             const SizedBox(height: 2),
//             Text(
//               "Generated on ${now.day} ${_currentMonth(now.month, now.year)}",
//               style: const TextStyle(color: Colors.white70, fontSize: 13),
//             ),
//           ],
//         ),
//         actions: [
//           Center(
//             child: Padding(
//               padding: const EdgeInsets.only(right: 16.0),
//               child: Text(
//                 _currentMonth(now.month, now.year),
//                 style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 16),
//               ),
//             ),
//           )
//         ],
//       ),
//       body: Stack(
//         children: [
//           Container(
//             decoration: const BoxDecoration(
//               image: DecorationImage(
//                 image: AssetImage("assets/images/bd_whatsapp.jpeg"),
//                 fit: BoxFit.cover,
//                 opacity: 0.6,
//               ),
//             ),
//           ),
//           SafeArea(
//             child: SingleChildScrollView(
//               padding: const EdgeInsets.all(16),
//               child: Column(
//                 children: [
                  
//                   // TOGGLE BUTTONS
//                   Container(
//                     decoration: BoxDecoration(
//                       color: Colors.white,
//                       borderRadius: BorderRadius.circular(30),
//                       border: Border.all(color: Colors.grey.withOpacity(0.3)),
//                     ),
//                     child: Row(
//                       children: [
//                         Expanded(
//                           child: GestureDetector(
//                             onTap: () => setState(() => compareMode = false),
//                             child: Container(
//                               padding: const EdgeInsets.symmetric(vertical: 14),
//                               decoration: BoxDecoration(
//                                 color: compareMode ? Colors.transparent : const Color(0xFF1E6F5C),
//                                 borderRadius: BorderRadius.circular(30),
//                               ),
//                               child: Center(
//                                 child: Text(
//                                   "This Month",
//                                   style: TextStyle(
//                                     fontSize: 15,
//                                     color: compareMode ? Colors.black87 : Colors.white,
//                                     fontWeight: FontWeight.bold,
//                                   ),
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ),
//                         Expanded(
//                           child: GestureDetector(
//                             onTap: () => setState(() => compareMode = true),
//                             child: Container(
//                               padding: const EdgeInsets.symmetric(vertical: 14),
//                               decoration: BoxDecoration(
//                                 color: compareMode ? const Color(0xFF1E6F5C) : Colors.transparent,
//                                 borderRadius: BorderRadius.circular(30),
//                               ),
//                               child: Center(
//                                 child: Text(
//                                   "Compare 3 Months",
//                                   style: TextStyle(
//                                     fontSize: 15,
//                                     color: compareMode ? Colors.white : Colors.black87,
//                                     fontWeight: FontWeight.bold,
//                                   ),
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),

//                   const SizedBox(height: 20),

//                   // TOP 3 STATS
//                   Row(
//                     children: [
//                       Expanded(
//                         child: _modernCard("Total Income", activeIncome, const Color(0xFFCBEBFF), const Color(0xFF0033B9)),
//                       ),
//                       const SizedBox(width: 8),
//                       Expanded(
//                         child: _modernCard("Total Expense", activeExpense, const Color(0xFFFFCCCC), const Color(0xFF990000)),
//                       ),
//                       const SizedBox(width: 8),
//                       Expanded(
//                         child: _modernCard("Total Saving", activeSaving, const Color(0xFFCCFFCC), const Color(0xFF006600)),
//                       ),
//                     ],
//                   ),

//                   const SizedBox(height: 20),

//                   if (!compareMode) ...[
//                     // THIS MONTH VIEW
//                     _sectionCard(
//                       title: "Top Transactions",
//                       child: Column(
//                         children: _topTransactionsUI(),
//                       ),
//                     ),
//                     const SizedBox(height: 20),
//                     _sectionCard(
//                       title: "Spending Trend",
//                       child: SizedBox(
//                         height: 220,
//                         child: _buildWeeklyChart(),
//                       ),
//                     ),
//                     const SizedBox(height: 20),
//                     _warningBox(tmExpense, tmIncome),
//                   ] else ...[
//                     // COMPARE 3 MONTHS VIEW
//                     _sectionCard(
//                       title: "Compare 3 Months",
//                       child: SizedBox(
//                         height: 250,
//                         child: _buildGroupedBarChart(mDataList),
//                       ),
//                     ),
//                     const SizedBox(height: 20),
//                     _dataTableCard(mDataList),
//                     const SizedBox(height: 20),
//                     _sectionCard(
//                       title: "Last 3 Months Expense Breakdown",
//                       child: SizedBox(
//                         height: 280,
//                         child: _buildDetailedPieChart(mDataList),
//                       ),
//                     ),
//                   ],

//                   const SizedBox(height: 30),

//                   SizedBox(
//                     width: double.infinity,
//                     child: ElevatedButton.icon(
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: const Color(0xFF007BFF),
//                         padding: const EdgeInsets.symmetric(vertical: 16),
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(8),
//                         ),
//                       ),
//                       icon: const Icon(Icons.share, color: Colors.white),
//                       label: const Text("Share Report", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
//                       onPressed: () async {
//                         await _sharePdf();
//                       },
//                     ),
//                   ),
//                   const SizedBox(height: 30),
//                 ],
//               ),
//             ),
//           )
//         ],
//       ),
//     );
//   }

//   Widget _modernCard(String title, double amount, Color bgColor, Color textColor) {
//     return Container(
//       padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
//       decoration: BoxDecoration(
//         color: bgColor,
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: Colors.grey.withOpacity(0.2)),
//         boxShadow: [
//           BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4),
//         ]
//       ),
//       child: Column(
//         children: [
//           Text(title, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.black87), textAlign: TextAlign.center),
//           const SizedBox(height: 6),
//           Text(
//             "₹${amount.toInt()}",
//             style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: textColor),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _sectionCard({required String title, required Widget child}) {
//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(12),
//         boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4)],
//         border: Border.all(color: Colors.grey.withOpacity(0.2)),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
//           const SizedBox(height: 16),
//           child,
//         ],
//       ),
//     );
//   }

//   // --- THIS MONTH METHODS ---
//   List<Widget> _topTransactionsUI() {
//     final sorted = allTransactions.where((tx) => tx.date.month == DateTime.now().month && tx.date.year == DateTime.now().year).toList();
//     sorted.sort((a,b)=>b.amount.compareTo(a.amount));
    
//     if (sorted.isEmpty) return [const Text("No transactions this month.")];

//     return sorted.take(3).map((tx){
//       return Container(
//         margin: const EdgeInsets.only(bottom: 12),
//         padding: const EdgeInsets.all(12),
//         decoration: BoxDecoration(
//           color: Colors.white,
//           border: Border.all(color: Colors.grey.withOpacity(0.2)),
//           borderRadius: BorderRadius.circular(10),
//         ),
//         child: Row(
//           children: [
//             CircleAvatar(
//               backgroundColor: const Color(0xFFFFE0E0),
//               radius: 18,
//               child: const Icon(Icons.arrow_upward, color: Colors.red, size: 18),
//             ),
//             const SizedBox(width: 12),
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(tx.description.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
//                   const SizedBox(height: 4),
//                   Text("${tx.isCredit ? 'Credit' : 'Debit'} • ${tx.date.day}/${tx.date.month}/${tx.date.year}", style: const TextStyle(fontSize: 11, color: Colors.grey)),
//                 ],
//               ),
//             ),
//             Text(
//               "${tx.isCredit ? '+' : '-'} ₹${tx.amount.toInt()}",
//               style: TextStyle(color: tx.isCredit ? Colors.green : Colors.red, fontWeight: FontWeight.bold),
//             ),
//           ],
//         ),
//       );
//     }).toList();
//   }

//   Widget _warningBox(double expense, double income) {
//     double per = income == 0 ? 0 : (expense / income) * 100;
    
//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: const Color(0xFFFFF4F4),
//         border: Border.all(color: const Color(0xFFFFCCCC)),
//         borderRadius: BorderRadius.circular(8),
//       ),
//       child: RichText(
//         text: TextSpan(
//           style: const TextStyle(color: Colors.black87),
//           children: [
//             const TextSpan(text: "⚠️ Warning: ", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
//             TextSpan(text: "You used ${per.toStringAsFixed(0)}% of your monthly budget! Consider reducing your shopping expenses."),
//           ]
//         ),
//       ),
//     );
//   }

//   Widget _buildWeeklyChart() {
//     List<double> weeks = [0,0,0,0,0];
//     final now = DateTime.now();

//     for(final tx in allTransactions){
//       if(!tx.isCredit && tx.date.month == now.month && tx.date.year == now.year){
//         int week = ((tx.date.day-1)/7).floor();
//         if(week < 5){
//           weeks[week] += tx.amount;
//         }
//       }
//     }

//     double maxVal = weeks.reduce((a, b) => a > b ? a : b);
//     maxVal = maxVal == 0 ? 1000 : maxVal * 1.5;

//     return BarChart(
//       BarChartData(
//         alignment: BarChartAlignment.spaceAround,
//         maxY: maxVal,
//         barTouchData: BarTouchData(enabled: false),
//         titlesData: FlTitlesData(
//           show: true,
//           bottomTitles: AxisTitles(
//             sideTitles: SideTitles(
//               showTitles: true,
//               getTitlesWidget: (value, meta) {
//                 return Text("Week ${value.toInt() + 1}", style: const TextStyle(fontSize: 10));
//               },
//             ),
//           ),
//           leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
//           topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
//           rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
//         ),
//         gridData: const FlGridData(show: false),
//         borderData: FlBorderData(show: false),
//         barGroups: List.generate(
//           5,
//           (i) => BarChartGroupData(
//             x: i,
//             showingTooltipIndicators: [0], // Shows the number on top
//             barRods: [
//               BarChartRodData(
//                 toY: weeks[i],
//                 width: 24,
//                 color: const Color(0xFF4B8BFF),
//                 borderRadius: const BorderRadius.only(topLeft: Radius.circular(4), topRight: Radius.circular(4)),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   // --- COMPARE 3 MONTHS METHODS ---
//   Widget _buildGroupedBarChart(List<MonthlyData> mDataList) {
//     double maxVal = 0;
//     for (var d in mDataList) {
//       if (d.income > maxVal) maxVal = d.income;
//       if (d.expense > maxVal) maxVal = d.expense;
//     }
//     maxVal = maxVal == 0 ? 1000 : maxVal * 1.3;

//     return Column(
//       children: [
//         Row(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Container(width: 10, height: 10, color: const Color(0xFF007BFF)),
//             const SizedBox(width: 4),
//             const Text("Income", style: TextStyle(fontSize: 12)),
//             const SizedBox(width: 16),
//             Container(width: 10, height: 10, color: const Color(0xFFFF4B4B)),
//             const SizedBox(width: 4),
//             const Text("Expense", style: TextStyle(fontSize: 12)),
//           ],
//         ),
//         const SizedBox(height: 16),
//         Expanded(
//           child: BarChart(
//             BarChartData(
//               maxY: maxVal,
//               alignment: BarChartAlignment.spaceAround,
//               titlesData: FlTitlesData(
//                 show: true,
//                 bottomTitles: AxisTitles(
//                   sideTitles: SideTitles(
//                     showTitles: true,
//                     getTitlesWidget: (value, meta) {
//                       return Padding(
//                         padding: const EdgeInsets.only(top: 8.0),
//                         child: Text(mDataList[value.toInt()].label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
//                       );
//                     },
//                   ),
//                 ),
//                 leftTitles: AxisTitles(
//                   sideTitles: SideTitles(
//                     showTitles: true,
//                     reservedSize: 40,
//                     getTitlesWidget: (value, meta) {
//                       if (value == 0) return const Text("0");
//                       if (value % 5000 != 0 && value % 10000 != 0) return const SizedBox.shrink();
//                       return Text("${(value).toInt()}", style: const TextStyle(fontSize: 10));
//                     },
//                   ),
//                 ),
//                 topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
//                 rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
//               ),
//               borderData: FlBorderData(
//                 show: true,
//                 border: const Border(bottom: BorderSide(color: Colors.black12), left: BorderSide(color: Colors.black12)),
//               ),
//               gridData: const FlGridData(show: false),
//               barGroups: List.generate(
//                 mDataList.length,
//                 (i) => BarChartGroupData(
//                   x: i,
//                   barsSpace: 4,
//                   barRods: [
//                     BarChartRodData(
//                       toY: mDataList[i].income,
//                       width: 18,
//                       color: const Color(0xFF007BFF),
//                       borderRadius: BorderRadius.zero,
//                     ),
//                     BarChartRodData(
//                       toY: mDataList[i].expense,
//                       width: 18,
//                       color: const Color(0xFFFF4B4B),
//                       borderRadius: BorderRadius.zero,
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _dataTableCard(List<MonthlyData> mDataList) {
//     return Container(
//       width: double.infinity,
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: Colors.grey.withOpacity(0.2)),
//         boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4)],
//       ),
//       child: ClipRRect(
//         borderRadius: BorderRadius.circular(12),
//         child: DataTable(
//           horizontalMargin: 12,
//           columnSpacing: 10,
//           headingRowColor: MaterialStateProperty.all(Colors.grey.shade100),
//           columns: const [
//             DataColumn(label: Text("Month", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11))),
//             DataColumn(label: Text("Income", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11))),
//             DataColumn(label: Text("Expense", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11))),
//             DataColumn(label: Text("Savings", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11))),
//             DataColumn(label: Text("Health", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11))),
//           ],
//           rows: mDataList.map((m) {
//             return DataRow(
//               cells: [
//                 DataCell(Text("${m.label} ${m.date.year}", style: const TextStyle(fontSize: 11))),
//                 DataCell(Text("₹${m.income.toInt()}", style: const TextStyle(fontSize: 11))),
//                 DataCell(Text("₹${m.expense.toInt()}", style: const TextStyle(fontSize: 11))),
//                 DataCell(Row(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     Text("₹${m.saving.toInt()}", style: const TextStyle(fontSize: 11)),
//                     Icon(m.saving >= 0 ? Icons.arrow_drop_up : Icons.arrow_drop_down, color: m.saving >= 0 ? Colors.green : Colors.red, size: 16),
//                   ],
//                 )),
//                 DataCell(Row(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     Text("${m.healthScore}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
//                     const SizedBox(width: 4),
//                     Text(m.healthScore >= 70 ? "Good" : "Poor", style: TextStyle(color: m.healthScore >= 70 ? Colors.green : Colors.red, fontSize: 10)),
//                   ],
//                 )),
//               ]
//             );
//           }).toList(),
//         ),
//       ),
//     );
//   }

//   Widget _buildDetailedPieChart(List<MonthlyData> mDataList) {
//     // 🔥 Used completely distinct colors so months don't get mixed up visually!
//     final colors = [
//       const Color(0xFF9C27B0), // Purple for Month 1 (e.g. Jan)
//       const Color(0xFFFF9800), // Orange for Month 2 (e.g. Feb)
//       const Color(0xFFE91E63), // Pink for Month 3 (e.g. Mar)
//     ];
    
//     double totalAll = mDataList.fold(0, (s, e) => s + e.expense);
//     if (totalAll == 0) return const Center(child: Text("No expenses to chart."));

//     return Column(
//       children: [
//         Expanded(
//           child: Stack(
//             alignment: Alignment.center,
//             children: [
//               PieChart(
//                 PieChartData(
//                   sectionsSpace: 2,
//                   centerSpaceRadius: 0,
//                   sections: List.generate(mDataList.length, (i) {
//                     final d = mDataList[i];
//                     double per = (d.expense / totalAll) * 100;
//                     return PieChartSectionData(
//                       value: per,
//                       color: colors[i % colors.length],
//                       title: "${per.toStringAsFixed(0)}%",
//                       radius: 90,
//                       titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
//                     );
//                   }),
//                 )
//               ),
//             ],
//           ),
//         ),
//         const SizedBox(height: 16),
//         Row(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: List.generate(mDataList.length, (i) {
//             return Row(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 Container(width: 10, height: 10, decoration: BoxDecoration(color: colors[i % colors.length], shape: BoxShape.circle)),
//                 const SizedBox(width: 4),
//                 Text(mDataList[i].label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
//                 const SizedBox(width: 16),
//               ],
//             );
//           }),
//         ),
//       ],
//     );
//   }

//   // --- UTILS ---
//   Future<File> _generatePdf() async {
//     final pdf = pw.Document();
//     pdf.addPage(
//       pw.Page(
//         build: (context) => pw.Center(child: pw.Text("BudgetBee Monthly Report\nMore detailed PDF under construction.", textAlign: pw.TextAlign.center)),
//       ),
//     );
//     final directory = Directory("/storage/emulated/0/Download");
//     if (!await directory.exists()) await directory.create(recursive: true);
//     final file = File("${directory.path}/BudgetBee_${DateTime.now().millisecondsSinceEpoch}.pdf");
//     await file.writeAsBytes(await pdf.save());
//     return file;
//   }

//   Future<void> _sharePdf() async {
//     try {
//       final file = await _generatePdf();
//       await Share.shareXFiles([XFile(file.path)], text: "My BudgetBee Monthly Report");
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Error sharing PDF")));
//     }
//   }

//   String _currentMonth(int m, int y) {
//     const months=["", "January","February","March","April","May","June","July","August","September","October","November","December"];
//     return "${months[m]} $y";
//   }
// }

// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:fl_chart/fl_chart.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:share_plus/share_plus.dart';
// import 'package:pdf/widgets.dart' as pw;
// import '../globals.dart';
// import 'package:pdf/pdf.dart';
// import 'package:permission_handler/permission_handler.dart';

// class MonthlyData {
//   final DateTime date;
//   final String label;
//   final double income;
//   final double expense;
//   MonthlyData(this.date, this.label, this.income, this.expense);
//   double get saving => income - expense;
//   int get healthScore {
//     if (income == 0) return expense == 0 ? 100 : 0;
//     double per = (expense / income) * 100;
//     int score = (100 - per).round();
//     return score.clamp(0, 100);
//   }
// }

// class MonthlyReportScreen extends StatefulWidget {
//   const MonthlyReportScreen({super.key});

//   @override
//   State<MonthlyReportScreen> createState() => _MonthlyReportScreenState();
// }

// class _MonthlyReportScreenState extends State<MonthlyReportScreen> {
//   bool compareMode = false;

//   @override
//   Widget build(BuildContext context) {
//     // Current month calculations
//     double tmIncome = totalCredit;
//     double tmExpense = totalDebit;
//     double tmSaving = totalCredit - totalDebit;

//     // 3 Months Calculations
//     final now = DateTime.now();
//     List<MonthlyData> mDataList = [];
    
//     for (int i = 2; i >= 0; i--) {
//       int targetMonth = now.month - i;
//       int targetYear = now.year;
//       if (targetMonth <= 0) {
//         targetMonth += 12;
//         targetYear -= 1;
//       }
      
//       double mIncome = 0;
//       double mExpense = 0;

//       for (var tx in allTransactions) {
//         if (tx.date.year == targetYear && tx.date.month == targetMonth) {
//           if (tx.isCredit) {
//             mIncome += tx.amount;
//           } else {
//             mExpense += tx.amount;
//           }
//         }
//       }

//       final months = ["", "Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];
//       String label = "${months[targetMonth]}";
      
//       mDataList.add(MonthlyData(DateTime(targetYear, targetMonth, 1), label, mIncome, mExpense));
//     }

//     double compIncome = mDataList.fold(0, (sum, item) => sum + item.income);
//     double compExpense = mDataList.fold(0, (sum, item) => sum + item.expense);
//     double compSaving = compIncome - compExpense;

//     double activeIncome = compareMode ? compIncome : tmIncome;
//     double activeExpense = compareMode ? compExpense : tmExpense;
//     double activeSaving = compareMode ? compSaving : tmSaving;

//     return Scaffold(
//       backgroundColor: const Color(0xFFF4F8FB),
//       appBar: AppBar(
//         iconTheme: const IconThemeData(color: Colors.white),
//         backgroundColor: const Color(0xFF1E6F5C),
//         elevation: 0,
//         title: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const Text(
//               "Monthly Report",
//               style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
//             ),
//             const SizedBox(height: 2),
//             Text(
//               "Generated on ${now.day} ${_currentMonth(now.month, now.year)}",
//               style: const TextStyle(color: Colors.white70, fontSize: 13),
//             ),
//           ],
//         ),
//         actions: [
//           Center(
//             child: Padding(
//               padding: const EdgeInsets.only(right: 16.0),
//               child: Text(
//                 _currentMonth(now.month, now.year),
//                 style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 16),
//               ),
//             ),
//           )
//         ],
//       ),
//       body: Stack(
//         children: [
//           Container(
//             decoration: const BoxDecoration(
//               image: DecorationImage(
//                 image: AssetImage("assets/images/bd_whatsapp.jpeg"),
//                 fit: BoxFit.cover,
//                 opacity: 0.6,
//               ),
//             ),
//           ),
//           SafeArea(
//             child: SingleChildScrollView(
//               padding: const EdgeInsets.all(16),
//               child: Column(
//                 children: [
                  
//                   // TOGGLE BUTTONS
//                   Container(
//                     decoration: BoxDecoration(
//                       color: Colors.white,
//                       borderRadius: BorderRadius.circular(30),
//                       border: Border.all(color: Colors.grey.withOpacity(0.3)),
//                     ),
//                     child: Row(
//                       children: [
//                         Expanded(
//                           child: GestureDetector(
//                             onTap: () => setState(() => compareMode = false),
//                             child: Container(
//                               padding: const EdgeInsets.symmetric(vertical: 14),
//                               decoration: BoxDecoration(
//                                 color: compareMode ? Colors.transparent : const Color(0xFF1E6F5C),
//                                 borderRadius: BorderRadius.circular(30),
//                               ),
//                               child: Center(
//                                 child: Text(
//                                   "This Month",
//                                   style: TextStyle(
//                                     fontSize: 15,
//                                     color: compareMode ? Colors.black87 : Colors.white,
//                                     fontWeight: FontWeight.bold,
//                                   ),
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ),
//                         Expanded(
//                           child: GestureDetector(
//                             onTap: () => setState(() => compareMode = true),
//                             child: Container(
//                               padding: const EdgeInsets.symmetric(vertical: 14),
//                               decoration: BoxDecoration(
//                                 color: compareMode ? const Color(0xFF1E6F5C) : Colors.transparent,
//                                 borderRadius: BorderRadius.circular(30),
//                               ),
//                               child: Center(
//                                 child: Text(
//                                   "Compare 3 Months",
//                                   style: TextStyle(
//                                     fontSize: 15,
//                                     color: compareMode ? Colors.white : Colors.black87,
//                                     fontWeight: FontWeight.bold,
//                                   ),
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),

//                   const SizedBox(height: 20),

//                   // TOP 3 STATS
//                   Row(
//                     children: [
//                       Expanded(
//                         child: _modernCard("Total Income", activeIncome, const Color(0xFFCBEBFF), const Color(0xFF0033B9)),
//                       ),
//                       const SizedBox(width: 8),
//                       Expanded(
//                         child: _modernCard("Total Expense", activeExpense, const Color(0xFFFFCCCC), const Color(0xFF990000)),
//                       ),
//                       const SizedBox(width: 8),
//                       Expanded(
//                         child: _modernCard("Total Saving", activeSaving, const Color(0xFFCCFFCC), const Color(0xFF006600)),
//                       ),
//                     ],
//                   ),

//                   const SizedBox(height: 20),

//                   if (!compareMode) ...[
//                     // THIS MONTH VIEW
//                     _sectionCard(
//                       title: "Top Transactions",
//                       child: Column(
//                         children: _topTransactionsUI(),
//                       ),
//                     ),
//                     const SizedBox(height: 20),
//                     _sectionCard(
//                       title: "Spending Trend",
//                       child: SizedBox(
//                         height: 220,
//                         child: _buildWeeklyChart(),
//                       ),
//                     ),
//                     const SizedBox(height: 20),
//                     _warningBox(tmExpense, tmIncome),
                    
//                     const SizedBox(height: 30),

//                     SizedBox(
//                       width: double.infinity,
//                       child: ElevatedButton.icon(
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: const Color(0xFF007BFF),
//                           padding: const EdgeInsets.symmetric(vertical: 16),
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(8),
//                           ),
//                         ),
//                         icon: const Icon(Icons.share, color: Colors.white),
//                         label: const Text("Share Report", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
//                         onPressed: () async {
//                           await _sharePdf();
//                         },
//                       ),
//                     ),
//                     const SizedBox(height: 30),
//                   ] else ...[
//                     // COMPARE 3 MONTHS VIEW
//                     _sectionCard(
//                       title: "Compare 3 Months",
//                       child: SizedBox(
//                         height: 250,
//                         child: _buildGroupedBarChart(mDataList),
//                       ),
//                     ),
//                     const SizedBox(height: 20),
//                     _dataTableCard(mDataList),
//                     const SizedBox(height: 20),
//                     _sectionCard(
//                       title: "Last 3 Months Expense Breakdown",
//                       child: SizedBox(
//                         height: 280,
//                         child: _buildDetailedPieChart(mDataList),
//                       ),
//                     ),
//                     const SizedBox(height: 30),
//                   ],
//                 ],
//               ),
//             ),
//           )
//         ],
//       ),
//     );
//   }

//   Widget _modernCard(String title, double amount, Color bgColor, Color textColor) {
//     return Container(
//       padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
//       decoration: BoxDecoration(
//         color: bgColor,
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: Colors.grey.withOpacity(0.2)),
//         boxShadow: [
//           BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4),
//         ]
//       ),
//       child: Column(
//         children: [
//           Text(title, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.black87), textAlign: TextAlign.center),
//           const SizedBox(height: 6),
//           Text(
//             "₹${amount.toInt()}",
//             style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: textColor),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _sectionCard({required String title, required Widget child}) {
//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(12),
//         boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4)],
//         border: Border.all(color: Colors.grey.withOpacity(0.2)),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
//           const SizedBox(height: 16),
//           child,
//         ],
//       ),
//     );
//   }

//   // --- THIS MONTH METHODS ---
//   List<Widget> _topTransactionsUI() {
//     final sorted = allTransactions.where((tx) => tx.date.month == DateTime.now().month && tx.date.year == DateTime.now().year).toList();
//     sorted.sort((a,b)=>b.amount.compareTo(a.amount));
    
//     if (sorted.isEmpty) return [const Text("No transactions this month.")];

//     return sorted.take(3).map((tx){
//       return Container(
//         margin: const EdgeInsets.only(bottom: 12),
//         padding: const EdgeInsets.all(12),
//         decoration: BoxDecoration(
//           color: Colors.white,
//           border: Border.all(color: Colors.grey.withOpacity(0.2)),
//           borderRadius: BorderRadius.circular(10),
//         ),
//         child: Row(
//           children: [
//             CircleAvatar(
//               backgroundColor: const Color(0xFFFFE0E0),
//               radius: 18,
//               child: const Icon(Icons.arrow_upward, color: Colors.red, size: 18),
//             ),
//             const SizedBox(width: 12),
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(tx.description.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
//                   const SizedBox(height: 4),
//                   Text("${tx.isCredit ? 'Credit' : 'Debit'} • ${tx.date.day}/${tx.date.month}/${tx.date.year}", style: const TextStyle(fontSize: 11, color: Colors.grey)),
//                 ],
//               ),
//             ),
//             Text(
//               "${tx.isCredit ? '+' : '-'} ₹${tx.amount.toInt()}",
//               style: TextStyle(color: tx.isCredit ? Colors.green : Colors.red, fontWeight: FontWeight.bold),
//             ),
//           ],
//         ),
//       );
//     }).toList();
//   }

//   Widget _warningBox(double expense, double income) {
//     double per = income == 0 ? 0 : (expense / income) * 100;
    
//     if (per > 75) {
//       return Container(
//         width: double.infinity,
//         padding: const EdgeInsets.all(16),
//         decoration: BoxDecoration(
//           color: const Color(0xFFFFF4F4),
//           border: Border.all(color: const Color(0xFFFFCCCC)),
//           borderRadius: BorderRadius.circular(8),
//         ),
//         child: RichText(
//           text: TextSpan(
//             style: const TextStyle(color: Colors.black87),
//             children: [
//               const TextSpan(text: "⚠️ Warning: ", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
//               TextSpan(text: "You used ${per.toStringAsFixed(0)}% of your monthly budget! Consider reducing your shopping expenses."),
//             ]
//           ),
//         ),
//       );
//     } else {
//       return Container(
//         width: double.infinity,
//         padding: const EdgeInsets.all(16),
//         decoration: BoxDecoration(
//           color: const Color(0xFFF4FFF4),
//           border: Border.all(color: const Color(0xFFCCFFCC)),
//           borderRadius: BorderRadius.circular(8),
//         ),
//         child: RichText(
//           text: TextSpan(
//             style: const TextStyle(color: Colors.black87),
//             children: [
//               const TextSpan(text: "✅ Great Job: ", style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
//               TextSpan(text: "You only used ${per.toStringAsFixed(0)}% of your monthly budget! Keep saving."),
//             ]
//           ),
//         ),
//       );
//     }
//   }

//   Widget _buildWeeklyChart() {
//     List<double> weeks = [0,0,0,0,0];
//     final now = DateTime.now();

//     for(final tx in allTransactions){
//       if(!tx.isCredit && tx.date.month == now.month && tx.date.year == now.year){
//         int week = ((tx.date.day-1)/7).floor();
//         if(week < 5){
//           weeks[week] += tx.amount;
//         }
//       }
//     }

//     double maxVal = weeks.reduce((a, b) => a > b ? a : b);
//     maxVal = maxVal == 0 ? 1000 : maxVal * 1.5;

//     return BarChart(
//       BarChartData(
//         alignment: BarChartAlignment.spaceAround,
//         maxY: maxVal,
//         barTouchData: BarTouchData(enabled: false),
//         titlesData: FlTitlesData(
//           show: true,
//           bottomTitles: AxisTitles(
//             sideTitles: SideTitles(
//               showTitles: true,
//               getTitlesWidget: (value, meta) {
//                 return Text("Week ${value.toInt() + 1}", style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold));
//               },
//             ),
//           ),
//           leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
//           topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
//           rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
//         ),
//         gridData: const FlGridData(show: false),
//         borderData: FlBorderData(show: false),
//         barGroups: List.generate(
//           5,
//           (i) => BarChartGroupData(
//             x: i,
//             showingTooltipIndicators: [],
//             barRods: [
//               BarChartRodData(
//                 toY: weeks[i],
//                 width: 28,
//                 color: const Color(0xFF4B8BFF),
//                 borderRadius: const BorderRadius.only(topLeft: Radius.circular(4), topRight: Radius.circular(4)),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   // --- COMPARE 3 MONTHS METHODS ---
//   Widget _buildGroupedBarChart(List<MonthlyData> mDataList) {
//     double maxVal = 0;
//     for (var d in mDataList) {
//       if (d.income > maxVal) maxVal = d.income;
//       if (d.expense > maxVal) maxVal = d.expense;
//     }
//     maxVal = maxVal == 0 ? 1000 : maxVal * 1.3;

//     return Column(
//       children: [
//         Row(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Container(width: 10, height: 10, color: const Color(0xFF007BFF)),
//             const SizedBox(width: 4),
//             const Text("Income", style: TextStyle(fontSize: 12)),
//             const SizedBox(width: 16),
//             Container(width: 10, height: 10, color: const Color(0xFFFF4B4B)),
//             const SizedBox(width: 4),
//             const Text("Expense", style: TextStyle(fontSize: 12)),
//           ],
//         ),
//         const SizedBox(height: 16),
//         Expanded(
//           child: BarChart(
//             BarChartData(
//               maxY: maxVal,
//               alignment: BarChartAlignment.spaceAround,
//               titlesData: FlTitlesData(
//                 show: true,
//                 bottomTitles: AxisTitles(
//                   sideTitles: SideTitles(
//                     showTitles: true,
//                     getTitlesWidget: (value, meta) {
//                       return Padding(
//                         padding: const EdgeInsets.only(top: 8.0),
//                         child: Text(mDataList[value.toInt()].label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
//                       );
//                     },
//                   ),
//                 ),
//                 leftTitles: AxisTitles(
//                   sideTitles: SideTitles(
//                     showTitles: true,
//                     reservedSize: 40,
//                     getTitlesWidget: (value, meta) {
//                       if (value == 0) return const Text("0");
//                       if (value % 5000 != 0 && value % 10000 != 0) return const SizedBox.shrink();
//                       return Text("${(value).toInt()}", style: const TextStyle(fontSize: 10));
//                     },
//                   ),
//                 ),
//                 topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
//                 rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
//               ),
//               borderData: FlBorderData(
//                 show: true,
//                 border: const Border(bottom: BorderSide(color: Colors.black12), left: BorderSide(color: Colors.black12)),
//               ),
//               gridData: const FlGridData(show: false),
//               barGroups: List.generate(
//                 mDataList.length,
//                 (i) => BarChartGroupData(
//                   x: i,
//                   barsSpace: 4,
//                   barRods: [
//                     BarChartRodData(
//                       toY: mDataList[i].income,
//                       width: 24,
//                       color: const Color(0xFF007BFF),
//                       borderRadius: BorderRadius.zero,
//                     ),
//                     BarChartRodData(
//                       toY: mDataList[i].expense,
//                       width: 24,
//                       color: const Color(0xFFFF4B4B),
//                       borderRadius: BorderRadius.zero,
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _dataTableCard(List<MonthlyData> mDataList) {
//     return Container(
//       width: double.infinity,
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: Colors.grey.withOpacity(0.2)),
//         boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4)],
//       ),
//       child: ClipRRect(
//         borderRadius: BorderRadius.circular(12),
//         child: DataTable(
//           horizontalMargin: 12,
//           columnSpacing: 10,
//           headingRowColor: MaterialStateProperty.all(Colors.grey.shade100),
//           columns: const [
//             DataColumn(label: Text("Month", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11))),
//             DataColumn(label: Text("Income", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11))),
//             DataColumn(label: Text("Expense", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11))),
//             DataColumn(label: Text("Savings", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11))),
//             DataColumn(label: Text("Health", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11))),
//           ],
//           rows: mDataList.map((m) {
//             return DataRow(
//               cells: [
//                 DataCell(Text("${m.label} ${m.date.year}", style: const TextStyle(fontSize: 11))),
//                 DataCell(Text("₹${m.income.toInt()}", style: const TextStyle(fontSize: 11))),
//                 DataCell(Text("₹${m.expense.toInt()}", style: const TextStyle(fontSize: 11))),
//                 DataCell(Row(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     Text("₹${m.saving.toInt()}", style: const TextStyle(fontSize: 11)),
//                     Icon(m.saving >= 0 ? Icons.arrow_drop_up : Icons.arrow_drop_down, color: m.saving >= 0 ? Colors.green : Colors.red, size: 16),
//                   ],
//                 )),
//                 DataCell(Row(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     Text("${m.healthScore}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
//                     const SizedBox(width: 4),
//                     Text(m.healthScore >= 70 ? "Good" : "Poor", style: TextStyle(color: m.healthScore >= 70 ? Colors.green : Colors.red, fontSize: 10)),
//                   ],
//                 )),
//               ]
//             );
//           }).toList(),
//         ),
//       ),
//     );
//   }

//   Widget _buildDetailedPieChart(List<MonthlyData> mDataList) {
//     final colors = [const Color(0xFF0033B9), const Color(0xFFFF9900), const Color(0xFF00AACC)];
    
//     double totalAll = mDataList.fold(0, (s, e) => s + e.expense);
//     if (totalAll == 0) return const Center(child: Text("No expenses to chart."));

//     return Column(
//       children: [
//         Expanded(
//           child: Stack(
//             alignment: Alignment.center,
//             children: [
//               PieChart(
//                 PieChartData(
//                   sectionsSpace: 0,
//                   centerSpaceRadius: 0,
//                   sections: List.generate(mDataList.length, (i) {
//                     final d = mDataList[i];
//                     double per = (d.expense / totalAll) * 100;
//                     return PieChartSectionData(
//                       value: per,
//                       color: colors[i % colors.length],
//                       title: "${per.toStringAsFixed(0)}%",
//                       radius: 90,
//                       titlePositionPercentageOffset: 1.3,
//                       titleStyle: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 13),
//                     );
//                   }),
//                 )
//               ),
//             ],
//           ),
//         ),
//         const SizedBox(height: 16),
//         Row(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: List.generate(mDataList.length, (i) {
//             return Row(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 Container(width: 10, height: 10, decoration: BoxDecoration(color: colors[i % colors.length], shape: BoxShape.circle)),
//                 const SizedBox(width: 4),
//                 Text(mDataList[i].label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
//                 const SizedBox(width: 16),
//               ],
//             );
//           }),
//         ),
//       ],
//     );
//   }

//   // --- UTILS ---
//   Future<File> _generatePdf() async {
//     final pdf = pw.Document();
//     pdf.addPage(
//       pw.Page(
//         build: (context) => pw.Center(child: pw.Text("BudgetBee Monthly Report\nMore detailed PDF under construction.", textAlign: pw.TextAlign.center)),
//       ),
//     );
//     final directory = Directory("/storage/emulated/0/Download");
//     if (!await directory.exists()) await directory.create(recursive: true);
//     final file = File("${directory.path}/BudgetBee_${DateTime.now().millisecondsSinceEpoch}.pdf");
//     await file.writeAsBytes(await pdf.save());
//     return file;
//   }

//   Future<void> _sharePdf() async {
//     try {
//       final file = await _generatePdf();
//       await Share.shareXFiles([XFile(file.path)], text: "My BudgetBee Monthly Report");
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Error sharing PDF")));
//     }
//   }

//   String _currentMonth(int m, int y) {
//     const months=["", "January","February","March","April","May","June","July","August","September","October","November","December"];
//     return "${months[m]} $y";
//   }
// }

// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:fl_chart/fl_chart.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:share_plus/share_plus.dart';
// import 'package:pdf/widgets.dart' as pw;
// import '../globals.dart';
// import 'package:pdf/pdf.dart';
// import 'package:permission_handler/permission_handler.dart';
// import '../widgets/chatbot_fab.dart';

// class MonthlyData {
//   final DateTime date;
//   final String label;
//   final double income;
//   final double expense;
//   MonthlyData(this.date, this.label, this.income, this.expense);
//   double get saving => income - expense;
//   int get healthScore {
//     if (income == 0) return expense == 0 ? 100 : 0;
//     double per = (expense / income) * 100;
//     int score = (100 - per).round();
//     return score.clamp(0, 100);
//   }
// }

// class MonthlyReportScreen extends StatefulWidget {
//   const MonthlyReportScreen({super.key});

//   @override
//   State<MonthlyReportScreen> createState() => _MonthlyReportScreenState();
// }

// class _MonthlyReportScreenState extends State<MonthlyReportScreen> {
//   bool compareMode = false;

//   @override
//   Widget build(BuildContext context) {
//     // Current month calculations
//     double tmIncome = totalCredit;
//     double tmExpense = totalDebit;
//     double tmSaving = totalCredit - totalDebit;

//     // 3 Months Calculations
//     final now = DateTime.now();
//     List<MonthlyData> mDataList = [];
    
//     for (int i = 2; i >= 0; i--) {
//       int targetMonth = now.month - i;
//       int targetYear = now.year;
//       if (targetMonth <= 0) {
//         targetMonth += 12;
//         targetYear -= 1;
//       }
      
//       double mIncome = 0;
//       double mExpense = 0;

//       for (var tx in allTransactions) {
//         if (tx.date.year == targetYear && tx.date.month == targetMonth) {
//           if (tx.isCredit) {
//             mIncome += tx.amount;
//           } else {
//             mExpense += tx.amount;
//           }
//         }
//       }

//       final months = ["", "Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];
//       String label = "${months[targetMonth]}";
      
//       mDataList.add(MonthlyData(DateTime(targetYear, targetMonth, 1), label, mIncome, mExpense));
//     }

//     double compIncome = mDataList.fold(0, (sum, item) => sum + item.income);
//     double compExpense = mDataList.fold(0, (sum, item) => sum + item.expense);
//     double compSaving = compIncome - compExpense;

//     double activeIncome = compareMode ? compIncome : tmIncome;
//     double activeExpense = compareMode ? compExpense : tmExpense;
//     double activeSaving = compareMode ? compSaving : tmSaving;

//     return Scaffold(
//       backgroundColor: const Color(0xFFF4F8FB),
//       appBar: AppBar(
//         iconTheme: const IconThemeData(color: Colors.white),
//         backgroundColor: const Color(0xFF1E6F5C),
//         elevation: 0,
//         title: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const Text(
//               "Monthly Report",
//               style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
//             ),
//             const SizedBox(height: 2),
//             Text(
//               "Generated on ${now.day} ${_currentMonth(now.month, now.year)}",
//               style: const TextStyle(color: Colors.white70, fontSize: 13),
//             ),
//           ],
//         ),
//         actions: [
//           Center(
//             child: Padding(
//               padding: const EdgeInsets.only(right: 16.0),
//               child: Text(
//                 _currentMonth(now.month, now.year),
//                 style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 16),
//               ),
//             ),
//           )
//         ],
//       ),
//       floatingActionButton: const ChatbotFab(),
//       body: Stack(
//         children: [
//           Container(
//             decoration: const BoxDecoration(
//               image: DecorationImage(
//                 image: AssetImage("assets/images/bd_whatsapp.jpeg"),
//                 fit: BoxFit.cover,
//                 opacity: 0.6,
//               ),
//             ),
//           ),
//           SafeArea(
//             child: SingleChildScrollView(
//               padding: const EdgeInsets.all(16),
//               child: Column(
//                 children: [
                  
//                   // TOGGLE BUTTONS
//                   Container(
//                     decoration: BoxDecoration(
//                       color: Colors.white,
//                       borderRadius: BorderRadius.circular(30),
//                       border: Border.all(color: Colors.grey.withOpacity(0.3)),
//                     ),
//                     child: Row(
//                       children: [
//                         Expanded(
//                           child: GestureDetector(
//                             onTap: () => setState(() => compareMode = false),
//                             child: Container(
//                               padding: const EdgeInsets.symmetric(vertical: 14),
//                               decoration: BoxDecoration(
//                                 color: compareMode ? Colors.transparent : const Color(0xFF1E6F5C),
//                                 borderRadius: BorderRadius.circular(30),
//                               ),
//                               child: Center(
//                                 child: Text(
//                                   "This Month",
//                                   style: TextStyle(
//                                     fontSize: 15,
//                                     color: compareMode ? Colors.black87 : Colors.white,
//                                     fontWeight: FontWeight.bold,
//                                   ),
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ),
//                         Expanded(
//                           child: GestureDetector(
//                             onTap: () => setState(() => compareMode = true),
//                             child: Container(
//                               padding: const EdgeInsets.symmetric(vertical: 14),
//                               decoration: BoxDecoration(
//                                 color: compareMode ? const Color(0xFF1E6F5C) : Colors.transparent,
//                                 borderRadius: BorderRadius.circular(30),
//                               ),
//                               child: Center(
//                                 child: Text(
//                                   "Compare 3 Months",
//                                   style: TextStyle(
//                                     fontSize: 15,
//                                     color: compareMode ? Colors.white : Colors.black87,
//                                     fontWeight: FontWeight.bold,
//                                   ),
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),

//                   const SizedBox(height: 20),

//                   // TOP 3 STATS
//                   Row(
//                     children: [
//                       Expanded(
//                         child: _modernCard("Total Income", activeIncome, const Color(0xFFCBEBFF), const Color(0xFF0033B9)),
//                       ),
//                       const SizedBox(width: 8),
//                       Expanded(
//                         child: _modernCard("Total Expense", activeExpense, const Color(0xFFFFCCCC), const Color(0xFF990000)),
//                       ),
//                       const SizedBox(width: 8),
//                       Expanded(
//                         child: _modernCard("Total Saving", activeSaving, const Color(0xFFCCFFCC), const Color(0xFF006600)),
//                       ),
//                     ],
//                   ),

//                   const SizedBox(height: 20),

//                   if (!compareMode) ...[
//                     // THIS MONTH VIEW
//                     _sectionCard(
//                       title: "Top Transactions",
//                       child: Column(
//                         children: _topTransactionsUI(),
//                       ),
//                     ),
//                     const SizedBox(height: 20),
//                     _sectionCard(
//                       title: "Spending Trend",
//                       child: SizedBox(
//                         height: 220,
//                         child: _buildWeeklyChart(),
//                       ),
//                     ),
//                     const SizedBox(height: 20),
//                     _warningBox(tmExpense, tmIncome),
                    
//                     const SizedBox(height: 30),

//                     SizedBox(
//                       width: double.infinity,
//                       child: ElevatedButton.icon(
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: const Color(0xFF007BFF),
//                           padding: const EdgeInsets.symmetric(vertical: 16),
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(8),
//                           ),
//                         ),
//                         icon: const Icon(Icons.share, color: Colors.white),
//                         label: const Text("Share Report", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
//                         onPressed: () async {
//                           await _sharePdf();
//                         },
//                       ),
//                     ),
//                     const SizedBox(height: 30),
//                   ] else ...[
//                     // COMPARE 3 MONTHS VIEW
//                     _sectionCard(
//                       title: "Compare 3 Months",
//                       child: SizedBox(
//                         height: 250,
//                         child: _buildGroupedBarChart(mDataList),
//                       ),
//                     ),
//                     const SizedBox(height: 20),
//                     _dataTableCard(mDataList),
//                     const SizedBox(height: 20),
//                     _sectionCard(
//                       title: "Last 3 Months Expense Breakdown",
//                       child: SizedBox(
//                         height: 280,
//                         child: _buildDetailedPieChart(mDataList),
//                       ),
//                     ),
//                     const SizedBox(height: 30),
//                   ],
//                 ],
//               ),
//             ),
//           )
//         ],
//       ),
//     );
//   }

//   Widget _modernCard(String title, double amount, Color bgColor, Color textColor) {
//     return Container(
//       padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
//       decoration: BoxDecoration(
//         color: bgColor,
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: Colors.grey.withOpacity(0.2)),
//         boxShadow: [
//           BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4),
//         ]
//       ),
//       child: Column(
//         children: [
//           Text(title, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.black87), textAlign: TextAlign.center),
//           const SizedBox(height: 6),
//           Text(
//             "₹${amount.toInt()}",
//             style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: textColor),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _sectionCard({required String title, required Widget child}) {
//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(12),
//         boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4)],
//         border: Border.all(color: Colors.grey.withOpacity(0.2)),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
//           const SizedBox(height: 16),
//           child,
//         ],
//       ),
//     );
//   }

//   // --- THIS MONTH METHODS ---
//   List<Widget> _topTransactionsUI() {
//     final sorted = allTransactions.where((tx) => tx.date.month == DateTime.now().month && tx.date.year == DateTime.now().year).toList();
//     sorted.sort((a,b)=>b.amount.compareTo(a.amount));
    
//     if (sorted.isEmpty) return [const Text("No transactions this month.")];

//     return sorted.take(3).map((tx){
//       return Container(
//         margin: const EdgeInsets.only(bottom: 12),
//         padding: const EdgeInsets.all(12),
//         decoration: BoxDecoration(
//           color: Colors.white,
//           border: Border.all(color: Colors.grey.withOpacity(0.2)),
//           borderRadius: BorderRadius.circular(10),
//         ),
//         child: Row(
//           children: [
//             CircleAvatar(
//               backgroundColor: const Color(0xFFFFE0E0),
//               radius: 18,
//               child: const Icon(Icons.arrow_upward, color: Colors.red, size: 18),
//             ),
//             const SizedBox(width: 12),
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(tx.description.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
//                   const SizedBox(height: 4),
//                   Text("${tx.isCredit ? 'Credit' : 'Debit'} • ${tx.date.day}/${tx.date.month}/${tx.date.year}", style: const TextStyle(fontSize: 11, color: Colors.grey)),
//                 ],
//               ),
//             ),
//             Text(
//               "${tx.isCredit ? '+' : '-'} ₹${tx.amount.toInt()}",
//               style: TextStyle(color: tx.isCredit ? Colors.green : Colors.red, fontWeight: FontWeight.bold),
//             ),
//           ],
//         ),
//       );
//     }).toList();
//   }

//   Widget _warningBox(double expense, double income) {
//     double per = income == 0 ? 0 : (expense / income) * 100;
    
//     if (per > 75) {
//       return Container(
//         width: double.infinity,
//         padding: const EdgeInsets.all(16),
//         decoration: BoxDecoration(
//           color: const Color(0xFFFFF4F4),
//           border: Border.all(color: const Color(0xFFFFCCCC)),
//           borderRadius: BorderRadius.circular(8),
//         ),
//         child: RichText(
//           text: TextSpan(
//             style: const TextStyle(color: Colors.black87),
//             children: [
//               const TextSpan(text: "⚠️ Warning: ", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
//               TextSpan(text: "You used ${per.toStringAsFixed(0)}% of your monthly budget! Consider reducing your shopping expenses."),
//             ]
//           ),
//         ),
//       );
//     } else {
//       return Container(
//         width: double.infinity,
//         padding: const EdgeInsets.all(16),
//         decoration: BoxDecoration(
//           color: const Color(0xFFF4FFF4),
//           border: Border.all(color: const Color(0xFFCCFFCC)),
//           borderRadius: BorderRadius.circular(8),
//         ),
//         child: RichText(
//           text: TextSpan(
//             style: const TextStyle(color: Colors.black87),
//             children: [
//               const TextSpan(text: "✅ Great Job: ", style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
//               TextSpan(text: "You only used ${per.toStringAsFixed(0)}% of your monthly budget! Keep saving."),
//             ]
//           ),
//         ),
//       );
//     }
//   }

//   Widget _buildWeeklyChart() {
//     List<double> weeks = [0,0,0,0,0];
//     final now = DateTime.now();

//     for(final tx in allTransactions){
//       if(!tx.isCredit && tx.date.month == now.month && tx.date.year == now.year){
//         int week = ((tx.date.day-1)/7).floor();
//         if(week < 5){
//           weeks[week] += tx.amount;
//         }
//       }
//     }

//     double maxVal = weeks.reduce((a, b) => a > b ? a : b);
//     maxVal = maxVal == 0 ? 1000 : maxVal * 1.5;

//     return BarChart(
//       BarChartData(
//         alignment: BarChartAlignment.spaceAround,
//         maxY: maxVal,
//         barTouchData: BarTouchData(
//           enabled: false,
//           touchTooltipData: BarTouchTooltipData(
//             getTooltipColor: (_) => Colors.transparent,
//             tooltipPadding: EdgeInsets.zero,
//             tooltipMargin: 4,
//             getTooltipItem: (group, groupIndex, rod, rodIndex) {
//               if (rod.toY == 0) return null;
//               return BarTooltipItem(
//                 "₹${rod.toY.toInt()}",
//                 const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 10),
//               );
//             },
//           ),
//         ),
//         titlesData: FlTitlesData(
//           show: true,
//           bottomTitles: AxisTitles(
//             sideTitles: SideTitles(
//               showTitles: true,
//               getTitlesWidget: (value, meta) {
//                 return Text("Week ${value.toInt() + 1}", style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold));
//               },
//             ),
//           ),
//           leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
//           topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
//           rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
//         ),
//         gridData: const FlGridData(show: false),
//         borderData: FlBorderData(show: false),
//         barGroups: List.generate(
//           5,
//           (i) => BarChartGroupData(
//             x: i,
//             showingTooltipIndicators: [0],
//             barRods: [
//               BarChartRodData(
//                 toY: weeks[i],
//                 width: 28,
//                 color: const Color(0xFF4B8BFF),
//                 borderRadius: const BorderRadius.only(topLeft: Radius.circular(4), topRight: Radius.circular(4)),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   // --- COMPARE 3 MONTHS METHODS ---
//   Widget _buildGroupedBarChart(List<MonthlyData> mDataList) {
//     double maxVal = 0;
//     for (var d in mDataList) {
//       if (d.income > maxVal) maxVal = d.income;
//       if (d.expense > maxVal) maxVal = d.expense;
//     }
//     maxVal = maxVal == 0 ? 1000 : maxVal * 1.3;

//     return Column(
//       children: [
//         Row(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Container(width: 10, height: 10, color: const Color(0xFF007BFF)),
//             const SizedBox(width: 4),
//             const Text("Income", style: TextStyle(fontSize: 12)),
//             const SizedBox(width: 16),
//             Container(width: 10, height: 10, color: const Color(0xFFFF4B4B)),
//             const SizedBox(width: 4),
//             const Text("Expense", style: TextStyle(fontSize: 12)),
//           ],
//         ),
//         const SizedBox(height: 16),
//         Expanded(
//           child: BarChart(
//             BarChartData(
//               maxY: maxVal,
//               alignment: BarChartAlignment.spaceAround,
//               titlesData: FlTitlesData(
//                 show: true,
//                 bottomTitles: AxisTitles(
//                   sideTitles: SideTitles(
//                     showTitles: true,
//                     getTitlesWidget: (value, meta) {
//                       return Padding(
//                         padding: const EdgeInsets.only(top: 8.0),
//                         child: Text(mDataList[value.toInt()].label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
//                       );
//                     },
//                   ),
//                 ),
//                 leftTitles: AxisTitles(
//                   sideTitles: SideTitles(
//                     showTitles: true,
//                     reservedSize: 40,
//                     getTitlesWidget: (value, meta) {
//                       if (value == 0) return const Text("0");
//                       if (value % 5000 != 0 && value % 10000 != 0) return const SizedBox.shrink();
//                       return Text("${(value).toInt()}", style: const TextStyle(fontSize: 10));
//                     },
//                   ),
//                 ),
//                 topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
//                 rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
//               ),
//               borderData: FlBorderData(
//                 show: true,
//                 border: const Border(bottom: BorderSide(color: Colors.black12), left: BorderSide(color: Colors.black12)),
//               ),
//               gridData: const FlGridData(show: false),
//               barTouchData: BarTouchData(
//                 enabled: false,
//                 touchTooltipData: BarTouchTooltipData(
//                   getTooltipColor: (_) => Colors.transparent,
//                   tooltipPadding: EdgeInsets.zero,
//                   tooltipMargin: 6,
//                   getTooltipItem: (group, groupIndex, rod, rodIndex) {
//                     if (rod.toY == 0) return null;
//                     return BarTooltipItem(
//                       "₹${rod.toY.toInt()}",
//                       const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 9),
//                     );
//                   },
//                 ),
//               ),
//               barGroups: List.generate(
//                 mDataList.length,
//                 (i) => BarChartGroupData(
//                   x: i,
//                   barsSpace: 4,
//                   showingTooltipIndicators: [0, 1],
//                   barRods: [
//                     BarChartRodData(
//                       toY: mDataList[i].income,
//                       width: 24,
//                       color: const Color(0xFF007BFF),
//                       borderRadius: BorderRadius.zero,
//                     ),
//                     BarChartRodData(
//                       toY: mDataList[i].expense,
//                       width: 24,
//                       color: const Color(0xFFFF4B4B),
//                       borderRadius: BorderRadius.zero,
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _dataTableCard(List<MonthlyData> mDataList) {
//     return Container(
//       width: double.infinity,
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: Colors.grey.withOpacity(0.2)),
//         boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4)],
//       ),
//       child: ClipRRect(
//         borderRadius: BorderRadius.circular(12),
//         child: DataTable(
//           horizontalMargin: 12,
//           columnSpacing: 10,
//           headingRowColor: MaterialStateProperty.all(Colors.grey.shade100),
//           columns: const [
//             DataColumn(label: Text("Month", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11))),
//             DataColumn(label: Text("Income", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11))),
//             DataColumn(label: Text("Expense", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11))),
//             DataColumn(label: Text("Savings", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11))),
//             DataColumn(label: Text("Health", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11))),
//           ],
//           rows: mDataList.map((m) {
//             return DataRow(
//               cells: [
//                 DataCell(Text("${m.label} ${m.date.year}", style: const TextStyle(fontSize: 11))),
//                 DataCell(Text("₹${m.income.toInt()}", style: const TextStyle(fontSize: 11))),
//                 DataCell(Text("₹${m.expense.toInt()}", style: const TextStyle(fontSize: 11))),
//                 DataCell(Row(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     Text("₹${m.saving.toInt()}", style: const TextStyle(fontSize: 11)),
//                     Icon(m.saving >= 0 ? Icons.arrow_drop_up : Icons.arrow_drop_down, color: m.saving >= 0 ? Colors.green : Colors.red, size: 16),
//                   ],
//                 )),
//                 DataCell(Row(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     Text("${m.healthScore}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
//                     const SizedBox(width: 4),
//                     Text(m.healthScore >= 70 ? "Good" : "Poor", style: TextStyle(color: m.healthScore >= 70 ? Colors.green : Colors.red, fontSize: 10)),
//                   ],
//                 )),
//               ]
//             );
//           }).toList(),
//         ),
//       ),
//     );
//   }

//   Widget _buildDetailedPieChart(List<MonthlyData> mDataList) {
//     final colors = [const Color(0xFF0033B9), const Color(0xFFFF9900), const Color(0xFF00AACC)];
    
//     double totalAll = mDataList.fold(0, (s, e) => s + e.expense);
//     if (totalAll == 0) return const Center(child: Text("No expenses to chart."));

//     return Column(
//       children: [
//         Expanded(
//           child: Stack(
//             alignment: Alignment.center,
//             children: [
//               PieChart(
//                 PieChartData(
//                   sectionsSpace: 0,
//                   centerSpaceRadius: 0,
//                   sections: List.generate(mDataList.length, (i) {
//                     final d = mDataList[i];
//                     double per = (d.expense / totalAll) * 100;
//                     return PieChartSectionData(
//                       value: per,
//                       color: colors[i % colors.length],
//                       title: "${per.toStringAsFixed(0)}%",
//                       radius: 90,
//                       titlePositionPercentageOffset: 1.3,
//                       titleStyle: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 13),
//                     );
//                   }),
//                 )
//               ),
//             ],
//           ),
//         ),
//         const SizedBox(height: 16),
//         Row(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: List.generate(mDataList.length, (i) {
//             return Row(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 Container(width: 10, height: 10, decoration: BoxDecoration(color: colors[i % colors.length], shape: BoxShape.circle)),
//                 const SizedBox(width: 4),
//                 Text(mDataList[i].label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
//                 const SizedBox(width: 16),
//               ],
//             );
//           }),
//         ),
//       ],
//     );
//   }

//   // --- UTILS ---
//   Future<File> _generatePdf() async {
//     final pdf = pw.Document();
//     pdf.addPage(
//       pw.Page(
//         build: (context) => pw.Center(child: pw.Text("BudgetBee Monthly Report\nMore detailed PDF under construction.", textAlign: pw.TextAlign.center)),
//       ),
//     );
//     final directory = Directory("/storage/emulated/0/Download");
//     if (!await directory.exists()) await directory.create(recursive: true);
//     final file = File("${directory.path}/BudgetBee_${DateTime.now().millisecondsSinceEpoch}.pdf");
//     await file.writeAsBytes(await pdf.save());
//     return file;
//   }

//   Future<void> _sharePdf() async {
//     try {
//       final file = await _generatePdf();
//       await Share.shareXFiles([XFile(file.path)], text: "My BudgetBee Monthly Report");
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Error sharing PDF")));
//     }
//   }

//   String _currentMonth(int m, int y) {
//     const months=["", "January","February","March","April","May","June","July","August","September","October","November","December"];
//     return "${months[m]} $y";
//   }
// }


// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:fl_chart/fl_chart.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:share_plus/share_plus.dart';
// import 'package:pdf/widgets.dart' as pw;
// import '../globals.dart';
// import 'package:pdf/pdf.dart';
// import 'package:permission_handler/permission_handler.dart';
// import '../widgets/chatbot_fab.dart';

// class MonthlyData {
//   final DateTime date;
//   final String label;
//   final double income;
//   final double expense;
//   MonthlyData(this.date, this.label, this.income, this.expense);
//   double get saving => income - expense;
//   int get healthScore {
//     if (income == 0) return expense == 0 ? 100 : 0;
//     double per = (expense / income) * 100;
//     int score = (100 - per).round();
//     return score.clamp(0, 100);
//   }
// }

// class MonthlyReportScreen extends StatefulWidget {
//   const MonthlyReportScreen({super.key});

//   @override
//   State<MonthlyReportScreen> createState() => _MonthlyReportScreenState();
// }

// class _MonthlyReportScreenState extends State<MonthlyReportScreen> {
//   bool compareMode = false;

//   @override
//   Widget build(BuildContext context) {
//     // Current month calculations
//     double tmIncome = totalCredit;
//     double tmExpense = totalDebit;
//     double tmSaving = totalCredit - totalDebit;

//     // 3 Months Calculations
//     final now = DateTime.now();
//     List<MonthlyData> mDataList = [];
    
//     for (int i = 2; i >= 0; i--) {
//       int targetMonth = now.month - i;
//       int targetYear = now.year;
//       if (targetMonth <= 0) {
//         targetMonth += 12;
//         targetYear -= 1;
//       }
      
//       double mIncome = 0;
//       double mExpense = 0;

//       for (var tx in allTransactions) {
//         if (tx.date.year == targetYear && tx.date.month == targetMonth) {
//           if (tx.isCredit) {
//             mIncome += tx.amount;
//           } else {
//             mExpense += tx.amount;
//           }
//         }
//       }

//       final months = ["", "Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];
//       String label = "${months[targetMonth]}";
      
//       mDataList.add(MonthlyData(DateTime(targetYear, targetMonth, 1), label, mIncome, mExpense));
//     }

//     double compIncome = mDataList.fold(0, (sum, item) => sum + item.income);
//     double compExpense = mDataList.fold(0, (sum, item) => sum + item.expense);
//     double compSaving = compIncome - compExpense;

//     double activeIncome = compareMode ? compIncome : tmIncome;
//     double activeExpense = compareMode ? compExpense : tmExpense;
//     double activeSaving = compareMode ? compSaving : tmSaving;

//     return Scaffold(
//       backgroundColor: const Color(0xFFF4F8FB),
//       floatingActionButton: const ChatbotFab(),
//       appBar: AppBar(
//         iconTheme: const IconThemeData(color: Colors.white),
//         backgroundColor: const Color(0xFF1E6F5C),
//         elevation: 0,
//         title: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const Text(
//               "Monthly Report",
//               style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
//             ),
//             const SizedBox(height: 2),
//             Text(
//               "Generated on ${now.day} ${_currentMonth(now.month, now.year)}",
//               style: const TextStyle(color: Colors.white70, fontSize: 13),
//             ),
//           ],
//         ),
//         actions: [
//           Center(
//             child: Padding(
//               padding: const EdgeInsets.only(right: 16.0),
//               child: Text(
//                 _currentMonth(now.month, now.year),
//                 style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 16),
//               ),
//             ),
//           )
//         ],
//       ),
//       body: Stack(
//         children: [
//           Container(
//             decoration: const BoxDecoration(
//               image: DecorationImage(
//                 image: AssetImage("assets/images/bd_whatsapp.jpeg"),
//                 fit: BoxFit.cover,
//                 opacity: 0.6,
//               ),
//             ),
//           ),
//           SafeArea(
//             child: SingleChildScrollView(
//               padding: const EdgeInsets.all(16),
//               child: Column(
//                 children: [
                  
//                   // TOGGLE BUTTONS
//                   Container(
//                     decoration: BoxDecoration(
//                       color: Colors.white,
//                       borderRadius: BorderRadius.circular(30),
//                       border: Border.all(color: Colors.grey.withOpacity(0.3)),
//                     ),
//                     child: Row(
//                       children: [
//                         Expanded(
//                           child: GestureDetector(
//                             onTap: () => setState(() => compareMode = false),
//                             child: Container(
//                               padding: const EdgeInsets.symmetric(vertical: 14),
//                               decoration: BoxDecoration(
//                                 color: compareMode ? Colors.transparent : const Color(0xFF1E6F5C),
//                                 borderRadius: BorderRadius.circular(30),
//                               ),
//                               child: Center(
//                                 child: Text(
//                                   "This Month",
//                                   style: TextStyle(
//                                     fontSize: 15,
//                                     color: compareMode ? Colors.black87 : Colors.white,
//                                     fontWeight: FontWeight.bold,
//                                   ),
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ),
//                         Expanded(
//                           child: GestureDetector(
//                             onTap: () => setState(() => compareMode = true),
//                             child: Container(
//                               padding: const EdgeInsets.symmetric(vertical: 14),
//                               decoration: BoxDecoration(
//                                 color: compareMode ? const Color(0xFF1E6F5C) : Colors.transparent,
//                                 borderRadius: BorderRadius.circular(30),
//                               ),
//                               child: Center(
//                                 child: Text(
//                                   "Compare 3 Months",
//                                   style: TextStyle(
//                                     fontSize: 15,
//                                     color: compareMode ? Colors.white : Colors.black87,
//                                     fontWeight: FontWeight.bold,
//                                   ),
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),

//                   const SizedBox(height: 20),

//                   // TOP 3 STATS
//                   Row(
//                     children: [
//                       Expanded(
//                         child: _modernCard("Total Income", activeIncome, const Color(0xFFCBEBFF), const Color(0xFF0033B9)),
//                       ),
//                       const SizedBox(width: 8),
//                       Expanded(
//                         child: _modernCard("Total Expense", activeExpense, const Color(0xFFFFCCCC), const Color(0xFF990000)),
//                       ),
//                       const SizedBox(width: 8),
//                       Expanded(
//                         child: _modernCard("Total Saving", activeSaving, const Color(0xFFCCFFCC), const Color(0xFF006600)),
//                       ),
//                     ],
//                   ),

//                   const SizedBox(height: 20),

//                   if (!compareMode) ...[
//                     // THIS MONTH VIEW
//                     _sectionCard(
//                       title: "Top Transactions",
//                       child: Column(
//                         children: _topTransactionsUI(),
//                       ),
//                     ),
//                     const SizedBox(height: 20),
//                     _sectionCard(
//                       title: "Spending Trend",
//                       child: SizedBox(
//                         height: 220,
//                         child: _buildWeeklyChart(),
//                       ),
//                     ),
//                     const SizedBox(height: 20),
//                     _warningBox(tmExpense, tmIncome),
                    
//                     const SizedBox(height: 30),

//                     SizedBox(
//                       width: double.infinity,
//                       child: ElevatedButton.icon(
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: const Color(0xFF007BFF),
//                           padding: const EdgeInsets.symmetric(vertical: 16),
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(8),
//                           ),
//                         ),
//                         icon: const Icon(Icons.share, color: Colors.white),
//                         label: const Text("Share Report", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
//                         onPressed: () async {
//                           await _sharePdf();
//                         },
//                       ),
//                     ),
//                     const SizedBox(height: 30),
//                   ] else ...[
//                     // COMPARE 3 MONTHS VIEW
//                     _sectionCard(
//                       title: "Compare 3 Months",
//                       child: SizedBox(
//                         height: 250,
//                         child: _buildGroupedBarChart(mDataList),
//                       ),
//                     ),
//                     const SizedBox(height: 20),
//                     _dataTableCard(mDataList),
//                     const SizedBox(height: 20),
//                     _sectionCard(
//                       title: "Last 3 Months Expense Breakdown",
//                       child: SizedBox(
//                         height: 280,
//                         child: _buildDetailedPieChart(mDataList),
//                       ),
//                     ),
//                     const SizedBox(height: 30),
//                   ],
//                 ],
//               ),
//             ),
//           )
//         ],
//       ),
//     );
//   }

//   Widget _modernCard(String title, double amount, Color bgColor, Color textColor) {
//     return Container(
//       padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
//       decoration: BoxDecoration(
//         color: bgColor,
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: Colors.grey.withOpacity(0.2)),
//         boxShadow: [
//           BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4),
//         ]
//       ),
//       child: Column(
//         children: [
//           Text(title, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.black87), textAlign: TextAlign.center),
//           const SizedBox(height: 6),
//           Text(
//             "₹${amount.toInt()}",
//             style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: textColor),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _sectionCard({required String title, required Widget child}) {
//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(12),
//         boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4)],
//         border: Border.all(color: Colors.grey.withOpacity(0.2)),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
//           const SizedBox(height: 16),
//           child,
//         ],
//       ),
//     );
//   }

//   // --- THIS MONTH METHODS ---
//   List<Widget> _topTransactionsUI() {
//     final sorted = allTransactions.where((tx) => tx.date.month == DateTime.now().month && tx.date.year == DateTime.now().year).toList();
//     sorted.sort((a,b)=>b.amount.compareTo(a.amount));
    
//     if (sorted.isEmpty) return [const Text("No transactions this month.")];

//     return sorted.take(3).map((tx){
//       return Container(
//         margin: const EdgeInsets.only(bottom: 12),
//         padding: const EdgeInsets.all(12),
//         decoration: BoxDecoration(
//           color: Colors.white,
//           border: Border.all(color: Colors.grey.withOpacity(0.2)),
//           borderRadius: BorderRadius.circular(10),
//         ),
//         child: Row(
//           children: [
//             CircleAvatar(
//               backgroundColor: const Color(0xFFFFE0E0),
//               radius: 18,
//               child: const Icon(Icons.arrow_upward, color: Colors.red, size: 18),
//             ),
//             const SizedBox(width: 12),
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(tx.description.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
//                   const SizedBox(height: 4),
//                   Text("${tx.isCredit ? 'Credit' : 'Debit'} • ${tx.date.day}/${tx.date.month}/${tx.date.year}", style: const TextStyle(fontSize: 11, color: Colors.grey)),
//                 ],
//               ),
//             ),
//             Text(
//               "${tx.isCredit ? '+' : '-'} ₹${tx.amount.toInt()}",
//               style: TextStyle(color: tx.isCredit ? Colors.green : Colors.red, fontWeight: FontWeight.bold),
//             ),
//           ],
//         ),
//       );
//     }).toList();
//   }

//   Widget _warningBox(double expense, double income) {
//     double per = income == 0 ? 0 : (expense / income) * 100;
    
//     if (per > 75) {
//       return Container(
//         width: double.infinity,
//         padding: const EdgeInsets.all(16),
//         decoration: BoxDecoration(
//           color: const Color(0xFFFFF4F4),
//           border: Border.all(color: const Color(0xFFFFCCCC)),
//           borderRadius: BorderRadius.circular(8),
//         ),
//         child: RichText(
//           text: TextSpan(
//             style: const TextStyle(color: Colors.black87),
//             children: [
//               const TextSpan(text: "⚠️ Warning: ", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
//               TextSpan(text: "You used ${per.toStringAsFixed(0)}% of your monthly budget! Consider reducing your shopping expenses."),
//             ]
//           ),
//         ),
//       );
//     } else {
//       return Container(
//         width: double.infinity,
//         padding: const EdgeInsets.all(16),
//         decoration: BoxDecoration(
//           color: const Color(0xFFF4FFF4),
//           border: Border.all(color: const Color(0xFFCCFFCC)),
//           borderRadius: BorderRadius.circular(8),
//         ),
//         child: RichText(
//           text: TextSpan(
//             style: const TextStyle(color: Colors.black87),
//             children: [
//               const TextSpan(text: "✅ Great Job: ", style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
//               TextSpan(text: "You only used ${per.toStringAsFixed(0)}% of your monthly budget! Keep saving."),
//             ]
//           ),
//         ),
//       );
//     }
//   }

//   Widget _buildWeeklyChart() {
//     List<double> weeks = [0,0,0,0,0];
//     final now = DateTime.now();

//     for(final tx in allTransactions){
//       if(!tx.isCredit && tx.date.month == now.month && tx.date.year == now.year){
//         int week = ((tx.date.day-1)/7).floor();
//         if(week < 5){
//           weeks[week] += tx.amount;
//         }
//       }
//     }

//     double maxVal = weeks.reduce((a, b) => a > b ? a : b);
//     maxVal = maxVal == 0 ? 1000 : maxVal * 1.5;

//     return BarChart(
//       BarChartData(
//         alignment: BarChartAlignment.spaceAround,
//         maxY: maxVal,
//         barTouchData: BarTouchData(
//           enabled: false,
//           touchTooltipData: BarTouchTooltipData(
//             getTooltipColor: (_) => Colors.transparent,
//             tooltipPadding: EdgeInsets.zero,
//             tooltipMargin: 4,
//             getTooltipItem: (group, groupIndex, rod, rodIndex) {
//               if (rod.toY == 0) return null;
//               return BarTooltipItem(
//                 "₹${rod.toY.toInt()}",
//                 const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 10),
//               );
//             },
//           ),
//         ),
//         titlesData: FlTitlesData(
//           show: true,
//           bottomTitles: AxisTitles(
//             sideTitles: SideTitles(
//               showTitles: true,
//               getTitlesWidget: (value, meta) {
//                 return Text("Week ${value.toInt() + 1}", style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold));
//               },
//             ),
//           ),
//           leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
//           topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
//           rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
//         ),
//         gridData: const FlGridData(show: false),
//         borderData: FlBorderData(show: false),
//         barGroups: List.generate(
//           5,
//           (i) => BarChartGroupData(
//             x: i,
//             showingTooltipIndicators: [0],
//             barRods: [
//               BarChartRodData(
//                 toY: weeks[i],
//                 width: 28,
//                 color: const Color(0xFF4B8BFF),
//                 borderRadius: const BorderRadius.only(topLeft: Radius.circular(4), topRight: Radius.circular(4)),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   // --- COMPARE 3 MONTHS METHODS ---
//   Widget _buildGroupedBarChart(List<MonthlyData> mDataList) {
//     double maxVal = 0;
//     for (var d in mDataList) {
//       if (d.income > maxVal) maxVal = d.income;
//       if (d.expense > maxVal) maxVal = d.expense;
//     }
//     maxVal = maxVal == 0 ? 1000 : maxVal * 1.3;

//     return Column(
//       children: [
//         Row(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Container(width: 10, height: 10, color: const Color(0xFF007BFF)),
//             const SizedBox(width: 4),
//             const Text("Income", style: TextStyle(fontSize: 12)),
//             const SizedBox(width: 16),
//             Container(width: 10, height: 10, color: const Color(0xFFFF4B4B)),
//             const SizedBox(width: 4),
//             const Text("Expense", style: TextStyle(fontSize: 12)),
//           ],
//         ),
//         const SizedBox(height: 16),
//         Expanded(
//           child: BarChart(
//             BarChartData(
//               maxY: maxVal,
//               alignment: BarChartAlignment.spaceAround,
//               titlesData: FlTitlesData(
//                 show: true,
//                 bottomTitles: AxisTitles(
//                   sideTitles: SideTitles(
//                     showTitles: true,
//                     getTitlesWidget: (value, meta) {
//                       return Padding(
//                         padding: const EdgeInsets.only(top: 8.0),
//                         child: Text(mDataList[value.toInt()].label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
//                       );
//                     },
//                   ),
//                 ),
//                 leftTitles: AxisTitles(
//                   sideTitles: SideTitles(
//                     showTitles: true,
//                     reservedSize: 40,
//                     getTitlesWidget: (value, meta) {
//                       if (value == 0) return const Text("0");
//                       if (value % 5000 != 0 && value % 10000 != 0) return const SizedBox.shrink();
//                       return Text("${(value).toInt()}", style: const TextStyle(fontSize: 10));
//                     },
//                   ),
//                 ),
//                 topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
//                 rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
//               ),
//               borderData: FlBorderData(
//                 show: true,
//                 border: const Border(bottom: BorderSide(color: Colors.black12), left: BorderSide(color: Colors.black12)),
//               ),
//               gridData: const FlGridData(show: false),
//               barTouchData: BarTouchData(
//                 enabled: false,
//                 touchTooltipData: BarTouchTooltipData(
//                   getTooltipColor: (_) => Colors.transparent,
//                   tooltipPadding: EdgeInsets.zero,
//                   tooltipMargin: 6,
//                   getTooltipItem: (group, groupIndex, rod, rodIndex) {
//                     if (rod.toY == 0) return null;
//                     return BarTooltipItem(
//                       "₹${rod.toY.toInt()}",
//                       const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 9),
//                     );
//                   },
//                 ),
//               ),
//               barGroups: List.generate(
//                 mDataList.length,
//                 (i) => BarChartGroupData(
//                   x: i,
//                   barsSpace: 4,
//                   showingTooltipIndicators: [0, 1],
//                   barRods: [
//                     BarChartRodData(
//                       toY: mDataList[i].income,
//                       width: 24,
//                       color: const Color(0xFF007BFF),
//                       borderRadius: BorderRadius.zero,
//                     ),
//                     BarChartRodData(
//                       toY: mDataList[i].expense,
//                       width: 24,
//                       color: const Color(0xFFFF4B4B),
//                       borderRadius: BorderRadius.zero,
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _dataTableCard(List<MonthlyData> mDataList) {
//     return Container(
//       width: double.infinity,
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: Colors.grey.withOpacity(0.2)),
//         boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4)],
//       ),
//       child: ClipRRect(
//         borderRadius: BorderRadius.circular(12),
//         child: DataTable(
//           horizontalMargin: 12,
//           columnSpacing: 10,
//           headingRowColor: MaterialStateProperty.all(Colors.grey.shade100),
//           columns: const [
//             DataColumn(label: Text("Month", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11))),
//             DataColumn(label: Text("Income", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11))),
//             DataColumn(label: Text("Expense", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11))),
//             DataColumn(label: Text("Savings", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11))),
//             DataColumn(label: Text("Health", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11))),
//           ],
//           rows: mDataList.map((m) {
//             return DataRow(
//               cells: [
//                 DataCell(Text("${m.label} ${m.date.year}", style: const TextStyle(fontSize: 11))),
//                 DataCell(Text("₹${m.income.toInt()}", style: const TextStyle(fontSize: 11))),
//                 DataCell(Text("₹${m.expense.toInt()}", style: const TextStyle(fontSize: 11))),
//                 DataCell(Row(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     Text("₹${m.saving.toInt()}", style: const TextStyle(fontSize: 11)),
//                     Icon(m.saving >= 0 ? Icons.arrow_drop_up : Icons.arrow_drop_down, color: m.saving >= 0 ? Colors.green : Colors.red, size: 16),
//                   ],
//                 )),
//                 DataCell(Row(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     Text("${m.healthScore}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
//                     const SizedBox(width: 4),
//                     Text(m.healthScore >= 70 ? "Good" : "Poor", style: TextStyle(color: m.healthScore >= 70 ? Colors.green : Colors.red, fontSize: 10)),
//                   ],
//                 )),
//               ]
//             );
//           }).toList(),
//         ),
//       ),
//     );
//   }

//   Widget _buildDetailedPieChart(List<MonthlyData> mDataList) {
//     final colors = [const Color(0xFF0033B9), const Color(0xFFFF9900), const Color(0xFF00AACC)];
    
//     double totalAll = mDataList.fold(0, (s, e) => s + e.expense);
//     if (totalAll == 0) return const Center(child: Text("No expenses to chart."));

//     return Column(
//       children: [
//         Expanded(
//           child: Stack(
//             alignment: Alignment.center,
//             children: [
//               PieChart(
//                 PieChartData(
//                   sectionsSpace: 0,
//                   centerSpaceRadius: 0,
//                   sections: List.generate(mDataList.length, (i) {
//                     final d = mDataList[i];
//                     double per = (d.expense / totalAll) * 100;
//                     return PieChartSectionData(
//                       value: per,
//                       color: colors[i % colors.length],
//                       title: "${per.toStringAsFixed(0)}%",
//                       radius: 90,
//                       titlePositionPercentageOffset: 1.3,
//                       titleStyle: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 13),
//                     );
//                   }),
//                 )
//               ),
//             ],
//           ),
//         ),
//         const SizedBox(height: 16),
//         Row(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: List.generate(mDataList.length, (i) {
//             return Row(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 Container(width: 10, height: 10, decoration: BoxDecoration(color: colors[i % colors.length], shape: BoxShape.circle)),
//                 const SizedBox(width: 4),
//                 Text(mDataList[i].label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
//                 const SizedBox(width: 16),
//               ],
//             );
//           }),
//         ),
//       ],
//     );
//   }

//   // --- UTILS ---
//   Future<File> _generatePdf() async {
//     final pdf = pw.Document();
//     final now = DateTime.now();

//     double tmIncome = totalCredit;
//     double tmExpense = totalDebit;
//     double tmSaving = tmIncome - tmExpense;
//     double expensePercent = tmIncome == 0 ? 0 : (tmExpense / tmIncome) * 100;

//     final sortedTxs = allTransactions.where((tx) => tx.date.month == now.month && tx.date.year == now.year).toList();
//     sortedTxs.sort((a,b)=>b.amount.compareTo(a.amount));
//     final topTxs = sortedTxs; // Change to include ALL transactions

//     List<double> weeks = [0,0,0,0,0];
//     for(final tx in allTransactions){
//       if(!tx.isCredit && tx.date.month == now.month && tx.date.year == now.year){
//         int week = ((tx.date.day-1)/7).floor();
//         if(week < 5){
//           weeks[week] += tx.amount;
//         }
//       }
//     }
//     double maxWeekly = 0;
//     if (weeks.isNotEmpty) {
//       maxWeekly = weeks.reduce((a, b) => a > b ? a : b);
//     }
//     if(maxWeekly == 0) maxWeekly = 1000;

//     pdf.addPage(
//       pw.Page(
//         pageFormat: PdfPageFormat.a4,
//         margin: const pw.EdgeInsets.all(32),
//         build: (context) {
//           return pw.Column(
//             crossAxisAlignment: pw.CrossAxisAlignment.start,
//             children: [
//               // Header
//               pw.Container(
//                 padding: const pw.EdgeInsets.all(16),
//                 decoration: pw.BoxDecoration(
//                   color: const PdfColor.fromInt(0xFF1E6F5C),
//                   borderRadius: pw.BorderRadius.circular(8),
//                 ),
//                 child: pw.Row(
//                   mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
//                   children: [
//                     pw.Column(
//                       crossAxisAlignment: pw.CrossAxisAlignment.start,
//                       children: [
//                         pw.Text("Monthly Report", style: pw.TextStyle(color: PdfColors.white, fontSize: 24, fontWeight: pw.FontWeight.bold)),
//                         pw.SizedBox(height: 4),
//                         pw.Text("Generated on ${now.day} ${_currentMonth(now.month, now.year)}", style: const pw.TextStyle(color: PdfColors.white, fontSize: 12)),
//                       ]
//                     ),
//                     pw.Text(_currentMonth(now.month, now.year), style: pw.TextStyle(color: PdfColors.white, fontSize: 18, fontWeight: pw.FontWeight.bold)),
//                   ]
//                 )
//               ),
//               pw.SizedBox(height: 20),

//               // Summary Cards
//               pw.Row(
//                 mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
//                 children: [
//                   _pdfSummaryCard("Total Income", tmIncome, const PdfColor.fromInt(0xFF0033B9), const PdfColor.fromInt(0xFFCBEBFF)),
//                   _pdfSummaryCard("Total Expense", tmExpense, const PdfColor.fromInt(0xFF990000), const PdfColor.fromInt(0xFFFFCCCC)),
//                   _pdfSummaryCard("Total Saving", tmSaving, const PdfColor.fromInt(0xFF006600), const PdfColor.fromInt(0xFFCCFFCC)),
//                 ]
//               ),
//               pw.SizedBox(height: 20),

//               // Warning Box
//               if (expensePercent > 75) ...[
//                 pw.Container(
//                   width: double.infinity,
//                   padding: const pw.EdgeInsets.all(12),
//                   decoration: pw.BoxDecoration(
//                     color: const PdfColor.fromInt(0xFFFFF4F4),
//                     border: pw.Border.all(color: const PdfColor.fromInt(0xFFFFCCCC)),
//                     borderRadius: pw.BorderRadius.circular(8),
//                   ),
//                   child: pw.Text(
//                     "Warning: You used ${expensePercent.toStringAsFixed(0)}% of your monthly budget! Consider reducing unnecessary expenses.",
//                     style: pw.TextStyle(color: const PdfColor.fromInt(0xFF990000), fontWeight: pw.FontWeight.bold),
//                   ),
//                 ),
//                 pw.SizedBox(height: 20),
//               ],

//               // Transactions
//               pw.Text("Transactions", style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
//               pw.SizedBox(height: 10),
//               if (topTxs.isEmpty)
//                 pw.Text("No transactions this month.")
//               else
//                 pw.Column(
//                   children: topTxs.map((tx) {
//                     return pw.Container(
//                       margin: const pw.EdgeInsets.only(bottom: 8),
//                       padding: const pw.EdgeInsets.all(10),
//                       decoration: pw.BoxDecoration(
//                         border: pw.Border.all(color: PdfColors.grey300),
//                         borderRadius: pw.BorderRadius.circular(6),
//                       ),
//                       child: pw.Row(
//                         mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
//                         children: [
//                           pw.Expanded(
//                             child: pw.Column(
//                               crossAxisAlignment: pw.CrossAxisAlignment.start,
//                               children: [
//                                 pw.Text(tx.description.toUpperCase(), style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12)),
//                                 pw.SizedBox(height: 4),
//                                 pw.Text("${tx.isCredit ? 'Credit' : 'Debit'} * ${tx.date.day}/${tx.date.month}/${tx.date.year}", style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey600)),
//                               ],
//                             ),
//                           ),
//                           pw.SizedBox(width: 8),
//                           pw.Text(
//                             "${tx.isCredit ? '+' : '-'} Rs.${tx.amount.toInt()}",
//                             style: pw.TextStyle(
//                               color: tx.isCredit ? const PdfColor.fromInt(0xFF006600) : const PdfColor.fromInt(0xFF990000),
//                               fontWeight: pw.FontWeight.bold,
//                             ),
//                           ),
//                         ]
//                       )
//                     );
//                   }).toList(),
//                 ),
//               pw.SizedBox(height: 20),

//               // Spending Trend (Weekly Chart)
//               pw.Text("Spending Trend", style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
//               pw.SizedBox(height: 10),
//               pw.Container(
//                 height: 150,
//                 padding: const pw.EdgeInsets.all(16),
//                 decoration: pw.BoxDecoration(
//                   border: pw.Border.all(color: PdfColors.grey300),
//                   borderRadius: pw.BorderRadius.circular(8),
//                 ),
//                 child: pw.Row(
//                   crossAxisAlignment: pw.CrossAxisAlignment.end,
//                   mainAxisAlignment: pw.MainAxisAlignment.spaceEvenly,
//                   children: List.generate(5, (i) {
//                     double barHeight = (weeks[i] / maxWeekly) * 100;
//                     if (barHeight < 2 && weeks[i] > 0) barHeight = 2;
//                     return pw.Column(
//                       mainAxisAlignment: pw.MainAxisAlignment.end,
//                       children: [
//                         if (weeks[i] > 0)
//                           pw.Text("Rs.${weeks[i].toInt()}", style: const pw.TextStyle(fontSize: 8)),
//                         pw.SizedBox(height: 4),
//                         pw.Container(
//                           width: 25,
//                           height: barHeight,
//                           color: const PdfColor.fromInt(0xFF4B8BFF),
//                         ),
//                         pw.SizedBox(height: 6),
//                         pw.Text("Week ${i + 1}", style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
//                       ]
//                     );
//                   }),
//                 )
//               ),
//             ]
//           );
//         }
//       ),
//     );
//     final directory = Directory("/storage/emulated/0/Download");
//     if (!await directory.exists()) await directory.create(recursive: true);
//     final file = File("${directory.path}/BudgetBee_${DateTime.now().millisecondsSinceEpoch}.pdf");
//     await file.writeAsBytes(await pdf.save());
//     return file;
//   }

//   pw.Widget _pdfSummaryCard(String title, double amount, PdfColor textColor, PdfColor bgColor) {
//     return pw.Container(
//       width: 155,
//       padding: const pw.EdgeInsets.symmetric(vertical: 12, horizontal: 8),
//       decoration: pw.BoxDecoration(
//         color: bgColor,
//         borderRadius: pw.BorderRadius.circular(8),
//         border: pw.Border.all(color: PdfColors.grey300),
//       ),
//       child: pw.Column(
//         children: [
//           pw.Text(title, style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: PdfColors.black)),
//           pw.SizedBox(height: 6),
//           pw.Text("Rs.${amount.toInt()}", style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, color: textColor)),
//         ]
//       )
//     );
//   }

//   Future<void> _sharePdf() async {
//     try {
//       final file = await _generatePdf();
//       await Share.shareXFiles([XFile(file.path)], text: "My BudgetBee Monthly Report");
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Error sharing PDF")));
//     }
//   }

//   String _currentMonth(int m, int y) {
//     const months=["", "January","February","March","April","May","June","July","August","September","October","November","December"];
//     return "${months[m]} $y";
//   }
// }

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:pdf/widgets.dart' as pw;
import '../widgets/chatbot_fab.dart';
import '../globals.dart';
import 'package:pdf/pdf.dart';
import 'package:permission_handler/permission_handler.dart';

class MonthlyData {
  final DateTime date;
  final String label;
  final double income;
  final double expense;
  MonthlyData(this.date, this.label, this.income, this.expense);
  double get saving => income - expense;
  int get healthScore {
    if (income == 0) return expense == 0 ? 100 : 0;
    double per = (expense / income) * 100;
    int score = (100 - per).round();
    return score.clamp(0, 100);
  }
}

class MonthlyReportScreen extends StatefulWidget {
  const MonthlyReportScreen({super.key});

  @override
  State<MonthlyReportScreen> createState() => _MonthlyReportScreenState();
}

class _MonthlyReportScreenState extends State<MonthlyReportScreen> {
  bool compareMode = false;

  @override
  Widget build(BuildContext context) {
    // Current month calculations
    double tmIncome = totalCredit;
    double tmExpense = totalDebit;
    double tmSaving = totalCredit - totalDebit;

    // 3 Months Calculations
    final now = DateTime.now();
    List<MonthlyData> mDataList = [];
    
    for (int i = 2; i >= 0; i--) {
      int targetMonth = now.month - i;
      int targetYear = now.year;
      if (targetMonth <= 0) {
        targetMonth += 12;
        targetYear -= 1;
      }
      
      double mIncome = 0;
      double mExpense = 0;

      for (var tx in allTransactions) {
        if (tx.date.year == targetYear && tx.date.month == targetMonth) {
          if (tx.isCredit) {
            mIncome += tx.amount;
          } else {
            mExpense += tx.amount;
          }
        }
      }

      final months = ["", "Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];
      String label = "${months[targetMonth]}";
      
      mDataList.add(MonthlyData(DateTime(targetYear, targetMonth, 1), label, mIncome, mExpense));
    }

    double compIncome = mDataList.fold(0, (sum, item) => sum + item.income);
    double compExpense = mDataList.fold(0, (sum, item) => sum + item.expense);
    double compSaving = compIncome - compExpense;

    double activeIncome = compareMode ? compIncome : tmIncome;
    double activeExpense = compareMode ? compExpense : tmExpense;
    double activeSaving = compareMode ? compSaving : tmSaving;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F8FB),
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: const Color(0xFF1E6F5C),
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Monthly Report",
              style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 2),
            Text(
              "Generated on ${now.day} ${_currentMonth(now.month, now.year)}",
              style: const TextStyle(color: Colors.white70, fontSize: 13),
            ),
          ],
        ),
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Text(
                _currentMonth(now.month, now.year),
                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 16),
              ),
            ),
          )
        ],
      ),
      floatingActionButton: const ChatbotFab(),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/images/bd_whatsapp.jpeg"),
                fit: BoxFit.cover,
                opacity: 0.6,
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  
                  // TOGGLE BUTTONS
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: Colors.grey.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => compareMode = false),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              decoration: BoxDecoration(
                                color: compareMode ? Colors.transparent : const Color(0xFF1E6F5C),
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: Center(
                                child: Text(
                                  "This Month",
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: compareMode ? Colors.black87 : Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => compareMode = true),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              decoration: BoxDecoration(
                                color: compareMode ? const Color(0xFF1E6F5C) : Colors.transparent,
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: Center(
                                child: Text(
                                  "Compare 3 Months",
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: compareMode ? Colors.white : Colors.black87,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // TOP 3 STATS
                  Row(
                    children: [
                      Expanded(
                        child: _modernCard("Total Income", activeIncome, const Color(0xFFCBEBFF), const Color(0xFF0033B9)),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _modernCard("Total Expense", activeExpense, const Color(0xFFFFCCCC), const Color(0xFF990000)),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _modernCard("Total Saving", activeSaving, const Color(0xFFCCFFCC), const Color(0xFF006600)),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  if (!compareMode) ...[
                    // THIS MONTH VIEW
                    _sectionCard(
                      title: "Top Transactions",
                      child: Column(
                        children: _topTransactionsUI(),
                      ),
                    ),
                    const SizedBox(height: 20),
                    _sectionCard(
                      title: "Spending Trend",
                      child: SizedBox(
                        height: 220,
                        child: _buildWeeklyChart(),
                      ),
                    ),
                    const SizedBox(height: 20),
                    _warningBox(tmExpense, tmIncome),
                    
                    const SizedBox(height: 30),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF007BFF),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        icon: const Icon(Icons.share, color: Colors.white),
                        label: const Text("Share Report", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                        onPressed: () async {
                          await _sharePdf();
                        },
                      ),
                    ),
                    const SizedBox(height: 30),
                  ] else ...[
                    // COMPARE 3 MONTHS VIEW
                    _sectionCard(
                      title: "Compare 3 Months",
                      child: SizedBox(
                        height: 250,
                        child: _buildGroupedBarChart(mDataList),
                      ),
                    ),
                    const SizedBox(height: 20),
                    _dataTableCard(mDataList),
                    const SizedBox(height: 20),
                    _sectionCard(
                      title: "Last 3 Months Expense Breakdown",
                      child: SizedBox(
                        height: 280,
                        child: _buildDetailedPieChart(mDataList),
                      ),
                    ),
                    const SizedBox(height: 30),
                  ],
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _modernCard(String title, double amount, Color bgColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4),
        ]
      ),
      child: Column(
        children: [
          Text(title, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.black87), textAlign: TextAlign.center),
          const SizedBox(height: 6),
          Text(
            "₹${amount.toInt()}",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: textColor),
          ),
        ],
      ),
    );
  }

  Widget _sectionCard({required String title, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4)],
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  // --- THIS MONTH METHODS ---
  List<Widget> _topTransactionsUI() {
    final sorted = allTransactions.where((tx) => tx.date.month == DateTime.now().month && tx.date.year == DateTime.now().year).toList();
    sorted.sort((a,b)=>b.amount.compareTo(a.amount));
    
    if (sorted.isEmpty) return [const Text("No transactions this month.")];

    return sorted.take(3).map((tx){
      return Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.grey.withOpacity(0.2)),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: const Color(0xFFFFE0E0),
              radius: 18,
              child: const Icon(Icons.arrow_upward, color: Colors.red, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(tx.description.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                  const SizedBox(height: 4),
                  Text("${tx.isCredit ? 'Credit' : 'Debit'} • ${tx.date.day}/${tx.date.month}/${tx.date.year}", style: const TextStyle(fontSize: 11, color: Colors.grey)),
                ],
              ),
            ),
            Text(
              "${tx.isCredit ? '+' : '-'} ₹${tx.amount.toInt()}",
              style: TextStyle(color: tx.isCredit ? Colors.green : Colors.red, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      );
    }).toList();
  }

  Widget _warningBox(double expense, double income) {
    double per = income == 0 ? 0 : (expense / income) * 100;
    
    if (per > 75) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF4F4),
          border: Border.all(color: const Color(0xFFFFCCCC)),
          borderRadius: BorderRadius.circular(8),
        ),
        child: RichText(
          text: TextSpan(
            style: const TextStyle(color: Colors.black87),
            children: [
              const TextSpan(text: "⚠️ Warning: ", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
              TextSpan(text: "You used ${per.toStringAsFixed(0)}% of your monthly budget! Consider reducing your shopping expenses."),
            ]
          ),
        ),
      );
    } else {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFF4FFF4),
          border: Border.all(color: const Color(0xFFCCFFCC)),
          borderRadius: BorderRadius.circular(8),
        ),
        child: RichText(
          text: TextSpan(
            style: const TextStyle(color: Colors.black87),
            children: [
              const TextSpan(text: "✅ Great Job: ", style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
              TextSpan(text: "You only used ${per.toStringAsFixed(0)}% of your monthly budget! Keep saving."),
            ]
          ),
        ),
      );
    }
  }

  Widget _buildWeeklyChart() {
    List<double> weeks = [0,0,0,0,0];
    final now = DateTime.now();

    for(final tx in allTransactions){
      if(!tx.isCredit && tx.date.month == now.month && tx.date.year == now.year){
        int week = ((tx.date.day-1)/7).floor();
        if(week < 5){
          weeks[week] += tx.amount;
        }
      }
    }

    double maxVal = weeks.reduce((a, b) => a > b ? a : b);
    maxVal = maxVal == 0 ? 1000 : maxVal * 1.5;

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: maxVal,
        barTouchData: BarTouchData(
          enabled: false,
          touchTooltipData: BarTouchTooltipData(
            getTooltipColor: (_) => Colors.transparent,
            tooltipPadding: EdgeInsets.zero,
            tooltipMargin: 4,
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              if (rod.toY == 0) return null;
              return BarTooltipItem(
                "₹${rod.toY.toInt()}",
                const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 10),
              );
            },
          ),
        ),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                return Text("Week ${value.toInt() + 1}", style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold));
              },
            ),
          ),
          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false),
        barGroups: List.generate(
          5,
          (i) => BarChartGroupData(
            x: i,
            showingTooltipIndicators: [0],
            barRods: [
              BarChartRodData(
                toY: weeks[i],
                width: 28,
                color: const Color(0xFF4B8BFF),
                borderRadius: const BorderRadius.only(topLeft: Radius.circular(4), topRight: Radius.circular(4)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- COMPARE 3 MONTHS METHODS ---
  Widget _buildGroupedBarChart(List<MonthlyData> mDataList) {
    double maxVal = 0;
    for (var d in mDataList) {
      if (d.income > maxVal) maxVal = d.income;
      if (d.expense > maxVal) maxVal = d.expense;
    }
    maxVal = maxVal == 0 ? 1000 : maxVal * 1.3;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(width: 10, height: 10, color: const Color(0xFF007BFF)),
            const SizedBox(width: 4),
            const Text("Income", style: TextStyle(fontSize: 12)),
            const SizedBox(width: 16),
            Container(width: 10, height: 10, color: const Color(0xFFFF4B4B)),
            const SizedBox(width: 4),
            const Text("Expense", style: TextStyle(fontSize: 12)),
          ],
        ),
        const SizedBox(height: 16),
        Expanded(
          child: BarChart(
            BarChartData(
              maxY: maxVal,
              alignment: BarChartAlignment.spaceAround,
              titlesData: FlTitlesData(
                show: true,
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      return Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(mDataList[value.toInt()].label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      );
                    },
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 40,
                    getTitlesWidget: (value, meta) {
                      if (value == 0) return const Text("0");
                      if (value % 5000 != 0 && value % 10000 != 0) return const SizedBox.shrink();
                      return Text("${(value).toInt()}", style: const TextStyle(fontSize: 10));
                    },
                  ),
                ),
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
              borderData: FlBorderData(
                show: true,
                border: const Border(bottom: BorderSide(color: Colors.black12), left: BorderSide(color: Colors.black12)),
              ),
              gridData: const FlGridData(show: false),
              barTouchData: BarTouchData(
                enabled: false,
                touchTooltipData: BarTouchTooltipData(
                  getTooltipColor: (_) => Colors.transparent,
                  tooltipPadding: EdgeInsets.zero,
                  tooltipMargin: 6,
                  getTooltipItem: (group, groupIndex, rod, rodIndex) {
                    if (rod.toY == 0) return null;
                    return BarTooltipItem(
                      "₹${rod.toY.toInt()}",
                      const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 9),
                    );
                  },
                ),
              ),
              barGroups: List.generate(
                mDataList.length,
                (i) => BarChartGroupData(
                  x: i,
                  barsSpace: 4,
                  showingTooltipIndicators: [0, 1],
                  barRods: [
                    BarChartRodData(
                      toY: mDataList[i].income,
                      width: 24,
                      color: const Color(0xFF007BFF),
                      borderRadius: BorderRadius.zero,
                    ),
                    BarChartRodData(
                      toY: mDataList[i].expense,
                      width: 24,
                      color: const Color(0xFFFF4B4B),
                      borderRadius: BorderRadius.zero,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _dataTableCard(List<MonthlyData> mDataList) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4)],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: DataTable(
          horizontalMargin: 12,
          columnSpacing: 10,
          headingRowColor: MaterialStateProperty.all(Colors.grey.shade100),
          columns: const [
            DataColumn(label: Text("Month", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11))),
            DataColumn(label: Text("Income", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11))),
            DataColumn(label: Text("Expense", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11))),
            DataColumn(label: Text("Savings", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11))),
            DataColumn(label: Text("Health", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11))),
          ],
          rows: mDataList.map((m) {
            return DataRow(
              cells: [
                DataCell(Text("${m.label} ${m.date.year}", style: const TextStyle(fontSize: 11))),
                DataCell(Text("₹${m.income.toInt()}", style: const TextStyle(fontSize: 11))),
                DataCell(Text("₹${m.expense.toInt()}", style: const TextStyle(fontSize: 11))),
                DataCell(Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text("₹${m.saving.toInt()}", style: const TextStyle(fontSize: 11)),
                    Icon(m.saving >= 0 ? Icons.arrow_drop_up : Icons.arrow_drop_down, color: m.saving >= 0 ? Colors.green : Colors.red, size: 16),
                  ],
                )),
                DataCell(Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text("${m.healthScore}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
                    const SizedBox(width: 4),
                    Text(m.healthScore >= 70 ? "Good" : "Poor", style: TextStyle(color: m.healthScore >= 70 ? Colors.green : Colors.red, fontSize: 10)),
                  ],
                )),
              ]
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildDetailedPieChart(List<MonthlyData> mDataList) {
    final colors = [const Color(0xFF0033B9), const Color(0xFFFF9900), const Color(0xFF00AACC)];
    
    double totalAll = mDataList.fold(0, (s, e) => s + e.expense);
    if (totalAll == 0) return const Center(child: Text("No expenses to chart."));

    return Column(
      children: [
        Expanded(
          child: Stack(
            alignment: Alignment.center,
            children: [
              PieChart(
                PieChartData(
                  sectionsSpace: 0,
                  centerSpaceRadius: 0,
                  sections: List.generate(mDataList.length, (i) {
                    final d = mDataList[i];
                    double per = (d.expense / totalAll) * 100;
                    return PieChartSectionData(
                      value: per,
                      color: colors[i % colors.length],
                      title: "${per.toStringAsFixed(0)}%",
                      radius: 90,
                      titlePositionPercentageOffset: 1.3,
                      titleStyle: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 13),
                    );
                  }),
                )
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(mDataList.length, (i) {
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(width: 10, height: 10, decoration: BoxDecoration(color: colors[i % colors.length], shape: BoxShape.circle)),
                const SizedBox(width: 4),
                Text(mDataList[i].label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                const SizedBox(width: 16),
              ],
            );
          }),
        ),
      ],
    );
  }

  // --- UTILS ---
  Future<File> _generatePdf() async {
    final pdf = pw.Document();
    final now = DateTime.now();

    double tmIncome = totalCredit;
    double tmExpense = totalDebit;
    double tmSaving = tmIncome - tmExpense;
    double expensePercent = tmIncome == 0 ? 0 : (tmExpense / tmIncome) * 100;

    final sortedTxs = allTransactions.where((tx) => tx.date.month == now.month && tx.date.year == now.year).toList();
    sortedTxs.sort((a,b)=>b.amount.compareTo(a.amount));
    final topTxs = sortedTxs.take(3).toList();

    List<double> weeks = [0,0,0,0,0];
    for(final tx in allTransactions){
      if(!tx.isCredit && tx.date.month == now.month && tx.date.year == now.year){
        int week = ((tx.date.day-1)/7).floor();
        if(week < 5){
          weeks[week] += tx.amount;
        }
      }
    }
    double maxWeekly = 0;
    if (weeks.isNotEmpty) {
      maxWeekly = weeks.reduce((a, b) => a > b ? a : b);
    }
    if(maxWeekly == 0) maxWeekly = 1000;

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header
              pw.Container(
                padding: const pw.EdgeInsets.all(16),
                decoration: pw.BoxDecoration(
                  color: const PdfColor.fromInt(0xFF1E6F5C),
                  borderRadius: pw.BorderRadius.circular(8),
                ),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text("Monthly Report", style: pw.TextStyle(color: PdfColors.white, fontSize: 24, fontWeight: pw.FontWeight.bold)),
                        pw.SizedBox(height: 4),
                        pw.Text("Generated on ${now.day} ${_currentMonth(now.month, now.year)}", style: const pw.TextStyle(color: PdfColors.white, fontSize: 12)),
                      ]
                    ),
                    pw.Text(_currentMonth(now.month, now.year), style: pw.TextStyle(color: PdfColors.white, fontSize: 18, fontWeight: pw.FontWeight.bold)),
                  ]
                )
              ),
              pw.SizedBox(height: 20),

              // Summary Cards
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  _pdfSummaryCard("Total Income", tmIncome, const PdfColor.fromInt(0xFF0033B9), const PdfColor.fromInt(0xFFCBEBFF)),
                  _pdfSummaryCard("Total Expense", tmExpense, const PdfColor.fromInt(0xFF990000), const PdfColor.fromInt(0xFFFFCCCC)),
                  _pdfSummaryCard("Total Saving", tmSaving, const PdfColor.fromInt(0xFF006600), const PdfColor.fromInt(0xFFCCFFCC)),
                ]
              ),
              pw.SizedBox(height: 20),

              // Warning Box
              if (expensePercent > 75) ...[
                pw.Container(
                  width: double.infinity,
                  padding: const pw.EdgeInsets.all(12),
                  decoration: pw.BoxDecoration(
                    color: const PdfColor.fromInt(0xFFFFF4F4),
                    border: pw.Border.all(color: const PdfColor.fromInt(0xFFFFCCCC)),
                    borderRadius: pw.BorderRadius.circular(8),
                  ),
                  child: pw.Text(
                    "Warning: You used ${expensePercent.toStringAsFixed(0)}% of your monthly budget! Consider reducing unnecessary expenses.",
                    style: pw.TextStyle(color: const PdfColor.fromInt(0xFF990000), fontWeight: pw.FontWeight.bold),
                  ),
                ),
                pw.SizedBox(height: 20),
              ],

              // Top Transactions
              pw.Text("Top Transactions", style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 10),
              if (topTxs.isEmpty)
                pw.Text("No transactions this month.")
              else
                pw.Column(
                  children: topTxs.map((tx) {
                    return pw.Container(
                      margin: const pw.EdgeInsets.only(bottom: 8),
                      padding: const pw.EdgeInsets.all(10),
                      decoration: pw.BoxDecoration(
                        border: pw.Border.all(color: PdfColors.grey300),
                        borderRadius: pw.BorderRadius.circular(6),
                      ),
                      child: pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Expanded(
                            child: pw.Column(
                              crossAxisAlignment: pw.CrossAxisAlignment.start,
                              children: [
                                pw.Text(tx.description.toUpperCase(), style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12)),
                                pw.SizedBox(height: 4),
                                pw.Text("${tx.isCredit ? 'Credit' : 'Debit'} * ${tx.date.day}/${tx.date.month}/${tx.date.year}", style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey600)),
                              ],
                            ),
                          ),
                          pw.SizedBox(width: 8),
                          pw.Text(
                            "${tx.isCredit ? '+' : '-'} Rs.${tx.amount.toInt()}",
                            style: pw.TextStyle(
                              color: tx.isCredit ? const PdfColor.fromInt(0xFF006600) : const PdfColor.fromInt(0xFF990000),
                              fontWeight: pw.FontWeight.bold,
                            ),
                          ),
                        ]
                      )
                    );
                  }).toList(),
                ),
              pw.SizedBox(height: 20),

              // Spending Trend (Weekly Chart)
              pw.Text("Spending Trend", style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 10),
              pw.Container(
                height: 180,
                padding: const pw.EdgeInsets.all(16),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.grey300),
                  borderRadius: pw.BorderRadius.circular(8),
                ),
                child: pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  mainAxisAlignment: pw.MainAxisAlignment.spaceEvenly,
                  children: List.generate(5, (i) {
                    double barHeight = (weeks[i] / maxWeekly) * 80;
                    if (barHeight < 2 && weeks[i] > 0) barHeight = 2;
                    return pw.Column(
                      mainAxisAlignment: pw.MainAxisAlignment.end,
                      children: [
                        if (weeks[i] > 0)
                          pw.Text("Rs.${weeks[i].toInt()}", style: pw.TextStyle(fontSize: 9, color: PdfColors.black, fontWeight: pw.FontWeight.bold)),
                        pw.SizedBox(height: 4),
                        pw.Container(
                          width: 28,
                          height: barHeight == 0 ? 1 : barHeight,
                          color: weeks[i] > 0 ? const PdfColor.fromInt(0xFF4B8BFF) : null,
                        ),
                        pw.SizedBox(height: 6),
                        pw.Text("Week ${i + 1}", style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: PdfColors.black)),
                      ]
                    );
                  }),
                )
              ),
            ]
          );
        }
      ),
    );
    final directory = Directory("/storage/emulated/0/Download");
    if (!await directory.exists()) await directory.create(recursive: true);
    final file = File("${directory.path}/BudgetBee_${DateTime.now().millisecondsSinceEpoch}.pdf");
    await file.writeAsBytes(await pdf.save());
    return file;
  }

  pw.Widget _pdfSummaryCard(String title, double amount, PdfColor textColor, PdfColor bgColor) {
    return pw.Container(
      width: 155,
      padding: const pw.EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: pw.BoxDecoration(
        color: bgColor,
        borderRadius: pw.BorderRadius.circular(8),
        border: pw.Border.all(color: PdfColors.grey300),
      ),
      child: pw.Column(
        children: [
          pw.Text(title, style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: PdfColors.black)),
          pw.SizedBox(height: 6),
          pw.Text("Rs.${amount.toInt()}", style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, color: textColor)),
        ]
      )
    );
  }

  Future<void> _sharePdf() async {
    try {
      final file = await _generatePdf();
      await Share.shareXFiles([XFile(file.path)], text: "My BudgetBee Monthly Report");
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Error sharing PDF")));
    }
  }

  String _currentMonth(int m, int y) {
    const months=["", "January","February","March","April","May","June","July","August","September","October","November","December"];
    return "${months[m]} $y";
  }
}