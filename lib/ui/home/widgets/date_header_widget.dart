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
            const Divider(thickness: 1, height: 32),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Expanded(
                    child: SelectionArea(
                      child: InkWell(
                        onTap: () {
                          context.read<HomeBloc>().add(const LoadEntries());
                        },
                        borderRadius: BorderRadius.circular(8.0),
                        child: Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: Text(
                            isToday
                                ? '${date.toReadableDate()} '
                                      '(${translate('today')})'
                                : date.toReadableDate(),
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: isToday ? null : Colors.orangeAccent,
                                ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  if (!isToday)
                    ElevatedButton.icon(
                      onPressed: () {
                        context.read<HomeBloc>().add(const LoadEntries());
                      },
                      icon: const Icon(Icons.today),
                      label: Text(translate('go_to_today')),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(
                          context,
                        ).colorScheme.primaryContainer,
                      ),
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
