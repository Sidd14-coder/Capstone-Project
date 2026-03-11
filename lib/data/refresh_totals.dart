import 'package:telephony/telephony.dart';
import '../../globals.dart';

class BankData {
  final String bankName;
  final double balance;
  final String accountNumber;
  final int date;

  BankData({
    required this.bankName,
    required this.balance,
    required this.accountNumber,
    required this.date,
  });
}

/// Recalculate debit, credit and total spent
/// whenever filter (weekly / monthly) changes
Future<void> refreshTotals() async {
  final telephony = Telephony.instance;

  // We fetch a larger batch to ensure we don't miss transactions 
  // at the start of the month if the user is very active.
  final sms = await telephony.getInboxSms(
    columns: [SmsColumn.BODY, SmsColumn.DATE],
    sortOrder: [OrderBy(SmsColumn.DATE, sort: Sort.DESC)],
  );

  double debitSum = 0;
  double creditSum = 0;

  final now = DateTime.now();
  
  // ✅ 1st Day of current month at 00:00:00
  final startOfMonth = DateTime(now.year, now.month, 1);
  
  // ✅ Exactly 7 days ago from this exact second
  final sevenDaysAgo = now.subtract(const Duration(days: 7));

  // Clear daily maps for fresh calculation
  dailyDebitMap.clear();
  dailyCreditMap.clear();

  bankBalances.clear();
  bankAccounts.clear();
  bankLastSmsTime.clear();

//   for (var msg in sms.take(500)) { 
//     final body = msg.body ?? '';
//     final ts = msg.date;
//     if (ts == null) continue;

//     final d = DateTime.fromMillisecondsSinceEpoch(ts);

//     // ✅ REFINED RANGE LOGIC
//     bool inRange;
//     if (currentFilter == FilterType.weekly) {
//       // Is the message timestamp after 7 days ago?
//       inRange = d.isAfter(sevenDaysAgo);
//     } else {
//       // Is the message timestamp on or after the 1st of this month?
//       // isAfter(1st - 1 second) covers the very start of the day
//       inRange = d.isAfter(startOfMonth.subtract(const Duration(seconds: 1)));
//     }

//     if (!inRange) continue;

//     final debit = _isDebit(body);
//     final credit = _isCredit(body);

//     if (!debit && !credit) continue;

//     final amt = _extractAmount(body);
//     if (amt == 0) continue;

//     // 🔵 BANK DETECTION
//     // 🔵 BANK DETECTION – NO DATE FILTER
// final bankName = extractBankNameFromSMS(body);

// if (bankName != 'Unknown Bank') {
//   // BALANCE – only latest per bank
//   final balStr = extractAvailableBalance(body);
//   if (balStr != null && !bankBalances.containsKey(bankName)) {
//     final bal = double.tryParse(balStr);
//     if (bal != null) {
//       bankBalances[bankName] = bal;
//     }
//   }

//   // ACCOUNT – only latest per bank
//   final acc = extractAccountNumber(body);
//   if (acc != null && !bankAccounts.containsKey(bankName)) {
//     bankAccounts[bankName] = acc;
//   }
// }

// // 🔽 AMOUNT CALCULATION – WITH DATE FILTER
// if (!inRange) continue;

// final debit = _isDebit(body);
// final credit = _isCredit(body);

// if (!debit && !credit) continue;

// final amt = _extractAmount(body);
// if (amt == 0) continue;

//     final day = DateTime(d.year, d.month, d.day);

//     if (debit) {
//       debitSum += amt;
//       dailyDebitMap[day] = (dailyDebitMap[day] ?? 0) + amt;
//     } else if (credit) {
//       creditSum += amt;
//       dailyCreditMap[day] = (dailyCreditMap[day] ?? 0) + amt;
//     }
//   }

  for (var msg in sms.take(1500)) {
  final body = msg.body ?? '';
  final ts = msg.date;
  if (ts == null) continue;

  final d = DateTime.fromMillisecondsSinceEpoch(ts);

  // 🔵 BANK DETECTION – NO DATE FILTER
  final bankName = extractBankNameFromSMS(body);

if (bankName != 'Unknown Bank') {
  final msgTime = ts!;

  final balStr = extractAvailableBalance(body);

  if (balStr != null) {
    final bal = double.tryParse(balStr);
    if (bal != null) {
      if (!bankLastSmsTime.containsKey(bankName) ||
          msgTime > bankLastSmsTime[bankName]!) {
        bankLastSmsTime[bankName] = msgTime;
        bankBalances[bankName] = bal;
      }
    }
  }

  final acc = extractAccountNumber(body);
  if (acc != null && !bankAccounts.containsKey(bankName)) {
    bankAccounts[bankName] = acc;
  }
}

  // 🔽 DATE FILTER ONLY FOR TOTALS
  bool inRange;
  if (currentFilter == FilterType.weekly) {
    inRange = d.isAfter(sevenDaysAgo);
  } else {
    inRange =
        d.isAfter(startOfMonth.subtract(const Duration(seconds: 1)));
  }

  if (!inRange) continue;

  // 🔽 AMOUNT CALCULATION (DECLARE ONLY ONCE)
  final debit = _isDebit(body);
  final credit = _isCredit(body);

  if (!debit && !credit) continue;

  final amt = _extractAmount(body);
  if (amt == 0) continue;

  final day = DateTime(d.year, d.month, d.day);

  if (debit) {
    debitSum += amt;
    dailyDebitMap[day] = (dailyDebitMap[day] ?? 0) + amt;
  } else if (credit) {
    creditSum += amt;
    dailyCreditMap[day] = (dailyCreditMap[day] ?? 0) + amt;
  }
}

  totalDebit = debitSum;
  totalCredit = creditSum;
  globalTotalSpent = debitSum;
}

/* ---------------- HELPER FUNCTIONS ---------------- */

double _extractAmount(String body) {
  // Removes commas from amounts like "1,250.00" before parsing
  final regex = RegExp(
    r'(rs\.?|inr|₹)\s?([\d,]+(\.\d+)?)',
    caseSensitive: false,
  );

  final match = regex.firstMatch(body.replaceAll(',', ''));
  if (match != null) {
    return double.tryParse(match.group(2)!) ?? 0;
  }
  return 0;
}

bool _isDebit(String body) {
  final b = body.toLowerCase();
  final explicitDebit = RegExp(r'\b(debit(?:ed)?|withdrawn|spent|purchase|paid|payment|card payment|atm withdrawal|sent)\b', caseSensitive: false);
  if (explicitDebit.hasMatch(b)) return true;

  final explicitCredit = RegExp(r'\b(credit(?:ed)?|deposited|received|refund|cashback|reversal)\b', caseSensitive: false);
  if (explicitCredit.hasMatch(b)) return false;

  final abbrev = RegExp(r'\bdr\b', caseSensitive: false);
  return abbrev.hasMatch(b);
}

bool _isCredit(String body) {
  final b = body.toLowerCase();
  final explicitCredit = RegExp(r'\b(credit(?:ed)?|deposited|received|refund|cashback|reversal)\b', caseSensitive: false);
  if (explicitCredit.hasMatch(b)) return true;

  final explicitDebit = RegExp(r'\b(debit(?:ed)?|withdrawn|spent|purchase|paid|payment|card payment|atm withdrawal|sent)\b', caseSensitive: false);
  if (explicitDebit.hasMatch(b)) return false;

  final abbrev = RegExp(r'\bcr\b', caseSensitive: false);
  return abbrev.hasMatch(b);
}

String? extractAvailableBalance(String body) {
  final cleaned = body.replaceAll(',', '').toLowerCase();

  final patterns = [
    RegExp(r'avl\s*bal(?:ance)?[:\s]*rs\.?\s?([\d]+(\.\d+)?)'),
    RegExp(r'avl\s*bal(?:ance)?[:\s]*([\d]+(\.\d+)?)'), // ✅ BOI FIX
    RegExp(r'available\s*bal(?:ance)?[:\s]*rs\.?\s?([\d]+(\.\d+)?)'),
    RegExp(r'\bbal(?:ance)?[:\s]*rs\.?\s?([\d]+(\.\d+)?)'),
    RegExp(r'bal(?:ance)?[:\s]*inr\s?([\d]+(\.\d+)?)'),
    RegExp(r'inr\s?([\d]+(\.\d+)?)\s*(?:is\s*)?your\s*bal'),
    RegExp(r'bal[:\s]*([\d]+(\.\d+)?)'),
  ];

  for (final regex in patterns) {
    final match = regex.firstMatch(cleaned);
    if (match != null) {
      return match.group(1);
    }
  }

  return null;
}

String? extractAccountNumber(String body) {
  body = body.toLowerCase();

  // 1️⃣ format: a/c xx1234
  final acRegex = RegExp(r'a/c\s*[xX*]*([0-9]{3,4})');
  final acMatch = acRegex.firstMatch(body);
  if (acMatch != null) {
    return 'A/c xx${acMatch.group(1)}';
  }

  // 2️⃣ format: account xxxx1234 (BOI, many banks)
  final accRegex = RegExp(r'account\s*[xX*]*([0-9]{4})');
  final accMatch = accRegex.firstMatch(body);
  if (accMatch != null) {
    return 'A/c xx${accMatch.group(1)}';
  }

  // 3️⃣ format: ending with XXXX1234
  final last4Regex = RegExp(r'[xX]{2,}([0-9]{4})');
  final last4Match = last4Regex.firstMatch(body);
  if (last4Match != null) {
    return 'A/c xx${last4Match.group(1)}';
  }

  return null;
}

String extractBankNameFromSMS(String body) {
  final b = body.toUpperCase();

  if (b.contains('IPPB') || b.contains('INDIA POST')) {
    return 'India Post Payments Bank';
  }

  if (b.contains('BANK OF INDIA') || b.contains('BOI') || b.contains('BOIIND')) {
    return 'Bank of India';
  }

  if (b.contains('SLICE') || b.contains('SLCEIT')) {
    return 'Slice';
  }

  if (b.contains('HDFC')) return 'HDFC Bank';
  if (b.contains('SBI') || b.contains('STATE BANK')) return 'State Bank of India';
  if (b.contains('ICICI')) return 'ICICI Bank';
  if (b.contains('AXIS')) return 'Axis Bank';
  if (b.contains('KOTAK')) return 'Kotak Mahindra Bank';
  if (b.contains('PNB') || b.contains('PUNJAB NATIONAL')) return 'Punjab National Bank';
  if (b.contains('CANARA')) return 'Canara Bank';
  if (b.contains('UNION BANK')) return 'Union Bank of India';
  if (b.contains('INDUSIND')) return 'IndusInd Bank';
  if (b.contains('YES BANK')) return 'Yes Bank';
  if (b.contains('IDFC')) return 'IDFC First Bank';
  if (b.contains('UCO')) return 'UCO Bank';
  if (b.contains('PAYTM')) return 'Paytm Payments Bank';
  if (b.contains('NSDL')) return 'NSDL Payments Bank';
  if (b.contains('JANA')) return 'Jana Small Finance Bank';
  if (b.contains('EQUITAS')) return 'Equitas Small Finance Bank';
  if (b.contains('UJJIVAN')) return 'Ujjivan Small Finance Bank';
  if (b.contains('ESAF')) return 'ESAF Small Finance Bank';
  if (b.contains('SURYODAY')) return 'Suryoday Small Finance Bank';
  if (b.contains('AU SMALL')) return 'AU Small Finance Bank';
  if (b.contains('KARNATAKA')) return 'Karnataka Bank';
  if (b.contains('KARUR VYSYA')) return 'Karur Vysya Bank';
  if (b.contains('CENTRAL BANK')) return 'Central Bank of India';
  if (b.contains('BANK OF BARODA') || b.contains('BOB')) return 'Bank of Baroda';
  if (b.contains('INDIAN BANK')) return 'Indian Bank';
  if (b.contains('INDIAN OVERSEAS')) return 'Indian Overseas Bank';
  if (b.contains('CITY UNION')) return 'City Union Bank';
  if (b.contains('FEDERAL BANK')) return 'Federal Bank';
  if (b.contains('TAMILNAD MERCANTILE')) return 'Tamilnad Mercantile Bank';
  if (b.contains('SOUTH INDIAN')) return 'South Indian Bank';
  if (b.contains('RBL')) return 'RBL Bank';
  if (b.contains('HSBC')) return 'HSBC Bank';
  if (b.contains('DEUTSCHE')) return 'Deutsche Bank';
  if (b.contains('BARCLAYS')) return 'Barclays Bank';
  if (b.contains('BNP')) return 'BNP Paribas';

  return 'Unknown Bank';
}