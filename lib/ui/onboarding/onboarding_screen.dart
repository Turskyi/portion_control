import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:portion_control/infrastructure/data_sources/local/local_data_source.dart';
import 'package:portion_control/router/app_route.dart';
import 'package:portion_control/ui/onboarding/widgets/onboarding_controls.dart';
import 'package:portion_control/ui/onboarding/widgets/onboarding_page.dart';
import 'package:portion_control/ui/widgets/gradient_background_scaffold.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({required this.localDataSource, super.key});

  final LocalDataSource localDataSource;

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  void _onNextPressed() {
    _pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeIn,
    );
  }

  void _onGetStartedPressed() {
    widget.localDataSource.saveOnboardingCompleted();
    Navigator.of(context).pushReplacementNamed(AppRoute.home.path);
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return GradientBackgroundScaffold(
      body: Column(
        children: <Widget>[
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: (int page) {
                setState(() {
                  _currentPage = page;
                });
              },
              children: const <Widget>[
                OnboardingPage(
                  titleKey: 'onboarding.page1.title',
                  contentKey: 'onboarding.page1.content',
                  imageAsset: 'assets/images/onboarding_plate.png',
                  isAnimated: true,
                ),
                OnboardingPage(
                  titleKey: 'onboarding.page2.title',
                  contentKey: 'onboarding.page2.content',
                  imageAsset: 'assets/images/onboarding_chart.png',
                ),
                OnboardingPage(
                  titleKey: 'onboarding.page3.title',
                  contentKey: 'onboarding.page3.content',
                  imageAsset: 'assets/images/onboarding_journey.png',
                ),
              ],
            ),
          ),
          SmoothPageIndicator(
            controller: _pageController,
            count: 3,
            effect: ExpandingDotsEffect(
              activeDotColor: theme.colorScheme.primary,
              dotHeight: 8,
              dotWidth: 8,
            ),
          ),
          OnboardingControls(
            currentPage: _currentPage,
            onNextPressed: _onNextPressed,
            onGetStartedPressed: _onGetStartedPressed,
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 32.0, left: 16, right: 16),
            child: Text(
              translate('onboarding.tagline'),
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }
}
