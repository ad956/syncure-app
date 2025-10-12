import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import '../../themes/app_theme.dart';
import '../../widgets/mobile_layout.dart';
import '../../services/razorpay_service.dart';
import '../../models/booking_data.dart';
import '../../providers/booking_provider.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

class AppointmentBookingScreen extends ConsumerStatefulWidget {
  const AppointmentBookingScreen({super.key});

  @override
  ConsumerState<AppointmentBookingScreen> createState() => _AppointmentBookingScreenState();
}

class _AppointmentBookingScreenState extends ConsumerState<AppointmentBookingScreen> {
  final PageController _pageController = PageController();
  final TextEditingController _notesController = TextEditingController();
  final BookingSelection _selection = BookingSelection();
  
  int _currentPage = 0;
  bool _isLoading = false;
  Map<String, dynamic>? _selectedHospital;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(bookingProvider.notifier).fetchStates();
      ref.read(bookingProvider.notifier).fetchDiseases();
    });
  }

  @override
  Widget build(BuildContext context) {
    return MobileLayout(
      currentRoute: '/appointments',
      child: Container(
        color: const Color(0xFFF8FAFC),
        child: Column(
          children: [
            _buildHeader(),
            _buildProgressIndicator(),
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (page) => setState(() => _currentPage = page),
                children: [
                  _buildStatesPage(),
                  _buildCitiesPage(),
                  _buildHospitalsPage(),
                  _buildDiseasesPage(),
                  _buildNotesPage(),
                  _buildPaymentPage(),
                ],
              ),
            ),
            _buildNavigationButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Book Appointment',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Step ${_currentPage + 1} of 6 - ${_getStepDescription(_currentPage)}',
            style: const TextStyle(
              fontSize: 16,
              color: Color(0xFF6B7280),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      color: Colors.white,
      child: Column(
        children: [
          Row(
            children: List.generate(6, (index) {
              final isActive = index <= _currentPage;
              final isCompleted = index < _currentPage;
              
              return Expanded(
                child: Container(
                  margin: EdgeInsets.only(right: index < 5 ? 8 : 0),
                  child: Column(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: isCompleted 
                              ? const Color(0xFF10B981)
                              : isActive 
                                  ? const Color(0xFF6366F1)
                                  : const Color(0xFFE5E7EB),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          isCompleted ? Icons.check : Icons.circle,
                          color: isActive || isCompleted ? Colors.white : const Color(0xFF9CA3AF),
                          size: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _getStepTitle(index),
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          color: isActive ? const Color(0xFF6366F1) : const Color(0xFF9CA3AF),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 16),
          LinearProgressIndicator(
            value: (_currentPage + 1) / 6,
            backgroundColor: const Color(0xFFE5E7EB),
            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF6366F1)),
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      ),
    );
  }

  String _getStepTitle(int index) {
    switch (index) {
      case 0: return 'State';
      case 1: return 'City';
      case 2: return 'Hospital';
      case 3: return 'Condition';
      case 4: return 'Notes';
      case 5: return 'Payment';
      default: return '';
    }
  }

  String _getStepDescription(int index) {
    switch (index) {
      case 0: return 'Select your state';
      case 1: return 'Choose your city';
      case 2: return 'Pick a hospital';
      case 3: return 'Select condition';
      case 4: return 'Add notes';
      case 5: return 'Complete payment';
      default: return '';
    }
  }

  Widget _buildLoadingGrid() {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 2.5,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: 6,
      itemBuilder: (context, index) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Container(
              width: 60,
              height: 16,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatesPage() {
    final bookingState = ref.watch(bookingProvider);
    return _buildSelectionPage(
      'Select State', 
      bookingState.states.map((e) => e.toString()).toList(), 
      _selection.state, 
      (value) {
        setState(() => _selection.state = value);
        ref.read(bookingProvider.notifier).fetchCities(value);
      },
      isLoading: bookingState.isLoadingStates,
    );
  }

  Widget _buildCitiesPage() {
    final bookingState = ref.watch(bookingProvider);
    return _buildSelectionPage(
      'Select City', 
      bookingState.cities, 
      _selection.city, 
      (value) {
        setState(() => _selection.city = value);
        if (_selection.state != null) {
          ref.read(bookingProvider.notifier).fetchHospitals(_selection.state!, value);
        }
      },
      isLoading: bookingState.isLoadingCities,
    );
  }

  Widget _buildHospitalsPage() {
    final bookingState = ref.watch(bookingProvider);
    return _buildHospitalSelectionPage(
      'Select Hospital', 
      bookingState.hospitals, 
      _selectedHospital, 
      (hospital) {
        setState(() {
          _selectedHospital = hospital;
          _selection.hospital = hospital['hospital_name'];
        });
      },
      isLoading: bookingState.isLoadingHospitals,
    );
  }

  Widget _buildDiseasesPage() {
    final bookingState = ref.watch(bookingProvider);
    return _buildSelectionPage(
      'Select Condition', 
      bookingState.diseases, 
      _selection.disease, 
      (value) => setState(() => _selection.disease = value),
      isLoading: bookingState.isLoadingDiseases,
    );
  }

  Widget _buildHospitalSelectionPage(String title, List<Map<String, dynamic>> hospitals, Map<String, dynamic>? selectedHospital, Function(Map<String, dynamic>) onSelect, {bool isLoading = false}) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Choose from the options below',
            style: const TextStyle(
              fontSize: 16,
              color: Color(0xFF6B7280),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: isLoading 
                ? _buildLoadingGrid()
                : ListView.builder(
              itemCount: hospitals.isEmpty ? 3 : hospitals.length,
              itemBuilder: (context, index) {
                if (hospitals.isEmpty) {
                  return _buildHospitalLoadingItem();
                }
                final hospital = hospitals[index];
                final isSelected = selectedHospital?['hospital_id'] == hospital['hospital_id'];
                
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => onSelect(hospital),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isSelected ? const Color(0xFF6366F1) : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected ? const Color(0xFF6366F1) : const Color(0xFFE5E7EB),
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              hospital['hospital_name'] ?? 'Unknown Hospital',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: isSelected ? Colors.white : const Color(0xFF1F2937),
                              ),
                            ),
                            if (hospital['address'] != null) ...[
                              const SizedBox(height: 4),
                              Text(
                                hospital['address'],
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isSelected ? Colors.white70 : const Color(0xFF6B7280),
                                ),
                              ),
                            ],
                            if (hospital['contact'] != null) ...[
                              const SizedBox(height: 4),
                              Text(
                                hospital['contact'],
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isSelected ? Colors.white70 : const Color(0xFF6B7280),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHospitalLoadingItem() {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 16,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            height: 12,
            width: 200,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectionPage(String title, List<String> options, String? selectedValue, Function(String) onSelect, {bool isLoading = false}) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Choose from the options below',
            style: const TextStyle(
              fontSize: 16,
              color: Color(0xFF6B7280),
            ),
          ),
          const SizedBox(height: 16),
          if (_currentPage == 0)
            Container(
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: const Color(0xFF6366F1).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF6366F1).withOpacity(0.2)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF6366F1).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.location_on, color: Color(0xFF6366F1), size: 20),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Select your state to find nearby hospitals and doctors',
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF4338CA),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          Expanded(
            child: isLoading 
                ? _buildLoadingGrid()
                : GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 2.5,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: options.isEmpty ? 6 : options.length,
              itemBuilder: (context, index) {
                final option = options[index];
                final isSelected = selectedValue == option;
                
                return Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => onSelect(option),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xFF6366F1) : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected ? const Color(0xFF6366F1) : const Color(0xFFE5E7EB),
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          option,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: isSelected ? Colors.white : const Color(0xFF1F2937),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotesPage() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Additional Notes',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Describe your symptoms or concerns (minimum 10 characters)',
            style: TextStyle(
              fontSize: 16,
              color: Color(0xFF6B7280),
            ),
          ),
          const SizedBox(height: 24),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TextFormField(
              controller: _notesController,
              maxLines: 6,
              maxLength: 200,
              onChanged: (value) {
                setState(() => _selection.notes = value);
              },
              decoration: const InputDecoration(
                hintText: 'Describe your symptoms, pain level, duration, etc...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.white,
                contentPadding: EdgeInsets.all(16),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF10B981).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFF10B981).withOpacity(0.2),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.info_outline,
                  color: Color(0xFF10B981),
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Providing detailed information helps doctors prepare better for your consultation.',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF059669),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentPage() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Booking Summary',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 24),
          Container(
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
                _buildSummaryRow('State', _selection.state ?? '', Iconsax.location),
                _buildSummaryRow('City', _selection.city ?? '', Iconsax.buildings),
                _buildSummaryRow('Hospital', _selection.hospital ?? '', Iconsax.hospital),
                _buildSummaryRow('Condition', _selection.disease ?? '', Iconsax.health),
                const Divider(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Consultation Fee',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                    const Text(
                      '₹500',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF10B981),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _isLoading ? null : _processPayment,
              icon: _isLoading 
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Icon(Iconsax.card, size: 20),
              label: Text(_isLoading ? 'Processing...' : 'Pay ₹500 & Book Appointment'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF10B981),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF6366F1).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: const Color(0xFF6366F1), size: 16),
          ),
          const SizedBox(width: 12),
          Text(
            '$label:',
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF6B7280),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1F2937),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationButtons() {
    return Container(
      padding: const EdgeInsets.all(20),
      color: Colors.white,
      child: Row(
        children: [
          if (_currentPage > 0)
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _goToPreviousPage,
                icon: const Icon(Icons.arrow_back, size: 18),
                label: const Text('Previous'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF6366F1),
                  side: const BorderSide(color: Color(0xFF6366F1)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          if (_currentPage > 0) const SizedBox(width: 12),
          if (_currentPage < 5)
            Expanded(
              flex: _currentPage == 0 ? 1 : 1,
              child: ElevatedButton.icon(
                onPressed: _canProceedToNext() ? _goToNextPage : null,
                icon: const Icon(Icons.arrow_forward, size: 18),
                label: const Text('Next'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6366F1),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 0,
                ),
              ),
            ),
        ],
      ),
    );
  }

  bool _canProceedToNext() {
    switch (_currentPage) {
      case 0: return _selection.canProceedToCity;
      case 1: return _selection.canProceedToHospital;
      case 2: return _selection.canProceedToDisease;
      case 3: return _selection.canProceedToNotes;
      case 4: return _selection.canProceedToPayment;
      default: return false;
    }
  }

  void _goToNextPage() {
    if (!_canProceedToNext()) {
      _showValidationError();
      return;
    }
    
    if (_currentPage < 5) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _goToPreviousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _showValidationError() {
    String message = '';
    switch (_currentPage) {
      case 0: message = 'Please select a state to continue';
        break;
      case 1: message = 'Please select a city to continue';
        break;
      case 2: message = 'Please select a hospital to continue';
        break;
      case 3: message = 'Please select a condition to continue';
        break;
      case 4: message = 'Please provide notes (minimum 10 characters)';
        break;
    }
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFFEF4444),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  void _processPayment() async {
    if (_selectedHospital == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a hospital first'),
          backgroundColor: Color(0xFFEF4444),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);
    
    try {
      // Step 1: Check for pending appointments
      final hasPending = await ref.read(bookingProvider.notifier)
          .checkPendingAppointment(_selectedHospital!['hospital_id']);
      
      if (hasPending) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('You already have a pending appointment with this hospital'),
            backgroundColor: Color(0xFFF59E0B),
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }

      // Step 2: Create payment order
      final orderId = await ref.read(bookingProvider.notifier)
          .createPaymentOrder(50000); // 500 INR in paise
      
      if (orderId == null) {
        throw Exception('Failed to create payment order');
      }

      // Step 3: Start Razorpay payment
      RazorpayService.startPayment(
        amount: 500.0,
        orderId: orderId,
        name: 'John Doe', // Replace with actual user name
        email: 'john@example.com', // Replace with actual user email
        contact: '9876543210', // Replace with actual user contact
        description: 'Appointment with ${_selection.disease}',
        onSuccess: (response) => _handlePaymentSuccess(response, orderId),
        onError: (response) => _handlePaymentError(response),
      );
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: const Color(0xFFEF4444),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response, String orderId) async {
    try {
      // Step 4: Verify payment
      final isVerified = await ref.read(bookingProvider.notifier).verifyPayment(
        orderId: orderId,
        paymentId: response.paymentId!,
        signature: response.signature!,
      );

      if (!isVerified) {
        throw Exception('Payment verification failed');
      }

      // Step 5: Book appointment
      final isBooked = await ref.read(bookingProvider.notifier).bookAppointment(
        state: _selection.state!,
        city: _selection.city!,
        hospital: {
          'hospital_id': _selectedHospital!['hospital_id'],
          'hospital_name': _selectedHospital!['hospital_name'],
        },
        disease: _selection.disease!,
        notes: _selection.notes!,
        transactionId: response.paymentId!,
      );

      if (!isBooked) {
        throw Exception('Failed to book appointment');
      }

      setState(() => _isLoading = false);
      _showSuccessToast();
      _resetForm();
      Navigator.of(context).pop();
    } catch (e) {
      setState(() => _isLoading = false);
      _showErrorToast('Booking failed: ${e.toString().replaceAll('Exception: ', '')}');
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    setState(() => _isLoading = false);
    _showErrorToast('Payment failed: ${response.message ?? "Something went wrong"}');
  }

  void _showSuccessToast() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.check_circle,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Appointment booked successfully!',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF10B981),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showErrorToast(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.error,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFFEF4444),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  void _resetForm() {
    setState(() {
      _currentPage = 0;
      _selectedHospital = null;
      _selection.reset();
      _notesController.clear();
    });
    _pageController.animateToPage(
      0,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    _notesController.dispose();
    super.dispose();
  }
}