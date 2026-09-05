abstract interface class AccountSession {
  bool get signedIn;
  Future<void> initialize();
  Future<void> signIn(String email, String password, {required bool register});
  Future<void> resetPassword(String email);
}
