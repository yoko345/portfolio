import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:portfolio_ver1/firebase_services/firestore_service.dart';
import 'package:portfolio_ver1/providers/firestore_providers.dart';
import 'models.dart';


class ChatPage extends ConsumerWidget {
  ChatPage({Key? key, required this.userId, required this.friendId, required this.friendName}) : super(key: key);
  final String userId;
  final String friendId;
  final String friendName;

  TextEditingController chatEditingController = TextEditingController();
  bool checkDate = true;
  List<String> checkDateList = [];

  // firestoreのリファレンスはウィジェットの中に作るよりも、専用のクラスにまとめたほうが良いです
  // CollectionReference<Chat> chatRef = FirebaseFirestore.instance.collection('chats')
  //     .withConverter<Chat>(
  //   fromFirestore: (snapshots, _) => Chat.fromJson(snapshots.data()!),
  //   toFirestore: (chat, _) => chat.toJson(),
  // );

  void addChat() async {
    if(chatEditingController.text != '') {
      FirestoreService().addChat(
          Chat(
            chat: chatEditingController.text,
            newChat: chatEditingController.text,
            id: userId,
            friendId: friendId,
            date: DateTime.now().millisecondsSinceEpoch,
            dateYear: DateTime.now().year,
            dateMonth: DateTime.now().month,
            dateDay: DateTime.now().day,
            dateHour: DateTime.now().hour,
            dateMinute: DateFormat('mm').format(DateTime.now()),
          ));
      chatEditingController.clear();
    } else {
      return;
    }
  }


  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chatList = ref.watch(chatProvider);

    final double sizeWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.arrow_back),
            color: Colors.black87
        ),
        title: Text(friendName, style: const TextStyle(fontSize: 25, fontWeight: FontWeight.bold, color: Colors.black87),),
        centerTitle: false,
        backgroundColor: Colors.white54,
        elevation: 0,
      ),
      body: Column(
        children: [
          // riverpodを使用する場合は　Firestore => UI　という流れではなく、　
          // Firestore => Provider => UI　という流れにするとプロジェクトがまとまります
          // StreamBuilder<QuerySnapshot<Chat>> (
          //     stream: FirestoreService().getChatStream(changeQuery: (query)=>query.orderBy('date')),
          //     builder: (context, snapshot) {
          //       if(snapshot.hasData) {
          //         final data = snapshot.data!;
          //         return Expanded(
          //           child: ListView.builder(
          //               itemCount: data.docs.length,
          //               itemBuilder: (context, index) {
          //                 return chatCard(data.docs[index].data(), sizeWidth);
          //               }
          //           ),
          //         );
          //       }
          //       return const Center(
          //         child: CircularProgressIndicator(),
          //       );
          //     }
          // ),

          // UI部分に書く内容が少なく済みます
          chatList!=null?Expanded(
            child: ListView(
              children: chatList.map((e) => chatCard(e, sizeWidth)).toList(),
            ),
          ):const CircularProgressIndicator(),

          Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              children: [
                Flexible(
                  child: SingleChildScrollView(
                    child: TextField(
                      controller: chatEditingController,
                      keyboardType: TextInputType.multiline,
                      minLines: 1,
                      maxLines: 10,
                      cursorColor: Colors.grey[600],
                      decoration: InputDecoration(
                        hintText: 'メッセージ',
                        hintStyle: const TextStyle(color: Colors.grey),
                        border: const OutlineInputBorder(),
                        focusedBorder: const OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey, width: 2),
                        ),
                        suffixIcon: IconButton(
                          onPressed: () {
                            addChat();
                            checkDate = true;
                            checkDateList = [];
                          },
                          icon: const Icon(Icons.send),
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget chatCard(Chat chat, double sizeWidth) {

    if((chat.friendId ==  friendId && chat.id == userId) || (chat.friendId == userId && chat.id == friendId)) {

      if(!checkDateList.contains('${chat.dateYear}/${chat.dateMonth}/${chat.dateDay}')) {
        checkDateList.add('${chat.dateYear}/${chat.dateMonth}/${chat.dateDay}');
        checkDate = true;
      } else {
        checkDate = false;
      }

      return Column(
        children: <Widget>[

          checkDate
              ? Padding(
            padding: const EdgeInsets.all(20),
            child: Text('${chat.dateMonth}/${chat.dateDay}'),
          )
              : Container(),

          userId == chat.id
              ? Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Align(
              alignment: Alignment.centerRight,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: sizeWidth / 1.8,
                    decoration: BoxDecoration(
                      color: Colors.orange[300],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Text(chat.chat, style: const TextStyle(fontSize: 14, color: Colors.white),),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    child: Text('${chat.dateHour}:${chat.dateMinute}'),
                  ),
                  const SizedBox(height: 20,),
                ],
              ),
            ),
          )
              : Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    width: sizeWidth / 1.8,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE0E0E0),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Text(chat.chat, style: const TextStyle(fontSize: 14,)),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    child: Text('${chat.dateHour}:${chat.dateMinute}'),
                  ),
                  const SizedBox(height: 20,),
                ],
              ),
            ),
          ),
        ],
      );
    } else {
      return Container();
    }
  }
}
