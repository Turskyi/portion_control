enum AppRoute {
  onboarding('/onboarding'),
  landing('/'),
  home('/home'),
  about('/about'),
  support('/support'),
  privacyPolity('/privacy-policy');

  const AppRoute(this.path);

  final String path;
}
