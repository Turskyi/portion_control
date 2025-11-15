import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:portion_control/application_services/blocs/onboarding/onboarding_bloc.dart';
import 'package:portion_control/domain/enums/language.dart';
import 'package:portion_control/infrastructure/data_sources/local/local_data_source.dart';
import 'package:portion_control/res/constants/constants.dart' as constants;
import 'package:portion_control/router/app_route.dart';
import 'package:portion_control/ui/onboarding/widgets/onboarding_controls.dart';
import 'package:portion_control/ui/onboarding/widgets/onboarding_page.dart';
import 'package:portion_control/ui/widgets/gradient_background_scaffold.dart';
import 'package:portion_control/ui/widgets/language_selector.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({required this.localDataSource, super.key});

  final LocalDataSource localDataSource;

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  final ValueNotifier<int> _currentPage = ValueNotifier<int>(0);

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return GradientBackgroundScaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        actions: <Widget>[
          BlocBuilder<OnboardingBloc, OnboardingState>(
            builder: (BuildContext context, OnboardingState viewModel) {
              return LanguageSelector(
                currentLanguage: viewModel.language,
                onLanguageSelected: (Language newLanguage) {
                  // Dispatch event to the bloc to handle language
                  // change logic and update its state (which might also
                  // update this screen's language).
                  context.read<OnboardingBloc>().add(
                    ChangeLanguageEvent(newLanguage),
                  );
                  // Force a rebuild of the current screen's state.
                  setState(() {});
                },
              );
            },
          ),
        ],
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: (int page) {
                _currentPage.value = page;
              },
              children: <Widget>[
                OnboardingPage(
                  // By adding a UniqueKey, we ensure this widget and its state
                  // are completely rebuilt when the parent rebuilds. [2, 3, 4]
                  key: UniqueKey(),
                  titleKey: 'onboarding.page1.title',
                  contentKey: 'onboarding.page1.content',
                  imageAsset: '${constants.imagePath}onboarding_plate.png',
                  isAnimated: true,
                ),
                const OnboardingPage(
                  titleKey: 'onboarding.page2.title',
                  contentKey: 'onboarding.page2.content',
                  imageAsset: '${constants.imagePath}onboarding_chart.png',
                ),
                const OnboardingPage(
                  titleKey: 'onboarding.page3.title',
                  contentKey: 'onboarding.page3.content',
                  imageAsset: '${constants.imagePath}onboarding_journey.png',
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
          ValueListenableBuilder<int>(
            valueListenable: _currentPage,
            builder: (BuildContext _, int value, Widget? _) {
              return OnboardingControls(
                currentPage: value,
                onNextPressed: _onNextPressed,
                onGetStartedPressed: _onGetStartedPressed,
              );
            },
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
}
