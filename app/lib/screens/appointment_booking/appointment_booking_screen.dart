import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import '../../themes/app_theme.dart';
import '../../widgets/mobile_layout.dart';
import '../../services/razorpay_service.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

class AppointmentBookingScreen extends ConsumerStatefulWidget {
  const AppointmentBookingScreen({super.key});

  @override
  ConsumerState<AppointmentBookingScreen> createState() => _AppointmentBookingScreenState();
}

class _AppointmentBookingScreenState extends ConsumerState<AppointmentBookingScreen> {
  int _currentStep = 0;
  String? _selectedState;
  String? _selectedCity;
  String? _selectedHospital;
  String? _selectedDisease;
  final _notesController = TextEditingController();

  final List<String> _states = ['Maharashtra', 'Gujarat', 'Karnataka', 'Tamil Nadu'];
  final List<String> _cities = ['Mumbai', 'Pune', 'Ahmedabad', 'Bangalore'];
  final List<String> _hospitals = ['Apollo Hospital', 'Fortis Hospital', 'Max Healthcare'];
  final List<String> _diseases = ['General Checkup', 'Cardiology', 'Orthopedic', 'Dermatology'];

  @override
  Widget build(BuildContext context) {
    return MobileLayout(
      currentRoute: '/dashboard',
      child: Container(
        color: const Color(0xFFF8FAFC),
        child: Stepper(
                currentStep: _currentStep,
                onStepTapped: (step) => setState(() => _currentStep = step),
                controlsBuilder: (context, details) => _buildControls(details),
                steps: [
                  _buildStep(0, 'State', 'Select your state', _buildStateSelection()),
                  _buildStep(1, 'City', 'Choose your city', _buildCitySelection()),
                  _buildStep(2, 'Hospital', 'Pick a hospital', _buildHospitalSelection()),
                  _buildStep(3, 'Disease', 'Select condition', _buildDiseaseSelection()),
                  _buildStep(4, 'Notes', 'Additional details', _buildNotesInput()),
                  _buildStep(5, 'Payment', 'Complete booking', _buildPaymentSection()),
                ],
        ),
      ),
    );
  }



  Step _buildStep(int index, String title, String subtitle, Widget content) {
    return Step(
      title: Text(title),
      content: content,
      isActive: _currentStep >= index,
      state: _currentStep > index ? StepState.complete : StepState.indexed,
    );
  }

  Widget _buildStateSelection() {
    return DropdownButtonFormField<String>(
      value: _selectedState,
      decoration: const InputDecoration(labelText: 'Select State'),
      items: _states.map((state) => DropdownMenuItem(value: state, child: Text(state))).toList(),
      onChanged: (value) => setState(() => _selectedState = value),
    );
  }

  Widget _buildCitySelection() {
    return DropdownButtonFormField<String>(
      value: _selectedCity,
      decoration: const InputDecoration(labelText: 'Select City'),
      items: _cities.map((city) => DropdownMenuItem(value: city, child: Text(city))).toList(),
      onChanged: (value) => setState(() => _selectedCity = value),
    );
  }

  Widget _buildHospitalSelection() {
    return DropdownButtonFormField<String>(
      value: _selectedHospital,
      decoration: const InputDecoration(labelText: 'Select Hospital'),
      items: _hospitals.map((hospital) => DropdownMenuItem(value: hospital, child: Text(hospital))).toList(),
      onChanged: (value) => setState(() => _selectedHospital = value),
    );
  }

  Widget _buildDiseaseSelection() {
    return DropdownButtonFormField<String>(
      value: _selectedDisease,
      decoration: const InputDecoration(labelText: 'Select Condition'),
      items: _diseases.map((disease) => DropdownMenuItem(value: disease, child: Text(disease))).toList(),
      onChanged: (value) => setState(() => _selectedDisease = value),
    );
  }

  Widget _buildNotesInput() {
    return TextFormField(
      controller: _notesController,
      decoration: const InputDecoration(
        labelText: 'Additional Notes',
        hintText: 'Describe your symptoms (10-100 characters)',
      ),
      maxLines: 3,
      maxLength: 100,
    );
  }

  Widget _buildPaymentSection() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF10B981).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Consultation Fee:', style: TextStyle(fontWeight: FontWeight.w600)),
                  const Text('₹500', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 8),
              Text('Hospital: $_selectedHospital', style: const TextStyle(color: AppTheme.textSecondary)),
              Text('Condition: $_selectedDisease', style: const TextStyle(color: AppTheme.textSecondary)),
            ],
          ),
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _processPayment,
            icon: const Icon(Iconsax.card),
            label: const Text('Pay ₹500 & Book'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF10B981),
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildControls(ControlsDetails details) {
    return Row(
      children: [
        if (details.stepIndex > 0)
          TextButton(
            onPressed: details.onStepCancel,
            child: const Text('Back'),
          ),
        const SizedBox(width: 8),
        if (details.stepIndex < 5)
          ElevatedButton(
            onPressed: _canProceed() ? details.onStepContinue : null,
            child: const Text('Next'),
          ),
      ],
    );
  }

  bool _canProceed() {
    switch (_currentStep) {
      case 0: return _selectedState != null;
      case 1: return _selectedCity != null;
      case 2: return _selectedHospital != null;
      case 3: return _selectedDisease != null;
      case 4: return _notesController.text.length >= 10;
      default: return true;
    }
  }

  void _processPayment() {
    RazorpayService.payForAppointment(
      context: context,
      amount: 500.0,
      appointmentId: DateTime.now().millisecondsSinceEpoch.toString(),
      doctorName: _selectedDisease ?? 'Doctor',
      onSuccess: (response) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Appointment booked successfully!')),
        );
        Navigator.of(context).pop();
      },
      onError: (response) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Payment failed: ${response.message}')),
        );
      },
    );
  }
}