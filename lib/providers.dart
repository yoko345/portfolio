import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// @immutable
// class ChatModel{
//   const ChatModel({
//     required this.chat,
//     required this.newChat,
//     required this.id,
//     required this.userName,
//     required this.friendName,
//     required this.date,
//     required this.dateYear,
//     required this.dateMonth,
//     required this.dateDay,
//     required this.dateHour,
//     required this.dateMinute,
//   });
//
//   ChatModel.fromJson(Map<String, Object?> json)
//   : this(
//     chat: json['chat']! as String,
//     newChat: json['newChat']! as String,
//     id: json['id']! as String,
//     userName: json['userName']! as String,
//     friendName: json['friendName']! as String,
//     date: json['date']! as int,
//     dateYear: json['dateYear']! as int,
//     dateMonth: json['dateMonth']! as int,
//     dateDay: json['dateDay']! as int,
//     dateHour: json['dateHour']! as int,
//     dateMinute: json['dateMinute']! as int,
//   );
//
//   final String chat;
//   final String newChat;
//   final String id;
//   final String userName;
//   final String friendName;
//   final int date;
//   final int dateYear;
//   final int dateMonth;
//   final int dateDay;
//   final int dateHour;
//   final int dateMinute;
//
//   Map<String, Object?> toJson() {
//     return {
//       'chat': chat,
//       'newChat': newChat,
//       'id': id,
//       'userName': userName,
//       'friendName': friendName,
//       'date': date,
//       'dateYear': dateYear,
//       'dateMonth': dateMonth,
//       'dateDay': dateDay,
//       'dateHour': dateHour,
//       'dateMinute': dateMinute,
//     };
//   }
// }

final searchProvider = StateProvider<String>((ref) => '');
final toggleSearchWordProvider = StateProvider<bool>((ref) => false);

final imageUrlProvider = StateProvider<String>((ref) => '');

final userNameProvider = StateProvider<String>((ref) => '');

final newChatProvider = StateProvider<List<String>>((ref) => []);
final newChatListProvider = StateProvider<Map<String, dynamic>>((ref) => {});
final newChatCounterProvider = StateProvider<int>((ref) => 0);
final oldChatProvider = StateProvider<List<String>>((ref) => []);
final oldChatListProvider = StateProvider<Map<String, dynamic>>((ref) => {});
final recentMonthProvider = StateProvider<int>((ref) => 0);
final recentDayProvider = StateProvider<int>((ref) => 0);
