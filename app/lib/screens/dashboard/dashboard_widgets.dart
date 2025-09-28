import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../themes/app_theme.dart';


mixin DashboardWidgets {
  Widget buildCalendar(DateTime selectedDay, DateTime focusedDay,
      Function(DateTime, DateTime) onDaySelected, BuildContext context) {
    final appointmentDates = <DateTime>[];
    
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
              const Icon(Icons.calendar_today, color: Color(0xFF6366F1), size: 20),
              const SizedBox(width: 8),
              const Text(
                'Appointments',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TableCalendar<dynamic>(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: focusedDay,
            selectedDayPredicate: (day) => isSameDay(selectedDay, day),
            onDaySelected: (selectedDay, focusedDay) {
              onDaySelected(selectedDay, focusedDay);
              final appointment = null;
              if (appointment != null) {
                _showAppointmentPopup(context, appointment);
              }
            },
            calendarFormat: CalendarFormat.month,
            startingDayOfWeek: StartingDayOfWeek.sunday,
            headerVisible: false,
            calendarBuilders: CalendarBuilders(
              defaultBuilder: (context, day, focusedDay) {
                final hasAppointment = appointmentDates.any((date) => 
                  date.year == day.year && date.month == day.month && date.day == day.day);
                
                if (hasAppointment) {
                  return Container(
                    margin: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE95B7B).withOpacity(0.1),
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFFE95B7B), width: 2),
                    ),
                    child: Center(
                      child: Text(
                        '${day.day}',
                        style: const TextStyle(
                          color: Color(0xFFE95B7B),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  );
                }
                return null;
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
                decoration: BoxDecoration(
                  color: const Color(0xFFE95B7B),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'Appointment dates',
                style: TextStyle(
                  fontSize: 12,
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showAppointmentPopup(BuildContext context, Map<String, dynamic> appointment) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE95B7B).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.medical_services,
                        color: Color(0xFFE95B7B),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Appointment Details',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          Text(
                            appointment['time'],
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close, size: 20),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildDetailRow('Doctor:', appointment['doctorName']),
                _buildDetailRow('Specialty:', appointment['specialty']),
                _buildDetailRow('Hospital:', appointment['hospital']),
                _buildDetailRow('Issue:', appointment['issue']),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: appointment['status'] == 'Confirmed' 
                        ? Colors.green.withOpacity(0.1)
                        : Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    appointment['status'],
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: appointment['status'] == 'Confirmed' 
                          ? Colors.green : Colors.orange,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildTabSection(int selectedTabIndex, Function(int) onTabChanged) {
    return Container(
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
          Container(
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Color(0xFFE5E7EB), width: 1),
              ),
            ),
            child: Row(
              children: [
                _buildTab('Pending Bills', 0, selectedTabIndex, onTabChanged,
                    const Color(0xFFEC4899)),
                _buildTab('My Doctors', 1, selectedTabIndex, onTabChanged,
                    const Color(0xFF10B981)),
                _buildTab('Lab Results', 2, selectedTabIndex, onTabChanged,
                    const Color(0xFF3B82F6)),
              ],
            ),
          ),
          Container(
            height: 400,
            padding: const EdgeInsets.all(20),
            child: _buildTabContent(selectedTabIndex),
          ),
        ],
      ),
    );
  }

  Widget _buildTab(String title, int index, int selectedIndex,
      Function(int) onTap, Color color) {
    final isSelected = index == selectedIndex;
    return Expanded(
      child: GestureDetector(
        onTap: () => onTap(index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isSelected ? color : Colors.transparent,
                width: 2,
              ),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (index == 0)
                const Icon(Icons.receipt_long,
                    size: 16, color: Color(0xFFEC4899)),
              if (index == 1)
                const Icon(Icons.medical_services,
                    size: 16, color: Color(0xFF10B981)),
              if (index == 2)
                const Icon(Icons.science, size: 16, color: Color(0xFF3B82F6)),
              const SizedBox(width: 4),
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected ? color : AppTheme.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabContent(int selectedIndex) {
    switch (selectedIndex) {
      case 0:
        return _buildPendingBills();
      case 1:
        return _buildMyDoctors();
      case 2:
        return _buildLabResults();
      default:
        return _buildPendingBills();
    }
  }

  Widget _buildPendingBills() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Recent Bills',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
            ),
            Text(
              '1 pending',
              style: TextStyle(
                fontSize: 14,
                color: Colors.blue[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Expanded(
          child: ListView.builder(
            itemCount: 0,
            itemBuilder: (context, index) {
              final bill = <String, dynamic>{};
              return _buildBillItem(bill);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildBillItem(Map<String, dynamic> bill) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: const Color(0xFFF3F4F6),
            child: const Icon(Icons.local_hospital,
                color: Color(0xFF6B7280), size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  bill['hospital'],
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
                Text(
                  bill['date'],
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
                bill['amount'],
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color:
                      bill['status'] == 'Pending' ? Colors.red : Colors.green,
                ),
              ),
              Text(
                bill['status'] == 'Pending' ? 'Due soon' : 'Paid',
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
  }

  Widget _buildMyDoctors() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Your Doctors',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: ListView.builder(
            itemCount: 0,
            itemBuilder: (context, index) {
              final doctor = <String, dynamic>{};
              return _buildDoctorItem(doctor);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDoctorItem(Map<String, dynamic> doctor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundImage: AssetImage(doctor['avatar']),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  doctor['name'],
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
                Text(
                  doctor['specialty'],
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.textSecondary,
                  ),
                ),
                Row(
                  children: [
                    Icon(
                      Icons.circle,
                      size: 8,
                      color: doctor['isOnline'] ? Colors.green : Colors.grey,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      doctor['isOnline'] ? 'Online' : 'Offline',
                      style: TextStyle(
                        fontSize: 12,
                        color: doctor['isOnline'] ? Colors.green : Colors.grey,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF10B981),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              minimumSize: Size.zero,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            child: const Text(
              'Chat',
              style: TextStyle(
                fontSize: 12,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabResults() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Recent Lab Results',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: ListView.builder(
            itemCount: 0,
            itemBuilder: (context, index) {
              final result = <String, dynamic>{};
              return _buildLabResultItem(result);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildLabResultItem(Map<String, dynamic> result) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: result['status'] == 'Normal'
                  ? Colors.green.withOpacity(0.1)
                  : Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.science,
              color:
                  result['status'] == 'Normal' ? Colors.green : Colors.orange,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  result['testName'],
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
                Text(
                  '${result['date']} • ${result['hospital']}',
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
              color: result['status'] == 'Normal'
                  ? Colors.green.withOpacity(0.1)
                  : Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              result['status'],
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color:
                    result['status'] == 'Normal' ? Colors.green : Colors.orange,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
