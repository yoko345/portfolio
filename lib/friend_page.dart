import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'account_setting.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'friend_add.dart';
import 'models.dart';
import 'chat_page.dart';

final searchWordProvider = StateProvider<String>((ref) => '');
final toggleSearchWordProvider = StateProvider<bool>((ref) => false);

class FriendPage extends StatefulWidget {
  FriendPage({Key? key, required this.userId}) : super(key: key);
  final String userId;

  @override
  State<FriendPage> createState() => _FriendPageState();
}

class _FriendPageState extends State<FriendPage> {

  CollectionReference<FriendCard> friendCardRef = FirebaseFirestore.instance.collection('friendCards')
      .withConverter<FriendCard>(
    fromFirestore: (snapshots, _) => FriendCard.fromJson(snapshots.data()!),
    toFirestore: (friendCard, _) => friendCard.toJson(),
  );

  CollectionReference<UserModel> userModelRef = FirebaseFirestore.instance.collection('users')
      .withConverter<UserModel>(
    fromFirestore: (snapshots, _) => UserModel.fromJson(snapshots.data()!),
    toFirestore: (userModel, _) => userModel.toJson(),
  );

  CollectionReference<ImageModel> imageModelRef = FirebaseFirestore.instance.collection('images')
      .withConverter<ImageModel>(
    fromFirestore: (snapshots, _) => ImageModel.fromJson(snapshots.data()!),
    toFirestore: (imageModel, _) => imageModel.toJson(),
  );

  CollectionReference<Chat> chatRef = FirebaseFirestore.instance.collection('chats')
      .withConverter<Chat>(
    fromFirestore: (snapshots, _) => Chat.fromJson(snapshots.data()!),
    toFirestore: (chat, _) => chat.toJson(),
  );


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('友達', style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold, color: Colors.black87),),
        centerTitle: false,
        backgroundColor: Colors.white54,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (context) {return FriendAdd(userId: widget.userId);})),
            icon: const Icon(Icons.person_add),
            color: Colors.black87,
          ),
          IconButton(
            onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (context) {return AccountSetting(userId: widget.userId);})),
            icon: const Icon(Icons.manage_accounts),
            color: Colors.black87,
          ),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 10,),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              width: MediaQuery.of(context).size.width,
              padding: const EdgeInsets.symmetric(vertical: 5),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(5),
              ),
              child: searchFriend(), // 下にウィジェットがある
            ),
          ),
          StreamBuilder<QuerySnapshot<FriendCard>>(
              stream: friendCardRef.where('id', isEqualTo: widget.userId).snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  final data = snapshot.data!;
                  return Expanded(
                    child: ListView.builder(
                        itemCount: data.docs.length,
                        itemBuilder: (context, index) {
                          return friendCard(data.docs[index].data(), widget.userId);
                        }
                    ),
                  );
                } else {
                  return const Center(child: CircularProgressIndicator(),);
                }
              }
          ),
        ],
      ),
    );
  }

  Widget searchFriend() {
    return Consumer(
      builder: (context, ref, child) {
        final toggleSearchWord = ref.watch(toggleSearchWordProvider);
        TextEditingController searchEditingController = TextEditingController();

        return TextFormField(
          onChanged: (value) {
            ref.read(searchWordProvider.notifier).state = value;
          },
          onTap: () {
            ref.read(toggleSearchWordProvider.notifier).state = true;
          },
          controller: searchEditingController,
          keyboardType: TextInputType.text,
          cursorColor: Colors.grey[600],
          decoration: InputDecoration(
            hintText: '検索',
            hintStyle: const TextStyle(color: Colors.grey),
            prefixIcon: Icon(Icons.search, color: Colors.grey[600],),
            suffixIcon: IconButton(
              onPressed: () {
                searchEditingController.clear();
                ref.read(searchWordProvider.notifier).state = '';
                ref.read(toggleSearchWordProvider.notifier).state = false;
              },
              icon: const Icon(Icons.cancel),
              color: toggleSearchWord ? Colors.grey[600] : Colors.transparent,
            ),
            border: InputBorder.none,
          ),
        );
      },
    );
  }



  Widget friendCard(FriendCard friendCard, String userId) {

    void friendCardControl(String friendName, String userId) async {
      String imageUrl = '';
      String friendId = '';
      String date = '';
      int recentMonth = 0;
      int recentDay = 0;
      int newChatCounter = 0;
      List<String> chatList = [];
      List<String> newChatList = [];

      await userModelRef.where('userName', isEqualTo: friendName).get().then((QuerySnapshot snapshot) {
        snapshot.docs.forEach((doc) async {
          friendId = doc.get('id');
          await friendCardRef.where('friendName', isEqualTo: friendName).get().then((QuerySnapshot snapshot) {
            snapshot.docs.forEach((doc) async {
              await friendCardRef.doc(doc.id).update({
                'friendId': friendId,
              });
            });
          });
          await imageModelRef.where('id', isEqualTo: friendId).get().then((QuerySnapshot snapshot) {
            snapshot.docs.forEach((doc) async {
              if (doc.get('imageUrl') != '') {
                imageUrl = doc.get('imageUrl');
                await friendCardRef.where('friendName', isEqualTo: friendName).get().then((QuerySnapshot snapshot) {
                  snapshot.docs.forEach((doc) async {
                    await friendCardRef.doc(doc.id).update({
                      'imageUrl': imageUrl,
                    });
                  });
                });
              } else {
                return;
              }
            });
          });
        });
      });

      await chatRef.orderBy('date').get().then((QuerySnapshot snapshot) {
        snapshot.docs.forEach((doc) async {

          if((doc.get('friendId') ==  friendId && doc.get('id') == userId) || (doc.get('friendId') == userId && doc.get('id') == friendId)) {

            recentMonth = doc.get('dateMonth');
            recentDay = doc.get('dateDay');
            await friendCardRef.where('id', isEqualTo: userId).where('friendName', isEqualTo: friendName).get().then((QuerySnapshot snapshot) {
              snapshot.docs.forEach((doc) async {
                date = '$recentMonth/$recentDay';
                await friendCardRef.doc(doc.id).update({
                  'date': date,
                });
              });
            });

            chatList.add(doc.get('chat'));

            await friendCardRef.where('id', isEqualTo: userId).where('friendName', isEqualTo: friendName).get().then((QuerySnapshot snapshot) {
              snapshot.docs.forEach((doc) async {
                await friendCardRef.doc(doc.id).update({
                  'chat': chatList.join('  '),
                });
              });
            });

            if(doc.get('friendId') == userId && doc.get('id') == friendId) {
              if(!newChatList.contains(doc.get('newChat'))) {
                if(doc.get('newChat') != '') {
                  newChatCounter++;
                  await friendCardRef.where('id', isEqualTo: userId).where('friendName', isEqualTo: friendName).get().then((QuerySnapshot snapshot) {
                    snapshot.docs.forEach((doc) async {
                      await friendCardRef.doc(doc.id).update({
                        'newChatCounter': newChatCounter,
                      });
                    });
                  });
                }
              }
            }

          } else {
            return;
          }
        });
      });

    }

    return Consumer(
        builder: (context, ref, child) {

          final searchWord = ref.watch(searchWordProvider);

          friendCardControl(friendCard.friendName, userId);

          void newChatClear(String friendId) async {
            await chatRef.where('friendId', isEqualTo: userId).where('id', isEqualTo: friendId).get().then((QuerySnapshot snapshot) {
              snapshot.docs.forEach((doc) {
                chatRef.doc(doc.id).update({'newChat': '',});
              });
            });

            await friendCardRef.where('friendId', isEqualTo: friendId).get().then((QuerySnapshot snapshot) {
              snapshot.docs.forEach((doc) {
                friendCardRef.doc(doc.id).update({'newChatCounter': 0,});
              });
            });

          }

          if(friendCard.friendName.contains(searchWord) && friendCard.id == userId) {
            return Card(
              child: ListTile(
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(30),
                  child: friendCard.imageUrl != ''
                      ? Image.network(friendCard.imageUrl, width: 30, height: 30, fit: BoxFit.cover,)
                      : const Icon(Icons.image),
                ),
                title: Text(friendCard.friendName),
                subtitle: Text(
                  friendCard.chat != '' ? friendCard.chat : '',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: Wrap(
                  children: [
                    Column(
                      children: [
                        Text(friendCard.date),
                        const SizedBox(height: 5,),
                        friendCard.newChatCounter > 0
                            ? SizedBox(
                          height: 25,
                          width: 25,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(25),
                            child: Container(
                              color: Colors.orange[400],
                              child: Center(
                                child: Text('${friendCard.newChatCounter}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),),
                              ),
                            ),
                          ),
                        )
                            : const SizedBox(height: 25, width: 25,)
                      ],
                    ),
                    IconButton(
                      onPressed: () {
                        Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                          return ChatPage(userId: userId, friendId: friendCard.friendId, friendName: friendCard.friendName,);
                        }));

                        newChatClear(friendCard.friendId);
                      },
                      icon: const Icon(Icons.arrow_forward_ios),
                    ),
                  ],
                ),
              ),
            );
          } else {
            return const Card();
          }
        }
    );
  }
}






