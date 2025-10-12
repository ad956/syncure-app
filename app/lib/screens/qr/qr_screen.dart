import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../themes/app_theme.dart';
import '../../widgets/mobile_layout.dart';


class QRScreen extends ConsumerStatefulWidget {
  const QRScreen({super.key});

  @override
  ConsumerState<QRScreen> createState() => _QRScreenState();
}

class _QRScreenState extends ConsumerState<QRScreen> with TickerProviderStateMixin {
  late AnimationController _hoverController;
  late AnimationController _rotationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _elevationAnimation;
  late Animation<double> _rotationAnimation;
  late Animation<double> _glowAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _hoverController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _rotationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _hoverController, curve: Curves.elasticOut),
    );
    _elevationAnimation = Tween<double>(begin: 8.0, end: 24.0).animate(
      CurvedAnimation(parent: _hoverController, curve: Curves.easeOutCubic),
    );
    _rotationAnimation = Tween<double>(begin: 0.0, end: 0.02).animate(
      CurvedAnimation(parent: _rotationController, curve: Curves.easeInOut),
    );
    _glowAnimation = Tween<double>(begin: 0.15, end: 0.3).animate(
      CurvedAnimation(parent: _hoverController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _hoverController.dispose();
    _rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MobileLayout(
      currentRoute: '/qr',
      child: Container(
        color: const Color(0xFFF8FAFC),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundImage: const AssetImage('assets/images/admin.png'),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'John Doe',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        Text(
                          '@johndoe',
                          style: const TextStyle(
                            fontSize: 16,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                const Text(
                  'Quick Patient Verification via QR Code',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                const Text(
                  'Receptionists can scan this code to verify your identity instantly and access your medical records for a smoother check-in process.',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppTheme.textSecondary,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                AnimatedBuilder(
                  animation: Listenable.merge([_hoverController, _rotationController]),
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _scaleAnimation.value,
                      child: Transform(
                        alignment: Alignment.center,
                        transform: Matrix4.identity()
                          ..setEntry(3, 2, 0.001)
                          ..rotateX(_rotationAnimation.value)
                          ..rotateY(_rotationAnimation.value * 0.5),
                        child: GestureDetector(
                          onTapDown: (_) {
                            setState(() => _isPressed = true);
                            _hoverController.forward();
                            _rotationController.forward();
                          },
                          onTapUp: (_) {
                            setState(() => _isPressed = false);
                            _hoverController.reverse();
                            _rotationController.reverse();
                          },
                          onTapCancel: () {
                            setState(() => _isPressed = false);
                            _hoverController.reverse();
                            _rotationController.reverse();
                          },
                          onLongPressStart: (_) {
                            _hoverController.forward();
                            _rotationController.repeat(reverse: true);
                          },
                          onLongPressEnd: (_) {
                            _hoverController.reverse();
                            _rotationController.stop();
                            _rotationController.reset();
                          },
                          child: Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF6366F1).withOpacity(_glowAnimation.value),
                                  blurRadius: _elevationAnimation.value,
                                  offset: Offset(0, _elevationAnimation.value / 3),
                                  spreadRadius: _elevationAnimation.value / 4,
                                ),
                                BoxShadow(
                                  color: const Color(0xFFF31260).withOpacity(_glowAnimation.value * 0.5),
                                  blurRadius: _elevationAnimation.value * 0.8,
                                  offset: Offset(0, _elevationAnimation.value / 4),
                                  spreadRadius: 1,
                                ),
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: _elevationAnimation.value / 2,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF8FAFC),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: _isPressed 
                                    ? const Color(0xFF6366F1).withOpacity(0.3)
                                    : Colors.transparent,
                                  width: 2,
                                ),
                              ),
                              child: const QrImageView(
                                data: 'patient_johndoe_syncure_2024',
                                version: QrVersions.auto,
                                size: 180.0,
                                backgroundColor: Color(0xFFF8FAFC),
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 24),
                Text(
                  _isPressed ? 'Hold to see 3D effect!' : 'Tap and hold QR code for 3D effect',
                  style: TextStyle(
                    fontSize: 12,
                    color: _isPressed ? const Color(0xFF6366F1) : AppTheme.textSecondary,
                    fontWeight: _isPressed ? FontWeight.w600 : FontWeight.normal,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.download_rounded),
                    label: const Text('Download QR Code'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE95B7B),
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
          ),
        ),
      ),
    );
  }












}