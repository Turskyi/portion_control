import 'package:feedback/feedback.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:portion_control/application_services/blocs/home/home_bloc.dart';
import 'package:portion_control/domain/models/food_weight.dart';
import 'package:portion_control/extensions/list_extension.dart';
import 'package:portion_control/res/constants/constants.dart' as constants;
import 'package:portion_control/ui/home/widgets/body_weight_line_chart.dart';
import 'package:portion_control/ui/home/widgets/food_entries_column.dart';
import 'package:portion_control/ui/home/widgets/healthy_weight_recommendations.dart';
import 'package:portion_control/ui/home/widgets/portion_control_message.dart';
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
        final double height = state.height;
        final List<FoodWeight> foodEntries = state.foodEntries;
        final double horizontalIndent = 12.0;

        return SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            horizontalIndent,
            MediaQuery.of(context).padding.top,
            horizontalIndent,
            80.0,
          ),
          controller: _scrollController,
          child: Column(
            spacing: 16.0,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const UserDetailsWidget(),
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
                  onChanged: (String value) {
                    context.read<HomeBloc>().add(UpdateBodyWeight(value));
                  },
                ),
              if (state is DetailsSubmittedState)
                const SubmitEditBodyWeightButton(),
              if (state.bodyWeightEntries.length > 1)
                // Line Chart of Body Weight trends for the last two weeks.
                BodyWeightLineChart(
                  bodyWeightEntries: state.bodyWeightEntries
                      .takeLast(DateTime.daysPerWeek * 2)
                      .toList(),
                ),
              if (state is BodyWeightSubmittedState)
                HealthyWeightRecommendations(height: height, weight: weight),
              if (state is BodyWeightSubmittedState)
                const PortionControlMessage(),
              if (state is BodyWeightSubmittedState)
                FoodEntriesColumn(foodEntries: foodEntries),
              if (state is HomeLoading) const FancyLoadingIndicator(),
            ],
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
          action: SnackBarAction(
            label: translate('button.report'),
            onPressed: () {
              context.read<HomeBloc>().add(const HomeBugReportPressedEvent());
            },
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
      (UserFeedback feedback) =>
          context.read<HomeBloc>().add(HomeSubmitFeedbackEvent(feedback)),
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
