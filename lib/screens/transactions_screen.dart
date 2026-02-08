import 'package:flutter/material.dart';
import 'package:telephony/telephony.dart';
import '../globals.dart';

/* ---------------- MERCHANT EXTRACTION ---------------- */

String extractMerchant(String body) {
  body = body.toUpperCase();

  final known = [
    'ZOMATO',
    'SWIGGY',
    'AMAZON',
    'FLIPKART',
    'UBER',
    'OLA',
    'PAYTM',
    'GOOGLE',
    'IRCTC',
    'NETFLIX',
    'SPOTIFY',
    'RELIANCE',
    'DMART',
  ];

  for (var m in known) {
    if (body.contains(m)) return m;
  }

  final patterns = [
    RegExp(r'SPENT AT ([A-Z0-9\s]+)'),
    RegExp(r'PAID TO ([A-Z0-9\s]+)'),
    RegExp(r'AT ([A-Z0-9\s]+)'),
    RegExp(r'TO ([A-Z0-9\s]+)'),
  ];

  for (var p in patterns) {
    final match = p.firstMatch(body);
    if (match != null) {
      final name = match.group(1)!.trim();
      if (name.length > 3 && !name.contains('ACCOUNT')) {
        return name;
      }
    }
  }

  return 'BANK TRANSACTION';
}

/* ---------------- TRANSACTIONS SCREEN ---------------- */

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  final Telephony telephony = Telephony.instance;
  List<SmsMessage> messages = [];
  bool isLoading = true; // Added loading state for better UX

  @override
  void initState() {
    super.initState();
    loadSms();
  }

  /* -------- DEBIT / CREDIT -------- */

  bool isDebit(String body) {
    final b = body.toLowerCase();
    final explicitDebit = RegExp(
        r'\b(debit(?:ed)?|withdrawn|spent|purchase|paid|payment|card payment|atm withdrawal|sent)\b',
        caseSensitive: false);
    if (explicitDebit.hasMatch(b)) return true;

    final explicitCredit = RegExp(
        r'\b(credit(?:ed)?|deposited|received|refund|cashback|reversal)\b',
        caseSensitive: false);
    if (explicitCredit.hasMatch(b)) return false;

    final abbrev = RegExp(r'\bdr\b', caseSensitive: false);
    return abbrev.hasMatch(b);
  }

  bool isCredit(String body) {
    final b = body.toLowerCase();
    final explicitCredit = RegExp(
        r'\b(credit(?:ed)?|deposited|received|refund|cashback|reversal)\b',
        caseSensitive: false);
    if (explicitCredit.hasMatch(b)) return true;

    final explicitDebit = RegExp(
        r'\b(debit(?:ed)?|withdrawn|spent|purchase|paid|payment|card payment|atm withdrawal|sent)\b',
        caseSensitive: false);
    if (explicitDebit.hasMatch(b)) return false;

    final abbrev = RegExp(r'\bcr\b', caseSensitive: false);
    return abbrev.hasMatch(b);
  }

  /* -------- DATE FILTER -------- */

  bool isInRange(int? ts) {
    if (ts == null) return false;

    final d = DateTime.fromMillisecondsSinceEpoch(ts);
    final now = DateTime.now();

    if (currentFilter == FilterType.weekly) {
      return d.isAfter(now.subtract(const Duration(days: 7)));
    }

    // Logic for 3 months: If today is Feb 8, this goes back to Nov 8
    final threeMonthsAgo = DateTime(now.year, now.month - 3, now.day);
    return d.isAfter(threeMonthsAgo);
  }

  /* -------- LOAD SMS -------- */

  Future<void> loadSms() async {
    setState(() => isLoading = true);
    final ok = await telephony.requestSmsPermissions;
    if (ok != true) {
      setState(() => isLoading = false);
      return;
    }

    final sms = await telephony.getInboxSms(
      columns: [SmsColumn.BODY, SmsColumn.DATE],
      sortOrder: [OrderBy(SmsColumn.DATE, sort: Sort.DESC)],
    );

    double debitSum = 0;
    double creditSum = 0;

    dailyDebitMap.clear();
    dailyCreditMap.clear();

    final List<SmsMessage> filtered = [];
    
    // REMOVED .take(50) to allow scanning all 3 months of history
    for (var msg in sms) {
      final body = msg.body ?? '';
      
      // 1. Filter by date first
      if (!isInRange(msg.date)) continue;

      final debit = isDebit(body);
      final credit = isCredit(body);

      // 2. Determine if it's a financial transaction
      if (!debit && !credit) continue;

      // 3. Extract amount
      final amt = extractAmount(body);
      if (amt == 0) continue;

      final dateTime = DateTime.fromMillisecondsSinceEpoch(msg.date!);
      final day = DateTime(dateTime.year, dateTime.month, dateTime.day);

      if (debit) {
        debitSum += amt;
        dailyDebitMap[day] = (dailyDebitMap[day] ?? 0) + amt;
      } else if (credit) {
        creditSum += amt;
        dailyCreditMap[day] = (dailyCreditMap[day] ?? 0) + amt;
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

  /* -------- AMOUNT EXTRACTION -------- */

  double extractAmount(String body) {
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

  /* -------- MONTH HEADER -------- */

  Widget _monthHeader(DateTime date) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December',
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 6),
      child: Row(
        children: [
          const Icon(Icons.calendar_month, size: 18, color: Colors.black54),
          const SizedBox(width: 6),
          Text(
            '${months[date.month - 1]} ${date.year}',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  /* -------- UI -------- */

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F8FB),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(76),
        child: AppBar(
          elevation: 0,
          automaticallyImplyLeading: false,
          backgroundColor: Colors.transparent,
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF1E3CFF), Color(0xFF4B6CFF)],
              ),
            ),
          ),
          title: const Padding(
            padding: EdgeInsets.fromLTRB(20, 20, 20, 2),
            child: Text(
              'Transactions',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          actions: const [
            Padding(
              padding: EdgeInsets.only(right: 16, top: 12),
              child: Icon(Icons.receipt_long, color: Colors.white),
            ),
          ],
        ),
      ),
      body: isLoading 
          ? const Center(child: CircularProgressIndicator()) 
          : Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/bd_whatsapp.jpeg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: messages.length,
            itemBuilder: (_, i) {
              final msg = messages[i];
              final body = msg.body ?? '';
              final date = DateTime.fromMillisecondsSinceEpoch(msg.date ?? 0);

              // Month Header logic
              bool showHeader = false;
              if (i == 0) {
                showHeader = true;
              } else {
                final prevDate = DateTime.fromMillisecondsSinceEpoch(messages[i - 1].date!);
                if (date.month != prevDate.month || date.year != prevDate.year) {
                  showHeader = true;
                }
              }

              final amt = extractAmount(body);
              final debit = isDebit(body);
              final color = debit ? Colors.red : Colors.green;
              final sign = debit ? '-' : '+';
              final type = debit ? 'Debit' : 'Credit';
              final formattedDate = '${date.day}/${date.month}/${date.year}';

              return SafeArea(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (showHeader) _monthHeader(date),
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: CircleAvatar(
                          backgroundColor: color.withOpacity(0.12),
                          child: Icon(
                            debit ? Icons.arrow_upward : Icons.arrow_downward,
                            color: color,
                          ),
                        ),
                        title: Text(
                          extractMerchant(body),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          '$type • $formattedDate',
                          style: TextStyle(color: color, fontSize: 12),
                        ),
                        trailing: Text(
                          '$sign ₹${amt.toStringAsFixed(0)}',
                          style: TextStyle(
                            color: color,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        onTap: () {
                          showModalBottomSheet(
                            context: context,
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                            ),
                            builder: (_) => SafeArea(
                              child: Padding(
                                padding: const EdgeInsets.all(20),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      extractMerchant(body),
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      type,
                                      style: TextStyle(
                                        color: color,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Amount: $sign ₹${amt.toStringAsFixed(0)}',
                                      style: TextStyle(
                                        color: color,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Date: $formattedDate',
                                      style: const TextStyle(color: Colors.grey),
                                    ),
                                    const Divider(height: 24),
                                    const Text(
                                      'Transaction Message',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      body,
                                      style: const TextStyle(fontSize: 13),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}