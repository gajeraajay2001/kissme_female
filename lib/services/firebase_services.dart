import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseService {
  FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  static FirebaseFirestore firebaseFireStore = FirebaseFirestore.instance;

  static Future<DocumentReference<Map<String, dynamic>>>
      addChatDataToLiveStreaming(
          {required String chatId,
          required Map<String, dynamic> chatData}) async {
    return await firebaseFireStore
        .collection("liveStream")
        .doc(chatId)
        .collection("message")
        .add(chatData);
  }

  static Stream<QuerySnapshot> getStreamChatData({required String chatId}) {
    return firebaseFireStore
        .collection("liveStream")
        .doc(chatId)
        .collection("message")
        // .orderBy("dateTime", descending: false)
        .snapshots();
  }
}
