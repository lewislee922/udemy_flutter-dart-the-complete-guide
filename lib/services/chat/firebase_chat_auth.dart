import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:udemy_flutter_dart_the_complete_guide_course_demo/services/shared/errors.dart';

import 'chat_auth.dart';

class FirebaseChatAuth implements ChatAuth<User, XFile> {
  final FirebaseAuth _firebase;

  FirebaseChatAuth() : _firebase = FirebaseAuth.instance;

  @override
  User? get currentUser => _firebase.currentUser;

  @override
  Future<dynamic> signIn(String email, String password) async {
    try {
      await _firebase.signInWithEmailAndPassword(
          email: email, password: password);
      // final user = _firebase.currentUser;
      // if (user != null) {
      //   final storage =
      //       FirebaseStorage.instance.ref().child('images').child(user!.uid).getData();
      // }
      return true;
    } on FirebaseAuthException catch (e) {
      return AuthError(e.message ?? "");
    }
  }

  @override
  Stream<User?> listenAuthChanges() => _firebase.authStateChanges();

  @override
  Future<void> signOut() async {
    await _firebase.signOut();
  }

  @override
  Future<dynamic> createAccount(
      String email, String password, XFile userImage, String username) async {
    try {
      final userCredential = await _firebase.createUserWithEmailAndPassword(
          email: email, password: password);
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('images')
          .child(userCredential.user!.uid)
          .child('avator.jpg');
      final data = await userImage.readAsBytes();
      await storageRef.putData(data);
      final realTimeDatabaseRef =
          FirebaseDatabase.instance.ref('users/${userCredential.user!.uid}');
      await realTimeDatabaseRef.update(
          {"name": username, "avator": await storageRef.getDownloadURL()});
      return true;
    } on FirebaseAuthException catch (e) {
      return AuthError(e.message ?? "");
    }
  }
}
