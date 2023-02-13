import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:portfolio_ver1/firestore_providers.dart';
import 'models.dart';
import 'firestore_service.dart';


class ChatPage extends ConsumerWidget {
  ChatPage({Key? key, required this.userId, required this.friendId, required this.friendName}) : super(key: key);
  final String userId;
  final String friendId;
  final String friendName;

  bool checkDate = true;
  List<String> checkDateList = [];

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    final double sizeWidth = MediaQuery.of(context).size.width;
    final chatList = ref.watch(chatProvider);


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
          chatList != null
          ? Expanded(
            child: ListView(
              children: chatList.map((chat) => chatCard(chat, sizeWidth)).toList(),
            ),
          )
          : const CircularProgressIndicator(),
        ChatTextField(userId: userId, friendId: friendId, checkDate: checkDate, checkDateList: checkDateList) , // コードは下にある
        ],
      ),
    );
  }

  Widget chatCard(Chat chat, double sizeWidth) {

    if((chat.friendId ==  friendId && chat.id == userId) || (chat.friendId == userId && chat.id == friendId)) {

      if(checkDateList.isNotEmpty) {
        if(!checkDateList.contains('${chat.dateYear}/${chat.dateMonth}/${chat.dateDay}')) {
          checkDateList.add('${chat.dateYear}/${chat.dateMonth}/${chat.dateDay}');
          checkDate = true;
        } else {
          checkDate = false;
        }
      } else {
        checkDateList.add('${chat.dateYear}/${chat.dateMonth}/${chat.dateDay}');
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


class ChatTextField extends StatefulWidget {
  ChatTextField({Key? key, required this.userId, required this.friendId, required this.checkDate, required this.checkDateList}) : super(key: key);
  final String userId;
  final String friendId;
  bool checkDate;
  List<String> checkDateList;

  @override
  State<ChatTextField> createState() => _ChatTextFieldState();
}

class _ChatTextFieldState extends State<ChatTextField> {

  TextEditingController chatEditingController = TextEditingController();

  void addChat() {
    if(chatEditingController.text != '') {
      int dateMinuteInt = DateTime.now().minute;
      String dateMinuteString = '';
      if (dateMinuteInt < 10) {
        dateMinuteString = '0$dateMinuteInt';
      } else {
        dateMinuteString = dateMinuteInt.toString();
      }
      FirestoreService().addChat(
          Chat(
            chat: chatEditingController.text,
            newChat: chatEditingController.text,
            id: widget.userId,
            friendId: widget.friendId,
            date: DateTime.now().millisecondsSinceEpoch,
            dateYear: DateTime.now().year,
            dateMonth: DateTime.now().month,
            dateDay: DateTime.now().day,
            dateHour: DateTime.now().hour,
            dateMinute: dateMinuteString,
          )
      );
      chatEditingController.clear();
    } else {
      return;
    }
  }

  @override
  Widget build(BuildContext context) {

    return Padding(
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
                      widget.checkDate = true;
                      widget.checkDateList = [];
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
    );
  }
}


