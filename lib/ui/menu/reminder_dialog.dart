import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:portion_control/application_services/blocs/menu/menu_bloc.dart';

class ReminderDialog extends StatelessWidget {
  const ReminderDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MenuBloc, MenuState>(
      builder: (BuildContext context, MenuState state) {
        return AlertDialog(
          title: Text(translate('reminders.title')),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              SwitchListTile(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                title: Text(translate('reminders.log_weight_each_morning')),
                value: state.isWeightReminderEnabled,
                onChanged: (bool value) {
                  context.read<MenuBloc>().add(
                    ToggleWeightReminderEvent(value),
                  );
                },
              ),
              ListTile(
                title: Text(translate('reminders.pick_time')),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                subtitle: Text(state.weightReminderTime.format(context)),
                onTap: () => _pickTime(context, state.weightReminderTime),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(translate('button.close')),
            ),
            ElevatedButton(
              onPressed: () {
                context.read<MenuBloc>().add(const SaveReminderSettingsEvent());
                Navigator.of(context).pop();
              },
              child: Text(translate('button.ok')),
            ),
          ],
        );
      },
    );
  }

  Future<void> _pickTime(BuildContext context, TimeOfDay initialTime) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: initialTime,
    );
    if (picked != null && context.mounted) {
      context.read<MenuBloc>().add(ChangeWeightReminderTimeEvent(picked));
    }
  }
}
