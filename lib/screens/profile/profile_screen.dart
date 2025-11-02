import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../themes/app_theme.dart';
import '../../widgets/mobile_layout.dart';
import '../../api/api_service.dart';
import '../../providers/auth_provider.dart';
import '../../providers/new_dashboard_provider.dart';
import 'dart:convert';
import 'dart:io';

class FormValidator {
  static String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) return 'Name is required';
    if (value.trim().length < 2) return 'Name must be at least 2 characters';
    return null;
  }

  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) return 'Email is required';
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value.trim())) return 'Enter a valid email';
    return null;
  }

  static String? validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) return 'Phone is required';
    if (value.trim().length < 10) return 'Enter a valid phone number';
    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Password is required';
    if (value.length < 6) return 'Password must be at least 6 characters';
    return null;
  }
}

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final _apiService = ApiService();

  // Form Keys
  final _personalFormKey = GlobalKey<FormState>();
  final _addressFormKey = GlobalKey<FormState>();
  final _securityFormKey = GlobalKey<FormState>();

  // Personal Info Controllers
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _dobController = TextEditingController();
  final _ageController = TextEditingController();
  final _bloodController = TextEditingController();
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();
  String _selectedGender = 'Male';
  String _selectedCountryCode = '+1';

  // Address Controllers
  final _addressLine1Controller = TextEditingController();
  final _addressLine2Controller = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _zipController = TextEditingController();
  final _countryController = TextEditingController();

  // Security Controllers
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();

  // Original data for change detection
  Map<String, dynamic> _originalPersonalData = {};
  Map<String, dynamic> _originalAddressData = {};
  Map<String, dynamic> _profileData = {};

  bool _isLoading = false;
  bool _isLoadingProfile = true;
  bool _isUploadingImage = false;
  bool _obscureCurrentPassword = true;
  bool _obscureNewPassword = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadProfileData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _dobController.dispose();
    _addressLine1Controller.dispose();
    _addressLine2Controller.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _zipController.dispose();
    _countryController.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    super.dispose();
  }

  Future<void> _loadProfileData() async {
    try {
      final response = await _apiService.getProfile();
      final data = response.data['data'] ?? response.data;

      setState(() {
        _profileData = data;
        _firstNameController.text = data['firstname'] ?? '';
        _lastNameController.text = data['lastname'] ?? '';
        _usernameController.text = data['username'] ?? '';
        _emailController.text = data['email'] ?? '';
        _phoneController.text = data['contact'] ?? '';
        _dobController.text = data['dob'] ?? '';
        _selectedGender = data['gender'] ?? 'Male';
        _selectedCountryCode = data['countryCode'] ?? '+1';

        // Physical details
        final physical = data['physicalDetails'] ?? {};
        _ageController.text = physical['age']?.toString() ?? '';
        _bloodController.text = physical['blood'] ?? '';
        _heightController.text = physical['height']?.toString() ?? '';
        _weightController.text = physical['weight']?.toString() ?? '';

        // Address data from nested address object
        final address = data['address'] ?? {};
        _addressLine1Controller.text = address['address_line_1'] ?? '';
        _addressLine2Controller.text = address['address_line_2'] ?? '';
        _cityController.text = address['city'] ?? '';
        _stateController.text = address['state'] ?? '';
        _zipController.text = address['zip_code'] ?? '';
        _countryController.text = address['country'] ?? '';

        // Store original data
        _originalPersonalData = {
          'firstname': _firstNameController.text,
          'lastname': _lastNameController.text,
          'username': _usernameController.text,
          'email': _emailController.text,
          'contact': _phoneController.text,
          'countryCode': _selectedCountryCode,
          'dob': _dobController.text,
          'gender': _selectedGender,
          'physicalDetails': {
            'age': int.tryParse(_ageController.text) ?? 0,
            'blood': _bloodController.text,
            'height': double.tryParse(_heightController.text) ?? 0,
            'weight': double.tryParse(_weightController.text) ?? 0,
          },
        };

        _originalAddressData = {
          'address_line_1': _addressLine1Controller.text,
          'address_line_2': _addressLine2Controller.text,
          'city': _cityController.text,
          'state': _stateController.text,
          'zip_code': _zipController.text,
          'country': _countryController.text,
        };
        _isLoadingProfile = false;
      });
    } catch (e) {
      setState(() => _isLoadingProfile = false);
      _showSnackBar('Failed to load profile data', isError: true);
    }
  }

  bool _hasPersonalChanges() {
    final currentData = {
      'firstname': _firstNameController.text.trim(),
      'lastname': _lastNameController.text.trim(),
      'username': _usernameController.text.trim(),
      'email': _emailController.text.trim(),
      'contact': _phoneController.text.trim(),
      'countryCode': _selectedCountryCode,
      'dob': _dobController.text.trim(),
      'gender': _selectedGender,
      'physicalDetails': {
        'age': int.tryParse(_ageController.text) ?? 0,
        'blood': _bloodController.text.trim(),
        'height': double.tryParse(_heightController.text) ?? 0,
        'weight': double.tryParse(_weightController.text) ?? 0,
      },
    };
    return jsonEncode(_originalPersonalData) != jsonEncode(currentData);
  }

  Future<void> _updatePersonalInfo() async {
    if (!_personalFormKey.currentState!.validate()) return;

    if (!_hasPersonalChanges()) {
      _showSnackBar('No changes detected');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final data = {
        'firstname': _firstNameController.text.trim(),
        'lastname': _lastNameController.text.trim(),
        'username': _usernameController.text.trim(),
        'email': _emailController.text.trim(),
        'contact': _phoneController.text.trim(),
        'countryCode': _selectedCountryCode,
        'dob': _dobController.text.trim(),
        'gender': _selectedGender,
        'physicalDetails': {
          'age': int.tryParse(_ageController.text) ?? 0,
          'blood': _bloodController.text.trim(),
          'height': double.tryParse(_heightController.text) ?? 0,
          'weight': double.tryParse(_weightController.text) ?? 0,
        },
      };

      await _apiService.updatePersonalInfo(data);
      _originalPersonalData = Map.from(data);
      _showSnackBar('Profile updated successfully!');
    } catch (e) {
      _showSnackBar('Failed to update profile', isError: true);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _updateAddress() async {
    if (!_addressFormKey.currentState!.validate()) return;

    final currentData = {
      'address_line_1': _addressLine1Controller.text.trim(),
      'address_line_2': _addressLine2Controller.text.trim(),
      'city': _cityController.text.trim(),
      'state': _stateController.text.trim(),
      'zip_code': _zipController.text.trim(),
      'country': _countryController.text.trim(),
    };

    if (jsonEncode(_originalAddressData) == jsonEncode(currentData)) {
      _showSnackBar('No changes detected');
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _apiService.updateAddress(currentData);
      _originalAddressData = Map.from(currentData);
      _showSnackBar('Address updated successfully!');
    } catch (e) {
      _showSnackBar('Failed to update address', isError: true);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _updatePassword() async {
    if (!_securityFormKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await _apiService.resetPassword({
        'currentPassword': _currentPasswordController.text,
        'newPassword': _newPasswordController.text,
      });

      _currentPasswordController.clear();
      _newPasswordController.clear();
      _showSnackBar('Password updated successfully!');
    } catch (e) {
      _showSnackBar('Failed to update password', isError: true);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppTheme.errorColor : AppTheme.successColor,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider).user;
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 768;

    if (_isLoadingProfile) {
      return MobileLayout(
        currentRoute: '/profile',
        child: Container(
          color: AppTheme.backgroundColor,
          child: const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(color: AppTheme.primaryColor),
                SizedBox(height: 16),
                Text(
                  'Loading profile...',
                  style: TextStyle(
                    fontSize: 16,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return MobileLayout(
      currentRoute: '/profile',
      child: Container(
        color: AppTheme.backgroundColor,
        child: Column(
          children: [
            _buildProfileHeader(user, isTablet),
            _buildTabBar(isTablet),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildPersonalInfoTab(isTablet),
                  _buildAddressInfoTab(isTablet),
                  _buildSecurityTab(isTablet),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickAndUploadImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() => _isUploadingImage = true);

      try {
        print('Starting image upload process...');

        // Upload to Cloudinary
        final imageUrl = await _uploadToCloudinary(File(pickedFile.path));
        print('Image uploaded to Cloudinary: $imageUrl');

        // Update profile picture via API
        print('Updating profile picture via API...');
        final response = await _apiService.updateProfilePicture(imageUrl);
        print('API response: ${response.data}');

        // Reload profile to get updated data
        await _loadProfileData();

        // Refresh auth provider to update app bar
        ref.read(authProvider.notifier).loadSession();

        // Refresh dashboard provider to update patient card
        ref.read(newDashboardProvider.notifier).fetchDashboard();

        _showSnackBar('Profile picture updated successfully!');
      } catch (e) {
        print('Profile picture update error: $e');
        String errorMessage = 'Failed to update profile picture';
        if (e.toString().contains('500')) {
          errorMessage = 'Server error. Please try again later.';
        } else if (e.toString().contains('400')) {
          errorMessage = 'Invalid image format. Please try a different image.';
        } else if (e.toString().contains('network')) {
          errorMessage = 'Network error. Check your connection.';
        }
        _showSnackBar(errorMessage, isError: true);
      } finally {
        setState(() => _isUploadingImage = false);
      }
    }
  }

  Future<String> _uploadToCloudinary(File imageFile) async {
    try {
      // Step 1: Get signature from backend
      final timestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      final publicId = 'profile_${timestamp}';

      final signResponse = await _apiService.uploadImage({
        'paramsToSign': {
          'timestamp': timestamp.toString(),
          'folder': 'syncure',
          'public_id': publicId,
        }
      });

      if (signResponse.statusCode != 200) {
        throw Exception('Failed to get signature: ${signResponse.data}');
      }

      final signature = signResponse.data['signature'];
      final apiKey = dotenv.env['CLOUDINARY_API_KEY']!;

      // Step 2: Upload to Cloudinary using multipart
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(imageFile.path),
        'timestamp': timestamp.toString(),
        'folder': 'syncure',
        'public_id': publicId,
        'api_key': apiKey,
        'signature': signature,
      });

      final uploadResponse = await Dio().post(
        'https://api.cloudinary.com/v1_1/doahnjt5z/image/upload',
        data: formData,
      );

      if (uploadResponse.statusCode == 200) {
        print(
            'Cloudinary upload response: ${uploadResponse.data['secure_url']}');
        return uploadResponse.data['secure_url'];
      }

      throw Exception('Upload failed: ${uploadResponse.data}');
    } catch (e) {
      print('Cloudinary upload error: $e');
      throw Exception('Failed to upload image: $e');
    }
  }

  Widget _buildProfileHeader(user, bool isTablet) {
    final profileImage =
        _profileData['profile'] ?? _profileData['image'] ?? user?.image;
    final displayName =
        _profileData['firstname'] != null && _profileData['lastname'] != null
            ? '${_profileData['firstname']} ${_profileData['lastname']}'
            : (user?.name ?? 'User Name');
    final username = _profileData['username'] ?? 'username';

    return Container(
      width: double.infinity,
      margin: EdgeInsets.all(isTablet ? 24 : 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.primaryColor,
            AppTheme.primaryColor.withOpacity(0.8)
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withOpacity(0.3),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            top: -50,
            right: -50,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.1),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(isTablet ? 32 : 24),
            child: Column(
              children: [
                Stack(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.2),
                      ),
                      child: CircleAvatar(
                        radius: isTablet ? 60 : 50,
                        backgroundColor: Colors.white.withOpacity(0.3),
                        backgroundImage:
                            profileImage != null && profileImage.isNotEmpty
                                ? NetworkImage(profileImage)
                                : null,
                        child: profileImage == null || profileImage.isEmpty
                            ? Icon(
                                Icons.person,
                                size: isTablet ? 60 : 50,
                                color: Colors.white.withOpacity(0.8),
                              )
                            : null,
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: _pickAndUploadImage,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: _isUploadingImage
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        AppTheme.primaryColor),
                                  ),
                                )
                              : const Icon(
                                  Icons.edit,
                                  size: 16,
                                  color: AppTheme.primaryColor,
                                ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Text(
                  displayName,
                  style: TextStyle(
                    fontSize: isTablet ? 28 : 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '@$username',
                  style: TextStyle(
                    fontSize: isTablet ? 18 : 16,
                    color: Colors.white.withOpacity(0.9),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar(bool isTablet) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: isTablet ? 24 : 16),
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TabBar(
        controller: _tabController,
        labelColor: Colors.white,
        unselectedLabelColor: AppTheme.textSecondary,
        labelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
        unselectedLabelStyle:
            const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
        indicator: BoxDecoration(
          color: AppTheme.primaryColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryColor.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        tabs: const [
          Tab(
            icon: Icon(Icons.person_outline, size: 20),
            text: 'Personal',
          ),
          Tab(
            icon: Icon(Icons.location_on_outlined, size: 20),
            text: 'Address',
          ),
          Tab(
            icon: Icon(Icons.security_outlined, size: 20),
            text: 'Security',
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalInfoTab(bool isTablet) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(isTablet ? 24 : 16),
      child: Form(
        key: _personalFormKey,
        child: Column(
          children: [
            _buildInfoCard(
              'Basic Information',
              'Personal details and contact info',
              Icons.person_outline,
              [
                Row(
                  children: [
                    Expanded(
                        child: _buildValidatedField('First Name',
                            _firstNameController, FormValidator.validateName)),
                    const SizedBox(width: 16),
                    Expanded(
                        child: _buildValidatedField('Last Name',
                            _lastNameController, FormValidator.validateName)),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                        child: _buildValidatedField('Username',
                            _usernameController, FormValidator.validateName)),
                    const SizedBox(width: 16),
                    Expanded(
                        child: _buildValidatedField('Email', _emailController,
                            FormValidator.validateEmail,
                            suffixIcon: Icons.email_outlined)),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                        child: _buildDropdown(
                            'Gender',
                            _selectedGender,
                            ['Male', 'Female', 'Other'],
                            (v) => setState(() => _selectedGender = v!))),
                    const SizedBox(width: 16),
                    Expanded(
                        child: _buildValidatedField(
                            'Date of Birth', _dobController, null,
                            suffixIcon: Icons.calendar_today_outlined)),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                        flex: 1,
                        child: _buildDropdown(
                            'Code',
                            _selectedCountryCode,
                            ['+1', '+91', '+44', '+61'],
                            (v) => setState(() => _selectedCountryCode = v!))),
                    const SizedBox(width: 16),
                    Expanded(
                        flex: 2,
                        child: _buildValidatedField('Phone', _phoneController,
                            FormValidator.validatePhone)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildInfoCard(
              'Physical Details',
              'Health and body measurements',
              Icons.health_and_safety_outlined,
              [
                Row(
                  children: [
                    Expanded(
                        child: _buildValidatedField('Age', _ageController, null,
                            keyboardType: TextInputType.number)),
                    const SizedBox(width: 16),
                    Expanded(
                        child: _buildValidatedField(
                            'Blood Group', _bloodController, null)),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                        child: _buildValidatedField(
                            'Height (cm)', _heightController, null,
                            keyboardType: TextInputType.number)),
                    const SizedBox(width: 16),
                    Expanded(
                        child: _buildValidatedField(
                            'Weight (kg)', _weightController, null,
                            keyboardType: TextInputType.number)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildUpdateButton('Update Profile', _updatePersonalInfo),
          ],
        ),
      ),
    );
  }

  Widget _buildAddressInfoTab(bool isTablet) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(isTablet ? 24 : 16),
      child: Form(
        key: _addressFormKey,
        child: Column(
          children: [
            _buildInfoCard(
              'Address Information',
              'Your residential address details',
              Icons.location_on_outlined,
              [
                _buildValidatedField(
                    'Address Line 1',
                    _addressLine1Controller,
                    (v) => v?.trim().isEmpty == true
                        ? 'Address is required'
                        : null),
                const SizedBox(height: 16),
                _buildValidatedField(
                    'Address Line 2', _addressLine2Controller, null),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                        child: _buildValidatedField(
                            'City',
                            _cityController,
                            (v) => v?.trim().isEmpty == true
                                ? 'City is required'
                                : null)),
                    const SizedBox(width: 16),
                    Expanded(
                        child: _buildValidatedField(
                            'State',
                            _stateController,
                            (v) => v?.trim().isEmpty == true
                                ? 'State is required'
                                : null)),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                        child: _buildValidatedField(
                            'Zip Code',
                            _zipController,
                            (v) => v?.trim().isEmpty == true
                                ? 'Zip code is required'
                                : null)),
                    const SizedBox(width: 16),
                    Expanded(
                        child: _buildValidatedField(
                            'Country',
                            _countryController,
                            (v) => v?.trim().isEmpty == true
                                ? 'Country is required'
                                : null)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildUpdateButton('Update Address', _updateAddress),
          ],
        ),
      ),
    );
  }

  Widget _buildSecurityTab(bool isTablet) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(isTablet ? 24 : 16),
      child: Form(
        key: _securityFormKey,
        child: Column(
          children: [
            _buildInfoCard(
              'Security Settings',
              'Change your account password',
              Icons.security_outlined,
              [
                _buildPasswordField(
                    'Current Password',
                    _currentPasswordController,
                    _obscureCurrentPassword,
                    () => setState(() =>
                        _obscureCurrentPassword = !_obscureCurrentPassword),
                    FormValidator.validatePassword),
                const SizedBox(height: 16),
                _buildPasswordField(
                    'New Password',
                    _newPasswordController,
                    _obscureNewPassword,
                    () => setState(
                        () => _obscureNewPassword = !_obscureNewPassword),
                    FormValidator.validatePassword),
              ],
            ),
            const SizedBox(height: 24),
            _buildUpdateButton('Update Password', _updatePassword),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(
      String title, String subtitle, IconData icon, List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: AppTheme.primaryColor, size: 22),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppTheme.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),
          ...children,
        ],
      ),
    );
  }

  Widget _buildValidatedField(String label, TextEditingController controller,
      String? Function(String?)? validator,
      {IconData? suffixIcon, TextInputType? keyboardType}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          validator: validator,
          keyboardType: keyboardType,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.grey[50],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[200]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[200]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
                  const BorderSide(color: AppTheme.primaryColor, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppTheme.errorColor),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            suffixIcon: suffixIcon != null
                ? Icon(suffixIcon, color: AppTheme.textSecondary, size: 20)
                : null,
          ),
        ),
      ],
    );
  }

  Widget _buildUpdateButton(String text, VoidCallback onPressed) {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primaryColor,
            AppTheme.primaryColor.withOpacity(0.8)
          ],
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withOpacity(0.3),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: _isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        ),
        child: _isLoading
            ? const SizedBox(
                height: 22,
                width: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Text(
                text,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                  letterSpacing: 0.5,
                ),
              ),
      ),
    );
  }

  Widget _buildDropdown(String label, String value, List<String> items,
      ValueChanged<String?> onChanged) {
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
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFFE5E7EB)),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButtonFormField<String>(
            value: value,
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            items: items.map((String item) {
              return DropdownMenuItem<String>(
                value: item,
                child: Text(item),
              );
            }).toList(),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordField(
      String label,
      TextEditingController controller,
      bool obscure,
      VoidCallback toggleObscure,
      String? Function(String?)? validator) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: obscure,
          validator: validator,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.grey[50],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[200]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[200]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
                  const BorderSide(color: AppTheme.primaryColor, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppTheme.errorColor),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            suffixIcon: IconButton(
              icon: Icon(
                obscure
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                color: AppTheme.textSecondary,
              ),
              onPressed: toggleObscure,
            ),
          ),
        ),
      ],
    );
  }
}
