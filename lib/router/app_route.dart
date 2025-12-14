enum AppRoute {
  onboarding('/onboarding'),
  landing('/'),
  home('/home'),
  about('/about'),
  recipes('/recipes'),
  support('/support'),
  privacyPolity('/privacy-policy'),
  dailyFoodLogHistory('/daily-food-log-history');

  const AppRoute(this.path);

  final String path;
}
