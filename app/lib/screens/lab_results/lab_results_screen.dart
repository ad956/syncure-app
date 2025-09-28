import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import '../../themes/app_theme.dart';
import '../../widgets/mobile_layout.dart';

class LabResultsScreen extends ConsumerWidget {
  const LabResultsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MobileLayout(
      currentRoute: '/dashboard',
      child: Container(
        color: const Color(0xFFF8FAFC),
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(child: _buildResultsList()),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))],
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF1F2937)),
          ),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF10B981).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Iconsax.document_text, color: Color(0xFF10B981)),
          ),
          const SizedBox(width: 12),
          const Text(
            'Lab Results',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildResultsList() {
    final results = [
      LabResult(
        testName: 'Complete Blood Count (CBC)',
        date: DateTime.now().subtract(const Duration(days: 2)),
        status: 'Completed',
        hospital: 'Apollo Hospital',
        values: {'Hemoglobin': '14.2 g/dL', 'WBC Count': '7,200/μL', 'Platelet Count': '250,000/μL'},
      ),
      LabResult(
        testName: 'Lipid Profile',
        date: DateTime.now().subtract(const Duration(days: 5)),
        status: 'Completed',
        hospital: 'Fortis Hospital',
        values: {'Total Cholesterol': '180 mg/dL', 'HDL': '45 mg/dL', 'LDL': '110 mg/dL'},
      ),
      LabResult(
        testName: 'Thyroid Function Test',
        date: DateTime.now().subtract(const Duration(hours: 6)),
        status: 'Processing',
        hospital: 'Max Healthcare',
        values: {},
      ),
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: results.length,
      itemBuilder: (context, index) => _buildResultCard(results[index]),
    );
  }

  Widget _buildResultCard(LabResult result) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
                  color: _getStatusColor(result.status).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  _getStatusIcon(result.status),
                  color: _getStatusColor(result.status),
                  size: 16,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      result.testName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      result.hospital,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getStatusColor(result.status).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  result.status,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: _getStatusColor(result.status),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Icon(Iconsax.calendar, size: 14, color: AppTheme.textSecondary),
              const SizedBox(width: 4),
              Text(
                _formatDate(result.date),
                style: const TextStyle(
                  fontSize: 12,
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ),
          if (result.values.isNotEmpty) ...[
            const SizedBox(height: 16),
            const Text(
              'Results:',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            ...result.values.entries.map((entry) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    entry.key,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  Text(
                    entry.value,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ],
              ),
            )),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Iconsax.document_download, size: 16),
                label: const Text('Download Report'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF6366F1),
                  side: const BorderSide(color: Color(0xFF6366F1)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ] else ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF59E0B).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                children: [
                  Icon(Iconsax.clock, size: 16, color: Color(0xFFF59E0B)),
                  SizedBox(width: 8),
                  Text(
                    'Results will be available soon',
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFFF59E0B),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed': return const Color(0xFF10B981);
      case 'processing': return const Color(0xFFF59E0B);
      case 'pending': return const Color(0xFF6B7280);
      default: return const Color(0xFF6B7280);
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'completed': return Iconsax.tick_circle;
      case 'processing': return Iconsax.clock;
      case 'pending': return Iconsax.timer_1;
      default: return Iconsax.document_text;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inDays == 0) return 'Today';
    if (diff.inDays == 1) return 'Yesterday';
    if (diff.inDays < 7) return '${diff.inDays} days ago';
    return '${date.day}/${date.month}/${date.year}';
  }
}

class LabResult {
  final String testName;
  final DateTime date;
  final String status;
  final String hospital;
  final Map<String, String> values;

  LabResult({
    required this.testName,
    required this.date,
    required this.status,
    required this.hospital,
    required this.values,
  });
}