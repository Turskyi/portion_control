import 'dart:math' as math;

import 'package:feedback/feedback.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:portion_control/application_services/blocs/home/home_bloc.dart';
import 'package:portion_control/domain/models/food_weight.dart';
import 'package:portion_control/res/constants/constants.dart' as constants;
import 'package:portion_control/router/app_route.dart';
import 'package:portion_control/ui/home/widgets/body_weight_line_chart.dart';
import 'package:portion_control/ui/home/widgets/food_entries_column.dart';
import 'package:portion_control/ui/home/widgets/healthy_weight_recommendations.dart';
import 'package:portion_control/ui/home/widgets/portion_control_message.dart';
import 'package:portion_control/ui/home/widgets/random_recipe_card.dart';
import 'package:portion_control/ui/home/widgets/submit_edit_body_weight_button.dart';
import 'package:portion_control/ui/home/widgets/user_details_widget.dart';
import 'package:portion_control/ui/widgets/fancy_loading_indicator.dart';
import 'package:portion_control/ui/widgets/input_row.dart';

class HomePageContent extends StatefulWidget {
  const HomePageContent({super.key});

  @override
  State<HomePageContent> createState() => _HomePageContentState();
}

class _HomePageContentState extends State<HomePageContent> {
  final ScrollController _scrollController = ScrollController();
  FeedbackController? _feedbackController;

  @override
  void didChangeDependencies() {
    _feedbackController = BetterFeedback.of(context);
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<HomeBloc, HomeState>(
      listener: _homeStateListener,
      builder: (BuildContext context, HomeState state) {
        final ThemeData themeData = Theme.of(context);
        final TextTheme textTheme = themeData.textTheme;
        final TextStyle? titleMedium = textTheme.titleMedium;
        final double weight = state.bodyWeight;
        final double height = state.heightInCm;
        final List<FoodWeight> foodEntries = state.foodEntries;

        final SizedBox contentColumn = SizedBox(
          child: Column(
            spacing: 16.0,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const UserDetailsWidget(),
              // Show a brief note when app has no saved records yet so users
              // understand their data is local-only and may be lost.
              if (state.bodyWeightEntries.isEmpty && state.foodEntries.isEmpty)
                Card(
                  color: themeData.colorScheme.surfaceContainerHighest,
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: SelectionArea(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            translate('data_storage.title'),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: titleMedium?.fontSize,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            translate(
                              kIsWeb
                                  ? 'data_storage.message_web'
                                  : 'data_storage.message',
                            ),
                          ),
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: _navigateToSupportPage,
                              child: Text(
                                translate('learn_more'),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              if (state.isWeightNotSubmitted)
                Padding(
                  padding: const EdgeInsets.only(top: 12.0),
                  child: Text(
                    translate('home_page.enter_weight_instruction'),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: titleMedium?.fontSize,
                    ),
                  ),
                ),
              if (state is DetailsSubmittedState)
                // Body Weight Input.
                InputRow(
                  label: translate('home_page.body_weight_label'),
                  unit: translate('home_page.kg_unit'),
                  initialValue:
                      '${weight > constants.minBodyWeight ? weight : ''}',
                  value: state is BodyWeightSubmittedState ? '$weight' : null,
                  onChanged: _updateBodyWeight,
                  onSave: state is! BodyWeightSubmittedState
                      ? () {
                          context.read<HomeBloc>().add(
                            SubmitBodyWeight(state.bodyWeight),
                          );
                        }
                      : null,
                  isSaveEnabled: weight >= constants.minBodyWeight,
                ),
              if (state is DetailsSubmittedState &&
                  (state is BodyWeightSubmittedState ||
                      MediaQuery.sizeOf(context).width >=
                          constants.wideScreenThreshold))
                const SubmitEditBodyWeightButton(),
              const SizedBox(height: 4),
              if (state.bodyWeightEntries.length > 1)
                // Line Chart of Body Weight trends for the last two
                // weeks.
                Stack(
                  children: <Widget>[
                    BodyWeightLineChart(
                      bodyWeightEntries: state.lastTwoWeeksBodyWeightEntries,
                    ),
                    Positioned.fill(
                      child: RawMaterialButton(
                        onPressed: () {
                          Navigator.pushNamed(context, AppRoute.stats.path);
                        },
                      ),
                    ),
                  ],
                ),
              if (state is BodyWeightSubmittedState)
                HealthyWeightRecommendations(
                  height: height,
                  weight: weight,
                ),
              if (state is BodyWeightSubmittedState)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    const Expanded(child: PortionControlMessage()),
                    IconButton(
                      icon: const Icon(Icons.info_outline),
                      tooltip: translate('learn_more'),
                      onPressed: () {
                        Navigator.pushNamed(
                          context,
                          AppRoute.educationalContent.path,
                        );
                      },
                    ),
                  ],
                ),
              if (state is BodyWeightSubmittedState)
                FoodEntriesColumn(foodEntries: foodEntries),
              if (state is HomeLoading) const FancyLoadingIndicator(),
              if (state is BodyWeightSubmittedState) const RandomRecipeCard(),
            ],
          ),
        );
        return SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            constants.kHorizontalIndent,
            MediaQuery.paddingOf(context).top,
            constants.kHorizontalIndent,
            80.0,
          ),
          controller: _scrollController,
          child: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              final double maxWidthAvailable = constraints.maxWidth;
              final double width = math.min(
                constants.kWideScreenContentWidth,
                maxWidthAvailable.isFinite
                    ? maxWidthAvailable
                    : constants.kWideScreenContentWidth,
              );

              return Center(
                child: SizedBox(
                  width: width,
                  child: contentColumn,
                ),
              );
            },
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _feedbackController?.removeListener(_onFeedbackChanged);
    _feedbackController = null;
    super.dispose();
  }

  void _navigateToSupportPage() {
    Navigator.pushNamed(
      context,
      AppRoute.support.path,
    );
  }

  void _updateBodyWeight(String value) {
    context.read<HomeBloc>().add(UpdateBodyWeight(value));
  }

  void _onFeedbackChanged() {
    final bool? isVisible = _feedbackController?.isVisible;
    if (isVisible == false) {
      _feedbackController?.removeListener(_onFeedbackChanged);
      context.read<HomeBloc>().add(const HomeClosingFeedbackEvent());
    }
  }

  void _homeStateListener(BuildContext context, HomeState state) {
    if (state is BodyWeightSubmittedState) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToBottom();
      });
    } else if (state is ErrorState) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(state.errorMessage),
          behavior: SnackBarBehavior.floating,
          action: SnackBarAction(
            label: translate('button.ok'),
            onPressed: ScaffoldMessenger.of(context).hideCurrentSnackBar,
          ),
        ),
      );
    } else if (state is HomeFeedbackState) {
      _showFeedbackUi();
    } else if (state is HomeFeedbackSent) {
      _notifyFeedbackSent();
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeOut,
      );
    }
  }

  void _showFeedbackUi() {
    _feedbackController?.show(
      (UserFeedback feedback) {
        context.read<HomeBloc>().add(HomeSubmitFeedbackEvent(feedback));
      },
    );
    _feedbackController?.addListener(_onFeedbackChanged);
  }

  void _notifyFeedbackSent() {
    BetterFeedback.of(context).hide();
    // Let user know that his feedback is sent.
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(translate('feedback.sent')),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
