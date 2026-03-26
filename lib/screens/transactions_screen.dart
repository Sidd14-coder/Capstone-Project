// import 'package:flutter/material.dart';
// import 'package:telephony/telephony.dart';
// import '../globals.dart';
// import '../services/emi_service.dart';
// import '../services/emi_payment_service.dart';
// import '../models/emi_payment_model.dart';
// import 'package:hive/hive.dart';

// /* =========================================================
//    TRANSACTION PARSER (STRICT – NO FALSE POSITIVES)
//    ========================================================= */

// class ParsedTransaction {
//   final bool isDebit;
//   final double amount;
//   final String merchant;

//   ParsedTransaction({
//     required this.isDebit,
//     required this.amount,
//     required this.merchant,
//   });
// }

// ParsedTransaction? parseTransactionSMS(String bodyRaw) {
//   final body = bodyRaw.toUpperCase();

//   final debitRegex = RegExp(
//     r'\b(DEBIT(?:ED)?|DR\b|WITHDRAWN|SPENT|PURCHASE|PAID|SENT|UPI-DR|DBT)\b',
//   );

//   final creditRegex = RegExp(
//     r'\b(CREDIT(?:ED)?|CR\b|RECEIVED|REFUND|CASHBACK|REVERSAL|UPI-CR)\b',
//   );

//   bool? isDebit;

//   if (debitRegex.hasMatch(body)) isDebit = true;
//   if (creditRegex.hasMatch(body)) isDebit = false;

//   if (isDebit == null) return null;

//   final amountRegex = RegExp(
//     r'(?:RS\.?|INR|₹)\s*([\d,]+(?:\.\d{1,2})?)',
//     caseSensitive: false,
//   );

//   final amtMatch = amountRegex.firstMatch(body.replaceAll(',', ''));
//   if (amtMatch == null) return null;

//   final amount = double.tryParse(amtMatch.group(1) ?? '');
//   if (amount == null || amount <= 0) return null;

//   final knownMerchants = [
//     'AMAZON','FLIPKART','SWIGGY','ZOMATO','PAYTM',
//     'GPAY','PHONEPE','OLA','UBER','IRCTC',
//     'DMART','RELIANCE','NETFLIX','SPOTIFY',
//   ];

//   for (final m in knownMerchants) {
//     if (body.contains(m)) {
//       return ParsedTransaction(isDebit: isDebit, amount: amount, merchant: m);
//     }
//   }

//   final merchantPatterns = [
//     RegExp(r'AT\s+([A-Z0-9&\-\s]{3,})'),
//     RegExp(r'TO\s+([A-Z0-9&\-\s]{3,})'),
//     RegExp(r'FROM\s+([A-Z0-9&\-\s]{3,})'),
//   ];

//   for (final p in merchantPatterns) {
//     final m = p.firstMatch(body);
//     if (m != null) {
//       final name = m.group(1)!.trim();
//       if (!name.contains('ACCOUNT') && name.length > 2) {
//         return ParsedTransaction(
//           isDebit: isDebit,
//           amount: amount,
//           merchant: name,
//         );
//       }
//     }
//   }

//   return ParsedTransaction(
//     isDebit: isDebit,
//     amount: amount,
//     merchant: 'BANK TRANSACTION',
//   );
// }

// bool isEmiPayment(String bodyRaw) {

//   final body = bodyRaw.toUpperCase();

//   final emiKeywords = [
//     'EMI',
//     'INSTALLMENT',
//     'LOAN REPAYMENT',
//     'LOAN PAYMENT',
//     'ECS',
//   ];

//   for (final k in emiKeywords) {
//     if (body.contains(k)) {
//       return true;
//     }
//   }

//   return false;
// }

// /* =========================================================
//    TRANSACTIONS SCREEN
//    ========================================================= */

// class TransactionsScreen extends StatefulWidget {
//   const TransactionsScreen({super.key});

//   @override
//   State<TransactionsScreen> createState() => _TransactionsScreenState();
// }

// class _TransactionsScreenState extends State<TransactionsScreen> {
//   final Telephony telephony = Telephony.instance;

//   List<SmsMessage> messages = [];
//   bool isLoading = true;

//   Set<String> detectedBanks = {};
//   String? selectedBank;
//   bool showAccounts = false;

//   @override
//   void initState() {
//     super.initState();
//     loadSms();
//   }

//   String extractBankName(SmsMessage msg) {
//   final sender = (msg.address ?? '').toUpperCase();

//   if (sender.contains('BOI')) return 'Bank of India';
//   if (sender.contains('SBI')) return 'State Bank of India';
//   if (sender.contains('HDFC')) return 'HDFC Bank';
//   if (sender.contains('ICICI')) return 'ICICI Bank';
//   if (sender.contains('AXIS')) return 'Axis Bank';
//   if (sender.contains('KOTAK')) return 'Kotak Mahindra Bank';
//   if (sender.contains('IDFC')) return 'IDFC First Bank';
//   if (sender.contains('PNB')) return 'Punjab National Bank';
//   if (sender.contains('CANARA')) return 'Canara Bank';
//   if (sender.contains('UNION')) return 'Union Bank of India';
//   if (sender.contains('INDIANBANK')) return 'Indian Bank';
//   if (sender.contains('IOB')) return 'Indian Overseas Bank';
//   if (sender.contains('CENTRAL')) return 'Central Bank of India';
//   if (sender.contains('UCO')) return 'UCO Bank';
//   if (sender.contains('YES')) return 'Yes Bank';
//   if (sender.contains('RBL')) return 'RBL Bank';
//   if (sender.contains('FEDERAL')) return 'Federal Bank';
//   if (sender.contains('IDBI')) return 'IDBI Bank';
//   if (sender.contains('HSBC')) return 'HSBC Bank';
//   if (sender.contains('DBS')) return 'DBS Bank';
//   if (sender.contains('DEUTSCHE')) return 'Deutsche Bank';
//   if (sender.contains('STANDARD')) return 'Standard Chartered Bank';
//   if (sender.contains('BARCLAYS')) return 'Barclays Bank';
//   if (sender.contains('BNP')) return 'BNP Paribas Bank';

//   // 🏦 Payments Banks
//   if (sender.contains('IPPB') || sender.contains('IPB')) {
//     return 'India Post Payments Bank';
//   }
//   if (sender.contains('PAYTM')) return 'Paytm Payments Bank';
//   if (sender.contains('FINO')) return 'Fino Payments Bank';
//   if (sender.contains('NSDL')) return 'NSDL Payments Bank';
//   if (sender.contains('AIRTEL')) return 'Airtel Payments Bank';
//   if (sender.contains('JIO')) return 'Jio Payments Bank';

//   // 🏦 Small Finance Banks
//   if (sender.contains('UJJIVAN')) return 'Ujjivan Small Finance Bank';
//   if (sender.contains('EQUITAS')) return 'Equitas Small Finance Bank';
//   if (sender.contains('SURYODAY')) return 'Suryoday Small Finance Bank';
//   if (sender.contains('ESAF')) return 'ESAF Small Finance Bank';
//   if (sender.contains('AU')) return 'AU Small Finance Bank';
//   if (sender.contains('JANASMALL')) return 'Jana Small Finance Bank';
//   if (sender.contains('CAPITAL')) return 'Capital Small Finance Bank';

//   // 🏦 State / Co-operative Banks
//   if (sender.contains('MAHARASHTRA')) return 'Bank of Maharashtra';
//   if (sender.contains('KARNATAKA')) return 'Karnataka Bank';
//   if (sender.contains('KARUR')) return 'Karur Vysya Bank';
//   if (sender.contains('SARASWAT')) return 'Saraswat Co-operative Bank';
//   if (sender.contains('SHAMRAO')) return 'Shamrao Vithal Co-operative Bank';
//   if (sender.contains('TJSB')) return 'TJSB Sahakari Bank';
//   if (sender.contains('SOUTHDIAN') || sender.contains('SIB')) {
//     return 'South Indian Bank';
//   }
//   if (sender.contains('TAMILNAD')) return 'Tamilnad Mercantile Bank';
//   if (sender.contains('JNK') || sender.contains('JKB')) {
//     return 'Jammu & Kashmir Bank';
//   }

//   // 🧾 Slice (card based NBFC)
//   if (sender.contains('SLICE') || sender.contains('SLC')) return 'Slice';

//   // fallback
//   final parts = sender.split('-');
//   if (parts.length >= 2) {
//     return parts[1];
//   }

//   return sender;
// }

//   bool isInRange(int? ts) {
//     if (ts == null) return false;

//     final d = DateTime.fromMillisecondsSinceEpoch(ts);
//     final now = DateTime.now();

//     if (currentFilter == FilterType.weekly) {
//       return d.isAfter(now.subtract(const Duration(days: 7)));
//     }

//     final threeMonthsAgo = DateTime(now.year, now.month - 3, now.day);
//     return d.isAfter(threeMonthsAgo);
//   }

//   Future<void> loadSms() async {
//     setState(() => isLoading = true);

//     final ok = await telephony.requestSmsPermissions;
//     if (ok != true) {
//       setState(() => isLoading = false);
//       return;
//     }

//     final sms = await telephony.getInboxSms(
//       columns: [SmsColumn.BODY, SmsColumn.DATE, SmsColumn.ADDRESS],
//       sortOrder: [OrderBy(SmsColumn.DATE, sort: Sort.DESC)],
//     );

//     double debitSum = 0;
//     double creditSum = 0;

//     dailyDebitMap.clear();
//     dailyCreditMap.clear();
//     detectedBanks.clear();

//     final List<SmsMessage> filtered = [];

//     for (var msg in sms) {
//       if (!isInRange(msg.date)) continue;

//       final parsed = parseTransactionSMS(msg.body ?? '');
//       if (parsed == null) continue;

//       // ⭐ EMI detection
//   if (isEmiPayment(msg.body ?? '')) {

//   final parsed = parseTransactionSMS(msg.body ?? '');

//   if (parsed != null && parsed.isDebit) {

//     // Payment history me add
//     if (isEmiPayment(msg.body ?? '')) {

//   final parsed = parseTransactionSMS(msg.body ?? '');

//   if (parsed != null && parsed.isDebit) {

//     var emiBox = Hive.box('emiBox');
//     var historyBox = Hive.box('paymentHistory');

//     var emiList = emiBox.values.toList();

//     for (int i = 0; i < emiList.length; i++) {

//       var emi = emiList[i];

//       // 🔥 MATCH AMOUNT
//       if (parsed.amount == emi['emi']) {

//         // ✅ UPDATE EMI
//         int remaining = emi['remainingMonths'];

//         if (remaining > 0) {
//           emi['remainingMonths'] = remaining - 1;

//           emiBox.putAt(i, emi);
//         }

//         // ✅ SAVE HISTORY
//         historyBox.add({
//           "name": emi['name'],
//           "amount": parsed.amount,
//           "date": DateTime.fromMillisecondsSinceEpoch(msg.date!).toString(),
//         });

//         break;
//       }
//     }
//   }
// }

//   }
// }
//       final bankName = extractBankName(msg);
//       detectedBanks.add(bankName);

//       final dateTime = DateTime.fromMillisecondsSinceEpoch(msg.date!);
//       final day = DateTime(dateTime.year, dateTime.month, dateTime.day);

//       if (parsed.isDebit) {
//         debitSum += parsed.amount;
//         dailyDebitMap[day] = (dailyDebitMap[day] ?? 0) + parsed.amount;
//       } else {
//         creditSum += parsed.amount;
//         dailyCreditMap[day] = (dailyCreditMap[day] ?? 0) + parsed.amount;
//       }

//       filtered.add(msg);
//     }

//     setState(() {
//       messages = filtered;
//       totalDebit = debitSum;
//       totalCredit = creditSum;
//       globalTotalSpent = debitSum;
//       isLoading = false;
//     });
//   }

//   String _monthName(int month) {
//     const months = [
//       "January","February","March","April","May","June",
//       "July","August","September","October","November","December"
//     ];
//     return months[month - 1];
//   }

//   @override
// Widget build(BuildContext context) {
//   final displayMessages = selectedBank == null
//       ? messages
//       : messages.where((msg) {
//           final bank = extractBankName(msg);
//           return bank == selectedBank;
//         }).toList();

//   final Map<String, List<SmsMessage>> groupedMessages = {};

//   for (var msg in displayMessages) {
//     final date = DateTime.fromMillisecondsSinceEpoch(msg.date ?? 0);
//     final key = "${_monthName(date.month)} ${date.year}";
//     groupedMessages.putIfAbsent(key, () => []);
//     groupedMessages[key]!.add(msg);
//   }

//     return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: const Color(0xFFF4F8FB),
      appBar: AppBar(
        title: const Text('Transactions'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      floatingActionButton: const ChatbotFab(),
      body: Stack(
//       children: [

//         // 🖼 FULL BACKGROUND IMAGE
//         Container(
//           decoration: const BoxDecoration(
//             image: DecorationImage(
//               image: AssetImage('assets/images/bd_whatsapp.jpeg'),
//               fit: BoxFit.cover,
//             ),
//           ),
//         ),

//         // 🔵 TOP BLUE GRADIENT ONLY
//         Column(
//           children: [
//             Container(
//               height: MediaQuery.of(context).padding.top + kToolbarHeight,
//               decoration: const BoxDecoration(
//                 gradient: LinearGradient(
//                   colors: [
//                     Color(0xFF4A6CF7),
//                     Color(0xFF6A8DFF),
//                   ],
//                   begin: Alignment.topCenter,
//                   end: Alignment.bottomCenter,
//                 ),
//               ),
//             ),

//             // 📄 ORIGINAL BODY (UNCHANGED)
//             Expanded(
//               child: SafeArea(
//                 top: false,
//                 child: isLoading
//                     ? const Center(child: CircularProgressIndicator())
//                     : Column(
//                         children: [
//                           const SizedBox(height: 4),

//                           Expanded(
//                             child: Container(
//                               decoration: const BoxDecoration(
//                                 color: Colors.transparent,
//                                 borderRadius: BorderRadius.vertical(
//                                   top: Radius.circular(30),
//                                 ),
//                               ),
//                               child: Column(
//                                 children: [

//                                   Padding(
//                                     padding: const EdgeInsets.all(16),
//                                     child: ElevatedButton(
//                                       onPressed: () {
//                                         setState(() {
//                                           showAccounts = !showAccounts;
//                                         });
//                                       },
//                                       child: const Text("Accounts"),
//                                     ),
//                                   ),

//                                   if (showAccounts)
//                                     Column(
//                                       children: detectedBanks.map((bank) {
//                                         return ListTile(
//                                           title: Text(bank),
//                                           trailing: selectedBank == bank
//                                               ? const Icon(Icons.check)
//                                               : null,
//                                           onTap: () {
//                                             setState(() {
//                                               selectedBank =
//                                                   selectedBank == bank ? null : bank;
//                                               showAccounts = false;
//                                             });
//                                           },
//                                         );
//                                       }).toList(),
//                                     ),

//                                   Expanded(
//                                     child: ListView(
//                                       padding: const EdgeInsets.only(bottom: 16),
//                                       children: groupedMessages.entries.map((entry) {
//                                         final month = entry.key;
//                                         final msgs = entry.value;

//                                         return Column(
//                                           crossAxisAlignment: CrossAxisAlignment.start,
//                                           children: [

//                                             Padding(
//                                               padding: const EdgeInsets.symmetric(
//                                                   horizontal: 16, vertical: 8),
//                                               child: Text(
//                                                 month,
//                                                 style: const TextStyle(
//                                                   fontSize: 16,
//                                                   fontWeight: FontWeight.bold,
//                                                 ),
//                                               ),
//                                             ),

//                                             ...msgs.map((msg) {

//                                               final parsed =
//                                                   parseTransactionSMS(msg.body ?? '')!;
//                                               final date = DateTime.fromMillisecondsSinceEpoch(
//                                                   msg.date ?? 0);

//                                               final color = parsed.isDebit
//                                                   ? Colors.red
//                                                   : Colors.green;
//                                               final sign =
//                                                   parsed.isDebit ? '-' : '+';
//                                               final type =
//                                                   parsed.isDebit ? 'Debit' : 'Credit';

//                                               final formattedDate =
//                                                   '${date.day}/${date.month}/${date.year}';

//                                               return Container(
//   margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
//   padding: const EdgeInsets.all(14),
//   decoration: BoxDecoration(
//     color: Colors.white,
//     borderRadius: BorderRadius.circular(16),
//   ),
//   child: Material(
//     color: Colors.transparent,
//     child: ListTile(
//       contentPadding: EdgeInsets.zero,

//       leading: CircleAvatar(
//         backgroundColor: color.withOpacity(0.12),
//         child: Icon(
//           parsed.isDebit ? Icons.arrow_upward : Icons.arrow_downward,
//           color: color,
//         ),
//       ),

//       title: Text(
//         parsed.merchant,
//         style: const TextStyle(fontWeight: FontWeight.bold),
//       ),

//       subtitle: Text(
//         '$type • $formattedDate',
//         style: TextStyle(color: color, fontSize: 12),
//       ),

//       trailing: Text(
//         '$sign ₹${parsed.amount.toStringAsFixed(0)}',
//         style: TextStyle(
//           color: color,
//           fontSize: 16,
//           fontWeight: FontWeight.bold,
//         ),
//       ),

//       onTap: () {
//         showModalBottomSheet(
//           context: context,
//           isScrollControlled: true,
//           shape: const RoundedRectangleBorder(
//             borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//           ),
//           builder: (_) => SafeArea(
//             child: DraggableScrollableSheet(
//               expand: false,
//               builder: (_, controller) => SingleChildScrollView(
//                 controller: controller,
//                 padding: const EdgeInsets.all(20),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(parsed.merchant,
//                         style: const TextStyle(
//                             fontSize: 18, fontWeight: FontWeight.bold)),
//                     const SizedBox(height: 8),

//                     Text(type,
//                         style: TextStyle(
//                             color: color, fontWeight: FontWeight.bold)),
//                     const SizedBox(height: 8),

//                     Text(
//                       'Amount: $sign ₹${parsed.amount.toStringAsFixed(2)}',
//                       style: TextStyle(
//                         color: color,
//                         fontSize: 16,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                     const SizedBox(height: 8),

//                     Text('Date: $formattedDate',
//                         style: const TextStyle(color: Colors.grey)),

//                     const Divider(height: 24),

//                     const Text('Transaction Message',
//                         style: TextStyle(
//                             fontWeight: FontWeight.bold, fontSize: 14)),
//                     const SizedBox(height: 6),

//                     Text(msg.body ?? '',
//                         style: const TextStyle(fontSize: 13)),

//                     const SizedBox(height: 40),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         );
//       },
//     ),
//   ),
// );

//                                             }).toList(),
//                                           ],
//                                         );
//                                       }).toList(),
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//               ),
//             ),
//           ],
//         ),
//       ],
//     ),
//   );

// }
// }

import 'package:flutter/material.dart';
import 'package:telephony/telephony.dart';
import '../globals.dart';
import '../services/emi_service.dart';
import '../services/emi_payment_service.dart';
import '../models/emi_payment_model.dart';
import 'package:hive/hive.dart';
import '../widgets/chatbot_fab.dart';

/* =========================================================
   TRANSACTION PARSER (STRICT – NO FALSE POSITIVES)
   ========================================================= */

class ParsedTransaction {
  final bool isDebit;
  final double amount;
  final String merchant;

  ParsedTransaction({
    required this.isDebit,
    required this.amount,
    required this.merchant,
  });
}

ParsedTransaction? parseTransactionSMS(String bodyRaw) {
  final body = bodyRaw.toUpperCase();

  final debitRegex = RegExp(
    r'\b(DEBIT(?:ED)?|DR\b|WITHDRAWN|SPENT|PURCHASE|PAID|SENT|UPI-DR|DBT)\b',
  );

  final creditRegex = RegExp(
    r'\b(CREDIT(?:ED)?|CR\b|RECEIVED|REFUND|CASHBACK|REVERSAL|UPI-CR)\b',
  );

  bool? isDebit;

  if (debitRegex.hasMatch(body)) isDebit = true;
  if (creditRegex.hasMatch(body)) isDebit = false;

  if (isDebit == null) return null;

  final amountRegex = RegExp(
    r'(?:RS\.?|INR|₹)\s*([\d,]+(?:\.\d{1,2})?)',
    caseSensitive: false,
  );

  final amtMatch = amountRegex.firstMatch(body.replaceAll(',', ''));
  if (amtMatch == null) return null;

  final amount = double.tryParse(amtMatch.group(1) ?? '');
  if (amount == null || amount <= 0) return null;

  final knownMerchants = [
    'AMAZON','FLIPKART','SWIGGY','ZOMATO','PAYTM',
    'GPAY','PHONEPE','OLA','UBER','IRCTC',
    'DMART','RELIANCE','NETFLIX','SPOTIFY',
  ];

  for (final m in knownMerchants) {
    if (body.contains(m)) {
      return ParsedTransaction(isDebit: isDebit, amount: amount, merchant: m);
    }
  }

  final merchantPatterns = [
    RegExp(r'AT\s+([A-Z0-9&\-\s]{3,})'),
    RegExp(r'TO\s+([A-Z0-9&\-\s]{3,})'),
    RegExp(r'FROM\s+([A-Z0-9&\-\s]{3,})'),
  ];

  for (final p in merchantPatterns) {
    final m = p.firstMatch(body);
    if (m != null) {
      final name = m.group(1)!.trim();
      if (!name.contains('ACCOUNT') && name.length > 2) {
        return ParsedTransaction(
          isDebit: isDebit,
          amount: amount,
          merchant: name,
        );
      }
    }
  }

  return ParsedTransaction(
    isDebit: isDebit,
    amount: amount,
    merchant: 'BANK TRANSACTION',
  );
}

bool isEmiPayment(String bodyRaw) {

  final body = bodyRaw.toUpperCase();

  final emiKeywords = [
    'EMI',
    'INSTALLMENT',
    'LOAN REPAYMENT',
    'LOAN PAYMENT',
    'ECS',
  ];

  for (final k in emiKeywords) {
    if (body.contains(k)) {
      return true;
    }
  }

  return false;
}

/* =========================================================
   TRANSACTIONS SCREEN
   ========================================================= */

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  final Telephony telephony = Telephony.instance;

  List<SmsMessage> messages = [];
  bool isLoading = true;

  Set<String> detectedBanks = {};
  String? selectedBank;
  bool showAccounts = false;

  @override
  void initState() {
    super.initState();
    loadSms();
  }

  String extractBankName(SmsMessage msg) {
  final sender = (msg.address ?? '').toUpperCase();

  if (sender.contains('BOI')) return 'Bank of India';
  if (sender.contains('SBI')) return 'State Bank of India';
  if (sender.contains('HDFC')) return 'HDFC Bank';
  if (sender.contains('ICICI')) return 'ICICI Bank';
  if (sender.contains('AXIS')) return 'Axis Bank';
  if (sender.contains('KOTAK')) return 'Kotak Mahindra Bank';
  if (sender.contains('IDFC')) return 'IDFC First Bank';
  if (sender.contains('PNB')) return 'Punjab National Bank';
  if (sender.contains('CANARA')) return 'Canara Bank';
  if (sender.contains('UNION')) return 'Union Bank of India';
  if (sender.contains('INDIANBANK')) return 'Indian Bank';
  if (sender.contains('IOB')) return 'Indian Overseas Bank';
  if (sender.contains('CENTRAL')) return 'Central Bank of India';
  if (sender.contains('UCO')) return 'UCO Bank';
  if (sender.contains('YES')) return 'Yes Bank';
  if (sender.contains('RBL')) return 'RBL Bank';
  if (sender.contains('FEDERAL')) return 'Federal Bank';
  if (sender.contains('IDBI')) return 'IDBI Bank';
  if (sender.contains('HSBC')) return 'HSBC Bank';
  if (sender.contains('DBS')) return 'DBS Bank';
  if (sender.contains('DEUTSCHE')) return 'Deutsche Bank';
  if (sender.contains('STANDARD')) return 'Standard Chartered Bank';
  if (sender.contains('BARCLAYS')) return 'Barclays Bank';
  if (sender.contains('BNP')) return 'BNP Paribas Bank';

  // 🏦 Payments Banks
  if (sender.contains('IPPB') || sender.contains('IPB')) {
    return 'India Post Payments Bank';
  }
  if (sender.contains('PAYTM')) return 'Paytm Payments Bank';
  if (sender.contains('FINO')) return 'Fino Payments Bank';
  if (sender.contains('NSDL')) return 'NSDL Payments Bank';
  if (sender.contains('AIRTEL')) return 'Airtel Payments Bank';
  if (sender.contains('JIO')) return 'Jio Payments Bank';

  // 🏦 Small Finance Banks
  if (sender.contains('UJJIVAN')) return 'Ujjivan Small Finance Bank';
  if (sender.contains('EQUITAS')) return 'Equitas Small Finance Bank';
  if (sender.contains('SURYODAY')) return 'Suryoday Small Finance Bank';
  if (sender.contains('ESAF')) return 'ESAF Small Finance Bank';
  if (sender.contains('AU')) return 'AU Small Finance Bank';
  if (sender.contains('JANASMALL')) return 'Jana Small Finance Bank';
  if (sender.contains('CAPITAL')) return 'Capital Small Finance Bank';

  // 🏦 State / Co-operative Banks
  if (sender.contains('MAHARASHTRA')) return 'Bank of Maharashtra';
  if (sender.contains('KARNATAKA')) return 'Karnataka Bank';
  if (sender.contains('KARUR')) return 'Karur Vysya Bank';
  if (sender.contains('SARASWAT')) return 'Saraswat Co-operative Bank';
  if (sender.contains('SHAMRAO')) return 'Shamrao Vithal Co-operative Bank';
  if (sender.contains('TJSB')) return 'TJSB Sahakari Bank';
  if (sender.contains('SOUTHDIAN') || sender.contains('SIB')) {
    return 'South Indian Bank';
  }
  if (sender.contains('TAMILNAD')) return 'Tamilnad Mercantile Bank';
  if (sender.contains('JNK') || sender.contains('JKB')) {
    return 'Jammu & Kashmir Bank';
  }

  // 🧾 Slice (card based NBFC)
  if (sender.contains('SLICE') || sender.contains('SLC')) return 'Slice';

  // fallback
  final parts = sender.split('-');
  if (parts.length >= 2) {
    return parts[1];
  }

  return sender;
}

  bool isInRange(int? ts) {
    if (ts == null) return false;

    final d = DateTime.fromMillisecondsSinceEpoch(ts);
    final now = DateTime.now();

    if (currentFilter == FilterType.weekly) {
      return d.isAfter(now.subtract(const Duration(days: 7)));
    }

    final threeMonthsAgo = DateTime(now.year, now.month - 3, now.day);
    return d.isAfter(threeMonthsAgo);
  }

  Future<void> loadSms() async {
    setState(() => isLoading = true);

    final ok = await telephony.requestSmsPermissions;
    if (ok != true) {
      setState(() => isLoading = false);
      return;
    }

    final sms = await telephony.getInboxSms(
      columns: [SmsColumn.BODY, SmsColumn.DATE, SmsColumn.ADDRESS],
      sortOrder: [OrderBy(SmsColumn.DATE, sort: Sort.DESC)],
    );

    double debitSum = 0;
    double creditSum = 0;

    dailyDebitMap.clear();
    dailyCreditMap.clear();
    detectedBanks.clear();

    final List<SmsMessage> filtered = [];

    for (var msg in sms) {
      if (!isInRange(msg.date)) continue;

      final parsed = parseTransactionSMS(msg.body ?? '');
      if (parsed == null) continue;

      // ⭐ EMI detection
  if (isEmiPayment(msg.body ?? '')) {

  final parsed = parseTransactionSMS(msg.body ?? '');

  if (parsed != null && parsed.isDebit) {

    // Payment history me add
    if (isEmiPayment(msg.body ?? '')) {

  final parsed = parseTransactionSMS(msg.body ?? '');

  if (parsed != null && parsed.isDebit) {

    var emiBox = Hive.box('emiBox');
    var historyBox = Hive.box('paymentHistory');

    var emiList = emiBox.values.toList();

    for (int i = 0; i < emiList.length; i++) {

      var emi = emiList[i];

      // 🔥 MATCH AMOUNT
      if (parsed.amount == emi['emi']) {

        // ✅ UPDATE EMI
        int remaining = emi['remainingMonths'];

        if (remaining > 0) {
          emi['remainingMonths'] = remaining - 1;

          emiBox.putAt(i, emi);
        }

        // ✅ SAVE HISTORY
        historyBox.add({
          "name": emi['name'],
          "amount": parsed.amount,
          "date": DateTime.fromMillisecondsSinceEpoch(msg.date!).toString(),
        });

        break;
      }
    }
  }
}

  }
}
      final bankName = extractBankName(msg);
      detectedBanks.add(bankName);

      final dateTime = DateTime.fromMillisecondsSinceEpoch(msg.date!);
      final day = DateTime(dateTime.year, dateTime.month, dateTime.day);

      if (parsed.isDebit) {
        debitSum += parsed.amount;
        dailyDebitMap[day] = (dailyDebitMap[day] ?? 0) + parsed.amount;
      } else {
        creditSum += parsed.amount;
        dailyCreditMap[day] = (dailyCreditMap[day] ?? 0) + parsed.amount;
      }

      filtered.add(msg);
    }

    setState(() {
      messages = filtered;
      totalDebit = debitSum;
      totalCredit = creditSum;
      globalTotalSpent = debitSum;
      isLoading = false;
    });
  }

  String _monthName(int month) {
    const months = [
      "January","February","March","April","May","June",
      "July","August","September","October","November","December"
    ];
    return months[month - 1];
  }

  @override
  @override
  Widget build(BuildContext context) {
    final displayMessages = selectedBank == null
        ? messages
        : messages.where((msg) {
            final bank = extractBankName(msg);
            return bank == selectedBank;
          }).toList();

    final Map<String, List<SmsMessage>> groupedMessages = {};

    for (var msg in displayMessages) {
      final date = DateTime.fromMillisecondsSinceEpoch(msg.date ?? 0);
      final key = "${_monthName(date.month)}, ${date.year}";
      groupedMessages.putIfAbsent(key, () => []);
      groupedMessages[key]!.add(msg);
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF4F8FB),
      appBar: AppBar(
        title: const Text('Transaction', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20)),
        backgroundColor: const Color(0xFF1E6F5C),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      floatingActionButton: const ChatbotFab(),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/bd_whatsapp.jpeg'),
                fit: BoxFit.cover,
                opacity: 0.6,
              ),
            ),
          ),
          SafeArea(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : Column(
                    children: [
                      // ACCOUNTS DROPDOWN SECTION
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Accounts",
                              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF1E6F5C)),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.grey.withOpacity(0.3)),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ]
                              ),
                              child: Column(
                                children: [
                                  InkWell(
                                    onTap: () {
                                      setState(() {
                                        showAccounts = !showAccounts;
                                      });
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            selectedBank ?? "Select your bank",
                                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                                          ),
                                          Icon(showAccounts ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down, size: 24),
                                        ],
                                      ),
                                    ),
                                  ),
                                  if (showAccounts)
                                    Container(
                                      constraints: const BoxConstraints(maxHeight: 200),
                                      child: ListView(
                                        shrinkWrap: true,
                                        padding: EdgeInsets.zero,
                                        physics: const BouncingScrollPhysics(),
                                        children: [
                                          // "All Banks" option
                                          if (selectedBank != null)
                                            InkWell(
                                              onTap: () {
                                                setState(() {
                                                  selectedBank = null;
                                                  showAccounts = false;
                                                });
                                              },
                                              child: Container(
                                                width: double.infinity,
                                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                                child: const Text("Show All Banks", style: TextStyle(fontStyle: FontStyle.italic)),
                                              ),
                                            ),
                                          ...detectedBanks.map((bank) {
                                            bool isSelected = selectedBank == bank;
                                            return InkWell(
                                              onTap: () {
                                                setState(() {
                                                  selectedBank = bank;
                                                  showAccounts = false;
                                                });
                                              },
                                              child: Container(
                                                width: double.infinity,
                                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                                color: isSelected ? Colors.grey.shade300 : Colors.transparent,
                                                child: Text(
                                                  bank,
                                                  style: const TextStyle(fontSize: 14),
                                                ),
                                              ),
                                            );
                                          }).toList()
                                        ],
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      // TRANSACTIONS LIST
                      Expanded(
                        child: ListView(
                          padding: const EdgeInsets.only(bottom: 80), // For FABs
                          children: groupedMessages.entries.map((entry) {
                            final month = entry.key;
                            final msgs = entry.value;

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  child: Text(
                                    month,
                                    style: const TextStyle(
                                      fontSize: 15,
                                      color: Color(0xFF1E6F5C),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                ...msgs.map((msg) {
                                  final parsed = parseTransactionSMS(msg.body ?? '')!;
                                  final date = DateTime.fromMillisecondsSinceEpoch(msg.date ?? 0);
                                  
                                  final color = parsed.isDebit ? const Color(0xFFEF5350) : const Color(0xFF66BB6A);
                                  final bgColor = parsed.isDebit ? const Color(0xFFFFEBEB) : const Color(0xFFE8F5E9);
                                  final sign = parsed.isDebit ? '-' : '+';
                                  final type = parsed.isDebit ? 'Debit' : 'Credit';
                                  final formattedDate = '${date.day}/${date.month}/${date.year}';

                                  return Container(
                                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(16),
                                      boxShadow: [
                                        BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 4, offset: const Offset(0, 2)),
                                      ]
                                    ),
                                    child: Material(
                                      color: Colors.transparent,
                                      child: InkWell(
                                        borderRadius: BorderRadius.circular(16),
                                        onTap: () {
                                          showModalBottomSheet(
                                            context: context,
                                            isScrollControlled: true,
                                            shape: const RoundedRectangleBorder(
                                              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                                            ),
                                            builder: (_) => SafeArea(
                                              child: DraggableScrollableSheet(
                                                expand: false,
                                                builder: (_, controller) => SingleChildScrollView(
                                                  controller: controller,
                                                  padding: const EdgeInsets.all(20),
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Text(parsed.merchant,
                                                          style: const TextStyle(
                                                              fontSize: 18, fontWeight: FontWeight.bold)),
                                                      const SizedBox(height: 8),

                                                      Text(type,
                                                          style: TextStyle(
                                                              color: color, fontWeight: FontWeight.bold)),
                                                      const SizedBox(height: 8),

                                                      Text(
                                                        'Amount: $sign ₹${parsed.amount.toStringAsFixed(2)}',
                                                        style: TextStyle(
                                                          color: color,
                                                          fontSize: 16,
                                                          fontWeight: FontWeight.bold,
                                                        ),
                                                      ),
                                                      const SizedBox(height: 8),

                                                      Text('Date: $formattedDate',
                                                          style: const TextStyle(color: Colors.grey)),

                                                      const Divider(height: 24),

                                                      const Text('Transaction Message',
                                                          style: TextStyle(
                                                              fontWeight: FontWeight.bold, fontSize: 14)),
                                                      const SizedBox(height: 6),

                                                      Text(msg.body ?? '',
                                                          style: const TextStyle(fontSize: 13)),

                                                      const SizedBox(height: 40),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                          );
                                        },
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                                          child: Row(
                                            children: [
                                              CircleAvatar(
                                                backgroundColor: bgColor,
                                                radius: 20,
                                                child: Icon(
                                                  parsed.isDebit ? Icons.arrow_upward : Icons.arrow_downward,
                                                  color: color,
                                                  size: 20,
                                                ),
                                              ),
                                              const SizedBox(width: 14),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      parsed.merchant.toUpperCase(),
                                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black87),
                                                      maxLines: 1,
                                                      overflow: TextOverflow.ellipsis,
                                                    ),
                                                    const SizedBox(height: 4),
                                                    Text(
                                                      '$type • $formattedDate',
                                                      style: TextStyle(color: color.withOpacity(0.8), fontSize: 11, fontWeight: FontWeight.w600),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Text(
                                                '$sign ₹${parsed.amount.toStringAsFixed(0)}',
                                                style: TextStyle(
                                                  color: color,
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ],
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}