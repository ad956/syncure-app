import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';
import 'dart:ui' as ui;
import 'dart:typed_data';
import '../../themes/app_theme.dart';
import '../../widgets/responsive_layout.dart';
import '../../widgets/common_widgets.dart';
import '../../widgets/safe_widget.dart';
import '../../widgets/loading_skeleton.dart';
import '../../services/toast_service.dart';
import '../../services/razorpay_service.dart';
import '../../providers/new_dashboard_provider.dart';
import '../../providers/appointments_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/dashboard.dart';
import '../../models/appointment.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  late DateTime _selectedDay;
  late DateTime _focusedDay;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedDay = DateTime(now.year, now.month, now.day);
    _focusedDay = DateTime(now.year, now.month, now.day);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(newDashboardProvider.notifier).fetchDashboard();
      ref.read(appointmentsProvider.notifier).fetchAppointments();
    });
  }



  @override
  Widget build(BuildContext context) {
    final dashboard = ref.watch(newDashboardProvider);
    
    return ResponsiveLayout(
      currentRoute: '/dashboard',
      child: ResponsiveBuilder(
        mobile: _buildMobileLayout(dashboard),
        tablet: _buildTabletLayout(dashboard),
        desktop: _buildDesktopLayout(dashboard),
      ),
    );
  }

  Widget _buildMobileLayout(DashboardResponse? dashboard) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildWelcomeHeader(dashboard),
          const SizedBox(height: 16),
          _buildPatientCard(dashboard),
          const SizedBox(height: 16),
          _buildHealthMetricsRow(dashboard),
          const SizedBox(height: 16),
          _buildTodaysVitals(dashboard),
          const SizedBox(height: 16),
          _buildQuickActions(),
          const SizedBox(height: 16),
          _buildUpcomingAppointments(dashboard),
          const SizedBox(height: 16),
          _buildPendingBills(),
          const SizedBox(height: 16),
          _buildMedications(dashboard),
        ],
      ),
    );
  }

  Widget _buildTabletLayout(DashboardResponse? dashboard) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildWelcomeHeader(dashboard),
          const SizedBox(height: 24),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 2,
                child: Column(
                  children: [
                    _buildPatientCard(dashboard),
                    const SizedBox(height: 24),
                    _buildTodaysVitals(dashboard),
                  ],
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: Column(
                  children: [
                    _buildHealthMetricsRow(dashboard),
                    const SizedBox(height: 24),
                    _buildQuickActions(),
                    const SizedBox(height: 24),
                    _buildMedications(dashboard),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopLayout(DashboardResponse? dashboard) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildWelcomeHeader(dashboard),
          const SizedBox(height: 32),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 3,
                child: Column(
                  children: [
                    _buildPatientCard(dashboard),
                    const SizedBox(height: 32),
                    _buildTodaysVitals(dashboard),
                  ],
                ),
              ),
              const SizedBox(width: 32),
              Expanded(
                flex: 2,
                child: Column(
                  children: [
                    _buildHealthMetricsRow(dashboard),
                    const SizedBox(height: 32),
                    _buildQuickActions(),
                    const SizedBox(height: 32),
                    _buildMedications(dashboard),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeHeader(DashboardResponse? dashboard) {
    final now = DateTime.now();
    final timeString = DateFormat('h:mm:ss a').format(now);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Welcome back, ${dashboard?.patient.firstname ?? 'John'}!',
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            const Icon(Icons.check_circle, color: Color(0xFF10B981), size: 16),
            const SizedBox(width: 8),
            const Text(
              'Your health data is secure and up to date',
              style: TextStyle(
                fontSize: 14,
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPatientCard(DashboardResponse? dashboard) {
    final patient = dashboard?.patient;
    
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
        children: [
          Row(
            children: [
              Stack(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundImage: patient?.profile != null 
                        ? NetworkImage(patient!.profile!) 
                        : const AssetImage('assets/images/admin.png') as ImageProvider,
                  ),
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      patient?.name ?? 'John Doe',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.phone, size: 14, color: AppTheme.textSecondary),
                        const SizedBox(width: 4),
                        Text(
                          '+91 ${patient?.contact ?? '9876543210'}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        const Icon(Icons.email, size: 14, color: AppTheme.textSecondary),
                        const SizedBox(width: 4),
                        Text(
                          patient?.email ?? 'john@example.com',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () => _downloadPatientCard(patient),
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: QrImageView(
                    data: patient?.email ?? 'johndoe@example.com',
                    version: QrVersions.auto,
                    size: 80,
                    backgroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildInfoCard('Patient ID', '#f171e', Icons.badge),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildInfoCard('Age', '21 years', Icons.cake),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildInfoCard('Blood Type', 'O+', Icons.bloodtype),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'Scan at hospital reception\nfor instant check-in',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _downloadPatientCard(patient),
              icon: const Icon(Icons.download, size: 16),
              label: const Text('Download Patient Card'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6366F1),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(String label, String value, IconData icon) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            color: AppTheme.textSecondary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildHealthMetricsRow(DashboardResponse? dashboard) {
    final metrics = dashboard?.healthMetrics;
    final nextAppt = dashboard?.nextAppointment;
    
    return SafeWidget(
      fallbackMessage: 'Health metrics error',
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Row(
            children: [
              Expanded(
                child: _buildMetricCard(
                  'NEXT APPOINTMENT',
                  nextAppt != null ? _formatDate(DateTime.parse(nextAppt.date)) : 'Oct 29',
                  nextAppt?.doctor ?? 'Dr. Smith',
                  AppTheme.primaryColor,
                  Iconsax.calendar,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildMetricCard(
                  'ACTIVE MEDS',
                  '${metrics?.activeMedications ?? 3}',
                  'On schedule',
                  const Color(0xFF8B5CF6),
                  Iconsax.health,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildMetricCard(String title, String value, String subtitle, Color color, IconData icon) {
    return Container(
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
              Text(
                title,
                style: const TextStyle(
                  fontSize: 10,
                  color: AppTheme.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Icon(icon, size: 16, color: color),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 12,
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTodaysVitals(DashboardResponse? dashboard) {
    final vitals = dashboard?.todaysVitals.isNotEmpty == true 
        ? dashboard!.todaysVitals.first 
        : null;
    
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
                  color: const Color(0xFFEF4444).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Iconsax.heart, color: Color(0xFFEF4444), size: 20),
              ),
              const SizedBox(width: 12),
              const Text(
                "Today's Vitals",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: () => _showRecordVitalsDialog(),
                icon: const Icon(Icons.add, size: 16),
                label: const Text('Record Vitals'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6366F1),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  textStyle: const TextStyle(fontSize: 12),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (vitals != null) ...[
            SafeRow(
              children: [
                Expanded(
                  child: _buildVitalCard(
                    'Weight',
                    '${vitals.weight?.toInt() ?? 56} kg',
                    Iconsax.weight,
                    AppTheme.primaryColor,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildVitalCard(
                    'Blood Pressure',
                    '${vitals.systolicBp ?? 120}/${vitals.diastolicBp ?? 80}',
                    Iconsax.heart,
                    const Color(0xFFEF4444),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildVitalCard(
                    'Heart Rate',
                    '${vitals.heartRate ?? 72} bpm',
                    Iconsax.activity,
                    const Color(0xFFEF4444),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildVitalCard(
                    'Blood Sugar',
                    '${vitals.bloodSugar ?? 95} mg/dL',
                    Iconsax.drop,
                    const Color(0xFFF59E0B),
                  ),
                ),
              ],
            ),
          ] else ...[
            Container(
              padding: const EdgeInsets.all(32),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF6366F1).withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Iconsax.heart,
                      size: 32,
                      color: Color(0xFF6366F1),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'No vitals recorded today',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Record your vital signs to track your health progress',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppTheme.textSecondary,
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

  Widget _buildVitalCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 16),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return SafeRow(
      children: [
        Expanded(
          child: _buildActionCard(
            'Lab Results',
            Iconsax.document_text,
            const Color(0xFFF59E0B),
            () => context.go('/lab-results'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildActionCard(
            'Health Records',
            Iconsax.activity,
            const Color(0xFF10B981),
            () => context.go('/health-records'),
          ),
        ),
      ],
    );
  }

  Widget _buildActionCard(String title, IconData icon, Color color, VoidCallback onTap) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
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
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 12),
              Flexible(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUpcomingAppointments(DashboardResponse? dashboard) {
    return Consumer(
      builder: (context, ref, child) {
        final appointmentsState = ref.watch(appointmentsProvider);
        final appointmentDates = appointmentsState.appointments.map((a) => a.date).toList();
        
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
                    child: const Icon(Iconsax.calendar, color: Color(0xFF6366F1), size: 20),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Upcoming Appointments',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const Spacer(),
                  if (appointmentsState.isLoading)
                    const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6366F1)),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              TableCalendar<dynamic>(
                firstDay: DateTime.utc(2020, 1, 1),
                lastDay: DateTime.utc(2030, 12, 31),
                focusedDay: _focusedDay,
                selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    _selectedDay = selectedDay;
                    _focusedDay = focusedDay;
                  });
                  final dayAppointments = appointmentsState.appointments.where((appointment) {
                    return appointment.date.year == selectedDay.year &&
                           appointment.date.month == selectedDay.month &&
                           appointment.date.day == selectedDay.day;
                  }).toList();
                  if (dayAppointments.isNotEmpty) {
                    _showAppointmentPopup(context, dayAppointments.first);
                  }
                },
                calendarFormat: CalendarFormat.month,
                startingDayOfWeek: StartingDayOfWeek.sunday,
                headerStyle: const HeaderStyle(
                  formatButtonVisible: false,
                  titleCentered: true,
                  leftChevronIcon: Icon(Icons.chevron_left, color: Color(0xFF6366F1)),
                  rightChevronIcon: Icon(Icons.chevron_right, color: Color(0xFF6366F1)),
                ),
                calendarBuilders: CalendarBuilders(
                  defaultBuilder: (context, day, focusedDay) {
                    final hasAppointment = appointmentDates.any((date) => 
                      date.year == day.year && date.month == day.month && date.day == day.day);
                    
                    if (hasAppointment) {
                      return Container(
                        margin: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF6366F1),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            '${day.day}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      );
                    }
                    return null;
                  },
                  todayBuilder: (context, day, focusedDay) {
                    final hasAppointment = appointmentDates.any((date) => 
                      date.year == day.year && date.month == day.month && date.day == day.day);
                    
                    if (hasAppointment) {
                      return Container(
                        margin: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF6366F1),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            '${day.day}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      );
                    }
                    return Container(
                      margin: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: AppTheme.accentColor.withOpacity(0.3),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '${day.day}',
                          style: const TextStyle(
                            color: AppTheme.textPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    );
                  },
                ),
                calendarStyle: const CalendarStyle(
                  outsideDaysVisible: false,
                  weekendTextStyle: TextStyle(color: AppTheme.textPrimary),
                  holidayTextStyle: TextStyle(color: AppTheme.textPrimary),
                  selectedDecoration: BoxDecoration(
                    color: AppTheme.primaryColor,
                    shape: BoxShape.circle,
                  ),
                  todayDecoration: BoxDecoration(
                    color: AppTheme.accentColor,
                    shape: BoxShape.circle,
                  ),
                  defaultTextStyle: TextStyle(color: AppTheme.textPrimary),
                ),
                daysOfWeekStyle: const DaysOfWeekStyle(
                  weekdayStyle: TextStyle(
                    color: AppTheme.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                  weekendStyle: TextStyle(
                    color: AppTheme.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: const BoxDecoration(
                      color: Color(0xFF6366F1),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${appointmentsState.appointments.length} Appointments',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void _showAppointmentPopup(BuildContext context, Appointment appointment) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Container(
            padding: const EdgeInsets.all(24),
            constraints: const BoxConstraints(maxWidth: 400),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.medical_services,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Appointment Details',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            DateFormat('EEEE, MMM dd, yyyy').format(appointment.date),
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close, size: 24, color: AppTheme.textSecondary),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      _buildDetailRow('Doctor:', appointment.doctorName, Iconsax.user),
                      const SizedBox(height: 12),
                      _buildDetailRow('Specialty:', appointment.doctorSpecialty ?? 'General', Iconsax.health),
                      const SizedBox(height: 12),
                      _buildDetailRow('Hospital:', appointment.hospitalName, Iconsax.hospital),
                      const SizedBox(height: 12),
                      _buildDetailRow('Time:', appointment.appointmentTime ?? 'Not set', Iconsax.clock),
                      const SizedBox(height: 12),
                      _buildDetailRow('Issue:', appointment.disease, Iconsax.note),
                      if (appointment.notes != null) ...[
                        const SizedBox(height: 12),
                        _buildDetailRow('Notes:', appointment.notes!, Iconsax.document_text),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: appointment.status == 'approved' 
                            ? const Color(0xFF10B981).withOpacity(0.1)
                            : const Color(0xFFF59E0B).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: appointment.status == 'approved' 
                              ? const Color(0xFF10B981)
                              : const Color(0xFFF59E0B),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            appointment.status == 'approved' 
                                ? Icons.check_circle 
                                : Icons.schedule,
                            size: 16,
                            color: appointment.status == 'approved' 
                                ? const Color(0xFF10B981)
                                : const Color(0xFFF59E0B),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            appointment.status == 'approved' ? 'Confirmed' : 'Pending',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: appointment.status == 'approved' 
                                  ? const Color(0xFF10B981)
                                  : const Color(0xFFF59E0B),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.of(context).pop();
                        context.go('/appointments');
                      },
                      icon: const Icon(Icons.calendar_today, size: 16),
                      label: const Text('View All'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6366F1),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value, [IconData? icon]) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (icon != null) ...[
          Icon(
            icon,
            size: 16,
            color: const Color(0xFF6366F1),
          ),
          const SizedBox(width: 8),
        ],
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: AppTheme.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              color: AppTheme.textPrimary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPendingBills() {
    final dashboard = ref.watch(newDashboardProvider);
    final pendingBills = dashboard?.pendingBills ?? [];
    
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
                  color: const Color(0xFFF59E0B).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Iconsax.receipt, color: Color(0xFFF59E0B), size: 20),
              ),
              const SizedBox(width: 12),
              const Text(
                'Recent Bills',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (pendingBills.isEmpty) ...[
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
                      Iconsax.receipt,
                      size: 32,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'No pending bills',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'All your bills are up to date',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppTheme.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ] else ...[
            ...pendingBills.take(4).map((bill) => Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFFF59E0B).withOpacity(0.2),
                ),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundImage: bill.hospitalProfile != null
                        ? NetworkImage(bill.hospitalProfile!)
                        : const AssetImage('assets/images/hospital_placeholder.png') as ImageProvider,
                    backgroundColor: const Color(0xFF10B981),
                    child: bill.hospitalProfile == null
                        ? const Icon(
                            Icons.local_hospital,
                            color: Colors.white,
                            size: 16,
                          )
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          bill.hospitalName,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          DateFormat('d MMM yyyy').format(bill.dueDate),
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '₹${bill.amount.toInt()}.00',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFF59E0B),
                        ),
                      ),
                      const SizedBox(height: 4),
                      GestureDetector(
                        onTap: () => _payBill(bill),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFF6366F1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'Pay Now',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            )),
          ],
        ],
      ),
    );
  }

  Widget _buildMedications(DashboardResponse? dashboard) {
    final medications = dashboard?.medications ?? [];
    
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
                'Medications',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Next Medications',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          if (medications.isEmpty) ...[
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
                      Iconsax.health,
                      size: 32,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'No medications today',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ] else ...[
            ...medications.map((med) => _buildMedicationItem(med)),
          ],
        ],
      ),
    );
  }

  Widget _buildMedicationItem(Medication medication) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF10B981).withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF10B981).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Iconsax.health, color: Color(0xFF10B981), size: 16),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  medication.name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${medication.dosage} • ${medication.frequency}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          if (!medication.wasTaken)
            ElevatedButton(
              onPressed: () {
                ref.read(newDashboardProvider.notifier).takeMedication(medication.id);
                ToastService.showSuccess('Medication marked as taken');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF10B981),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                textStyle: const TextStyle(fontSize: 12),
              ),
              child: const Text('Take'),
            )
          else
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF10B981).withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Text(
                'Taken',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF10B981),
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _payBill(PendingBill bill) {
    final dashboard = ref.read(newDashboardProvider);
    final patient = dashboard?.patient;
    
    RazorpayService.startPayment(
      amount: bill.amount,
      orderId: 'bill_${bill.id}',
      name: patient?.name ?? 'John Doe',
      email: patient?.email ?? 'john@example.com',
      contact: patient?.contact ?? '9876543210',
      description: '${bill.description} - ${bill.hospitalName}',
      onSuccess: (PaymentSuccessResponse response) {
        ToastService.showSuccess('Payment successful! Payment ID: ${response.paymentId}');
        // Refresh dashboard to update bills
        ref.read(newDashboardProvider.notifier).fetchDashboard();
      },
      onError: (PaymentFailureResponse response) {
        ToastService.showError('Payment failed: ${response.message}');
      },
    );
  }

  void _showRecordVitalsDialog() {
    final weightController = TextEditingController();
    final systolicController = TextEditingController();
    final diastolicController = TextEditingController();
    final heartRateController = TextEditingController();
    final temperatureController = TextEditingController();
    final bloodSugarController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          padding: const EdgeInsets.all(24),
          constraints: const BoxConstraints(maxWidth: 400),
          child: Column(
            mainAxisSize: MainAxisSize.min,
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
                      Iconsax.heart,
                      color: Color(0xFF6366F1),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Record Vitals',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, size: 20),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              SingleChildScrollView(
                child: Column(
                  children: [
                    _buildVitalInput(
                      controller: weightController,
                      label: 'Weight',
                      unit: 'kg',
                      icon: Iconsax.weight,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildVitalInput(
                            controller: systolicController,
                            label: 'Systolic BP',
                            unit: 'mmHg',
                            icon: Iconsax.heart,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildVitalInput(
                            controller: diastolicController,
                            label: 'Diastolic BP',
                            unit: 'mmHg',
                            icon: Iconsax.heart,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildVitalInput(
                            controller: heartRateController,
                            label: 'Heart Rate',
                            unit: 'bpm',
                            icon: Iconsax.activity,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildVitalInput(
                            controller: temperatureController,
                            label: 'Temperature',
                            unit: '°C',
                            icon: Iconsax.flash,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildVitalInput(
                      controller: bloodSugarController,
                      label: 'Blood Sugar',
                      unit: 'mg/dL',
                      icon: Iconsax.drop,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: () {
                        if (weightController.text.isNotEmpty &&
                            systolicController.text.isNotEmpty &&
                            diastolicController.text.isNotEmpty &&
                            heartRateController.text.isNotEmpty &&
                            temperatureController.text.isNotEmpty &&
                            bloodSugarController.text.isNotEmpty) {
                          ref.read(newDashboardProvider.notifier).recordVitals(
                            weight: double.parse(weightController.text),
                            systolicBp: int.parse(systolicController.text),
                            diastolicBp: int.parse(diastolicController.text),
                            heartRate: int.parse(heartRateController.text),
                            temperature: double.parse(temperatureController.text),
                            bloodSugar: int.parse(bloodSugarController.text),
                          );
                          ToastService.showSuccess('Vitals recorded successfully');
                          Navigator.pop(context);
                        } else {
                          ToastService.showError('Please fill all fields');
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6366F1),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('Record Vitals'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVitalInput({
    required TextEditingController controller,
    required String label,
    required String unit,
    required IconData icon,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          labelText: '$label ($unit)',
          prefixIcon: Icon(icon, color: const Color(0xFF6366F1), size: 20),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          labelStyle: const TextStyle(
            color: AppTheme.textSecondary,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return DateFormat('MMM dd').format(date);
  }

  Future<void> _downloadPatientCard(Patient? patient) async {
    if (patient == null) return;
    
    try {
      // Request storage permission
      PermissionStatus permission;
      if (await Permission.photos.isGranted || await Permission.storage.isGranted) {
        permission = PermissionStatus.granted;
      } else {
        permission = await Permission.photos.request();
        if (permission.isDenied) {
          permission = await Permission.storage.request();
        }
      }
      
      if (permission.isDenied) {
        ToastService.showError('Storage permission denied');
        return;
      }
      
      // Show loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );
      
      // Create widget to capture
      final boundary = GlobalKey();
      final cardWidget = RepaintBoundary(
        key: boundary,
        child: Material(
          color: Colors.white,
          child: Container(
            width: 400,
            height: 600,
            padding: const EdgeInsets.all(20),
            color: Colors.white,
            child: _buildPatientCardForDownload(patient),
          ),
        ),
      );
      
      // Build widget off-screen to capture
      final overlay = Overlay.of(context);
      final overlayEntry = OverlayEntry(
        builder: (context) => Positioned(
          left: -1000,
          top: -1000,
          child: cardWidget,
        ),
      );
      
      overlay.insert(overlayEntry);
      
      // Wait for widget to build
      await Future.delayed(const Duration(milliseconds: 100));
      
      // Capture widget as image
      final RenderRepaintBoundary renderBoundary = 
          boundary.currentContext!.findRenderObject() as RenderRepaintBoundary;
      final ui.Image image = await renderBoundary.toImage(pixelRatio: 3.0);
      final ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final Uint8List pngBytes = byteData!.buffer.asUint8List();
      
      // Save to Downloads
      final fileName = 'patient_card_${DateTime.now().millisecondsSinceEpoch}.png';
      final file = File('/storage/emulated/0/Download/$fileName');
      await file.writeAsBytes(pngBytes);
      
      // Clean up
      overlayEntry.remove();
      Navigator.pop(context); // Close loading
      
      ToastService.showSuccess('Patient card saved to Downloads/$fileName');
      
    } catch (e) {
      Navigator.pop(context); // Close loading if open
      ToastService.showError('Failed to download patient card: ${e.toString()}');
    }
  }

  Widget _buildPatientCardForDownload(Patient patient) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Row(
            children: [
              const Text(
                'SYNCURE',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF6366F1),
                ),
              ),
              const Spacer(),
              const Text(
                'PATIENT CARD',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Patient Info
          Row(
            children: [
              CircleAvatar(
                radius: 40,
                backgroundImage: patient.profile != null 
                    ? NetworkImage(patient.profile!) 
                    : const AssetImage('assets/images/admin.png') as ImageProvider,
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      patient.name,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text('Email: ${patient.email}'),
                    Text('Mobile: +91 ${patient.contact}'),
                    Text('Patient ID: #${patient.id.substring(0, 8)}'),
                  ],
                ),
              ),
              QrImageView(
                data: patient.email,
                version: QrVersions.auto,
                size: 120,
                backgroundColor: Colors.white,
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Physical Details
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildDetailColumn('Age', '${patient.physicalDetails?.age ?? 21}'),
                _buildDetailColumn('Blood Type', patient.physicalDetails?.blood ?? 'O+'),
                _buildDetailColumn('Height', '${patient.physicalDetails?.height ?? 5.6} ft'),
                _buildDetailColumn('Weight', '${patient.physicalDetails?.weight ?? 60} kg'),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Scan this QR code at hospital reception for instant check-in',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailColumn(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}