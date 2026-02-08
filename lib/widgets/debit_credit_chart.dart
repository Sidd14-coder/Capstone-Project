import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class DebitCreditBarChart extends StatelessWidget {
  final double totalDebit;
  final double totalCredit;

  const DebitCreditBarChart({
    super.key,
    required this.totalDebit,
    required this.totalCredit,
  });

  @override
  Widget build(BuildContext context) {
    final double rawMax =
        totalDebit > totalCredit ? totalDebit : totalCredit;
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
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(0.92),
            const Color(0xFFF3F6FF),
          ],
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: Colors.white.withOpacity(0.6),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 10),
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
                        fontWeight: FontWeight.w600,
                        color: Color.fromARGB(221, 37, 11, 188),
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
                  toY: totalDebit,
                  width: 54,
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFFFF8A80),
                      Color(0xFFD32F2F),
                    ],
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                  ),
                  borderRadius: BorderRadius.circular(2),
                  backDrawRodData: BackgroundBarChartRodData(
                    show: true,
                    toY: maxY,
                    color: Colors.red.withOpacity(0.07),
                  ),
                ),
              ],
            ),
            BarChartGroupData(
              x: 1,
              barRods: [
                BarChartRodData(
                  toY: totalCredit,
                  width: 54,
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF81C784),
                      Color(0xFF2E7D32),
                    ],
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                  ),
                  borderRadius: BorderRadius.circular(2),
                  backDrawRodData: BackgroundBarChartRodData(
                    show: true,
                    toY: maxY,
                    color: Colors.green.withOpacity(0.07),
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
