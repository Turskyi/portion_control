import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:portion_control/application_services/blocs/home_bloc.dart';
import 'package:portion_control/domain/enums/gender.dart';
import 'package:portion_control/extensions/date_time_extension.dart';
import 'package:portion_control/res/constants/date_constants.dart'
    as date_constants;
import 'package:portion_control/ui/home/widgets/gender_selection_widget.dart';
import 'package:portion_control/ui/home/widgets/input_row.dart';
import 'package:portion_control/ui/home/widgets/submit_edit_details_button.dart';

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
    return BlocBuilder<HomeBloc, HomeState>(
      builder: (BuildContext context, HomeState state) {
        final ThemeData themeData = Theme.of(context);
        final TextTheme textTheme = themeData.textTheme;
        final double bodyWeight = state.bodyWeight;
        final Gender gender = state.gender;
        final String dateOfBirth = state.dateOfBirth?.toReadableDate() ?? '';
        final double height = state.height;
        final String title = state is BodyWeightSubmittedState
            ? 'Your Details'
            : 'Enter Your Details';
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 16,
          children: <Widget>[
            Text(
              title,
              style: TextStyle(
                fontSize: textTheme.titleLarge?.fontSize,
                fontWeight: FontWeight.bold,
              ),
            ),
            GenderSelectionWidget(
              bodyWeight: bodyWeight,
              gender: gender,
              isDetailsSubmitted: state is DetailsSubmittedState,
            ),
            Row(
              children: <Widget>[
                if (gender.isMaleOrFemale)
                  Expanded(
                    child: InputRow(
                      label: 'Date of Birth',
                      controller: _dateOfBirthTextEditingController
                        ..text = dateOfBirth,
                      readOnly: true,
                      value:
                          state is DetailsSubmittedState ? dateOfBirth : null,
                      onTap: () => _pickDate(
                        dateOfBirthText: dateOfBirth,
                        dateOfBirthDateTime: state.dateOfBirth,
                      ),
                    ),
                  ),
                const SizedBox(width: 8),
                Expanded(
                  child: InputRow(
                    label: 'Height',
                    unit: 'cm',
                    initialValue: '${height > 0 ? height : ''}',
                    isRequired: true,
                    value: state is DetailsSubmittedState ? '$height' : null,
                    onChanged: (String value) {
                      context.read<HomeBloc>().add(UpdateHeight(value));
                    },
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

  Future<void> _pickDate({
    required String dateOfBirthText,
    required DateTime? dateOfBirthDateTime,
  }) async {
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
