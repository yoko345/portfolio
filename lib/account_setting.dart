import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:io'; //ファイルの入出力ができるようにする
import 'package:image_picker/image_picker.dart';//image_pickerをインポート
import 'package:firebase_storage/firebase_storage.dart';//firebase_storageをインポート
import 'package:flutter/services.dart';
import 'providers.dart';
import 'main.dart';

class AccountSetting extends ConsumerWidget {
  AccountSetting({Key? key, required this.userId}) : super(key: key);
  final String userId;
  bool get mounted => true;

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    TextEditingController nameEditingController = TextEditingController(text: ref.read(userNameProvider.notifier).state);
    final imageUrl = ref.watch(imageUrlProvider);
    String beforeUpdateUserName = ref.read(userNameProvider.notifier).state;

    File? image;

    Future<void> uploadImagePicker(File? image) async {
      try {
        Reference reference = FirebaseStorage.instance.ref().child(userId);
        await reference.putFile(image!);
        ref.read(imageUrlProvider.notifier).state = await reference.getDownloadURL();
        await FirebaseFirestore.instance.collection('images').doc(userId).set({
          'userName': ref.read(userNameProvider.notifier).state,
          'imageUrl': imageUrl,
        });
        debugPrint(imageUrl);
      } catch (e) {
        debugPrint(e.toString());
      }
    }

    Future<void> openImagePicker() async {
      try {
        final XFile? pickedImage = await ImagePicker().pickImage(source: ImageSource.gallery);
        if (pickedImage == null) return;
        File image = File(pickedImage.path);
        uploadImagePicker(image);
      } catch (e) {
        debugPrint(e.toString());
      }
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back),
          color: Colors.black87
        ),
        title: const Text('アカウント設定', style: TextStyle(fontSize: 25, color: Colors.black87),),
        centerTitle: false,
        backgroundColor: Colors.white54,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              if (!mounted) return; // Navigator.of(context)による「Do not use BuildContexts across async gaps.」という警告を避けるため
              await Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) {return const MyApp();}));
            },
            icon: const Icon(Icons.logout),
            color: Colors.black87
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 30),
                height: 280,
                child: Stack(
                  alignment: AlignmentDirectional.bottomEnd,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(100),
                      child: imageUrl==''
                          ? const Icon(Icons.image)
                          : Image.network(imageUrl, width: 200, height: 200, fit: BoxFit.cover,),
                    ),
                    SizedBox(
                      height: 50,
                      width: 50,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(50),
                        child: Container(
                          color: Colors.orange[400],
                          child: IconButton(
                            onPressed: () {
                              openImagePicker();
                            },
                            icon: const Icon(Icons.edit),
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30,),
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
                  ref.read(userNameProvider.notifier).state = nameEditingController.text;

                  FirebaseFirestore.instance.collection('users').doc(userId).update({
                    'userName': ref.read(userNameProvider.notifier).state,
                  });

                  FirebaseFirestore.instance.collection('chats').where('friendName', isEqualTo: beforeUpdateUserName).get().then((QuerySnapshot snapshot) {
                    snapshot.docs.forEach((doc) {
                      FirebaseFirestore.instance.collection('chats').doc(doc.id).update({
                        'friendName': ref.read(userNameProvider.notifier).state,
                      });
                    });
                  });

                  FirebaseFirestore.instance.collection('chats').where('userName', isEqualTo: beforeUpdateUserName).get().then((QuerySnapshot snapshot) {
                    snapshot.docs.forEach((doc) {
                      FirebaseFirestore.instance.collection('chats').doc(doc.id).update({
                        'userName': ref.read(userNameProvider.notifier).state,
                      });
                    });
                  });

                  Navigator.of(context).pop();
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
                      'プロフィールを更新',
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
