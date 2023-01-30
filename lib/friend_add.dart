import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'models.dart';


class FriendAdd extends ConsumerWidget {
  FriendAdd({Key? key, required this.userId}) : super(key: key);
  final String userId;

  CollectionReference<FriendCard> friendCardRef = FirebaseFirestore.instance.collection('friendCards')
      .withConverter<FriendCard>(
    fromFirestore: (snapshots, _) => FriendCard.fromJson(snapshots.data()!),
    toFirestore: (friendCard, _) => friendCard.toJson(),
  );

  void addFriend(String friendName) async {
    await friendCardRef.add(
        FriendCard(
          imageUrl: '',
          id: userId,
          friendName: friendName,
          friendId: '',
          chat: '',
          newChatCounter: 0,
          date: '',
        ));
  }


  @override
  Widget build(BuildContext context, WidgetRef ref) {

    TextEditingController nameEditingController = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.arrow_back),
            color: Colors.black87
        ),
        title: const Text('友達の追加登録', style: TextStyle(fontSize: 25, color: Colors.black87),),
        centerTitle: false,
        backgroundColor: Colors.white54,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: MediaQuery.of(context).size.height/4.5,),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TextFormField(
                controller: nameEditingController,
                keyboardType: TextInputType.text,
                style: const TextStyle(fontSize: 20),
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey, width: 2),
                  ),
                ),
              ),
            ),
            SizedBox(height: MediaQuery.of(context).size.height/4.5,),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: GestureDetector(
                onTap: () {
                  if(nameEditingController.text != '') {
                    addFriend(nameEditingController.text);
                    Navigator.of(context).pop();
                  } else {
                    return;
                  }
                },
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.orange[400],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Center(
                    child: Text(
                      '友達の追加登録',
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
