import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:portion_control/domain/enums/meal_type.dart';

class RandomRecipeCard extends StatefulWidget {
  const RandomRecipeCard({super.key});

  @override
  State<RandomRecipeCard> createState() => _RandomRecipeCardState();
}

class _RandomRecipeCardState extends State<RandomRecipeCard> {
  static const int _daysInMealPlan = 154;
  static const int _maxSelectionAttempts = 10;
  static const Duration _switchDuration = Duration(milliseconds: 320);
  static const Duration _iconRotationDuration = Duration(milliseconds: 420);

  final Random _random = Random();
  late String _mealType;
  late String _recipeKey;
  int _refreshTurns = 0;

  @override
  void initState() {
    super.initState();
    _selectRandomRecipe();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final TextTheme textTheme = theme.textTheme;
    final ColorScheme colorScheme = theme.colorScheme;
    final bool disableAnimations =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    final Duration switchDuration = disableAnimations
        ? Duration.zero
        : _switchDuration;
    final Duration iconRotationDuration = disableAnimations
        ? Duration.zero
        : _iconRotationDuration;

    final String translation = translate(_recipeKey);
    if (translation == _recipeKey) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: colorScheme.surface.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(16),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Icon(
                Icons.restaurant_menu,
                color: colorScheme.secondaryContainer,
              ),
              const SizedBox(width: 8),
              Text(
                translate('meal_type.$_mealType'),
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              IconButton(
                icon: AnimatedRotation(
                  turns: _refreshTurns.toDouble(),
                  duration: iconRotationDuration,
                  curve: Curves.easeOutCubic,
                  child: Icon(
                    Icons.refresh,
                    size: 20,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                // Keep this local: recipe rotation is ephemeral UI state for
                // this card only, so routing it through `HomeBloc` would widen
                // shared state and rebuild more of the home screen for no
                // domain or persistence benefit.
                onPressed: _onRefreshPressed,
                tooltip: translate('home_page.next_recipe'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          AnimatedSwitcher(
            duration: switchDuration,
            reverseDuration: switchDuration,
            switchInCurve: Curves.easeOutCubic,
            switchOutCurve: Curves.easeInCubic,
            transitionBuilder: (Widget child, Animation<double> animation) {
              final Animation<double> fade = CurvedAnimation(
                parent: animation,
                curve: Curves.easeOut,
              );
              final Animation<double> scale =
                  Tween<double>(
                    begin: 0.96,
                    end: 1,
                  ).animate(
                    CurvedAnimation(
                      parent: animation,
                      curve: Curves.easeOutBack,
                    ),
                  );
              final Animation<Offset> slide =
                  Tween<Offset>(
                    begin: const Offset(0, 0.08),
                    end: Offset.zero,
                  ).animate(
                    CurvedAnimation(
                      parent: animation,
                      curve: Curves.easeOutCubic,
                    ),
                  );

              return FadeTransition(
                opacity: fade,
                child: ScaleTransition(
                  scale: scale,
                  child: SlideTransition(
                    position: slide,
                    child: child,
                  ),
                ),
              );
            },
            child: Text(
              translation,
              key: ValueKey<String>(_recipeKey),
              style: textTheme.bodyMedium,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            translate('home_page.meal_inspiration_optional'),
            style: textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  String _buildRandomRecipeKey(String mealType) {
    final int day = _random.nextInt(_daysInMealPlan) + 1;
    return 'recipes_page.day_${day}_$mealType';
  }

  bool _hasTranslation(String key) => translate(key) != key;

  void _onRefreshPressed() {
    setState(() {
      _refreshTurns++;
      _selectRandomRecipe();
    });
  }

  void _selectRandomRecipe() {
    final DateTime now = DateTime.now();
    final int hour = now.hour;

    // Determine meal type based on time of day.
    final MealType type = MealType.values.firstWhere(
      (MealType m) => m.matchesHour(hour),
      orElse: () => MealType.dinner, // fallback
    );

    _mealType = type.translationKey;
    _recipeKey = _selectRecipeKeyForMealType(_mealType);
  }

  String _selectRecipeKeyForMealType(String mealType) {
    String recipeKey = _buildRandomRecipeKey(mealType);
    int attempts = 0;

    while (!_hasTranslation(recipeKey) && attempts < _maxSelectionAttempts) {
      recipeKey = _buildRandomRecipeKey(mealType);
      attempts++;
    }

    return recipeKey;
  }
}
