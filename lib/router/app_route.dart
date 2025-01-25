enum AppRoute {
  home('/home'),
  privacyPolity('/privacy-policy');

  const AppRoute(this.path);

  final String path;
}
