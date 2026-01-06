import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:portion_control/application_services/blocs/home/home_bloc.dart';
import 'package:portion_control/domain/enums/gender.dart';
import 'package:portion_control/extensions/date_time_extension.dart';
import 'package:portion_control/res/constants/date_constants.dart'
    as date_constants;
import 'package:portion_control/ui/home/widgets/gender_selection_widget.dart';
import 'package:portion_control/ui/home/widgets/submit_edit_details_button.dart';
import 'package:portion_control/ui/widgets/input_row.dart';

class UserDetailsWidget extends StatefulWidget {
  const UserDetailsWidget({super.key});

  @override
  State<UserDetailsWidget> createState() => _UserDetailsWidgetState();
}

class _UserDetailsWidgetState extends State<UserDetailsWidget> {
  final TextEditingController _dateOfBirthTextEditingController =
      TextEditingController();

  @override
  Widget build(BuildContext context) {
    // Helper for translation.
    String t(String key) => translate(key);
    return BlocBuilder<HomeBloc, HomeState>(
      builder: (BuildContext context, HomeState state) {
        final ThemeData themeData = Theme.of(context);
        final TextTheme textTheme = themeData.textTheme;
        final double bodyWeight = state.bodyWeight;
        final Gender gender = state.gender;
        final String dateOfBirth = state.dateOfBirth?.toReadableDate() ?? '';
        final double height = state.heightInCm;
        final String title = state is BodyWeightSubmittedState
            ? t('user_details_widget.title_your_details')
            : t('user_details_widget.title_enter_your_details');
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 16,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  title,
                  style: TextStyle(
                    fontSize: textTheme.titleLarge?.fontSize,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            GenderSelectionWidget(
              bodyWeight: bodyWeight,
              gender: gender,
              isDetailsSubmitted: state is DetailsSubmittedState,
            ),
            Row(
              spacing: 8.0,
              children: <Widget>[
                if (gender.isMaleOrFemale)
                  Expanded(
                    child: InputRow(
                      label: t('user_details_widget.label_date_of_birth'),
                      controller: _dateOfBirthTextEditingController
                        ..text = dateOfBirth,
                      readOnly: true,
                      value: state is DetailsSubmittedState
                          ? dateOfBirth
                          : null,
                      onTap: () {
                        _pickDate(dateOfBirthDateTime: state.dateOfBirth);
                      },
                    ),
                  ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      InputRow(
                        label: t('user_details_widget.label_height'),
                        unit: t('user_details_widget.unit_cm'),
                        initialValue: '${height > 0 ? height : ''}',
                        isRequired: true,
                        value: state is DetailsSubmittedState
                            ? '$height'
                            : null,
                        onChanged: (String value) {
                          context.read<HomeBloc>().add(UpdateHeight(value));
                        },
                        message: t('user_details_widget.height_hint'),
                        onUnitTap: _showHeightHintDialog,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SubmitEditDetailsButton(),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _dateOfBirthTextEditingController.dispose();
    super.dispose();
  }

  Future<void> _showHeightHintDialog() {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            translate('user_details_widget.label_height'),
          ),
          content: Text(
            translate('user_details_widget.height_hint'),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: Navigator.of(context).pop,
              child: Text(translate('button.ok')),
            ),
          ],
        );
      },
    );
  }

  Future<void> _pickDate({
    required DateTime? dateOfBirthDateTime,
  }) async {
    final String dateOfBirthText = dateOfBirthDateTime?.toReadableDate() ?? '';
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: dateOfBirthText.isNotEmpty
          ? dateOfBirthDateTime
          : DateTime(1987, 1, 13),
      firstDate: date_constants.maxAllowedBirthDate,
      lastDate: date_constants.minAllowedBirthDate,
    );

    if (mounted && pickedDate != null) {
      _dateOfBirthTextEditingController.text = pickedDate.toIso8601Date() ?? '';
      context.read<HomeBloc>().add(UpdateDateOfBirth(pickedDate));
    }
  }
}
