import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:fl_chart/fl_chart.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {

  String filter = "weekly";

  List getFilteredData() {
    var box = Hive.box('customTransactions');
    List data = box.values.toList();

    DateTime now = DateTime.now();

    return data.where((e) {
      if (e['date'] == null) return false;  
      DateTime d = DateTime.parse(e['date']);

      if (filter == "weekly") {
        return d.isAfter(now.subtract(const Duration(days: 7)));
      } else {
        return d.month == now.month && d.year == now.year;
      }
    }).toList();
  }

  /// PIE DATA
  Map<String, double> getCategoryData(List data) {
    Map<String, double> map = {};

    for (var e in data) {
      map[e['category']] =
          (map[e['category']] ?? 0) + (e['amount'] ?? 0);
    }

    return map;
  }

  /// LINE GRAPH DATA
  List<LineChartBarData> getLineData(List data) {
    Map<String, List<FlSpot>> map = {};

    int i = 0;

    for (var e in data) {
      String cat = e['category'] ?? "Unknown";

      map.putIfAbsent(cat, () => []);
      map[cat]!.add(FlSpot(i.toDouble(), (e['amount'] ?? 0).toDouble()));
      i++;
    }

    return map.entries.map((entry) {
      return LineChartBarData(
        spots: entry.value,
        isCurved: true,
        barWidth: 3,
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {

    List data = getFilteredData();
    var categoryData = getCategoryData(data);

    if (data.isEmpty) {
  return Scaffold(
    appBar: AppBar(
      title: const Text("Custom History & Analytics"),
      backgroundColor: const Color(0xFF1E6F5C),
    ),
    body: const Center(
      child: Text("No transactions found"),
    ),
  );
}

    return Scaffold(
      backgroundColor: const Color(0xFFBFD8C3),

      appBar: AppBar(
        backgroundColor: const Color(0xFF1E6F5C),
        title: const Text("Custom History & Analytics"),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(

          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            /// TOGGLE
            Center(
              child: ToggleButtons(
                isSelected: [filter == "weekly", filter == "monthly"],
                onPressed: (index) {
                  setState(() {
                    filter = index == 0 ? "weekly" : "monthly";
                  });
                },
                children: const [
                  Padding(
                    padding: EdgeInsets.all(10),
                    child: Text("Weekly"),
                  ),
                  Padding(
                    padding: EdgeInsets.all(10),
                    child: Text("Monthly"),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            /// TITLE CHANGE
            const Text(
              "Transactions",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),

            /// TRANSACTION LIST
            Card(
              child: Column(
                children: data.map((e) {
                  return ListTile(
                    title: Text(e['category']),
                    subtitle: Text(e['note'] ?? ""),
                    trailing: Text("₹ ${e['amount'] ?? 0}"),
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 20),

            /// PIE CHART
            const Text(
              "Spending Breakdown",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),

            SizedBox(
              height: 200,
              child: PieChart(
                PieChartData(
                  sections: categoryData.entries.map((e) {
                    return PieChartSectionData(
                      value: e.value,
                      title: e.key,
                    );
                  }).toList(),
                ),
              ),
            ),

            const SizedBox(height: 20),

            /// LINE GRAPH
            const Text(
              "Trend",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),

            SizedBox(
              height: 250,
              child: LineChart(
                LineChartData(
                  lineBarsData: data.isEmpty ? [] : getLineData(data),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}