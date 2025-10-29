import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../themes/app_theme.dart';
import '../../widgets/mobile_layout.dart';
import '../../providers/auth_provider.dart';
import '../../providers/appointments_provider.dart';

class AppointmentsScreen extends ConsumerStatefulWidget {
  const AppointmentsScreen({super.key});

  @override
  ConsumerState<AppointmentsScreen> createState() => _AppointmentsScreenState();
}

class _AppointmentsScreenState extends ConsumerState<AppointmentsScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  String _selectedState = '';
  String _selectedCity = '';
  String _selectedHospital = '';
  String _selectedDisease = '';
  final TextEditingController _notesController = TextEditingController();
  
  List<String> _states = [];
  List<String> _cities = [];
  List<String> _hospitals = [];
  List<String> _diseases = [];
  
  bool _isLoadingStates = false;
  bool _isLoadingCities = false;
  bool _isLoadingHospitals = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
    
    // Fetch appointments data and load initial data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(appointmentsProvider.notifier).fetchAppointments();
      _loadStates();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MobileLayout(
      currentRoute: '/appointments',
      child: Container(
        color: const Color(0xFFF8FAFC),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: AnimatedBuilder(
            animation: _fadeAnimation,
            builder: (context, child) {
              return FadeTransition(
                opacity: _fadeAnimation,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(),
                    const SizedBox(height: 24),
                    _buildBookingForm(),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }



  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Consumer(
          builder: (context, ref, child) {
            final authState = ref.watch(authProvider);
            final userName = authState.user?.firstName ?? 'User';
            return Text(
              'Welcome to your appointments, $userName!',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
                height: 1.3,
              ),
            );
          },
        ),
        const SizedBox(height: 12),
        const Text(
          'Book your medical appointments easily. Select your preferred location, hospital, and provide your health concerns to get started.',
          style: TextStyle(
            fontSize: 15,
            color: AppTheme.textSecondary,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          height: 140,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFF6366F1).withOpacity(0.1),
                const Color(0xFFE95B7B).withOpacity(0.1),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFF6366F1).withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF6366F1).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.calendar_today_rounded,
                  size: 32,
                  color: Color(0xFF6366F1),
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Schedule Your Appointment',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
              const Text(
                'Quick & Easy Booking',
                style: TextStyle(
                  fontSize: 12,
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBookingForm() {
    return Container(
      padding: const EdgeInsets.all(20),
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
          const Text(
            'Book an appointment',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 20),
          _buildDropdown(
            'Select State *',
            _selectedState,
            _states,
            (value) {
              setState(() {
                _selectedState = value!;
                _selectedCity = '';
                _selectedHospital = '';
                _cities = [];
                _hospitals = [];
              });
              _loadCities(_selectedState);
            },
            isLoading: _isLoadingStates,
          ),
          const SizedBox(height: 16),
          _buildDropdown(
            'Select City *',
            _selectedCity,
            _cities,
            (value) {
              setState(() {
                _selectedCity = value!;
                _selectedHospital = '';
                _hospitals = [];
              });
              _loadHospitals(_selectedCity);
            },
            isLoading: _isLoadingCities,
            enabled: _selectedState.isNotEmpty,
          ),
          const SizedBox(height: 16),
          _buildDropdown(
            'Select Hospital *',
            _selectedHospital,
            _hospitals,
            (value) => setState(() => _selectedHospital = value!),
            isLoading: _isLoadingHospitals,
            enabled: _selectedCity.isNotEmpty,
          ),
          const SizedBox(height: 16),
          _buildDropdown(
            'Select Disease *',
            _selectedDisease,
            _diseases,
            (value) => setState(() => _selectedDisease = value!),
          ),
          const SizedBox(height: 16),
          _buildTextField(
            'Additional Note *',
            'Enter your description',
            _notesController,
            maxLines: 4,
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Appointment request submitted successfully!'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE95B7B),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Request Appointment',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _loadStates() async {
    setState(() => _isLoadingStates = true);
    try {
      await Future.delayed(const Duration(milliseconds: 500));
      setState(() {
        _states = ['Maharashtra', 'Karnataka', 'Tamil Nadu', 'Gujarat', 'Rajasthan'];
        _diseases = ['General Consultation', 'Fever', 'Cold & Cough', 'Headache', 'Stomach Pain'];
        _isLoadingStates = false;
      });
    } catch (e) {
      setState(() => _isLoadingStates = false);
    }
  }
  
  Future<void> _loadCities(String state) async {
    setState(() => _isLoadingCities = true);
    try {
      await Future.delayed(const Duration(milliseconds: 500));
      setState(() {
        _cities = _getCitiesForState(state);
        _isLoadingCities = false;
      });
    } catch (e) {
      setState(() => _isLoadingCities = false);
    }
  }
  
  Future<void> _loadHospitals(String city) async {
    setState(() => _isLoadingHospitals = true);
    try {
      await Future.delayed(const Duration(milliseconds: 500));
      setState(() {
        _hospitals = _getHospitalsForCity(city);
        _isLoadingHospitals = false;
      });
    } catch (e) {
      setState(() => _isLoadingHospitals = false);
    }
  }
  
  List<String> _getCitiesForState(String state) {
    switch (state) {
      case 'Maharashtra':
        return ['Mumbai', 'Pune', 'Nagpur'];
      case 'Karnataka':
        return ['Bangalore', 'Mysore', 'Hubli'];
      case 'Tamil Nadu':
        return ['Chennai', 'Coimbatore', 'Madurai'];
      case 'Gujarat':
        return ['Ahmedabad', 'Surat', 'Vadodara'];
      case 'Rajasthan':
        return ['Jaipur', 'Jodhpur', 'Udaipur'];
      default:
        return [];
    }
  }
  
  List<String> _getHospitalsForCity(String city) {
    switch (city) {
      case 'Mumbai':
        return ['Apollo Hospital Mumbai', 'Fortis Hospital Mulund', 'Lilavati Hospital'];
      case 'Bangalore':
        return ['Manipal Hospital', 'Narayana Health City', 'Apollo Hospital Bangalore'];
      case 'Chennai':
        return ['Apollo Hospital Chennai', 'Fortis Malar Hospital', 'MIOT International'];
      default:
        return ['City General Hospital', 'Metro Medical Center'];
    }
  }

  Widget _buildDropdown(String label, String value, List<String> items, Function(String?) onChanged, {bool isLoading = false, bool enabled = true}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppTheme.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: value.isEmpty ? null : value,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppTheme.primaryColor, width: 2),
            ),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            suffixIcon: isLoading 
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: Padding(
                      padding: EdgeInsets.all(12),
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                : null,
          ),
          hint: Text(
            enabled ? label.replaceAll(' *', '') : 'Select previous option first',
            style: TextStyle(
              color: enabled ? const Color(0xFF9CA3AF) : const Color(0xFFD1D5DB),
            ),
          ),
          items: items.map((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(item),
            );
          }).toList(),
          onChanged: enabled && !isLoading ? onChanged : null,
        ),
      ],
    );
  }

  Widget _buildTextField(String label, String hint, TextEditingController controller, {int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppTheme.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Color(0xFF9CA3AF)),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppTheme.primaryColor, width: 2),
            ),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      ],
    );
  }
}