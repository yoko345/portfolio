import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'account_setting.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'providers.dart';
import 'friend_card.dart';

class FriendPage extends ConsumerWidget {
  const FriendPage({Key? key, required this.userId}) : super(key: key);
  final String userId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    final toggleSearchWord = ref.watch(toggleSearchWordProvider);
    TextEditingController searchEditingController = TextEditingController();

    FirebaseFirestore.instance.collection('users').get().then((QuerySnapshot snapshot) {
      snapshot.docs.forEach((doc) {
        if (doc.id == userId) {
          ref.read(userNameProvider.notifier).state = doc.get('userName');
        }
      });
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('友達', style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold, color: Colors.black87),),
        centerTitle: false,
        backgroundColor: Colors.white54,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (context) {return AccountSetting(userId: userId);})),
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
              child: TextFormField(
                onChanged: (value) {
                  ref.read(searchProvider.notifier).state = value;
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
                      ref.read(searchProvider.notifier).state = '';
                      ref.read(toggleSearchWordProvider.notifier).state = false;
                    },
                    icon: const Icon(Icons.cancel),
                    color: toggleSearchWord ? Colors.grey[600] : Colors.transparent,
                  ),
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          StreamBuilder<QuerySnapshot> (
            stream: FirebaseFirestore.instance.collection('friends').orderBy('friendName').snapshots(),
            builder: (context, snapshot) {
              if(snapshot.hasData) {
                List<DocumentSnapshot> friendsData = snapshot.data!.docs;
                return Expanded(
                  child: ListView.builder(
                    itemCount: friendsData.length,
                    itemBuilder: (context, index) {
                      Map<String, dynamic> friendData = friendsData[index].data()! as Map<String, dynamic>;
                      return FriendCard(friendCard: friendData, userId: userId, index: index);
                    }
                  ),
                );
              }
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
          ),
        ],
      ),
    );
  }

}

