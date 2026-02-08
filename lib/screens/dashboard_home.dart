import 'package:flutter/material.dart';
import '../globals.dart';
import '../widgets/debit_credit_chart.dart';
import 'analytics_screen.dart';
import '../data/refresh_totals.dart';

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

      // ===== HEADER =====
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
                colors: [
                  Color(0xFF1E3CFF),
                  Color(0xFF4B6CFF),
                ],
              ),
            ),
          ),
          title: Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
            child: Row(
              children: const [
                Icon(Icons.account_balance_wallet,
                    color: Colors.white, size: 22),
                SizedBox(width: 10),
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
                      color: const Color(0xFF1F3C88),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.12),
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
                                color: Colors.white70,
                                fontSize: 13,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: DropdownButton<FilterType>(
                                value: currentFilter,
                                dropdownColor: const Color(0xFF1F3C88),
                                underline: const SizedBox(),
                                icon: const Icon(
                                  Icons.keyboard_arrow_down,
                                  color: Colors.white,
                                  size: 20,
                                ),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
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
                                  color: Colors.white,
                                  strokeWidth: 2.5,
                                ),
                              )
                            : Text(
                                '₹ ${globalTotalSpent.toStringAsFixed(0)}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 34,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                        const SizedBox(height: 6),
                        Text(
                          currentFilter == FilterType.weekly 
                              ? 'Last 7 days' 
                              : 'Last 30 days',
                          style: const TextStyle(
                            color: Colors.white54,
                            fontSize: 11,
                          ),
                        ),
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
                        color: Colors.red,
                        icon: Icons.arrow_upward,
                      ),
                      _summaryCard(
                        title: 'Credit',
                        amount: totalCredit,
                        color: Colors.green,
                        icon: Icons.arrow_downward,
                      ),
                    ],
                  ),

                  const SizedBox(height: 30),

                  // ===== CHART =====
                  const Text(
                    'Debit vs Credit',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
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
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.analytics),
                      label: const Text(
                        'View Detailed Analytics',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      style: OutlinedButton.styleFrom(
                        backgroundColor: const Color(0xFF1E3CFF),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const AnalyticsScreen(),
                          ),
                        ).then((_) => _loadData()); // Refresh when coming back
                      },
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
  }) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.43,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: color.withOpacity(0.35),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withOpacity(0.6),
        ),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.25),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.4),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: color.withOpacity(0.9),
              size: 22,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color.fromARGB(255, 22, 1, 155),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '₹ ${amount.toStringAsFixed(0)}',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title == 'Debit' ? 'Money spent' : 'Money received',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Color.fromARGB(255, 49, 156, 47),
            ),
          ),
        ],
      ),
    );
  }
}