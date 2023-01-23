import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'chat_page.dart';
import 'providers.dart';

class FriendCard extends ConsumerWidget {
  const FriendCard({Key? key, required this.friendCard, required this.userId, required this.index}) : super(key: key);
  final Map<String, dynamic> friendCard;
  final String userId;
  final int index;


  @override
  Widget build(BuildContext context, WidgetRef ref) {

    final searchWord = ref.watch(searchProvider);
    final imageUrl = ref.watch(imageUrlProvider);
    final userName = ref.watch(userNameProvider);
    final recentMonth =  ref.watch(recentMonthProvider);
    final recentDay =  ref.watch(recentDayProvider);
    final newChat = ref.watch(newChatProvider);
    final newChatList = ref.watch(newChatListProvider);
    final newChatCounter = ref.watch(newChatCounterProvider);
    final oldChat = ref.watch(oldChatProvider);
    final oldChatList = ref.watch(oldChatListProvider);

    FirebaseFirestore.instance.collection('images').where('userName', isEqualTo: friendCard['friendName']).get().then((QuerySnapshot snapshot) {
      snapshot.docs.forEach((doc) {
        ref.read(imageUrlProvider.notifier).state = doc.get('imageUrl');
      });
    });

    FirebaseFirestore.instance.collection('chats').orderBy('date').get().then((QuerySnapshot snapshot) {
      snapshot.docs.forEach((doc) {
        if(doc.get('friendName') != '' && doc.get('userName') != '' &&  userName != '') {
          if((doc.get('friendName') ==  friendCard['friendName'] && doc.get('userName') == userName) || (doc.get('friendName') == userName && doc.get('userName') == friendCard['friendName'])) {
              ref.read(recentMonthProvider.notifier).state = doc.get('dateMonth');
              ref.read(recentDayProvider.notifier).state = doc.get('dateDay');

            if(!oldChat.contains(doc.get('chat'))) {
              oldChat.add(doc.get('chat'));
              oldChatList['$index'] = oldChat;
            }

            if(doc.get('friendName') == userName && doc.get('userName') == friendCard['friendName']) {
              if(!newChat.contains(doc.get('newChat'))){
                if(doc.get('newChat') != '') {
                  ref.read(recentMonthProvider.notifier).state = doc.get('dateMonth');
                  ref.read(recentDayProvider.notifier).state = doc.get('dateDay');

                  newChat.add(doc.get('newChat'));
                  newChatList['$index'] = newChat;
                  ref.read(newChatCounterProvider.notifier).state = newChatList['$index'].length;
                }
              }
            }

          } else if((friendCard['friendName'] != doc.get('friendName') && userName == doc.get('userName')) || (friendCard['friendName'] == doc.get('userName') && userName != doc.get('friendName'))) {
            newChatList['$index'] = [];
          }

        }
      });
    });


    if(friendCard['friendName'].contains(searchWord) && friendCard['id'] == userId) {
      return Card(
        child: ListTile(
          leading: ClipRRect(
            borderRadius: BorderRadius.circular(30),
            child: imageUrl==''
                ? const Icon(Icons.image)
                : Image.network(imageUrl, width: 30, height: 30, fit: BoxFit.cover,),
          ),
          title: Text(friendCard['friendName']),
          subtitle: Text(
            oldChatList['$index'] != null ? '${oldChatList['$index'].join('  ')}' : '',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          trailing: Wrap(
            children: [
              Column(
                children: [
                  Text('$recentMonth/$recentDay'),
                  const SizedBox(height: 5,),
                  newChatList['$index'] != null
                  ? newChatList['$index'].length != 0
                    ? SizedBox(
                        height: 25,
                        width: 25,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(25),
                          child: Container(
                            color: Colors.orange[400],
                            child: Center(
                              child: Text('$newChatCounter', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),),
                            ),
                          ),
                        ),
                    )
                    : const SizedBox(height: 25, width: 25,)
                  : const SizedBox(height: 25, width: 25,),
                ],
              ),
              IconButton(
                onPressed: () {

                  Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                    return ChatPage(userId: userId, userName: userName, friendName: friendCard['friendName'],);
                  }));

                  FirebaseFirestore.instance.collection('chats').where('friendName', isEqualTo: userName).where('userName', isEqualTo: friendCard['friendName']).get().then((QuerySnapshot snapshot) {
                    snapshot.docs.forEach((doc) {
                      FirebaseFirestore.instance.collection('chats').doc(doc.id).update({'newChat': '',});
                    });
                  });

                  newChat.clear();

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
}

