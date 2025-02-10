import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:portion_control/application_services/blocs/home_bloc.dart';
import 'package:portion_control/ui/home/widgets/home_page_content.dart';
import 'package:portion_control/ui/widgets/gradient_background_scaffold.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    final double horizontalIndent = 12.0;
    return GradientBackgroundScaffold(
      body: BlocListener<HomeBloc, HomeState>(
        listener: _homeStateListener,
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            if (constraints.maxWidth > 600) {
              // Wide screen layout.
              return Center(
                child: Container(
                  // Fixed width for wide screens.
                  width: 800,
                  padding: EdgeInsets.fromLTRB(
                    horizontalIndent,
                    MediaQuery.of(context).padding.top + 18,
                    horizontalIndent,
                    80.0,
                  ),
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    child: const HomePageContent(),
                  ),
                ),
              );
            } else {
              // Narrow screen layout.
              return SingleChildScrollView(
                controller: _scrollController,
                padding: EdgeInsets.fromLTRB(
                  horizontalIndent,
                  MediaQuery.of(context).padding.top + 18,
                  horizontalIndent,
                  80.0,
                ),
                child: const HomePageContent(),
              );
            }
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
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
        ),
      );
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
}
