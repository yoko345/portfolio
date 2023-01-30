import 'package:flutter/material.dart';

@immutable
class UserModel {
  const UserModel({
    required this.id,
    required this.userName,
    required this.email,
  });

  UserModel.fromJson(Map<String, Object?> json)
      : this(
    id: json['id']! as String,
    userName: json['userName']! as String,
    email: json['email'] as String,
  );

  final String id;
  final String userName;
  final String email;

  Map<String, Object?> toJson() {
    return {
      'id': id,
      'userName': userName,
      'email': email,
    };
  }

  UserModel copyWith({String? id, String? userName, String? email}) {
    return UserModel(
      id: id?? this.id,
      userName: userName?? this.userName,
      email: email?? this.email,
    );
  }
}

@immutable
class ImageModel{
  const ImageModel({
    required this.id,
    required this.imageUrl,
  });

  ImageModel.fromJson(Map<String, Object?> json)
      : this(
    id: json['id']! as String,
    imageUrl: json['imageUrl'] as String,
  );

  final String id;
  final String imageUrl;

  Map<String, Object?> toJson() {
    return {
      'id': id,
      'imageUrl': imageUrl,
    };
  }

  ImageModel copyWith({String? id, String? imageUrl}) {
    return ImageModel(
      id: id?? this.id,
      imageUrl: imageUrl?? this.imageUrl,
    );
  }
}

@immutable
class FriendCard{
  const FriendCard({
    required this.imageUrl,
    required this.id,
    required this.friendName,
    required this.friendId,
    required this.chat,
    required this.newChatCounter,
    required this.date,
  });

  FriendCard.fromJson(Map<String, Object?> json)
      : this(
    imageUrl: json['imageUrl']! as String,
    id: json['id']! as String,
    friendName: json['friendName']! as String,
    friendId: json['friendId']! as String,
    chat: json['chat']! as String,
    newChatCounter: json['newChatCounter']! as int,
    date: json['date']! as String,
  );

  final String imageUrl;
  final String id;
  final String friendName;
  final String friendId;
  final String chat;
  final int newChatCounter;
  final String date;

  Map<String, Object?> toJson() {
    return {
      'imageUrl': imageUrl,
      'id': id,
      'friendName': friendName,
      'friendId': friendId,
      'chat': chat,
      'newChatCounter': newChatCounter,
      'date': date,
    };
  }

  FriendCard copyWith({String? imageUrl, String? id, String? friendName, String? friendId, String? chat, int? newChatCounter, String? date}) {
    return FriendCard(
      imageUrl: imageUrl?? this.imageUrl,
      id: id?? this.id,
      friendName: friendName?? this.friendName,
      friendId: friendId?? this.friendId,
      chat: chat?? this.chat,
      newChatCounter: newChatCounter?? this.newChatCounter,
      date: date?? this.date,
    );
  }
}

@immutable
class Chat{
  const Chat({
    required this.chat,
    required this.newChat,
    required this.id,
    required this.friendId,
    required this.date,
    required this.dateYear,
    required this.dateMonth,
    required this.dateDay,
    required this.dateHour,
    required this.dateMinute,
  });

  Chat.fromJson(Map<String, Object?> json)
      : this(
    chat: json['chat']! as String,
    newChat: json['newChat']! as String,
    id: json['id']! as String,
    friendId: json['friendId']! as String,
    date: json['date']! as int,
    dateYear: json['dateYear']! as int,
    dateMonth: json['dateMonth']! as int,
    dateDay: json['dateDay']! as int,
    dateHour: json['dateHour']! as int,
    dateMinute: json['dateMinute']! as String,
  );

  final String chat;
  final String newChat;
  final String id;
  final String friendId;
  final int date;
  final int dateYear;
  final int dateMonth;
  final int dateDay;
  final int dateHour;
  final String dateMinute;

  Map<String, Object?> toJson() {
    return {
      'chat': chat,
      'newChat': newChat,
      'id': id,
      'friendId': friendId,
      'date': date,
      'dateYear': dateYear,
      'dateMonth': dateMonth,
      'dateDay': dateDay,
      'dateHour': dateHour,
      'dateMinute': dateMinute,
    };
  }

  Chat copyWith({String? chat, String? newChat, String? id, String? friendId, int? date, int? dateYear, int? dateMonth, int? dateDay, int? dateHour, String? dateMinute, }) {
    return Chat(
      chat: chat?? this.chat,
      newChat: newChat?? this.newChat,
      id: id?? this.id,
      friendId: friendId?? this.friendId,
      date: date?? this.date,
      dateYear: dateYear?? this.dateYear,
      dateMonth: dateMonth?? this.dateMonth,
      dateDay: dateDay?? this.dateDay,
      dateHour: dateHour?? this.dateHour,
      dateMinute: dateMinute?? this.dateMinute,
    );
  }
}
