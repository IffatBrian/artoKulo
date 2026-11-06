import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/transaction_model.dart';
import '../theme.dart';

/// Grafik batang pemasukan vs pengeluaran: 3 hari lalu, HARI INI (tengah), 3 hari ke depan.
class FlowChart extends StatelessWidget {
  final List<TransactionModel> items;
  const FlowChart({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final days = List.generate(7, (i) {
      final d = today.add(Duration(days: i - 3));
      return DateTime(d.year, d.month, d.day);
    });

    final income = List<double>.filled(7, 0);
    final expense = List<double>.filled(7, 0);
    for (final t in items) {
      final d = DateTime(t.date.year, t.date.month, t.date.day);
      final idx = days.indexOf(d);
      if (idx == -1) continue;
      if (t.isIncome) {
        income[idx] += t.amount;
      } else {
        expense[idx] += t.amount;
      }
    }

    double maxY = 0;
    for (var i = 0; i < 7; i++) {
      if (income[i] > maxY) maxY = income[i];
      if (expense[i] > maxY) maxY = expense[i];
    }
    final hasData = maxY > 0;
    if (!hasData) maxY = 100000;
    maxY *= 1.2;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Grafik 7 Hari',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          const Row(children: [
            _Legend(color: AppColors.income, label: 'Pemasukan'),
            SizedBox(width: 16),
            _Legend(color: AppColors.expense, label: 'Pengeluaran'),
            SizedBox(width: 16),
            _Legend(color: AppColors.primary, label: 'Hari ini'),
          ]),
          const SizedBox(height: 20),
          SizedBox(
            height: 180,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Sorotan lembut untuk kolom "hari ini" (tepat di tengah).
                Center(
                  child: FractionallySizedBox(
                    widthFactor: 0.13,
                    heightFactor: 1,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: AppColors.secondary.soft(0.5),
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                BarChart(
                  BarChartData(
                    maxY: maxY,
                    alignment: BarChartAlignment.spaceAround,
                    borderData: FlBorderData(show: false),
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: false,
                      horizontalInterval: maxY / 4,
                      getDrawingHorizontalLine: (_) => const FlLine(
                          color: AppColors.borderSoft, strokeWidth: 1),
                    ),
                    titlesData: FlTitlesData(
                      leftTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false)),
                      rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false)),
                      topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false)),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 28,
                          getTitlesWidget: (v, meta) => Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              DateFormat('E', 'id_ID')
                                  .format(days[v.toInt()])
                                  .substring(0, 3),
                              style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: v.toInt() == 3
                                      ? FontWeight.w800
                                      : FontWeight.w600,
                                  color: v.toInt() == 3
                                      ? AppColors.primary
                                      : AppColors.hint),
                            ),
                          ),
                        ),
                      ),
                    ),
                    barTouchData: BarTouchData(
                      touchTooltipData: BarTouchTooltipData(
                        getTooltipColor: (_) => const Color(0xFF263143),
                        getTooltipItem: (group, gi, rod, ri) => BarTooltipItem(
                          rupiah(rod.toY),
                          const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                    barGroups: List.generate(
                      7,
                      (i) => BarChartGroupData(
                        x: i,
                        barsSpace: 4,
                        barRods: [
                          BarChartRodData(
                            toY: income[i],
                            width: 8,
                            color: AppColors.income,
                            borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(4)),
                          ),
                          BarChartRodData(
                            toY: expense[i],
                            width: 8,
                            color: AppColors.expense,
                            borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(4)),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                if (!hasData)
                  const Text('Belum ada data minggu ini',
                      style: TextStyle(color: AppColors.hint, fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Menampilkan penanda untuk satu kategori grafik.
class _Legend extends StatelessWidget {
  final Color color;
  final String label;
  const _Legend({required this.color, required this.label});

  @override
  Widget build(BuildContext context) => Row(children: [
        Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Text(label,
            style: const TextStyle(fontSize: 12, color: AppColors.hint)),
      ]);
}
