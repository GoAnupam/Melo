/// Stand-in for the real authentication API.
///
/// Simulates latency and a failure path so the UI's loading and error states
/// can be exercised. Replace with a Django-backed implementation later.
class MockAuthRepository {
  const MockAuthRepository();

  static const _latency = Duration(milliseconds: 900);

  /// Code that always fails verification, to demo the error state.
  static const failingCode = '424242';

  Future<void> sendCode(String destination) async {
    await Future<void>.delayed(_latency);
  }

  /// Throws [AuthException] when the code is wrong.
  Future<void> verifyCode(String destination, String code) async {
    await Future<void>.delayed(_latency);
    if (code == failingCode) {
      throw const AuthException("That code doesn't match. Please try again.");
    }
  }
}

class AuthException implements Exception {
  const AuthException(this.message);

  final String message;

  @override
  String toString() => message;
}

const authRepository = MockAuthRepository();
