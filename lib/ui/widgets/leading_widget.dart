import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:portion_control/res/constants/constants.dart' as constants;
import 'package:portion_control/router/app_route.dart';

class LeadingWidget extends StatelessWidget {
  const LeadingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8.0),
        child: Material(
          // Ensures the background remains unchanged.
          color: Colors.transparent,
          child: InkWell(
            onTap: () => Navigator.of(context).pushReplacementNamed(
              kIsWeb ? AppRoute.landing.path : AppRoute.home.path,
            ),
            child: Ink.image(
              image: const AssetImage('${constants.imagePath}logo.png'),
              fit: BoxFit.cover,
            ),
          ),
        ),
      ),
    );
  }
}
