import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class DebitCreditBarChart extends StatefulWidget {
  final double totalDebit;
  final double totalCredit;

  const DebitCreditBarChart({
    super.key,
    required this.totalDebit,
    required this.totalCredit,
  });

  @override
  State<DebitCreditBarChart> createState() => _DebitCreditBarChartState();
}

class _DebitCreditBarChartState extends State<DebitCreditBarChart> {
  bool _isLoaded = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 150), () {
      if (mounted) setState(() => _isLoaded = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    final double rawMax =
        widget.totalDebit > widget.totalCredit ? widget.totalDebit : widget.totalCredit;
    final double maxY = rawMax == 0 ? 10000 : rawMax * 1.3;

    final double interval = maxY <= 10000
        ? 2000
        : maxY <= 20000
            ? 5000
            : maxY <= 50000
                ? 10000
                : 20000;

    return Container(
      height: 270,
      padding: const EdgeInsets.all(16),

      // 🔥 NEW BACKGROUND LOOK
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

      child: BarChart(
        BarChartData(
          maxY: maxY,
          alignment: BarChartAlignment.spaceEvenly,
          groupsSpace: 48,

          // ===== GRID =====
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: interval,
            getDrawingHorizontalLine: (value) => FlLine(
              color: Colors.grey.withOpacity(0.15),
              strokeWidth: 1,
            ),
          ),

          // ===== BORDER =====
          borderData: FlBorderData(show: false),

          // ===== TOOLTIP =====
          barTouchData: BarTouchData(
            enabled: true,
            touchTooltipData: BarTouchTooltipData(
              tooltipRoundedRadius: 10,
              tooltipPadding: const EdgeInsets.all(10),
              getTooltipItem: (group, _, rod, __) {
                final label = group.x == 0 ? 'Debit' : 'Credit';
                return BarTooltipItem(
                  '$label\n₹${rod.toY.toStringAsFixed(0)}',
                  const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                );
              },
            ),
          ),

          // ===== TITLES =====
          titlesData: FlTitlesData(
            topTitles:
                AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles:
                AxisTitles(sideTitles: SideTitles(showTitles: false)),

            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: interval,
                reservedSize: 60,
                getTitlesWidget: (value, meta) {
                  if (value == 0) return const SizedBox.shrink();
                  return Text(
                    value >= 1000
                        ? '₹${(value / 1000).toStringAsFixed(0)}K'
                        : '₹${value.toInt()}',
                    style: const TextStyle(
                      fontSize: 11,
                      color: Colors.black54,
                      fontWeight: FontWeight.w500,
                    ),
                  );
                },
              ),
            ),

            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 38,
                getTitlesWidget: (value, meta) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Text(
                      value.toInt() == 0 ? 'Debit' : 'Credit',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF114F2E),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          // ===== BARS =====
          barGroups: [
            BarChartGroupData(
              x: 0,
              barRods: [
                BarChartRodData(
                  toY: _isLoaded ? widget.totalDebit : 0,
                  width: 50,
                  color: const Color(0xFFFF1818),
                  borderRadius: BorderRadius.zero,
                  backDrawRodData: BackgroundBarChartRodData(
                    show: true,
                    toY: maxY,
                    color: const Color(0xFFFF1818).withOpacity(0.2),
                  ),
                ),
              ],
            ),
            BarChartGroupData(
              x: 1,
              barRods: [
                BarChartRodData(
                  toY: _isLoaded ? widget.totalCredit : 0,
                  width: 50,
                  color: const Color(0xFF00E600),
                  borderRadius: BorderRadius.zero,
                  backDrawRodData: BackgroundBarChartRodData(
                    show: true,
                    toY: maxY,
                    color: const Color(0xFF00E600).withOpacity(0.2),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
