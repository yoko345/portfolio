import 'package:cloud_firestore/cloud_firestore.dart';
import '../models.dart';

//このように、Firebaseからの読み取りや書き込みのコードを一か所にまとめておくと良いです
//情報の流れが、Firebase => Provider => UI　になっていることが分かりやすくなります。
class FirestoreService {

  final _firestore = FirebaseFirestore.instance;

  // firestoreからデータを読み取るメソッドです。引数のchangeQuery関数でクエリを変更できます。
  Stream<List<Chat>> getChatStream({Query Function(Query)? changeQuery}){
    Query query = _firestore.collection('chats');
    if(changeQuery != null){
      query = changeQuery(query);
    }

    final Stream<QuerySnapshot<Chat>> snapshots = query.withConverter<Chat>(
      fromFirestore: (snapshots, _) => Chat.fromJson(snapshots.data()!),
      toFirestore: (chat, _) => chat.toJson(),
    ).snapshots();

    return snapshots.map((snapshot){
      return snapshot.docs.map((data) => data.data()).toList();
    });
  }

  void addChat(Chat chat){
    _firestore.collection('Chats').withConverter<Chat>(
      fromFirestore: (snapshots, _) => Chat.fromJson(snapshots.data()!),
      toFirestore: (chat, _) => chat.toJson(),
    ).add(chat);
  }
}