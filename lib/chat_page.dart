import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'providers.dart';

class ChatPage extends ConsumerWidget {
  ChatPage({Key? key, required this.userId, required this.userName, required this.friendName}) : super(key: key);
  final String userId;
  final String userName;
  final String friendName;

  TextEditingController chatEditingController = TextEditingController();
  bool checkDate = true;
  int checkDateCounter = 0;
  int oldDateYear = 0;
  int oldDateMonth = 0;
  int oldDateDay = 0;

  void addChat() async {
    await FirebaseFirestore.instance.collection('chats').add({
      'chat': chatEditingController.text,
      'newChat': chatEditingController.text,
      'id': userId,
      'userName': userName,
      'friendName': friendName,
      'date': DateTime.now().millisecondsSinceEpoch,
      'dateYear': DateTime.now().year,
      'dateMonth': DateTime.now().month,
      'dateDay': DateTime.now().day,
      'dateHour': DateTime.now().hour,
      'dateMinute': DateFormat('mm').format(DateTime.now()),
    });
    chatEditingController.clear();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {

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
          StreamBuilder<QuerySnapshot> (
              stream: FirebaseFirestore.instance.collection('chats').orderBy('date').snapshots(),
              builder: (context, snapshot) {
                if(snapshot.hasData) {
                  List<DocumentSnapshot> chatsData = snapshot.data!.docs;
                  return Expanded(
                    child: ListView.builder(
                        itemCount: chatsData.length,
                        itemBuilder: (context, index) {
                          Map<String, dynamic> chatData = chatsData[index].data()! as Map<String, dynamic>;
                          return chatCard(chatData, sizeWidth);
                        }
                    ),
                  );
                }
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
          ),
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
                            ref.read(recentMonthProvider.notifier).state = DateTime.now().month;
                            ref.read(recentDayProvider.notifier).state = DateTime.now().day;
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

  Widget chatCard(Map<String, dynamic> chatData, double sizeWidth) {

    if((chatData['friendName'] ==  friendName && chatData['userName'] == userName) || (chatData['friendName'] == userName && chatData['userName'] == friendName)) {
      if(chatData['dateYear'] == DateTime.now().year && chatData['dateMonth'] == DateTime.now().month && chatData['dateDay'] == DateTime.now().day && checkDate && checkDateCounter == 0) {
        checkDateCounter = 1;
      } else if(chatData['dateYear'] == DateTime.now().year && chatData['dateMonth'] == DateTime.now().month && chatData['dateDay'] == DateTime.now().day) {
        if(checkDateCounter == 0) {
          checkDate = true;
          checkDateCounter = 1;
        } else {
          checkDate = false;
        }
      } if(chatData['dateYear'] == oldDateYear && chatData['dateMonth'] == oldDateMonth && chatData['dateDay'] == oldDateDay && checkDate && checkDateCounter == 0) {
        checkDateCounter = 1;
      } else if(chatData['dateYear'] == oldDateYear && chatData['dateMonth'] == oldDateMonth && chatData['dateDay'] == oldDateDay) {
        if(checkDateCounter == 0) {
          checkDate = true;
          checkDateCounter = 1;
        } else {
          checkDate = false;
        }
      } else {
        if(checkDateCounter == 0) {
          // checkDate = true;
          checkDateCounter = 1;
          oldDateYear = chatData['dateYear'];
          oldDateMonth = chatData['dateMonth'];
          oldDateDay = chatData['dateDay'];
        } else {
          checkDate = true;
          checkDateCounter == 0;
          oldDateYear = chatData['dateYear'];
          oldDateMonth = chatData['dateMonth'];
          oldDateDay = chatData['dateDay'];
        }
      }

      return Column(
        children: <Widget>[

          checkDate
          ? Padding(
            padding: const EdgeInsets.all(20),
            child: Text('${chatData['dateMonth']}/${chatData['dateDay']}'),
          )
          : Container(),

          userId == chatData['id']
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
                      child: Text(chatData['chat'], style: const TextStyle(fontSize: 14, color: Colors.white),),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    child: Text('${chatData['dateHour']}:${chatData['dateMinute']}'),
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
                      child: Text(chatData['chat'], style: const TextStyle(fontSize: 14,)),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    child: Text('${chatData['dateHour']}:${chatData['dateMinute']}'),
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
