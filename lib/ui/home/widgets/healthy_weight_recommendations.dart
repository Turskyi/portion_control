import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:portion_control/domain/models/bmi_category.dart';
import 'package:url_launcher/url_launcher.dart';

class HealthyWeightRecommendations extends StatelessWidget {
  const HealthyWeightRecommendations({
    required this.height,
    required this.weight,
    super.key,
  });

  /// in cm.
  final double height;

  /// in kg
  final double weight;

  @override
  Widget build(BuildContext context) {
    // Calculate Body Mass Index (BMI).
    final double heightInMeters = height / 100;
    final double bmi = weight / (heightInMeters * heightInMeters);

    // Calculate healthy weight range (BMI 18.5–24.9).
    final (double minHealthyWeight, double maxHealthyWeight) =
        BmiCategory.healthyWeightRange(height);

    final TextTheme textTheme = Theme.of(context).textTheme;
    final String kgSuffix = translate('healthy_weight.kg_suffix');

    final BmiCategory category = BmiCategory.fromWeightAndHeight(
      weightKg: weight,
      heightCm: height,
    );

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Flexible(
          child: Card(
            elevation: 4,
            margin: const EdgeInsets.symmetric(vertical: 16),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 8,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: Text(
                          '${translate("healthy_weight.your_bmi_prefix")}'
                          '${BmiCategory.roundBmi(bmi)}',
                          style: textTheme.titleMedium,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.info_outline),
                        tooltip: translate(
                          'healthy_weight.bmi_info_button_tooltip',
                        ),
                        onPressed: () {
                          _showBmiSourcesDialog(context);
                        },
                      ),
                    ],
                  ),
                  Text(
                    '${translate('healthy_weight.range_prefix')}'
                    '${minHealthyWeight.toStringAsFixed(1)}'
                    '${translate('healthy_weight.range_separator')}'
                    '${maxHealthyWeight.toStringAsFixed(1)}$kgSuffix',
                    style: textTheme.titleMedium,
                  ),
                  Text(
                    category.message,
                    style: textTheme.titleLarge?.copyWith(
                      color: category.color(context),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _showBmiSourcesDialog(BuildContext context) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            translate('healthy_weight.bmi_sources_title'),
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 8,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(bottom: 4.0),
                  child: Text(
                    translate('app.medical_disclaimer_full'),
                  ),
                ),
                Text(
                  translate(
                    'healthy_weight.bmi_sources_description',
                  ),
                ),
                TextButton(
                  onPressed: _launchWhoUrl,
                  child: Text(translate('healthy_weight.bmi_source_who')),
                ),
                TextButton(
                  onPressed: _launchCdcUrl,
                  child: Text(
                    translate('healthy_weight.bmi_source_cdc'),
                  ),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: Navigator.of(context).pop,
              child: Text(
                MaterialLocalizations.of(
                  context,
                ).closeButtonLabel,
              ),
            ),
          ],
        );
      },
    );
  }

  Future<bool> _launchCdcUrl() {
    return launchUrl(
      Uri.parse(
        translate('healthy_weight.bmi_source_cdc_url'),
      ),
      mode: LaunchMode.externalApplication,
    );
  }

  Future<bool> _launchWhoUrl() {
    return launchUrl(
      Uri.parse(
        translate(
          'healthy_weight.bmi_source_who_url',
        ),
      ),
      mode: LaunchMode.externalApplication,
    );
  }
}
