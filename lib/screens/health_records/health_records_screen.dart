import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../themes/app_theme.dart';
import '../../widgets/mobile_layout.dart';
import '../../providers/health_records_provider.dart';
import '../../models/health_records.dart';
import '../../models/dashboard.dart';

class HealthRecordsScreen extends ConsumerStatefulWidget {
  const HealthRecordsScreen({super.key});

  @override
  ConsumerState<HealthRecordsScreen> createState() => _HealthRecordsScreenState();
}

class _HealthRecordsScreenState extends ConsumerState<HealthRecordsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(healthRecordsProvider.notifier).loadAllData();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MobileLayout(
      currentRoute: '/health-records',
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        appBar: AppBar(
          title: const Text('Health Records'),
          backgroundColor: Colors.white,
          elevation: 0,
          bottom: TabBar(
            controller: _tabController,
            labelColor: const Color(0xFF6366F1),
            unselectedLabelColor: AppTheme.textSecondary,
            indicatorColor: const Color(0xFF6366F1),
            tabs: const [
              Tab(text: 'Vital Signs'),
              Tab(text: 'Medical History'),
              Tab(text: 'Lab Results'),
              Tab(text: 'Medications'),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildVitalSignsTab(),
            _buildMedicalHistoryTab(),
            _buildLabResultsTab(),
            _buildMedicationsTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildVitalSignsTab() {
    final healthRecords = ref.watch(healthRecordsProvider);
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildQuickEntryCard(),
          const SizedBox(height: 16),
          _buildVitalSignsChart(healthRecords.healthTrends),
          const SizedBox(height: 16),
          _buildVitalSignsHistory(healthRecords.vitalSigns),
        ],
      ),
    );
  }

  Widget _buildQuickEntryCard() {
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
                child: const Icon(Iconsax.heart, color: Color(0xFF6366F1), size: 20),
              ),
              const SizedBox(width: 12),
              const Text(
                'Quick Entry',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _showVitalSignsDialog,
              icon: const Icon(Icons.add, size: 20),
              label: const Text('Record New Vitals'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6366F1),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVitalSignsChart(List<HealthTrend> trends) {
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
          const Text(
            'Health Trends (30 Days)',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 200,
            child: trends.isNotEmpty
                ? LineChart(_buildLineChartData(trends))
                : const Center(
                    child: Text(
                      'No trend data available',
                      style: TextStyle(color: AppTheme.textSecondary),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  LineChartData _buildLineChartData(List<HealthTrend> trends) {
    final spots = trends.asMap().entries.map((entry) {
      final index = entry.key.toDouble();
      final trend = entry.value;
      return FlSpot(index, (trend.systolicBp ?? 120).toDouble());
    }).toList();

    return LineChartData(
      gridData: const FlGridData(show: true),
      titlesData: const FlTitlesData(show: false),
      borderData: FlBorderData(show: false),
      lineBarsData: [
        LineChartBarData(
          spots: spots,
          isCurved: true,
          color: const Color(0xFF6366F1),
          barWidth: 3,
          dotData: const FlDotData(show: false),
        ),
      ],
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
          const Text(
            'Recent Records',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          if (vitals.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Text(
                  'No vital signs recorded yet',
                  style: TextStyle(color: AppTheme.textSecondary),
                ),
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
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            DateFormat('MMM dd, yyyy - hh:mm a').format(DateTime.parse(vital.recordedAt)),
            style: const TextStyle(
              fontSize: 12,
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              if (vital.weight != null)
                _buildVitalMetric('Weight', '${vital.weight!.toInt()} kg', Iconsax.weight),
              if (vital.systolicBp != null && vital.diastolicBp != null)
                _buildVitalMetric('BP', '${vital.systolicBp}/${vital.diastolicBp}', Iconsax.heart),
              if (vital.heartRate != null)
                _buildVitalMetric('HR', '${vital.heartRate} bpm', Iconsax.activity),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildVitalMetric(String label, String value, IconData icon) {
    return Expanded(
      child: Row(
        children: [
          Icon(icon, size: 16, color: const Color(0xFF6366F1)),
          const SizedBox(width: 4),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 10,
                  color: AppTheme.textSecondary,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMedicalHistoryTab() {
    final healthRecords = ref.watch(healthRecordsProvider);
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          if (healthRecords.medicalHistory.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Text(
                  'No medical history available',
                  style: TextStyle(color: AppTheme.textSecondary),
                ),
              ),
            )
          else
            ...healthRecords.medicalHistory.map((record) => _buildMedicalHistoryItem(record)),
        ],
      ),
    );
  }

  Widget _buildMedicalHistoryItem(MedicalHistoryRecord record) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
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
              Expanded(
                child: Text(
                  record.treatmentName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getStatusColor(record.status).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  record.status,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: _getStatusColor(record.status),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '${record.hospitalName} • Dr. ${record.doctorName}',
            style: const TextStyle(
              fontSize: 14,
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Condition: ${record.condition}',
            style: const TextStyle(
              fontSize: 14,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Started: ${DateFormat('MMM dd, yyyy').format(DateTime.parse(record.startDate))}',
            style: const TextStyle(
              fontSize: 12,
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabResultsTab() {
    final healthRecords = ref.watch(healthRecordsProvider);
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          if (healthRecords.labResults.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Text(
                  'No lab results available',
                  style: TextStyle(color: AppTheme.textSecondary),
                ),
              ),
            )
          else
            ...healthRecords.labResults.map((result) => _buildLabResultItem(result)),
        ],
      ),
    );
  }

  Widget _buildLabResultItem(LabResult result) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
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
              Expanded(
                child: Text(
                  result.testName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getLabStatusColor(result.status).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  result.status,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: _getLabStatusColor(result.status),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Result: ${result.result}',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Reference: ${result.referenceRange}',
            style: const TextStyle(
              fontSize: 12,
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${result.labName} • ${DateFormat('MMM dd, yyyy').format(DateTime.parse(result.testDate))}',
            style: const TextStyle(
              fontSize: 12,
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMedicationsTab() {
    final healthRecords = ref.watch(healthRecordsProvider);
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildAddMedicationCard(),
          const SizedBox(height: 16),
          if (healthRecords.medications.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Text(
                  'No medications added yet',
                  style: TextStyle(color: AppTheme.textSecondary),
                ),
              ),
            )
          else
            ...healthRecords.medications.map((medication) => _buildMedicationItem(medication)),
        ],
      ),
    );
  }

  Widget _buildAddMedicationCard() {
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
                child: const Icon(Iconsax.health, color: Color(0xFF10B981), size: 20),
              ),
              const SizedBox(width: 12),
              const Text(
                'Medication Management',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _showAddMedicationDialog,
              icon: const Icon(Icons.add, size: 20),
              label: const Text('Add New Medication'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF10B981),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMedicationItem(MedicationRecord medication) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
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
              Expanded(
                child: Text(
                  medication.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ),
              if (medication.isActive)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    'Active',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF10B981),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '${medication.dosage} • ${medication.frequency}',
            style: const TextStyle(
              fontSize: 14,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Prescribed by: ${medication.prescribedBy}',
            style: const TextStyle(
              fontSize: 12,
              color: AppTheme.textSecondary,
            ),
          ),
          if (medication.instructions.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              'Instructions: ${medication.instructions}',
              style: const TextStyle(
                fontSize: 12,
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return const Color(0xFF10B981);
      case 'ongoing':
        return const Color(0xFF6366F1);
      case 'cancelled':
        return const Color(0xFFEF4444);
      default:
        return const Color(0xFFF59E0B);
    }
  }

  Color _getLabStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'normal':
        return const Color(0xFF10B981);
      case 'abnormal':
        return const Color(0xFFF59E0B);
      case 'critical':
        return const Color(0xFFEF4444);
      default:
        return const Color(0xFF6B7280);
    }
  }

  void _showVitalSignsDialog() {
    final weightController = TextEditingController();
    final systolicController = TextEditingController();
    final diastolicController = TextEditingController();
    final heartRateController = TextEditingController();
    final temperatureController = TextEditingController();
    final bloodSugarController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Record Vital Signs'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: weightController,
                decoration: const InputDecoration(labelText: 'Weight (kg)'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: systolicController,
                decoration: const InputDecoration(labelText: 'Systolic BP'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: diastolicController,
                decoration: const InputDecoration(labelText: 'Diastolic BP'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: heartRateController,
                decoration: const InputDecoration(labelText: 'Heart Rate (bpm)'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: temperatureController,
                decoration: const InputDecoration(labelText: 'Temperature (°C)'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: bloodSugarController,
                decoration: const InputDecoration(labelText: 'Blood Sugar (mg/dL)'),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              ref.read(healthRecordsProvider.notifier).addVitalSigns({
                'weight': double.tryParse(weightController.text),
                'systolic_bp': int.tryParse(systolicController.text),
                'diastolic_bp': int.tryParse(diastolicController.text),
                'heart_rate': int.tryParse(heartRateController.text),
                'temperature': double.tryParse(temperatureController.text),
                'blood_sugar': int.tryParse(bloodSugarController.text),
              });
              Navigator.pop(context);
            },
            child: const Text('Record'),
          ),
        ],
      ),
    );
  }

  void _showAddMedicationDialog() {
    final nameController = TextEditingController();
    final dosageController = TextEditingController();
    final frequencyController = TextEditingController();
    final instructionsController = TextEditingController();
    final prescribedByController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Medication'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Medication Name'),
              ),
              TextField(
                controller: dosageController,
                decoration: const InputDecoration(labelText: 'Dosage'),
              ),
              TextField(
                controller: frequencyController,
                decoration: const InputDecoration(labelText: 'Frequency'),
              ),
              TextField(
                controller: instructionsController,
                decoration: const InputDecoration(labelText: 'Instructions'),
                maxLines: 2,
              ),
              TextField(
                controller: prescribedByController,
                decoration: const InputDecoration(labelText: 'Prescribed By'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              ref.read(healthRecordsProvider.notifier).addMedication({
                'name': nameController.text,
                'dosage': dosageController.text,
                'frequency': frequencyController.text,
                'instructions': instructionsController.text,
                'prescribed_by': prescribedByController.text,
              });
              Navigator.pop(context);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}