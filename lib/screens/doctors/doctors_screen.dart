import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import '../../themes/app_theme.dart';
import '../../widgets/mobile_layout.dart';

class DoctorsScreen extends ConsumerWidget {
  const DoctorsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MobileLayout(
      currentRoute: '/dashboard',
      child: Container(
        color: const Color(0xFFF8FAFC),
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(child: _buildDoctorsList()),
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
              color: const Color(0xFF6366F1).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Iconsax.user, color: Color(0xFF6366F1)),
          ),
          const SizedBox(width: 12),
          const Text(
            'My Doctors',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildDoctorsList() {
    final doctors = [
      Doctor(name: 'Dr. Sarah Wilson', specialty: 'Cardiologist', hospital: 'Apollo Hospital', isOnline: true),
      Doctor(name: 'Dr. Michael Chen', specialty: 'Orthopedic', hospital: 'Fortis Hospital', isOnline: false),
      Doctor(name: 'Dr. Emily Davis', specialty: 'Dermatologist', hospital: 'Max Healthcare', isOnline: true),
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: doctors.length,
      itemBuilder: (context, index) => _buildDoctorCard(doctors[index]),
    );
  }

  Widget _buildDoctorCard(Doctor doctor) {
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
      child: Row(
        children: [
          Stack(
            children: [
              const CircleAvatar(
                radius: 30,
                backgroundImage: AssetImage('assets/images/admin.png'),
              ),
              if (doctor.isOnline)
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    width: 16,
                    height: 16,
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
                  doctor.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  doctor.specialty,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF6366F1),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  doctor.hospital,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: doctor.isOnline 
                    ? const Color(0xFF10B981).withOpacity(0.1)
                    : const Color(0xFF6B7280).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  doctor.isOnline ? 'Online' : 'Offline',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: doctor.isOnline ? const Color(0xFF10B981) : const Color(0xFF6B7280),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Iconsax.message, color: Color(0xFF6366F1), size: 20),
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Iconsax.call, color: Color(0xFF10B981), size: 20),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class Doctor {
  final String name;
  final String specialty;
  final String hospital;
  final bool isOnline;

  Doctor({
    required this.name,
    required this.specialty,
    required this.hospital,
    required this.isOnline,
  });
}