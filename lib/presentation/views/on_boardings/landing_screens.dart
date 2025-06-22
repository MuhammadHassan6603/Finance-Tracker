import 'package:finance_tracker/presentation/views/auth/login_view.dart';
import 'package:finance_tracker/presentation/views/on_boardings/currency_picker_screen.dart';
import 'package:finance_tracker/widgets/shared_dynamic_icon.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/services/session_manager.dart';
import '../../../data/models/onboarding_content_model.dart';
import '../../../widgets/custom_button.dart';

class LandingScreens extends StatefulWidget {
  const LandingScreens({super.key});

  @override
  State<LandingScreens> createState() => _LandingScreensState();
}

class _LandingScreensState extends State<LandingScreens> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingContent> contents = [
    OnboardingContent(
      image: 'assets/icons/mastering.svg',
      title: 'Master Your Money\nJourney',
      description:
          'Effortlessly track every penny and watch your wealth grow with our intuitive expense tracker',
    ),
    OnboardingContent(
      image: 'assets/icons/blueprint.svg',
      title: 'Your Financial\nSuccess Blueprint',
      description:
          'Create smart budgets that work for you. Stay on track and achieve your financial goals faster',
    ),
    OnboardingContent(
      image: 'assets/icons/success_transform.svg',
      title: 'Transform Your\nFinancial Future',
      description:
          'Unlock powerful insights and make informed decisions. Your path to financial freedom starts here',
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onNextPage() {
    if (_currentPage == contents.length - 1) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const CurrencyPickerScreen(),
        ),
      );
      _completeOnboarding(context);
    } else {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _completeOnboarding(BuildContext context) async {
    final sessionManager = context.read<SessionManager>();
    await sessionManager.setHasSeenOnboarding(true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: contents.length,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemBuilder: (context, index) {
                  return OnboardingPage(content: contents[index]);
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      contents.length,
                      (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        height: 8,
                        width: _currentPage == index ? 24 : 8,
                        decoration: BoxDecoration(
                          color: _currentPage == index
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context)
                                  .colorScheme
                                  .primary
                                  .withOpacity(0.3),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: 60,
                    child: CustomButton(
                      onPressed: _onNextPage,
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      child: Icon(
                        _currentPage == contents.length - 1
                            ? Icons.check
                            : Icons.arrow_forward,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class OnboardingPage extends StatelessWidget {
  final OnboardingContent content;

  const OnboardingPage({
    super.key,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SharedDynamicIcon(content.image, height: 190),
          // Container(
          //   width: 200,
          //   height: 200,
          //   decoration: BoxDecoration(
          //     shape: BoxShape.circle,
          //     border: Border.all(
          //       color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
          //       width: 2,
          //     ),
          //     image: DecorationImage(
          //       image: AssetImage(content.image),
          //       fit: BoxFit.cover,
          //     ),
          //   ),
          // ),
          const SizedBox(height: 40),
          Text(
            content.title,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                  color: Theme.of(context).colorScheme.onBackground,
                  height: 1.4,
                ),
          ),
          const SizedBox(height: 20),
          Text(
            content.description,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context)
                      .colorScheme
                      .onBackground
                      .withOpacity(0.7),
                ),
          ),
        ],
      ),
    );
  }
}
