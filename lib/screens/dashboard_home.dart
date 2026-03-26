import 'package:flutter/material.dart';
import '../globals.dart';
import '../widgets/debit_credit_chart.dart';
import 'analytics_screen.dart';
import '../data/refresh_totals.dart';
import 'monthly_report_screen.dart'; // ADDED
import 'custom/custom_transactions_screen.dart';
import 'chatbot_screen.dart';

class DashboardHome extends StatefulWidget {
  const DashboardHome({super.key});

  @override
  State<DashboardHome> createState() => _DashboardHomeState();
}

class _DashboardHomeState extends State<DashboardHome> {
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  /// Initial data load and RefreshIndicator logic
  Future<void> _loadData() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    // Ensure refreshTotals() uses the 'currentFilter' internally to filter SMS
    await refreshTotals();

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  /// Triggered when the Weekly/Monthly dropdown changes
  Future<void> _onFilterChange(FilterType v) async {
    setState(() {
      currentFilter = v;
      _isLoading = true;
    });

    // We call refreshTotals again so it can re-scan the SMS with the new date range
    await refreshTotals();

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F8FB),

      floatingActionButton: Stack(
        children: [
          // 🤖 CHATBOT BUTTON (UPPER)
          Positioned(
            bottom: 90,
            right: 16,
            child: FloatingActionButton(
              heroTag: "chatbot",
              backgroundColor: const Color(0xFF1E002B),
              shape: const CircleBorder(
                side: BorderSide(color: Colors.white, width: 2),
              ),
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Image.asset('assets/icons/chatbot.png'),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ChatbotScreen(),
                  ),
                );
              },
            ),
          ),

          // ➕ EXISTING PLUS BUTTON
          Positioned(
            bottom: 20,
            right: 16,
            child: FloatingActionButton(
              heroTag: "add",
              backgroundColor: const Color(0xFF1E6F5C),
              shape: const CircleBorder(
                side: BorderSide(color: Colors.white, width: 2),
              ),
              child: const Icon(Icons.add, color: Colors.white, size: 28),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const CustomTransactionsScreen(),
                  ),
                ).then((_) => _loadData());
              },
            ),
          ),
        ],
      ),

      // ===== HEADER =====
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(76),
        child: AppBar(
          elevation: 0,
          automaticallyImplyLeading: false,
          backgroundColor: const Color(0xFF1E6F5C),
          flexibleSpace: Container(
            color: const Color(0xFF1E6F5C),
          ),
          title: Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
            child: Row(
              children: const [
                Text(
                  'Overview',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),

      // ===== BODY =====
      body: Stack(
        children: [
          // Background image with overlay
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/bd_whatsapp.jpeg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Content
          RefreshIndicator(
            onRefresh: _loadData,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ===== TOTAL SPENT CARD =====
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 14,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Total Spent',
                              style: TextStyle(
                                color: Colors.black87,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFFBBE5BE),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: DropdownButton<FilterType>(
                                value: currentFilter,
                                dropdownColor: const Color(0xFFBBE5BE),
                                underline: const SizedBox(),
                                icon: const Icon(
                                  Icons.keyboard_arrow_down,
                                  color: Colors.black87,
                                  size: 20,
                                ),
                                style: const TextStyle(
                                  color: Colors.black87,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                                items: const [
                                  DropdownMenuItem(
                                    value: FilterType.weekly,
                                    child: Text('Weekly'),
                                  ),
                                  DropdownMenuItem(
                                    value: FilterType.monthly,
                                    child: Text('Monthly'),
                                  ),
                                ],
                                onChanged: (v) {
                                  if (v != null) _onFilterChange(v);
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),
                        _isLoading
                            ? const SizedBox(
                                height: 30,
                                width: 30,
                                child: CircularProgressIndicator(
                                  color: Colors.black87,
                                  strokeWidth: 2.5,
                                ),
                              )
                            : Text(
                                '₹${globalTotalSpent.toStringAsFixed(0)}',
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 34,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                        const SizedBox(height: 6),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // ===== DEBIT & CREDIT SUMMARY =====
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _summaryCard(
                        title: 'Debit',
                        amount: totalDebit,
                        color: const Color(0xFFF1655F),
                        icon: Icons.arrow_upward,
                        isDebit: true,
                      ),
                      _summaryCard(
                        title: 'Credit',
                        amount: totalCredit,
                        color: const Color(0xFF7DDF73),
                        icon: Icons.arrow_downward,
                        isDebit: false,
                      ),
                    ],
                  ),

                  const SizedBox(height: 30),

                  // ===== CHART =====
                  const Text(
                    'Debit vs Credit',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF114F2E),
                    ),
                  ),

                  const SizedBox(height: 12),

                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    child: DebitCreditBarChart(
                      totalDebit: totalDebit,
                      totalCredit: totalCredit,
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ===== ANALYTICS BUTTON =====
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        backgroundColor: const Color(0xFF1E6F5C),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        side: BorderSide.none,
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const AnalyticsScreen(),
                          ),
                        ).then((_) => _loadData());
                      },
                      child: const Text(
                        'View Detailed Analytics',
                        style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),

                  // ===== MONTHLY REPORT BUTTON (ADDED) =====
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        backgroundColor: const Color(0xFF1E6F5C),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        side: BorderSide.none,
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const MonthlyReportScreen(),
                          ),
                        );
                      },
                      child: const Text(
                        'View Monthly Report',
                        style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ===== SUMMARY CARD =====
  Widget _summaryCard({
    required String title,
    required double amount,
    required Color color,
    required IconData icon,
    required bool isDebit,
  }) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.43,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: color.withOpacity(0.9),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.35),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '₹${amount.toStringAsFixed(0)}',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            isDebit ? 'Money spent' : 'Money received',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: isDebit ? const Color(0xFF9B0000) : const Color(0xFF004F00),
            ),
          ),
        ],
      ),
    );
  }
}