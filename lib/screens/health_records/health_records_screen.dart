import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../themes/app_theme.dart';
import '../../widgets/responsive_layout.dart';
import '../../providers/vitals_provider.dart';
import '../../models/dashboard.dart';

class HealthRecordsScreen extends ConsumerStatefulWidget {
  const HealthRecordsScreen({super.key});

  @override
  ConsumerState<HealthRecordsScreen> createState() => _HealthRecordsScreenState();
}

class _HealthRecordsScreenState extends ConsumerState<HealthRecordsScreen> {
  DateTime selectedWeek = DateTime.now();
  DateTime selectedRecordsWeek = DateTime.now();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(vitalsProvider.notifier).fetchVitals();
    });
  }

  List<VitalSign> _filterVitalsByWeek(List<VitalSign> vitals) {
    final weekStart = selectedWeek.subtract(Duration(days: selectedWeek.weekday - 1));
    final weekEnd = weekStart.add(const Duration(days: 6));
    
    return vitals.where((vital) {
      final date = DateTime.parse(vital.recordedAt);
      return date.isAfter(weekStart.subtract(const Duration(days: 1))) && 
             date.isBefore(weekEnd.add(const Duration(days: 1)));
    }).toList();
  }

  List<VitalSign> _filterRecordsByWeek(List<VitalSign> vitals) {
    final weekStart = selectedRecordsWeek.subtract(Duration(days: selectedRecordsWeek.weekday - 1));
    final weekEnd = weekStart.add(const Duration(days: 6));
    
    return vitals.where((vital) {
      final date = DateTime.parse(vital.recordedAt);
      return date.isAfter(weekStart.subtract(const Duration(days: 1))) && 
             date.isBefore(weekEnd.add(const Duration(days: 1)));
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final vitalsAsync = ref.watch(vitalsProvider);
    
    return ResponsiveLayout(
      currentRoute: '/health-records',
      child: Container(
        color: const Color(0xFFF8FAFC),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              vitalsAsync.when(
                loading: () => _buildLoadingChart(),
                error: (error, stack) => _buildVitalSignsChart([]),
                data: (vitals) => _buildVitalSignsChart(_filterVitalsByWeek(vitals)),
              ),
              const SizedBox(height: 16),
              vitalsAsync.when(
                loading: () => _buildLoadingHistory(),
                error: (error, stack) => _buildVitalSignsHistory([]),
                data: (vitals) => _buildVitalSignsHistory(_filterRecordsByWeek(vitals)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Iconsax.document_text,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Health Records',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Track your vital signs and health trends',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVitalSignsTab() {
    // Removed unused method
    
    return const Center(
      child: Text('Removed unused method'),
    );
  }



  Widget _buildVitalSignsChart(List<VitalSign> vitals) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF6366F1).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Iconsax.activity,
                  color: Color(0xFF6366F1),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Vital Signs Trends',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedWeek = selectedWeek.subtract(const Duration(days: 7));
                        });
                      },
                      child: const Padding(
                        padding: EdgeInsets.all(4),
                        child: Icon(Icons.chevron_left, size: 14),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Text(
                        DateFormat('MMM dd').format(selectedWeek.subtract(Duration(days: selectedWeek.weekday - 1))),
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedWeek = selectedWeek.add(const Duration(days: 7));
                        });
                      },
                      child: const Padding(
                        padding: EdgeInsets.all(4),
                        child: Icon(Icons.chevron_right, size: 14),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 250,
            child: vitals.isNotEmpty
                ? _buildVitalsChart(vitals)
                : Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFF6B7280).withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Iconsax.chart,
                            size: 32,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'No vital signs data available',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Record your vitals to see trends',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
          if (vitals.isNotEmpty) ...[
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildChartLegend('Heart Rate', const Color(0xFF6366F1)),
                _buildChartLegend('Blood Pressure', const Color(0xFFEF4444)),
                _buildChartLegend('Weight (×1.5)', const Color(0xFF10B981)),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildChartLegend(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AppTheme.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildVitalsChart(List<VitalSign> vitals) {
    if (vitals.isEmpty) {
      return Container(
        height: 250,
        child: const Center(
          child: Text(
            'No vital signs data available',
            style: TextStyle(
              fontSize: 16,
              color: AppTheme.textSecondary,
            ),
          ),
        ),
      );
    }
    
    // Sort vitals by date and take last 7 days
    final sortedVitals = vitals.toList()
      ..sort((a, b) => DateTime.parse(a.recordedAt).compareTo(DateTime.parse(b.recordedAt)));
    
    List<FlSpot> heartRateSpots = [];
    List<FlSpot> bloodPressureSpots = [];
    List<FlSpot> weightSpots = [];
    
    for (int i = 0; i < sortedVitals.length; i++) {
      final vital = sortedVitals[i];
      final x = i.toDouble();
      
      if (vital.heartRate != null) {
        heartRateSpots.add(FlSpot(x, vital.heartRate!.toDouble()));
      }
      if (vital.systolicBp != null) {
        bloodPressureSpots.add(FlSpot(x, vital.systolicBp!.toDouble()));
      }
      if (vital.weight != null) {
        // Scale weight to be visible with other vitals (multiply by 1.5 for better visibility)
        weightSpots.add(FlSpot(x, vital.weight! * 1.5));
      }
    }
    
    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: 40,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: Colors.grey.shade200,
              strokeWidth: 1,
            );
          },
        ),
        titlesData: FlTitlesData(
          show: true,
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              getTitlesWidget: (value, meta) {
                if (value.toInt() < sortedVitals.length) {
                  final vital = sortedVitals[value.toInt()];
                  final date = DateTime.parse(vital.recordedAt);
                  return SideTitleWidget(
                    axisSide: meta.axisSide,
                    child: Text(
                      DateFormat('MMM dd').format(date),
                      style: const TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 10,
                      ),
                    ),
                  );
                }
                return const SizedBox();
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, meta) {
                return Text(
                  value.toInt().toString(),
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 10,
                  ),
                );
              },
            ),
          ),
        ),
        borderData: FlBorderData(
          show: true,
          border: Border.all(color: Colors.grey.shade200),
        ),
        minX: 0,
        maxX: (sortedVitals.length - 1).toDouble(),
        minY: 0,
        maxY: 200,
        lineBarsData: [
          if (heartRateSpots.isNotEmpty)
            LineChartBarData(
              spots: heartRateSpots,
              isCurved: true,
              color: const Color(0xFF6366F1),
              barWidth: 3,
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, percent, barData, index) {
                  return FlDotCirclePainter(
                    radius: 3,
                    color: const Color(0xFF6366F1),
                  );
                },
              ),
            ),
          if (bloodPressureSpots.isNotEmpty)
            LineChartBarData(
              spots: bloodPressureSpots,
              isCurved: true,
              color: const Color(0xFFEF4444),
              barWidth: 3,
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, percent, barData, index) {
                  return FlDotCirclePainter(
                    radius: 3,
                    color: const Color(0xFFEF4444),
                  );
                },
              ),
            ),
          if (weightSpots.isNotEmpty)
            LineChartBarData(
              spots: weightSpots,
              isCurved: true,
              color: const Color(0xFF10B981),
              barWidth: 3,
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, percent, barData, index) {
                  return FlDotCirclePainter(
                    radius: 3,
                    color: const Color(0xFF10B981),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildVitalSignsHistory(List<VitalSign> vitals) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Iconsax.document_text,
                  color: Color(0xFF10B981),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Recent Records',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedRecordsWeek = selectedRecordsWeek.subtract(const Duration(days: 7));
                        });
                      },
                      child: const Icon(Icons.chevron_left, size: 16),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      DateFormat('MMM dd').format(selectedRecordsWeek.subtract(Duration(days: selectedRecordsWeek.weekday - 1))),
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedRecordsWeek = selectedRecordsWeek.add(const Duration(days: 7));
                        });
                      },
                      child: const Icon(Icons.chevron_right, size: 16),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (vitals.isEmpty)
            Container(
              padding: const EdgeInsets.all(32),
              width: double.infinity,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF6B7280).withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Iconsax.heart,
                      size: 32,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'No vital signs recorded yet',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Start recording your vitals to track your health',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppTheme.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
          else
            ...vitals.map((vital) => _buildVitalSignItem(vital)),
        ],
      ),
    );
  }

  Widget _buildVitalSignItem(VitalSign vital) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF6366F1).withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Icon(
              Iconsax.heart,
              color: Color(0xFF6366F1),
              size: 16,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  DateFormat('MMM dd, yyyy').format(DateTime.parse(vital.recordedAt)),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    if (vital.heartRate != null) ...[
                      Text('HR: ${vital.heartRate}', style: const TextStyle(fontSize: 12, color: Color(0xFF6366F1))),
                      const SizedBox(width: 8),
                    ],
                    if (vital.systolicBp != null) ...[
                      Text('BP: ${vital.systolicBp}/${vital.diastolicBp}', style: const TextStyle(fontSize: 12, color: Color(0xFFEF4444))),
                      const SizedBox(width: 8),
                    ],
                    if (vital.weight != null)
                      Text('${vital.weight!.toInt()}kg', style: const TextStyle(fontSize: 12, color: Color(0xFF10B981))),
                  ],
                ),
              ],
            ),
          ),
          Text(
            DateFormat('hh:mm a').format(DateTime.parse(vital.recordedAt)),
            style: const TextStyle(
              fontSize: 12,
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingChart() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF6366F1).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Iconsax.activity,
                  color: Color(0xFF6366F1),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Vital Signs Trends',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            height: 250,
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF6366F1),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingHistory() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Iconsax.document_text,
                  color: Color(0xFF10B981),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Recent Records',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...List.generate(3, (index) => Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            height: 80,
          )),
        ],
      ),
    );
  }

  Widget _buildVitalMetric(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(right: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 10,
                    color: AppTheme.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}