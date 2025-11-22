import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math' as math;
import '../../main.dart';
import '../auth/login_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  late AnimationController _fadeController;
  late AnimationController _scaleController;

  final List<OnboardingData> _pages = [
    OnboardingData(
      title: 'Scan Instantly',
      description: 'Point your camera at any QR code and get instant results with our lightning-fast scanner.',
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF667eea), Color(0xFF764ba2)],
      ),
      lottieAsset: Icons.qr_code_scanner_rounded,
    ),
    OnboardingData(
      title: 'AI-Powered Security',
      description: 'Advanced threat detection analyzes every URL for phishing, malware, and suspicious patterns.',
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFFf093fb), Color(0xFFF5576C)],
      ),
      lottieAsset: Icons.security_rounded,
    ),
    OnboardingData(
      title: 'Safe Browsing',
      description: 'Browse links in our isolated sandbox environment. Your data stays protected, always.',
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF4facfe), Color(0xFF00f2fe)],
      ),
      lottieAsset: Icons.shield_outlined,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();
    
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _fadeController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  void _finishOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_complete', true);
    
    if (mounted) {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => const LoginScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      );
    }
  }

  void _onPageChanged(int page) {
    setState(() => _currentPage = page);
    _fadeController.reset();
    _fadeController.forward();
    _scaleController.reset();
    _scaleController.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Animated gradient background
          AnimatedContainer(
            duration: const Duration(milliseconds: 600),
            decoration: BoxDecoration(
              gradient: _pages[_currentPage].gradient,
            ),
          ),
          
          // Floating particles animation
          ...List.generate(20, (index) => _FloatingParticle(index: index)),
          
          SafeArea(
            child: Column(
              children: [
                // Skip button
                Align(
                  alignment: Alignment.topRight,
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: TextButton(
                      onPressed: _finishOnboarding,
                      child: const Text(
                        'Skip',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
                
                // Page content
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    onPageChanged: _onPageChanged,
                    itemCount: _pages.length,
                    itemBuilder: (context, index) {
                      return _OnboardingPage(
                        data: _pages[index],
                        fadeController: _fadeController,
                        scaleController: _scaleController,
                      );
                    },
                  ),
                ),
                
                // Page indicators
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _pages.length,
                      (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        height: 8,
                        width: _currentPage == index ? 32 : 8,
                        decoration: BoxDecoration(
                          color: _currentPage == index 
                              ? Colors.white 
                              : Colors.white.withOpacity(0.4),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                ),
                
                // Next/Get Started button
                Padding(
                  padding: const EdgeInsets.fromLTRB(40, 0, 40, 40),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: SizedBox(
                      key: ValueKey(_currentPage),
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: () {
                          if (_currentPage == _pages.length - 1) {
                            _finishOnboarding();
                          } else {
                            _pageController.nextPage(
                              duration: const Duration(milliseconds: 400),
                              curve: Curves.easeInOutCubic,
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: _pages[_currentPage].gradient.colors.first,
                          elevation: 8,
                          shadowColor: Colors.black.withOpacity(0.3),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(28),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              _currentPage == _pages.length - 1 
                                  ? 'Get Started' 
                                  : 'Next',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Icon(
                              _currentPage == _pages.length - 1
                                  ? Icons.arrow_forward_rounded
                                  : Icons.arrow_forward_ios_rounded,
                              size: 20,
                            ),
                          ],
                        ),
                      ),
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
}

class OnboardingData {
  final String title;
  final String description;
  final LinearGradient gradient;
  final IconData lottieAsset;

  OnboardingData({
    required this.title,
    required this.description,
    required this.gradient,
    required this.lottieAsset,
  });
}

class _OnboardingPage extends StatelessWidget {
  final OnboardingData data;
  final AnimationController fadeController;
  final AnimationController scaleController;

  const _OnboardingPage({
    required this.data,
    required this.fadeController,
    required this.scaleController,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Animated icon
          ScaleTransition(
            scale: CurvedAnimation(
              parent: scaleController,
              curve: Curves.elasticOut,
            ),
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 30,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Center(
                child: Container(
                  width: 160,
                  height: 160,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    data.lottieAsset,
                    size: 80,
                    color: data.gradient.colors.first,
                  ),
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 60),
          
          // Animated title
          FadeTransition(
            opacity: fadeController,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.3),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: fadeController,
                curve: Curves.easeOut,
              )),
              child: Text(
                data.title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  height: 1.2,
                  letterSpacing: -0.5,
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Animated description
          FadeTransition(
            opacity: fadeController,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.5),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: fadeController,
                curve: Curves.easeOut,
              )),
              child: Text(
                data.description,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white.withOpacity(0.9),
                  height: 1.6,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FloatingParticle extends StatefulWidget {
  final int index;

  const _FloatingParticle({required this.index});

  @override
  State<_FloatingParticle> createState() => _FloatingParticleState();
}

class _FloatingParticleState extends State<_FloatingParticle>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late double _startX;
  late double _startY;
  late double _size;

  @override
  void initState() {
    super.initState();
    final random = math.Random(widget.index);
    _startX = random.nextDouble();
    _startY = random.nextDouble();
    _size = random.nextDouble() * 4 + 2;
    
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: random.nextInt(10) + 10),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Positioned(
          left: MediaQuery.of(context).size.width * _startX,
          top: MediaQuery.of(context).size.height * 
              ((_startY + _controller.value) % 1.0),
          child: Opacity(
            opacity: 0.3,
            child: Container(
              width: _size,
              height: _size,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
            ),
          ),
        );
      },
    );
  }
}
