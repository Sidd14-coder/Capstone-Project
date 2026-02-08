import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class DebitCreditPieChart extends StatelessWidget {
  final double debit;
  final double credit;

  const DebitCreditPieChart({
    super.key,
    required this.debit,
    required this.credit,
  });

  @override
  Widget build(BuildContext context) {
    final double total = debit + credit;

    if (total == 0) {
      return const Center(
        child: Text(
          'No transaction data',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    final bool healthy = credit >= debit;
    final double netBalance = credit - debit;
    final double debitPercent = (debit / total) * 100;
    final double creditPercent = (credit / total) * 100;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [

        // ================= SMALL HEADER =================
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 10),
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            gradient: LinearGradient(
              colors: healthy
                  ? [
                      const Color(0xFF2E7D32).withOpacity(0.10),
                      const Color(0xFF69F0AE).withOpacity(0.10),
                    ]
                  : [
                      const Color(0xFFD32F2F).withOpacity(0.10),
                      const Color(0xFFFF5252).withOpacity(0.10),
                    ],
            ),
          ),
          child: Column(
            children: [
              Text(
                healthy ? 'Safe' : 'Overspending',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: healthy ? Colors.green : Colors.red,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '₹${netBalance.toStringAsFixed(0)}',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: healthy ? Colors.green : Colors.red,
                ),
              ),
              const SizedBox(height: 2),
              const Text(
                'Net Balance',
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.black54,
                ),
              ),
            ],
          ),
        ),

        // ================= SMALL PIE =================
        SizedBox(
          height: 200, // 🔽 significantly reduced
          child: Stack(
            alignment: Alignment.center,
            children: [
              PieChart(
                PieChartData(
                  startDegreeOffset: -90,
                  sectionsSpace: 3,
                  centerSpaceRadius: 48, // 🔽 reduced
                  sections: [
                    PieChartSectionData(
                      value: debit,
                      showTitle: false,
                      radius: 52, // 🔽 reduced
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFFFF5252),
                          Color(0xFFD32F2F),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                    PieChartSectionData(
                      value: credit,
                      showTitle: false,
                      radius: 52,
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFF69F0AE),
                          Color(0xFF2E7D32),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ],
                ),
              ),

              // ================= CENTER TOTAL =================
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Total',
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.black54,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '₹${total.toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 12),

        // ================= SMALL STATS =================
        Row(
          children: [
            _CompactStat(
              label: 'Spent',
              amount: debit,
              percent: debitPercent,
              color: Colors.red,
            ),
            const SizedBox(width: 8),
            _CompactStat(
              label: 'Received',
              amount: credit,
              percent: creditPercent,
              color: Colors.green,
            ),
          ],
        ),
      ],
    );
  }
}

// =======================================================
// ================= SMALL STAT ==========================
// =======================================================
class _CompactStat extends StatelessWidget {
  final String label;
  final double amount;
  final double percent;
  final Color color;

  const _CompactStat({
    required this.label,
    required this.amount,
    required this.percent,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: Colors.grey.withOpacity(0.04),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              '₹${amount.toStringAsFixed(0)}',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              '${percent.toStringAsFixed(1)}%',
              style: const TextStyle(
                fontSize: 10,
                color: Colors.black54,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
