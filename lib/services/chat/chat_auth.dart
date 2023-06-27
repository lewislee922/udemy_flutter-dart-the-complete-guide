abstract class ChatAuth<T, R> {
  Future<dynamic> signIn(String email, String password);
  Future<dynamic> createAccount(
      String email, String password, R userImage, String username);
  Future<void> signOut();
  Stream<T?> listenAuthChanges();
  T? get currentUser;
}
