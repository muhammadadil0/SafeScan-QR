import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../services/security_service.dart';
import 'result_screen.dart';

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> with SingleTickerProviderStateMixin {
  final SecurityService _securityService = SecurityService();
  final MobileScannerController _controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
    returnImage: false,
  );
  bool _isProcessing = false;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) async {
    if (_isProcessing) return;
    
    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;

    final String? code = barcodes.first.rawValue;
    if (code != null) {
      setState(() {
        _isProcessing = true;
      });
      
      // Haptic feedback could be added here
      
      final result = await _securityService.analyzeUrl(code);

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ResultScreen(result: result),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          MobileScanner(
            controller: _controller,
            onDetect: _onDetect,
          ),
          // Dark Overlay with Cutout
          CustomPaint(
            painter: ScannerOverlayPainter(
              borderColor: Colors.blueAccent,
              borderRadius: 20,
              borderLength: 40,
              borderWidth: 8,
              cutoutSize: 280,
            ),
            child: Container(),
          ),
          // Scanning Line Animation
          Center(
            child: SizedBox(
              width: 280,
              height: 280,
              child: AnimatedBuilder(
                animation: _animationController,
                builder: (context, child) {
                  return Stack(
                    children: [
                      Positioned(
                        top: _animationController.value * 280,
                        left: 0,
                        right: 0,
                        child: Container(
                          height: 2,
                          decoration: BoxDecoration(
                            color: Colors.blueAccent,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.blueAccent.withOpacity(0.5),
                                blurRadius: 10,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
          // Top Bar
          Positioned(
            top: 50,
            left: 20,
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          Positioned(
            top: 50,
            right: 20,
            child: IconButton(
              icon: ValueListenableBuilder(
                valueListenable: _controller,
                builder: (context, state, child) {
                  if (state.torchState == TorchState.on) {
                    return const Icon(Icons.flash_on, color: Colors.white);
                  }
                  return const Icon(Icons.flash_off, color: Colors.white);
                },
              ),
              onPressed: () => _controller.toggleTorch(),
            ),
          ),
          // Bottom Text
          const Positioned(
            bottom: 100,
            left: 0,
            right: 0,
            child: Text(
              'Align QR code within the frame',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white70,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ScannerOverlayPainter extends CustomPainter {
  final Color borderColor;
  final double borderRadius;
  final double borderLength;
  final double borderWidth;
  final double cutoutSize;

  ScannerOverlayPainter({
    required this.borderColor,
    required this.borderRadius,
    required this.borderLength,
    required this.borderWidth,
    required this.cutoutSize,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double scanAreaSize = cutoutSize;
    final double left = (size.width - scanAreaSize) / 2;
    final double top = (size.height - scanAreaSize) / 2;
    final double right = left + scanAreaSize;
    final double bottom = top + scanAreaSize;

    // Draw dark overlay
    final Path backgroundPath = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height));
    
    final Path cutoutPath = Path()
      ..addRRect(RRect.fromRectAndRadius(
        Rect.fromLTRB(left, top, right, bottom),
        Radius.circular(borderRadius),
      ));

    final Path overlayPath = Path.combine(
      PathOperation.difference,
      backgroundPath,
      cutoutPath,
    );

    final Paint backgroundPaint = Paint()
      ..color = Colors.black.withOpacity(0.7)
      ..style = PaintingStyle.fill;

    canvas.drawPath(overlayPath, backgroundPaint);

    // Draw corners
    final Paint borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth
      ..strokeCap = StrokeCap.round;

    final Path borderPath = Path();

    // Top Left
    borderPath.moveTo(left, top + borderLength);
    borderPath.lineTo(left, top + borderRadius);
    borderPath.quadraticBezierTo(left, top, left + borderRadius, top);
    borderPath.lineTo(left + borderLength, top);

    // Top Right
    borderPath.moveTo(right - borderLength, top);
    borderPath.lineTo(right - borderRadius, top);
    borderPath.quadraticBezierTo(right, top, right, top + borderRadius);
    borderPath.lineTo(right, top + borderLength);

    // Bottom Right
    borderPath.moveTo(right, bottom - borderLength);
    borderPath.lineTo(right, bottom - borderRadius);
    borderPath.quadraticBezierTo(right, bottom, right - borderRadius, bottom);
    borderPath.lineTo(right - borderLength, bottom);

    // Bottom Left
    borderPath.moveTo(left + borderLength, bottom);
    borderPath.lineTo(left + borderRadius, bottom);
    borderPath.quadraticBezierTo(left, bottom, left, bottom - borderRadius);
    borderPath.lineTo(left, bottom - borderLength);

    canvas.drawPath(borderPath, borderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
