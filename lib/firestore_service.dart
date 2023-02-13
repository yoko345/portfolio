import 'package:cloud_firestore/cloud_firestore.dart';
import 'models.dart';

class FirestoreService {
  final _firestore = FirebaseFirestore.instance;

  Query<UserModel> getUserStream({Query Function(Query)? changeQuery}) {
    Query query = _firestore.collection('users');
    if (changeQuery != null) {
      query = changeQuery(query);
    }

    return query.withConverter<UserModel>(
      fromFirestore: (snapshots, _) => UserModel.fromJson(snapshots.data()!),
      toFirestore: (userModel, _) => userModel.toJson(),
    );
  }

  CollectionReference<UserModel> userModelRef() {
    return _firestore.collection('users').withConverter<UserModel>(
      fromFirestore: (snapshots, _) => UserModel.fromJson(snapshots.data()!),
      toFirestore: (userModel, _) => userModel.toJson(),
    );
  }

  void addUser(UserModel userModel) {
    _firestore.collection('users').withConverter<UserModel>(
      fromFirestore: (snapshots, _) => UserModel.fromJson(snapshots.data()!),
      toFirestore: (userModel, _) => userModel.toJson(),
    ).add(userModel);
  }



  Stream<List<Chat>> getChatStream({Query Function(Query)? changeQuery}) {
    Query query = _firestore.collection('chats');
    if(changeQuery != null) {
      query = changeQuery(query);
    }

    final Stream<QuerySnapshot<Chat>> snapshots = query.withConverter<Chat>(
      fromFirestore: (snapshots, _) => Chat.fromJson(snapshots.data()!),
      toFirestore: (chat, _) => chat.toJson(),
    ).snapshots();

    return snapshots.map((snapshot) =>
      snapshot.docs.map((data) => data.data()).toList()
    );
  }

  Query<Chat> getChatQuery({Query Function(Query)? changeQuery}) {
    Query query = _firestore.collection('chats');
    if (changeQuery != null) {
      query = changeQuery(query);
    }

    return query.withConverter<Chat>(
      fromFirestore: (snapshots, _) => Chat.fromJson(snapshots.data()!),
      toFirestore: (chat, _) => chat.toJson(),
    );
  }

  CollectionReference<Chat> chatRef() {
    return _firestore.collection('chats').withConverter<Chat>(
      fromFirestore: (snapshots, _) => Chat.fromJson(snapshots.data()!),
      toFirestore: (chat, _) => chat.toJson(),
    );
  }

  void addChat(Chat chat) {
    _firestore.collection('chats').withConverter<Chat>(
      fromFirestore: (snapshots, _) => Chat.fromJson(snapshots.data()!),
      toFirestore: (chat, _) => chat.toJson(),
    ).add(chat);
  }



  Stream<List<FriendCard>> getFriendCardStream({Query Function(Query)? changeQuery}) {
    Query query = _firestore.collection('friendCards');
    if(changeQuery != null) {
      query = changeQuery(query);
    }

    final Stream<QuerySnapshot<FriendCard>> snapshots = query.withConverter<FriendCard>(
      fromFirestore: (snapshots, _) => FriendCard.fromJson(snapshots.data()!),
      toFirestore: (friendCard, _) => friendCard.toJson(),
    ).snapshots();

    return snapshots.map((snapshot) =>
        snapshot.docs.map((data) => data.data()).toList()
    );
  }

  Query<FriendCard> getFriendCardQuery({Query Function(Query)? changeQuery}) {
    Query query = _firestore.collection('friendCards');
    if (changeQuery != null) {
      query = changeQuery(query);
    }

    return query.withConverter<FriendCard>(
      fromFirestore: (snapshots, _) => FriendCard.fromJson(snapshots.data()!),
      toFirestore: (friendCard, _) => friendCard.toJson(),
    );
  }

  CollectionReference<FriendCard> friendCardRef() {
    return _firestore.collection('friendCards').withConverter<FriendCard>(
      fromFirestore: (snapshots, _) => FriendCard.fromJson(snapshots.data()!),
      toFirestore: (friendCard, _) => friendCard.toJson(),
    );
  }

  void addFriend(FriendCard friendCard) {
    _firestore.collection('friendCards').withConverter<FriendCard>(
      fromFirestore: (snapshots, _) => FriendCard.fromJson(snapshots.data()!),
      toFirestore: (friendCard, _) => friendCard.toJson(),
    ).add(friendCard);
  }



  Query<ImageModel> getImageModelQuery({Query Function(Query)? changeQuery}) {
    Query query = _firestore.collection('images');
    if (changeQuery != null) {
      query = changeQuery(query);
    }

    return query.withConverter<ImageModel>(
      fromFirestore: (snapshots, _) => ImageModel.fromJson(snapshots.data()!),
      toFirestore: (imageModel, _) => imageModel.toJson(),
    );
  }

  CollectionReference<ImageModel> imageModelRef() {
    return _firestore.collection('images').withConverter<ImageModel>(
      fromFirestore: (snapshots, _) => ImageModel.fromJson(snapshots.data()!),
      toFirestore: (imageModel, _) => imageModel.toJson(),
    );
  }

  void setImage(ImageModel imageModel, String userId) {
    _firestore.collection('images').doc(userId).withConverter<ImageModel>(
      fromFirestore: (snapshots, _) => ImageModel.fromJson(snapshots.data()!),
      toFirestore: (imageModel, _) => imageModel.toJson(),
    ).set(imageModel);
  }


}