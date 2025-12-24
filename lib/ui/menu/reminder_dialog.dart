import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:portion_control/infrastructure/data_sources/local/local_data_source.dart';
import 'package:portion_control/infrastructure/repositories/user_preferences_repository.dart';
import 'package:portion_control/services/reminder_service.dart';

class ReminderDialog extends StatefulWidget {
  const ReminderDialog({required this.localDataSource, super.key});

  final LocalDataSource localDataSource;

  @override
  State<ReminderDialog> createState() => _ReminderDialogState();
}

class _ReminderDialogState extends State<ReminderDialog> {
  late final UserPreferencesRepository _prefs;
  bool _enabled = false;
  TimeOfDay _time = const TimeOfDay(hour: 8, minute: 0);

  @override
  void initState() {
    super.initState();
    _prefs = UserPreferencesRepository(widget.localDataSource);
    _enabled = _prefs.isWeightReminderEnabled();
    final String? timeString = _prefs.getWeightReminderTimeString();
    if (timeString != null) {
      final List<String> parts = timeString.split(':');
      _time = TimeOfDay(
        hour: int.parse(parts[0]),
        minute: int.parse(parts[1]),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
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
            value: _enabled,
            onChanged: (bool value) {
              //TODO: use MenuBloc
              setState(() => _enabled = value);
            },
          ),
          ListTile(
            title: Text(translate('reminders.pick_time')),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            subtitle: Text(_time.format(context)),
            onTap: () async {
              final TimeOfDay? picked = await showTimePicker(
                context: context,
                initialTime: _time,
              );
              if (picked != null) {
                setState(() => _time = picked);
              }
            },
          ),
        ],
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(translate('button.close')),
        ),
        ElevatedButton(
          onPressed: _save,
          child: Text(translate('button.ok')),
        ),
      ],
    );
  }

  Future<void> _save() async {
    await _prefs.saveWeightReminderEnabled(_enabled);
    await _prefs.saveWeightReminderTimeString(
      '${_time.hour.toString().padLeft(2, '0')}:'
      '${_time.minute.toString().padLeft(2, '0')}',
    );

    if (_enabled) {
      bool granted = await ReminderService.instance
          .requestNotificationPermissions();

      if (granted && Platform.isAndroid) {
        granted = await Permission.scheduleExactAlarm.request().isGranted;
      }

      if (granted) {
        await ReminderService.instance.scheduleDailyWeightReminder(
          time: _time,
        );
      }
    } else {
      await ReminderService.instance.cancelWeightReminder();
    }

    if (mounted) Navigator.of(context).pop();
  }
}
