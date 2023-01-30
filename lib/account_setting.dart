import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:io'; //ファイルの入出力ができるようにする
import 'package:image_picker/image_picker.dart';//image_pickerをインポート
import 'package:firebase_storage/firebase_storage.dart';//firebase_storageをインポート
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
  bool get mounted => true;

  CollectionReference<UserModel> userModelRef = FirebaseFirestore.instance.collection('users')
      .withConverter<UserModel>(
    fromFirestore: (snapshots, _) => UserModel.fromJson(snapshots.data()!),
    toFirestore: (userModel, _) => userModel.toJson(),
  );

  CollectionReference<FriendCard> friendCardRef = FirebaseFirestore.instance.collection('friendCards')
      .withConverter<FriendCard>(
    fromFirestore: (snapshots, _) => FriendCard.fromJson(snapshots.data()!),
    toFirestore: (friendCard, _) => friendCard.toJson(),
  );

  CollectionReference<ImageModel> imageModelRef = FirebaseFirestore.instance.collection('images')
      .withConverter<ImageModel>(
    fromFirestore: (snapshots, _) => ImageModel.fromJson(snapshots.data()!),
    toFirestore: (imageModel, _) => imageModel.toJson(),
  );


  void userReName(String userReName, String beforeUserReName) async {
    await userModelRef.where('id', isEqualTo: widget.userId).get().then((QuerySnapshot snapshot) {
      snapshot.docs.forEach((doc) {
        userModelRef.doc(doc.id).update({
          'userName': userReName,
        });
      });
    });

    await friendCardRef.where('friendName', isEqualTo: beforeUserReName).get().then((QuerySnapshot snapshot) {
      snapshot.docs.forEach((doc) {
        friendCardRef.doc(doc.id).update({
          'friendName': userReName,
        });
      });
    });
  }

  void getUserName() async {
    await userModelRef.where('id', isEqualTo: widget.userId).get().then((QuerySnapshot snapshot) {
      snapshot.docs.forEach((doc) {
        ref.read(userNameProvider.notifier).state = doc.get('userName');
      });
    });
  }


  @override
  Widget build(BuildContext context) {

    getUserName();
    final userName = ref.watch(userNameProvider);
    final imageUrl = ref.watch(imageUrlProvider);


    TextEditingController nameEditingController = TextEditingController(text: userName);
    String beforeUserReName = userName;


    File? image;

    Future<void> uploadImagePicker(File? image) async {
      try {
        Reference reference = FirebaseStorage.instance.ref().child(widget.userId);
        await reference.putFile(image!);
        ref.read(imageUrlProvider.notifier).state = await reference.getDownloadURL();

        await imageModelRef.where('id', isEqualTo: widget.userId).get().then((QuerySnapshot snapshot) {
          snapshot.docs.forEach((doc) async {
            if(!doc.exists) {
              await imageModelRef.add(
                  ImageModel(
                    id: widget.userId,
                    imageUrl: imageUrl,
                  ));
            } else {
              imageModelRef.doc(doc.id).update({
                imageUrl: imageUrl,
              });
            }
          });
        });
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

