/// Build-time configuration, supplied via --dart-define.
///
/// Example:
///   flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8000/api/v1
class Env {
  Env._();

  /// Android emulators reach the host machine at 10.0.2.2;
  /// iOS simulators can use localhost.
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:8000/api/v1',
  );
}
