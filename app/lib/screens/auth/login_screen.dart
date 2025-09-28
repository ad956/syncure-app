import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';
import '../../themes/app_theme.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen>
    with TickerProviderStateMixin {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _otpController = TextEditingController();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Row(
        children: [
          // Login Form
          Expanded(
            child: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(40),
                child: AnimatedBuilder(
                  animation: _animationController,
                  builder: (context, child) {
                    return FadeTransition(
                      opacity: _fadeAnimation,
                      child: SlideTransition(
                        position: _slideAnimation,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 40),
                            Row(
                              children: [
                                Container(
                                  width: 40,
                                  height: 40,
                                  child: Image.asset(
                                    'assets/icons/patient.png',
                                    width: 40,
                                    height: 40,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                const Text(
                                  'Syncure',
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 60),
                            const Text(
                              'Welcome Back!',
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Please enter login details below',
                              style: TextStyle(
                                fontSize: 16,
                                color: AppTheme.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 40),
                            _buildTextField(
                              controller: _emailController,
                              hintText: 'Enter username or email',
                              prefixIcon: Icons.alternate_email,
                              suffixIcon: Icons.email_outlined,
                            ),
                            const SizedBox(height: 20),
                            Consumer(
                              builder: (context, ref, child) {
                                final authState = ref.watch(authProvider);
                                
                                if (authState.otpSent) {
                                  return _buildTextField(
                                    controller: _otpController,
                                    hintText: 'Enter OTP sent to your email',
                                    prefixIcon: Icons.security,
                                    suffixIcon: Icons.verified_user_outlined,
                                  );
                                }
                                
                                return _buildTextField(
                                  controller: _passwordController,
                                  hintText: 'Enter password',
                                  prefixIcon: Icons.lock_outline,
                                  suffixIcon: _obscurePassword
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                  obscureText: _obscurePassword,
                                  onSuffixTap: () {
                                    setState(() {
                                      _obscurePassword = !_obscurePassword;
                                    });
                                  },
                                );
                              },
                            ),
                            const SizedBox(height: 20),

                            Align(
                              alignment: Alignment.centerLeft,
                              child: TextButton(
                                onPressed: () {},
                                child: const Text(
                                  'Forget password ?',
                                  style: TextStyle(
                                    color: AppTheme.textSecondary,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            Consumer(
                              builder: (context, ref, child) {
                                final authState = ref.watch(authProvider);
                                
                                // Listen for auth state changes
                                ref.listen(authProvider, (previous, next) {
                                  if (next.user != null) {
                                    context.go('/dashboard');
                                  } else if (next.error != null) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(next.error!),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                  }
                                });
                                
                                return Column(
                                  children: [
                                    if (authState.error != null)
                                      Container(
                                        padding: const EdgeInsets.all(12),
                                        margin: const EdgeInsets.only(bottom: 16),
                                        decoration: BoxDecoration(
                                          color: Colors.red.shade50,
                                          borderRadius: BorderRadius.circular(8),
                                          border: Border.all(color: Colors.red.shade200),
                                        ),
                                        child: Row(
                                          children: [
                                            Icon(Icons.error_outline, color: Colors.red.shade600, size: 20),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: Text(
                                                authState.error!,
                                                style: TextStyle(color: Colors.red.shade600, fontSize: 14),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    Row(
                                  children: [
                                    Expanded(
                                      child: ElevatedButton(
                                        onPressed: authState.isLoading ? null : () {
                                          if (authState.otpSent) {
                                            ref.read(authProvider.notifier).verifyOtp(
                                              authState.email ?? _emailController.text,
                                              _otpController.text,
                                            );
                                          } else {
                                            ref.read(authProvider.notifier).login(
                                              _emailController.text,
                                              _passwordController.text,
                                            );
                                          }
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color(0xFF6B7280),
                                          padding: const EdgeInsets.symmetric(vertical: 16),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                        ),
                                        child: authState.isLoading
                                            ? const SizedBox(
                                                height: 20,
                                                width: 20,
                                                child: CircularProgressIndicator(
                                                  color: Colors.white,
                                                  strokeWidth: 2,
                                                ),
                                              )
                                            : Text(
                                                authState.otpSent ? 'Verify OTP' : 'Sign In',
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                      ),
                                    ),
                                    if (!authState.otpSent)
                                      const SizedBox(width: 16),
                                    if (!authState.otpSent)
                                      Expanded(
                                        child: OutlinedButton(
                                          onPressed: authState.isLoading ? null : () {
                                            ref.read(authProvider.notifier).demoLogin();
                                          },
                                          style: OutlinedButton.styleFrom(
                                            padding: const EdgeInsets.symmetric(vertical: 16),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            side: const BorderSide(color: Color(0xFF6B7280)),
                                          ),
                                          child: const Text(
                                            'Try Demo',
                                            style: TextStyle(
                                              color: Color(0xFF6B7280),
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ),
                                  ],
                                    ),
                                    if (authState.otpSent)
                                      Padding(
                                        padding: const EdgeInsets.only(top: 16),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            const Text(
                                              "Didn't receive OTP? ",
                                              style: TextStyle(color: AppTheme.textSecondary),
                                            ),
                                            TextButton(
                                              onPressed: authState.isLoading ? null : () {
                                                ref.read(authProvider.notifier).login(
                                                  _emailController.text,
                                                  _passwordController.text,
                                                );
                                              },
                                              child: const Text(
                                                'Resend',
                                                style: TextStyle(
                                                  color: AppTheme.primaryColor,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                  ],
                                );
                              },
                            ),
                            const SizedBox(height: 24),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text(
                                  "Don't have an account? ",
                                  style: TextStyle(color: AppTheme.textSecondary),
                                ),
                                TextButton(
                                  onPressed: () => context.go('/signup'),
                                  child: const Text(
                                    'Sign Up',
                                    style: TextStyle(
                                      color: AppTheme.primaryColor,
                                      fontWeight: FontWeight.w600,
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
                ),
              ),
            ),
          ),

        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData prefixIcon,
    IconData? suffixIcon,
    bool obscureText = false,
    VoidCallback? onSuffixTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: const TextStyle(color: Color(0xFF9CA3AF)),
          prefixIcon: Icon(prefixIcon, color: const Color(0xFF6B7280)),
          suffixIcon: suffixIcon != null
              ? GestureDetector(
                  onTap: onSuffixTap,
                  child: Icon(suffixIcon, color: const Color(0xFF6B7280)),
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
    );
  }


}