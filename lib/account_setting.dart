import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:io'; //ファイルの入出力ができるようにする
import 'package:path/path.dart';
import 'package:image_picker/image_picker.dart';//image_pickerをインポート
import 'package:http/http.dart' as http;
import 'package:firebase_storage/firebase_storage.dart';//firebase_storageをインポート
import 'package:portfolio_ver1/firestore_service.dart';
import 'main.dart';
import 'models.dart';


final imageUrlProvider = StateProvider<String>((ref) => '');

class AccountSetting extends ConsumerStatefulWidget {
  const AccountSetting({Key? key, required this.userId}) : super(key: key);
  final String userId;

  @override
  AccountSettingState createState() => AccountSettingState();
}

class AccountSettingState extends ConsumerState<AccountSetting> {

  String userName = '';
  String updateImageUrl = '';
  String fileName = '';
  List<dynamic> beforeFileNameList = [];
  TextEditingController nameEditingController = TextEditingController();

  void getInitialImage() {
    FirestoreService().getImageModelQuery(changeQuery: (query) => query.where('id', isEqualTo: widget.userId)).get().then((QuerySnapshot snapshot) async {
      for (var doc in snapshot.docs) {
        final url = Uri.parse(doc.get('imageUrl'));
        final response = await http.get(url);

        if(response.statusCode == 404) {
          ref.read(imageUrlProvider.notifier).state = '';
        } else {
          ref.read(imageUrlProvider.notifier).state = doc.get('imageUrl');
          beforeFileNameList = doc.get('beforeFileNameList');
        }
      }
    });
  }

  void getInitialUserName() {
    FirestoreService().getUserStream(changeQuery: (query) => query.where('id', isEqualTo: widget.userId)).get().then((QuerySnapshot snapshot) {
      for(var doc in snapshot.docs) {
        setState(() {  // setStateも使用できる！！
          userName = doc.get('userName');
          nameEditingController.text = userName;  // builderの中に入れると、再描画されたときに最初の状態に戻るため、うまく動作しなくなる
        });
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



  Future<void> uploadImage() async {
    if(beforeFileNameList.length == 2) {
      final Reference firebaseStorageDeleteRef = FirebaseStorage.instance.ref().child(beforeFileNameList[0]);
      await firebaseStorageDeleteRef.delete();
      beforeFileNameList.removeAt(0);
    }

    final XFile? pickedImage = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedImage == null) return;
    final File imageFile = File(pickedImage.path);
    fileName = basename(imageFile.path);
    beforeFileNameList.add(fileName);
    final Reference firebaseStorageRef = FirebaseStorage.instance.ref().child(fileName);
    await firebaseStorageRef.putFile(imageFile!);
    ref.read(imageUrlProvider.notifier).state = await firebaseStorageRef.getDownloadURL();

    FirestoreService().setImage(
      ImageModel(
        id: widget.userId,
        imageUrl: ref.read(imageUrlProvider.notifier).state,
        beforeFileNameList: beforeFileNameList,
      ),
      widget.userId,
    );
  }


  @override
  void initState() {
    super.initState();
    getInitialImage();
    getInitialUserName();
  }


  @override
  Widget build(BuildContext context) {
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
                FirebaseAuth.instance.signOut();
                Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) {return const MyApp();}));
              },
              icon: const Icon(Icons.logout),
              color: Colors.black87
          ),
        ],
      ),
      body: GestureDetector(
        behavior: HitTestBehavior.opaque, // 画面外のタップを検知する
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          child: Column(
            children: [
              // userAccountImage(),
              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 30),
                  height: 280,
                  child: Consumer(
                    builder: (context, ref, child) {
                      final imageUrl = ref.watch(imageUrlProvider);
                      return Stack(
                        alignment: AlignmentDirectional.bottomEnd,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(100),
                            child: imageUrl == ''
                                ? Container(width: 200, height: 200, color: Colors.grey,)
                                : Image.network(imageUrl, width: 200, height: 200, fit: BoxFit.cover,),
                          ),
                          child!,
                        ],
                      );
                    },
                    child: SizedBox(
                    height: 50,
                    width: 50,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(50),
                        child: Container(
                          color: Colors.orange[400],
                          child: IconButton(
                            onPressed: () {
                              uploadImage();
                            },
                            icon: const Icon(Icons.edit),
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
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
                    userReName(nameEditingController.text, userName);
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
      ),
    );
  }
}


