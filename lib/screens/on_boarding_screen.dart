import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:open_gpt_client/extensions/context_extension.dart';
import 'package:open_gpt_client/screens/password_setup_screen.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class OnBoardingScreen extends StatefulWidget {
  const OnBoardingScreen({super.key});

  @override
  State<OnBoardingScreen> createState() => _OnBoardingScreenState();
}

class _OnBoardingScreenState extends State<OnBoardingScreen> {
  late final _pageController = PageController();
  late final _pages = const [
    _Page1(),
    _Page2(),
    _Page3(),
  ];
  var _currentPageIndex = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appLocals = context.appLocals;
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: PageView(
              controller: _pageController,
              children: _pages,
              onPageChanged: (index) {
                setState(() {
                  _currentPageIndex = index;
                });
              },
            ),
          ),
          const SizedBox(height: 16),
          Stack(
            fit: StackFit.passthrough,
            children: [
              SizedBox(
                height: 50,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SmoothPageIndicator(
                      controller: _pageController,
                      count: _pages.length,
                      effect: ExpandingDotsEffect(
                        activeDotColor: Theme.of(context).colorScheme.tertiary,
                      ),
                      onDotClicked: (index) {
                        _pageController.animateToPage(
                          index,
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      },
                    ),
                  ],
                ),
              ),
              Positioned(
                right: 16,
                top: 0,
                bottom: 0,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: _currentPageIndex == _pages.length - 1
                          ? () {
                              context.pushAndRemoveUntil(PasswordSetupScreen());
                            }
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                      ),
                      child: Text(
                        appLocals.start.toUpperCase(),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: _currentPageIndex == 2
                              ? Theme.of(context).colorScheme.onPrimary
                              : Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Page1 extends StatelessWidget {
  const _Page1({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Spacer(),
        SvgPicture.asset(
          'assets/svg/open_source.svg',
          width: min(300, context.width * 0.4),
          height: min(300, context.height * 0.4),
        ),
        const SizedBox(height: 24),
        const Text(
          'Open Source',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Questo software è open source, visionabile e\npuoi contribuire al suo sviluppo su GitHub.',
          textAlign: TextAlign.center,
        ),
        const Spacer(),
      ],
    );
  }
}

class _Page2 extends StatelessWidget {
  const _Page2({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Spacer(),
        SvgPicture.asset(
          'assets/svg/secure.svg',
          width: min(300, context.width * 0.4),
          height: min(300, context.height * 0.4),
        ),
        const SizedBox(height: 24),
        const Text(
          'Sicuro',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        const Text.rich(
          TextSpan(
            text: 'Tutti i dati vengono salvati\nin modo sicuro ',
            children: [
              TextSpan(
                text: 'solo sul tuo dispositivo',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextSpan(text: ', con algoritmo '),
              TextSpan(
                text: 'AES-256.',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextSpan(
                  text: '\nI dati non vengono mai inviati a server remoti.'),
            ],
          ),
          textAlign: TextAlign.center,
        ),
        const Spacer(),
      ],
    );
  }
}

class _Page3 extends StatelessWidget {
  const _Page3({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Spacer(),
        SvgPicture.asset(
          'assets/svg/consume.svg',
          width: min(300, context.width * 0.4),
          height: min(300, context.height * 0.4),
        ),
        const SizedBox(height: 24),
        const Text(
          'Economico',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Il software è completamente gratuito e non richiede alcun abbonamento.\nUtilizzando le API di OpenAI pagherai solo per ciò che effettivamente consumi!',
          textAlign: TextAlign.center,
        ),
        const Spacer(),
      ],
    );
  }
}
