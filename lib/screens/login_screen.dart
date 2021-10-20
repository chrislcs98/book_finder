import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:book_finder/screens/books_screen.dart';
import 'package:flutter/rendering.dart';

class LoginScreen extends StatefulWidget {
  LoginScreen({Key? key, this.msgTitle, this.msgContent}) : super(key: key);

  String? msgTitle;
  String? msgContent;

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late String _email, _password;

  void setStateIfMounted() {
    if (mounted) setState(() {});
  }

  _showAlert() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(widget.msgTitle?? ''),
        content: Text(widget.msgContent?? ''),
        elevation: 25,
        backgroundColor: widget.msgTitle! == "Error" ? Colors.red.withOpacity(0.85) :
          Colors.lightBlueAccent.withOpacity(0.85),
        actions: [
          widget.msgTitle == "Waiting for Email Verification" ? TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _checkUser();
            },
            child: const Text('Done'),
          ) : Container(),
        ],
      )
    );

    // setStateIfMounted();
  }

  Future<void> _createUser() async {
    try {
      UserCredential userCredential = await FirebaseAuth
          .instance
          .createUserWithEmailAndPassword(email: _email, password: _password);
      // print("User: $userCredential");

      // Check if user's email is verified
      User? user = FirebaseAuth.instance.currentUser;

      if (user != null && !user.emailVerified) {
        await user.sendEmailVerification();

        widget.msgTitle = "Waiting for Email Verification";
        widget.msgContent = "Verify your email through the link in your email account.";

        await FirebaseAuth.instance.signOut();
        return _showAlert();
      }

    } on FirebaseAuthException catch (e) {
      print("Error $e");
      if (e.code == 'weak-password') {
        print('The password provided is too weak.');
      } else if (e.code == 'email-already-in-use') {
        print('The account already exists for that email.');
      }
    } catch (e) {
      print("Error $e");
    }
  }

  Future<String?> _checkUser() async {
    try {
      UserCredential userCredential = await FirebaseAuth
          .instance
          .signInWithEmailAndPassword(email: _email, password: _password);
      print("User: $userCredential");

      // Check if user's email is verified
      await FirebaseAuth.instance.currentUser?.reload();
      User? user = FirebaseAuth.instance.currentUser;

      if (user != null && !user.emailVerified) {
        // await user.sendEmailVerification();
        await FirebaseAuth.instance.signOut();
      }
    } on FirebaseAuthException catch (e) {
      print("Error $e");
      if (e.code == 'user-not-found') {
        print('No user found for that email.');
      } else if (e.code == 'wrong-password') {
        print('Wrong password provided for that user.');
      }
    } catch (e) {
      print("Error $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(
                decoration: const InputDecoration(
                  hintText: "Email"
                ),
                onChanged: (value) {
                  _email = value;
                },
                autocorrect: false,
              ),
              TextField(
                decoration: const InputDecoration(
                    hintText: "Password"
                ),
                onChanged: (value) {
                  _password = value;
                },
                autocorrect: false,
                enableSuggestions: false,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  MaterialButton(
                    onPressed: () {
                      if (widget.msgTitle != null) {
                        _showAlert();
                      } else {
                        _checkUser();
                        // Navigator.push(
                        //   context,
                        //   MaterialPageRoute(builder: (context) => BooksScreen()),
                        // );
                      }
                    },
                    child: Text("Login"),
                  ),
                  MaterialButton(
                    onPressed: () {
                      if (widget.msgTitle != null) {
                        _showAlert();
                      } else {
                        _createUser();
                      }
                    },
                    child: Text("Create New Account"),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
