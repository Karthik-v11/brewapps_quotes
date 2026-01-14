import 'package:flutter/material.dart';

class OnboardingPage extends StatefulWidget {
  final VoidCallback? onFinish;
  const OnboardingPage({super.key, this.onFinish});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  void _onPageChanged(int index) {
    setState(() {
      _currentPage = index;
    });
  }

  void _navigateToAuth() {
    if (widget.onFinish != null) {
      widget.onFinish!();
    } else {
      Navigator.of(context).pushReplacementNamed('/auth');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1C1C1E),
      body: Stack(
        children: [
          PageView(
            controller: _pageController,
            onPageChanged: _onPageChanged,
            children: [
              _WelcomeScreen(
                onGetStarted: () => _pageController.animateToPage(
                  1,
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeInOut,
                ),
              ),
              _DiscoverScreen(
                onContinue: () => _pageController.animateToPage(
                  2,
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeInOut,
                ),
              ),
              _ShareScreen(
                onGetStarted: _navigateToAuth,
                onSkip: _navigateToAuth,
              ),
            ],
          ),
          // Page Indicators
          Positioned(
            bottom: 60,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(3, (index) => _buildIndicator(index)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIndicator(int index) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      height: 8,
      width: 8,
      decoration: BoxDecoration(
        color: _currentPage == index
            ? const Color(0xFF666666)
            : const Color(0xFF404040),
        shape: BoxShape.circle,
      ),
    );
  }
}

class _WelcomeScreen extends StatelessWidget {
  final VoidCallback onGetStarted;
  const _WelcomeScreen({required this.onGetStarted});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final cardSize = size.width * 0.8; // Responsive sizing

    return SafeArea(
      child: Column(
        children: [
          const Spacer(),
          // Icon Area
          Center(
            child: Container(
              width: cardSize > 300 ? 300 : cardSize, // Clamping for mobile
              height: cardSize > 300 ? 300 : cardSize,
              decoration: BoxDecoration(
                color: const Color(0xFF2C2C2E),
                borderRadius: BorderRadius.circular(40),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.5),
                    offset: const Offset(10, 10),
                    blurRadius: 20,
                  ),
                  BoxShadow(
                    color: Colors.white.withOpacity(0.05),
                    offset: const Offset(-5, -5),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Concentric rings
                  ...List.generate(3, (index) {
                    return Container(
                      width: 100 + (index * 60.0),
                      height: 100 + (index * 60.0),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withOpacity(0.05 / (index + 1)),
                          width: 2,
                        ),
                      ),
                    );
                  }),
                  const Icon(
                    Icons.lightbulb_outline,
                    color: Color(0xFF1C1C1E),
                    size: 80,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 60),
          // Text Content
          const Text(
            'Welcome to\nQuoteVault',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 40,
              fontWeight: FontWeight.w700,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              'Your daily source of inspiration. Discover, save, and share quotes that move you.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: const Color(0xFFB0B0B0),
                fontSize: 18,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          const Spacer(),
          // Bottom Section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: onGetStarted,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2C2C2E),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Get Started',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ),
          const SizedBox(height: 120), // Button position
        ],
      ),
    );
  }
}

class _DiscoverScreen extends StatelessWidget {
  final VoidCallback onContinue;
  const _DiscoverScreen({required this.onContinue});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final imageAreaWidth = size.width * 0.85;

    return SafeArea(
      child: Column(
        children: [
          const SizedBox(height: 40),
          // Image Area + Card
          SizedBox(
            height: size.height * 0.6,
            child: Stack(
              alignment: Alignment.topCenter,
              clipBehavior: Clip.none,
              children: [
                // Square image
                Container(
                  width: imageAreaWidth,
                  height: imageAreaWidth,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFE0D0),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.search_rounded,
                      size: 150,
                      color: Color(0xFF8D6E63),
                    ),
                  ),
                ),
                // Content Card (overlapping bottom of image)
                Positioned(
                  top: imageAreaWidth * 0.7, // 70% down the image
                  left: 24,
                  right: 24,
                  child: Container(
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2C2C2E),
                      borderRadius: BorderRadius.circular(32),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 30,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'Discover Daily Quotes',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 36,
                            fontWeight: FontWeight.w700,
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Explore thousands of curated quotes from great minds. Find the perfect words to inspire and motivate you every day.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: const Color(0xFFABABAB),
                            fontSize: 17,
                            fontWeight: FontWeight.w400,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          // Bottom Section
          TextButton(
            onPressed: onContinue,
            child: const Text(
              'Continue',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }
}

class _ShareScreen extends StatelessWidget {
  final VoidCallback onGetStarted;
  final VoidCallback onSkip;
  const _ShareScreen({required this.onGetStarted, required this.onSkip});

  @override
  Widget build(BuildContext context) {
    const iconAreaSize = 280.0;

    return SafeArea(
      child: Column(
        children: [
          const SizedBox(height: 40),
          // Icon Area
          Container(
            width: iconAreaSize,
            height: iconAreaSize,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFFFFB499), Color(0xFFFFAA88)],
              ),
              borderRadius: BorderRadius.circular(140),
            ),
            child: Stack(
              children: [
                _buildShareIcon(
                  Icons.share_rounded,
                  const Alignment(-0.5, -0.5),
                  iconAreaSize,
                ),
                _buildShareIcon(
                  Icons.more_horiz_rounded,
                  const Alignment(0.5, -0.5),
                  iconAreaSize,
                ),
                _buildShareIcon(
                  Icons.hub_rounded,
                  const Alignment(-0.5, 0.5),
                  iconAreaSize,
                ),
                _buildShareIcon(
                  Icons.share_arrival_time_rounded,
                  const Alignment(0.5, 0.5),
                  iconAreaSize,
                ),
              ],
            ),
          ),
          const SizedBox(height: 60),
          // Text Content
          const Text(
            'Save & Share Favorites',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 40,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              'Build your personal collection of powerful quotes and easily share inspiration with friends on any platform.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: const Color(0xFFABABAB),
                fontSize: 18,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          const Spacer(),
          // Bottom Section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: onGetStarted,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2C2C2E),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Get Started',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          TextButton(
            onPressed: onSkip,
            child: const Text(
              'Skip',
              style: TextStyle(color: Color(0xFF808080), fontSize: 17),
            ),
          ),
          const SizedBox(height: 70),
        ],
      ),
    );
  }

  Widget _buildShareIcon(
    IconData icon,
    Alignment alignment,
    double containerSize,
  ) {
    return Align(
      alignment: alignment,
      child: Icon(
        icon,
        size: containerSize * 0.15,
        color: const Color(0xFF5D4037).withOpacity(0.7),
      ),
    );
  }
}
