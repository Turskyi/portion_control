import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:portion_control/application_services/blocs/home/home_bloc.dart';
import 'package:portion_control/extensions/date_time_extension.dart';

class DateHeaderWidget extends StatelessWidget {
  const DateHeaderWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeBloc, HomeState>(
      builder: (BuildContext context, HomeState state) {
        final DateTime date = state.dataDate;
        final bool isToday = date.isToday;

        return Column(
          children: <Widget>[
            const Divider(),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  SelectionArea(
                    child: Text(
                      isToday ? translate('today') : date.toReadableDate(),
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  if (!isToday)
                    TextButton.icon(
                      onPressed: () {
                        context.read<HomeBloc>().add(const LoadEntries());
                      },
                      icon: const Icon(Icons.today),
                      label: Text(translate('go_to_today')),
                    ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
