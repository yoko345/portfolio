import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'firestore_service.dart';
import 'models.dart';

final friendCardStreamProvider = StreamProvider((ref) =>
  FirestoreService().getFriendCardStream(changeQuery: (query) => query.orderBy('friendName'))
);

final friendCardProvider = Provider((ref) {
  final asyncValue = ref.watch(friendCardStreamProvider);
  return asyncValue.when(
    data: (data) => data,
    error: (err, stack) => null,
    loading: () => null,
  );
});



final chatStreamProvider = StreamProvider((ref) =>
  FirestoreService().getChatStream(changeQuery: (query) => query.orderBy('date'))
);

final chatProvider = Provider((ref) {
  final asyncValue = ref.watch(chatStreamProvider);
  return asyncValue.when(
    data: (data) => data,
    error: (err, stack) => null,
    loading: () => null,
  );
});
