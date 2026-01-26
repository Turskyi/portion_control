import 'package:shared_preferences/shared_preferences.dart';

/// Service to manage and persist "Tried" state for recipes
class RecipeTriedStateService {
  static const String _prefixKey = 'recipe_tried_';

  /// Get the tried state for a recipe by its ID
  Future<bool> getTriedState(String recipeId) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_prefixKey + recipeId) ?? false;
  }

  /// Set the tried state for a recipe
  Future<void> setTriedState(String recipeId, bool tried) async {
    final prefs = await SharedPreferences.getInstance();
    if (tried) {
      await prefs.setBool(_prefixKey + recipeId, true);
    } else {
      await prefs.remove(_prefixKey + recipeId);
    }
  }

  /// Toggle the tried state for a recipe
  Future<bool> toggleTriedState(String recipeId) async {
    final current = await getTriedState(recipeId);
    await setTriedState(recipeId, !current);
    return !current;
  }

  /// Clear all tried states
  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys();
    for (final key in keys) {
      if (key.startsWith(_prefixKey)) {
        await prefs.remove(key);
      }
    }
  }
}
