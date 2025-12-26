import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';

class RandomRecipeCard extends StatefulWidget {
  const RandomRecipeCard({super.key});

  @override
  State<RandomRecipeCard> createState() => _RandomRecipeCardState();
}

class _RandomRecipeCardState extends State<RandomRecipeCard> {
  late String _mealType;
  late String _recipeKey;

  @override
  void initState() {
    super.initState();
    _selectRandomRecipe();
  }

  void _selectRandomRecipe() {
    final DateTime now = DateTime.now();
    final int hour = now.hour;

    // Determine meal type based on time of day.
    if (hour <= 10 && hour > 3) {
      _mealType = 'breakfast';
    } else if (hour < 12 && hour >= 10) {
      _mealType = 'second_breakfast';
    } else if (hour < 15 && hour >= 12) {
      _mealType = 'lunch';
    } else if (hour < 18) {
      _mealType = 'snack';
    } else {
      _mealType = 'dinner';
    }

    // List of days in the meal plan, from 1 to 154, taken from
    // assets/i18n/en.json.
    final int day = Random().nextInt(154) + 1;
    _recipeKey = 'recipes_page.day_${day}_$_mealType';
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    // Check if translation exists, otherwise find another one.
    String translation = translate(_recipeKey);
    if (translation == _recipeKey) {
      // Fallback or retry logic could go here.
      // For now, if a specific meal doesn't exist for a day (e.g. some days
      // might have different structure),
      // we can hide the card or show a generic message.
      // However, looking at the JSON, most days have these keys.
      // Day 3, 9, 23, 31 have special diets and might not have standard keys.
      // Let's handle special days simply by picking another random day if the
      // key is missing.
      int attempts = 0;
      while (translation == _recipeKey && attempts < 10) {
        final int day = Random().nextInt(35) + 1;
        _recipeKey = 'recipes_page.day_${day}_$_mealType';
        translation = translate(_recipeKey);
        attempts++;
      }

      if (translation == _recipeKey) {
        return const SizedBox.shrink();
      }
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(16),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
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
              const Icon(Icons.restaurant_menu, color: Colors.orange),
              const SizedBox(width: 8),
              Text(
                translate('meal_type.$_mealType'),
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.refresh, size: 20, color: Colors.grey),
                onPressed: () {
                  //TODO: use HomeBloc
                  setState(() {
                    _selectRandomRecipe();
                  });
                },
                tooltip: translate('home_page.next_recipe'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            translation,
            style: textTheme.bodyMedium,
          ),
          const SizedBox(height: 8),
          Text(
            translate('home_page.meal_inspiration_optional'),
            style: textTheme.bodySmall?.copyWith(
              color: Colors.grey,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }
}
