// Store links can be supplied when the app has published listings.
class AppLinks {
  AppLinks._();

  static const String repositoryUrl =
      'https://github.com/longngoptit-lab/game_x_o';
  static const String playStoreUrl = String.fromEnvironment(
    'PLAY_STORE_URL',
    defaultValue: repositoryUrl,
  );
  static const String appStoreUrl = String.fromEnvironment(
    'APP_STORE_URL',
    defaultValue: repositoryUrl,
  );
}
