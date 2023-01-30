import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'models.dart';

class SignUp extends StatefulWidget {
  const SignUp({Key? key}) : super(key: key);

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {

  TextEditingController nameEditingController = TextEditingController();
  TextEditingController emailEditingController = TextEditingController();
  TextEditingController passwordEditingController = TextEditingController();
  bool _toggleObscureText = true;
  bool _alreadySignedUp = false;

  CollectionReference<UserModel> userModelRef = FirebaseFirestore.instance.collection('users')
      .withConverter<UserModel>(
    fromFirestore: (snapshots, _) => UserModel.fromJson(snapshots.data()!),
    toFirestore: (userModel, _) => userModel.toJson(),
  );

  void handleSignUp() async {
    try {

      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailEditingController.text,
        password: passwordEditingController.text,
      );

      User user = userCredential.user!;
      await userModelRef.add(
          UserModel(
            id: user.uid,
            userName: nameEditingController.text,
            email: emailEditingController.text,
          ));

    } on FirebaseAuthException catch(e) {
      if (e.code == 'email-already-in-use') {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('既に使用されているメールアドレスです'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ));
      } else if (e.code == 'weak-password') {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('パスワードは6文字以上に設定してください'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ));
      } else if (e.code == 'invalid-email') {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('メールアドレスの形式が正しくありません'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ));
      }
    }
  }

  void handleSignIn() async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailEditingController.text,
        password: passwordEditingController.text,
      );
    } on FirebaseAuthException catch(e) {
      if (e.code == 'user-not-found') {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('登録されていないメールアドレスです'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ));
      } else if (e.code == 'wrong-password') {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('パスワードが正しくありません'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ));
      } else if (e.code == 'invalid-email') {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('メールアドレスの形式が正しくありません'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: MediaQuery.of(context).size.height/6,),
              const Text('Chat App', style: TextStyle(fontSize: 60, fontWeight: FontWeight.bold),),
              SizedBox(height: MediaQuery.of(context).size.height/6,),
              _alreadySignedUp
                  ? const SizedBox(height: 30,)
                  : TextFormField(
                controller: nameEditingController,
                keyboardType: TextInputType.text,
                cursorColor: Colors.grey,
                decoration: const InputDecoration(
                  labelText: '氏名',
                  labelStyle: TextStyle(color: Colors.grey),
                  border: OutlineInputBorder(),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.red, width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 30,),
              TextFormField(
                controller: emailEditingController,
                keyboardType: TextInputType.emailAddress,
                autovalidateMode: AutovalidateMode.onUserInteraction,  // この記述がないとvalidatorの表示がされない
                validator: (String? value) {
                  return value != null && !value.contains('@') ? '正しいメールアドレスを入力してください' : null;
                },
                cursorColor: Colors.grey,
                decoration: const InputDecoration(
                  labelText: 'メールアドレス',
                  labelStyle: TextStyle(color: Colors.grey),
                  border: OutlineInputBorder(),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.red, width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 30,),
              TextFormField(
                controller: passwordEditingController,
                obscureText: _toggleObscureText,
                keyboardType: TextInputType.text,
                cursorColor: Colors.grey,
                decoration: InputDecoration(
                  labelText: 'パスワード',
                  labelStyle: const TextStyle(color: Colors.grey),
                  border: const OutlineInputBorder(),
                  focusedBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.red, width: 2),
                  ),
                  suffixIcon: IconButton(
                    color: _toggleObscureText ? Colors.black87 : Colors.grey,
                    icon: Icon(_toggleObscureText?Icons.visibility_off:Icons.visibility),
                    onPressed: () {
                      setState(() {
                        _toggleObscureText = !_toggleObscureText;
                      });
                    },
                  ),
                ),
              ),
              SizedBox(height: MediaQuery.of(context).size.height/4.5),
              GestureDetector(
                onTap: () {
                  _alreadySignedUp?handleSignIn():handleSignUp();
                },
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.orange[400],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Text(
                      _alreadySignedUp ? 'ログイン' : '新規アカウントを作成',
                      style: const TextStyle(color: Colors.white, fontSize: 18),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 30,),
              Text(
                _alreadySignedUp ? 'アカウントをお持ちではありませんか？' : '既にアカウントをお持ちですか？',
                style: const TextStyle(color: Colors.black87,),
              ),
              TextButton(
                  onPressed: () {
                    setState(() {
                      _alreadySignedUp = !_alreadySignedUp;
                    });
                  },
                  child: Text(
                    _alreadySignedUp ? 'アカウントの作成はこちら' : 'こちらからログイン',
                    style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
                  )
              ),
              SizedBox(height: MediaQuery.of(context).size.height/6),
            ],
          ),
        ),
      ),
    );
  }
}
