/// Run locally without an account. Enable the connected app explicitly after
/// configuring your Firebase project with scripts/configure_firebase.sh.
abstract final class RuntimeConfig {
  static const offlineMode = bool.fromEnvironment(
    'OFFLINE_MODE',
    defaultValue: true,
  );
  static const localUserId = 'local-player';
}
