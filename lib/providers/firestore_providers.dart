import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:portfolio_ver1/firebase_services/firestore_service.dart';
import '../models.dart';

//StreamProviderでfirestoreのデータを状態化します
final chatStreamProvider = StreamProvider<List<Chat>>((ref)=>
    FirestoreService().getChatStream(changeQuery: (query)=>query.orderBy('date'))
);

//asyncValueはそのままだと扱い辛いので、このように別のプロバイダーを経由して、
// 扱いやすい形に変えてから、ウィジェット内で使うこともできます
final chatProvider = Provider<List<Chat>?>((ref){
  final asyncValue = ref.watch(chatStreamProvider);
  return asyncValue.when(
      data: (data)=>data,
      error: (err, stack)=>null,
      loading: ()=>null,
  );
});