import 'package:feedback/feedback.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:portion_control/application_services/blocs/home/home_bloc.dart';
import 'package:portion_control/application_services/blocs/menu/menu_bloc.dart';
import 'package:portion_control/res/constants/constants.dart' as constants;
import 'package:portion_control/router/app_route.dart';
import 'package:portion_control/ui/home/widgets/home_page_content.dart';
import 'package:portion_control/ui/menu/animated_drawer.dart';
import 'package:portion_control/ui/widgets/gradient_background_scaffold.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  FeedbackController? _feedbackController;

  @override
  void didChangeDependencies() {
    _feedbackController = BetterFeedback.of(context);
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return GradientBackgroundScaffold(
      drawer: kIsWeb
          ? null
          : BlocListener<MenuBloc, MenuState>(
              listener: (_, MenuState state) {
                if (state is FeedbackState) {
                  _showFeedbackUi();
                } else if (state is FeedbackSent) {
                  _notifyFeedbackSent();
                }
              },
              child: const AnimatedDrawer(),
            ),
      body: LayoutBuilder(
        builder: (_, BoxConstraints constraints) {
          if (constraints.maxWidth > constants.wideScreenThreshold) {
            // Wide screen layout.
            return const Center(
              child: SizedBox(
                // Fixed width for wide screens.
                width: constants.wideScreenContentWidth,
                child: HomePageContent(),
              ),
            );
          } else {
            // Narrow screen layout.
            return const HomePageContent();
          }
        },
      ),
      persistentFooterAlignment: AlignmentDirectional.center,
      persistentFooterButtons: kIsWeb
          ? <Widget>[
              Semantics(
                label: 'Privacy Policy',
                button: true,
                child: TextButton.icon(
                  onPressed: () {
                    Navigator.pushNamed(context, AppRoute.privacyPolity.path);
                  },
                  icon: Icon(
                    Icons.privacy_tip,
                    size: Theme.of(context).textTheme.titleMedium?.fontSize,
                  ),
                  label: const Text('Privacy Policy'),
                ),
              ),
              Semantics(
                label: 'About Us',
                button: true,
                child: TextButton.icon(
                  onPressed: () {
                    Navigator.pushNamed(context, AppRoute.about.path);
                  },
                  icon: Icon(
                    Icons.group,
                    size: Theme.of(context).textTheme.titleMedium?.fontSize,
                  ),
                  label: const Text('About Us'),
                ),
              ),
              Semantics(
                label: 'Feedback',
                button: true,
                child: TextButton.icon(
                  onPressed: () => _showFeedbackDialog(context),
                  icon: Icon(
                    Icons.feedback,
                    size: Theme.of(context).textTheme.titleMedium?.fontSize,
                  ),
                  label: const Text('Feedback'),
                ),
              ),
            ]
          : null,
    );
  }

  @override
  void dispose() {
    _feedbackController?.removeListener(_onFeedbackChanged);
    _feedbackController = null;
    super.dispose();
  }

  void _showFeedbackDialog(BuildContext context) =>
      context.read<HomeBloc>().add(const HomeBugReportPressedEvent());

  void _showFeedbackUi() {
    _feedbackController?.show(
      (UserFeedback feedback) =>
          context.read<MenuBloc>().add(SubmitFeedbackEvent(feedback)),
    );
    _feedbackController?.addListener(_onFeedbackChanged);
  }

  void _notifyFeedbackSent() {
    BetterFeedback.of(context).hide();
    // Let user know that his feedback is sent.
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(translate('feedback.feedbackSent')),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _onFeedbackChanged() {
    final bool? isVisible = _feedbackController?.isVisible;
    if (isVisible == false) {
      _feedbackController?.removeListener(_onFeedbackChanged);
      context.read<MenuBloc>().add(const ClosingFeedbackEvent());
    }
  }
}
