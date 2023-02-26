import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'account_setting.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'friend_add.dart';
import 'models.dart';
import 'chat_page.dart';
import 'firestore_service.dart';
import 'firestore_providers.dart';

final searchWordProvider = StateProvider<String>((ref) => '');

class FriendPage extends ConsumerStatefulWidget {
  FriendPage({Key? key, required this.userId}) : super(key: key);
  final String userId;

  @override
  FriendPageState createState() => FriendPageState();
}

class FriendPageState extends ConsumerState<FriendPage> {

  bool toggleDeleteButton = false;
  TextEditingController searchEditingController = TextEditingController();

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
      body: GestureDetector(
        behavior: HitTestBehavior.opaque, // 画面外のタップを検知する
        onTap: () => FocusScope.of(context).unfocus(),
        child: Consumer(
          builder: (context, ref, child) {
            final friendCardList = ref.watch(friendCardProvider);
            return Column(
              children: [
                child!,
                friendCardList != null
                ? Expanded(
                  child: ListView(
                    children: friendCardList.map((friendCard) => friendCards(friendCard)).toList(),
                  ),
                )
                : const CircularProgressIndicator(),
              ]
            );
          },
          child: Column(
            children: [
              const SizedBox(height: 5,),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: TextFormField(
                    onChanged: (value) {
                      ref.read(searchWordProvider.notifier).state = value;
                      setState(() {
                        if(ref.read(searchWordProvider.notifier).state != '') {
                          toggleDeleteButton = true;
                        } else {
                          toggleDeleteButton = false;
                        }
                      });
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
                          setState(() {
                            toggleDeleteButton = false;
                          });
                        },
                        icon: const Icon(Icons.cancel),
                        color: toggleDeleteButton ? Colors.grey[600] : Colors.transparent,
                      ),
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }


  Widget friendCards(FriendCard friendCard) {

    void getFriendData(String friendName) {

      String friendId = '';
      String imageUrl = '';
      String date = '';
      int newChatCounter = 0;
      List<String> oldChatList = [];
      List<String> newChatList = [];

      FirestoreService().getUserStream(changeQuery: (query) => query.where('userName', isEqualTo: friendName)).get().then((QuerySnapshot snapshot) {
        for(var doc in snapshot.docs) {
          friendId = doc.get('id');

          FirestoreService().getFriendCardQuery(changeQuery: (query) => query.where('friendName', isEqualTo: friendName)).get().then((QuerySnapshot snapshot) {
            for(var doc in snapshot.docs) {
              FirestoreService().friendCardRef().doc(doc.id).update({
                'friendId': friendId,
              });
            }
          });

          FirestoreService().getImageModelQuery(changeQuery: (query) => query.where('id', isEqualTo: friendId)).get().then((QuerySnapshot snapshot) {
            for(var doc in snapshot.docs) {
              imageUrl = doc.get('imageUrl');

              FirestoreService().getFriendCardQuery(changeQuery: (query) => query.where('friendName', isEqualTo: friendName)).get().then((QuerySnapshot snapshot) {
                for(var doc in snapshot.docs) {
                  FirestoreService().friendCardRef().doc(doc.id).update({
                    'imageUrl': imageUrl,
                  });
                }
              });
            }
          });

          FirestoreService().getChatQuery(changeQuery: (query) => query.orderBy('date')).get().then((QuerySnapshot snapshot) {
            for(var doc in snapshot.docs) {
              if((doc.get('friendId') ==  friendId && doc.get('id') == widget.userId) || (doc.get('friendId') == widget.userId && doc.get('id') == friendId)) {
                date = '${doc.get('dateMonth')}/${doc.get('dateDay')}';
                oldChatList.add(doc.get('chat'));

                if((doc.get('friendId') == widget.userId && doc.get('id') == friendId) && doc.get('newChat') != '') {
                  newChatCounter++;
                }

                FirestoreService().getFriendCardQuery(changeQuery: (query) => query.where('id', isEqualTo: widget.userId).where('friendName', isEqualTo: friendName)).get().then((QuerySnapshot snapshot) {
                  for(var doc in snapshot.docs) {
                    FirestoreService().friendCardRef().doc(doc.id).update({
                      'date': date,
                      'chat': oldChatList.join('  '),
                      'newChatCounter': newChatCounter,
                    });
                  }
                });
              } else {
                continue;
              }
            }
          });
        }
      });
    }



    void newChatClear(String friendId) {
      FirestoreService().getChatQuery(changeQuery: (query) => query.where('friendId', isEqualTo: widget.userId).where('id', isEqualTo: friendId)).get().then((QuerySnapshot snapshot) {
        for(var doc in snapshot.docs) {
          FirestoreService().chatRef().doc(doc.id).update({'newChat': '',});
        }
      });

      FirestoreService().getFriendCardQuery(changeQuery: (query) => query.where('id', isEqualTo: widget.userId).where('friendId', isEqualTo: friendId)).get().then((QuerySnapshot snapshot) {
        for(var doc in snapshot.docs) {
          FirestoreService().friendCardRef().doc(doc.id).update({'newChatCounter': 0,});
        }
      });
    }

    return Consumer(
        builder: (context, ref, _) {
          getFriendData(friendCard.friendName);
          final searchWord = ref.watch(searchWordProvider);

          if(friendCard.friendName.contains(searchWord) && friendCard.id == widget.userId) {
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
                        Navigator.of(context).push(MaterialPageRoute(builder: (context) {return ChatPage(userId: widget.userId, friendId: friendCard.friendId, friendName: friendCard.friendName,);}));

                        newChatClear(friendCard.friendId);
                      },
                      icon: const Icon(Icons.arrow_forward_ios),
                    ),
                  ],
                ),
              ),
            );
          } else {
            return const SizedBox();
          }
        }
    );
  }

}
