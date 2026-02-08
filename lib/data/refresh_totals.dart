import 'package:telephony/telephony.dart';
import '../../globals.dart';

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

  for (var msg in sms.take(500)) { 
    final body = msg.body ?? '';
    final ts = msg.date;
    if (ts == null) continue;

    final d = DateTime.fromMillisecondsSinceEpoch(ts);

    // ✅ REFINED RANGE LOGIC
    bool inRange;
    if (currentFilter == FilterType.weekly) {
      // Is the message timestamp after 7 days ago?
      inRange = d.isAfter(sevenDaysAgo);
    } else {
      // Is the message timestamp on or after the 1st of this month?
      // isAfter(1st - 1 second) covers the very start of the day
      inRange = d.isAfter(startOfMonth.subtract(const Duration(seconds: 1)));
    }

    if (!inRange) continue;

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