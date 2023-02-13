import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:io'; //ファイルの入出力ができるようにする
import 'package:image_picker/image_picker.dart';//image_pickerをインポート
import 'package:firebase_storage/firebase_storage.dart';//firebase_storageをインポート
import 'package:portfolio_ver1/firestore_service.dart';
import 'main.dart';
import 'models.dart';

final imageUrlProvider = StateProvider<String>((ref) => '');
final userNameProvider = StateProvider<String>((ref) => '');

class AccountSetting extends ConsumerStatefulWidget {
  const AccountSetting({Key? key, required this.userId}) : super(key: key);
  final String userId;

  @override
  AccountSettingState createState() => AccountSettingState();
}

class AccountSettingState extends ConsumerState<AccountSetting> {

  void getInitialImage() {
    FirestoreService().getImageModelQuery(changeQuery: (query) => query.where('id', isEqualTo: widget.userId)).get().then((QuerySnapshot snapshot) {
      for (var doc in snapshot.docs) {
      ref.read(imageUrlProvider.notifier).state = doc.get('imageUrl');
      }
    });
  }

  void getInitialUserName() {
    FirestoreService().getUserStream(changeQuery: (query) => query.where('id', isEqualTo: widget.userId)).get().then((QuerySnapshot snapshot) {
      for(var doc in snapshot.docs) {
        ref.read(userNameProvider.notifier).state = doc.get('userName');
      }
    });
  }

  void userReName(String userReName, String beforeUserReName) {
    FirestoreService().getUserStream(changeQuery: (query) => query.where('id', isEqualTo: widget.userId)).get().then((QuerySnapshot snapshot) {
      for (var doc in snapshot.docs) {
        FirestoreService().userModelRef().doc(doc.id).update({
          'userName': userReName,
        });
      }
    });

    FirestoreService().getFriendCardQuery(changeQuery: (query) => query.where('friendName', isEqualTo: beforeUserReName)).get().then((QuerySnapshot snapshot) {
      for (var doc in snapshot.docs) {
        FirestoreService().friendCardRef().doc(doc.id).update({
          'friendName': userReName,
        });
      }
    });
  }


  Future<void> uploadImagePicker(File? image) async {
    try {
      Reference reference = FirebaseStorage.instance.ref().child(widget.userId);
      reference.putFile(image!);
      ref.read(imageUrlProvider.notifier).state = await reference.getDownloadURL();

      FirestoreService().setImage(
        ImageModel(
          id: widget.userId,
          imageUrl: ref.read(imageUrlProvider.notifier).state,
        ),
        widget.userId,
      );

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

  @override
  void initState() {
    super.initState();
    getInitialUserName();
    getInitialImage();
  }


  @override
  Widget build(BuildContext context) {


    final imageUrl = ref.watch(imageUrlProvider);
    final userName = ref.watch(userNameProvider);

    String beforeUserReName = userName;
    TextEditingController nameEditingController = TextEditingController(text: beforeUserReName);


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
              onPressed: () {
                ref.read(imageUrlProvider.notifier).state = '';
                FirebaseAuth.instance.signOut();
                Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) {return const MyApp();}));
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
                      child: imageUrl == ''
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
                  userReName(nameEditingController.text, beforeUserReName);
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
                    child: Text('プロフィールを更新', style: TextStyle(color: Colors.white, fontSize: 18),),
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

