enum AppRoute {
  landing('/'),
  home('/home'),
  about('/about'),
  privacyPolity('/privacy-policy');

  const AppRoute(this.path);

  final String path;
}
