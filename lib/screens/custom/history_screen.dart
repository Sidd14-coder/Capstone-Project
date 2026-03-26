import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:fl_chart/fl_chart.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen>
    with SingleTickerProviderStateMixin {

  String filter = "weekly";
  String selectedCategory = "All";

  /// ANIMATION
  late AnimationController _controller;

  /// CATEGORY ICONS
  Map<String, IconData> categoryIcons = {
    "Food": Icons.fastfood,
    "Health": Icons.health_and_safety,
    "Grocery": Icons.shopping_cart,
    "Bills": Icons.receipt,
    "Dining": Icons.restaurant,
    "Education": Icons.school,
    "Fuel": Icons.local_gas_station,
    "Gadgets": Icons.devices,
    "Shopping": Icons.shopping_bag,
    "Travel": Icons.flight,
    "Misc": Icons.category,
  };

  /// COLORS
  List<Color> chartColors = [
    Colors.blue,
    Colors.red,
    Colors.orange,
    Colors.purple,
    Colors.green,
    Colors.teal,
    Colors.pink,
    Colors.brown,
  ];

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  List getFilteredData() {
    var box = Hive.box('customTransactions');

    List data = box.keys.map((key) {
      final item = box.get(key);
      return {...item, "key": key};
    }).toList();

    DateTime now = DateTime.now();

    return data.where((e) {
      if (e['date'] == null) return false;
      DateTime d = DateTime.parse(e['date']);

      bool dateFilter = filter == "weekly"
          ? d.isAfter(now.subtract(const Duration(days: 7)))
          : (d.month == now.month && d.year == now.year);

      bool categoryFilter =
          selectedCategory == "All" || e['category'] == selectedCategory;

      return dateFilter && categoryFilter;
    }).toList();
  }

  void deleteTransaction(dynamic key) {
    var box = Hive.box('customTransactions');
    box.delete(key);
    setState(() {});
  }

  void editTransaction(Map e) {
    TextEditingController amountController =
        TextEditingController(text: e['amount'].toString());
    TextEditingController noteController =
        TextEditingController(text: e['note']);

    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text("Edit Transaction"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: amountController,
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: noteController,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                var box = Hive.box('customTransactions');

                box.put(e['key'], {
                  "type": e['type'],
                  "account": e['account'],
                  "category": e['category'],
                  "amount": double.tryParse(amountController.text),
                  "note": noteController.text,
                  "date": e['date'],
                });

                Navigator.pop(context);
                setState(() {});
              },
              child: const Text("Save"),
            )
          ],
        );
      },
    );
  }

  Map<String, double> getCategoryData(List data) {
    Map<String, double> map = {};
    for (var e in data) {
      map[e['category']] =
          (map[e['category']] ?? 0) + (e['amount'] ?? 0);
    }
    return map;
  }

  List<LineChartBarData> getLineData(List data) {
  Map<String, List<FlSpot>> map = {};
  int i = 0;

  for (var e in data) {
    String cat = e['category'] ?? "Unknown";

    map.putIfAbsent(cat, () => []);
    map[cat]!.add(
      FlSpot(
        i.toDouble(),
        (e['amount'] ?? 0).toDouble(),
      ),
    );
    i++;
  }

  int index = 0;

  return map.entries.map((entry) {
    Color color = chartColors[index % chartColors.length];
    index++;

    return LineChartBarData(
      spots: entry.value,

      /// 🔥 MAIN FIX (LINE SMOOTH + VISIBLE)
      isCurved: true,
      curveSmoothness: 0.5,
      barWidth: 5,
      color: color,

      /// ❌ REMOVE DOTS (THIS WAS YOUR ISSUE)
      dotData: FlDotData(show: false),

      /// ✅ CLEAN LINE STYLE
      isStrokeCapRound: true,

      /// 🔥 AREA UNDER LINE
      belowBarData: BarAreaData(
        show: true,
        gradient: LinearGradient(
          colors: [
            color.withOpacity(0.3),
            Colors.transparent,
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
    );
  }).toList();
}

  double getTotal(List data) {
    double total = 0;
    for (var e in data) {
      total += (e['amount'] ?? 0);
    }
    return total;
  }

  /// 🔥 GRAPH TAP DETAIL
  void showGraphDetail(String title, Widget chart) {
    showDialog(
      context: context,
      builder: (_) {
        return Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Container(
            padding: const EdgeInsets.all(20),
            height: 300,
            child: Column(
              children: [
                Text(title,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),
                Expanded(child: chart),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    List data = getFilteredData();
    var categoryData = getCategoryData(data);
    double total = getTotal(data);

    if (data.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text("Custom History & Analytics"),
          backgroundColor: const Color(0xFF1E6F5C),
        ),
        body: const Center(child: Text("No transactions found")),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFBFD8C3),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E6F5C),
        title: const Text("Custom History & Analytics"),
      ),
      body: FadeTransition(
        opacity: _controller,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              /// TOTAL
              Card(
                child: ListTile(
                  title: const Text("Total Spending"),
                  trailing: Text("₹ ${total.toStringAsFixed(2)}"),
                ),
              ),

              const SizedBox(height: 20),

              /// TRANSACTIONS
              Card(
                child: Column(
                  children: data.map((e) {
                    return ListTile(
                      leading: Icon(
                        categoryIcons[e['category']] ?? Icons.category,
                      ),
                      title: Text(e['category']),
                      subtitle: Text(e['note'] ?? ""),
                      trailing: Text("₹ ${e['amount'] ?? 0}"),
                      onTap: () => editTransaction(e),
                      onLongPress: () => deleteTransaction(e['key']),
                    );
                  }).toList(),
                ),
              ),

              const SizedBox(height: 20),

              /// PIE (CLICKABLE)
              GestureDetector(
                onTap: () => showGraphDetail(
                  "Spending Breakdown",
                  PieChart(
                    PieChartData(
                      sections: categoryData.entries
                          .toList()
                          .asMap()
                          .entries
                          .map((entry) {
                        int i = entry.key;
                        var e = entry.value;

                        return PieChartSectionData(
                          value: e.value,
                          title: "₹${e.value.toInt()}",
                          color: chartColors[i % chartColors.length],
                        );
                      }).toList(),
                    ),
                  ),
                ),
                child: SizedBox(
                  height: 200,
                  child: PieChart(
                    PieChartData(
                      sections: categoryData.entries
                          .toList()
                          .asMap()
                          .entries
                          .map((entry) {
                        int i = entry.key;
                        var e = entry.value;

                        return PieChartSectionData(
                          value: e.value,
                          title: "",
                          color: chartColors[i % chartColors.length],
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              /// LINE (CLICKABLE)
              GestureDetector(
                onTap: () => showGraphDetail(
                  "Trend Graph",
                  LineChart(
                    LineChartData(lineBarsData: getLineData(data)),
                  ),
                ),
                child: SizedBox(
                  height: 250,
                  child: LineChart(
                    LineChartData(lineBarsData: getLineData(data)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

