import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../validator.dart';

class LoginPage extends StatefulWidget {
  LoginPage({Key? key, this.snackMsg}) : super(key: key);

  String? snackMsg;

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  String _email = "";
  String _password = "";

  User? _user;
  bool _emailVerification = false;
  bool _secret = true;

  var visible = const Icon(
    Icons.visibility,
    color: Color(0xff4c5166),
  );
  var visibleOff = const Icon(
    Icons.visibility_off,
    color: Color(0xff4c5166),
  );


  // @override
  // void initState() {
  //   super.initState();
  //   _showSnackBar();
  // }

  // void setStateIfMounted() {
  //   if (mounted) setState(() {});
  // }

  _showSnackBar({String? msg, bool redBg = false}) async {
    msg ??= widget.snackMsg;
    var snackBar = SnackBar(
      content: Text(msg!),
      elevation: 10,
      backgroundColor: (msg.substring(0, 7) == "Network") || redBg ?
        Colors.red.withOpacity(0.85) : Colors.lightBlue.withOpacity(0.85),
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  _showAlert(title, content) async {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: Text(title),
          content: Text(content),
          elevation: 25,
          backgroundColor: Colors.lightBlueAccent.withOpacity(0.85),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _checkUser();
              },
              child: const Text(
                'Done',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        )
    );
  }

  Future<void> _checkUser() async {
    try {
      await FirebaseAuth.instance.signOut();
    } catch (e) {
      print("Error $e");
    }

    try {
      UserCredential userCredential = await FirebaseAuth
          .instance
          .signInWithEmailAndPassword(email: _email, password: _password);
      print("User: $userCredential");

      _user = userCredential.user;
      await _user?.reload();

    } on FirebaseAuthException catch (e) {
      print("Error $e");
      if (e.code == 'user-not-found') {
        print('No user found for that email.');
      } else if (e.code == 'wrong-password') {
        print('Wrong password provided for that user.');
      }
    } catch (e) {
      print("Error $e");
    } finally {
      // Check if user's email is verified
      if (_user != null && !_user!.emailVerified) {
        if (!_emailVerification) {
          await _user!.sendEmailVerification();
          _emailVerification = true;
        } else {
          _showSnackBar(msg: "Email verification needed!", redBg: true);
        }
        // await FirebaseAuth.instance.signOut();
      }
    }
  }

  Future<void> _createUser() async {

    FirebaseApp app = await Firebase.initializeApp(
        name: 'Secondary', options: Firebase.app().options);
    try {
      UserCredential userCredential = await FirebaseAuth.instanceFor(app: app)
          .createUserWithEmailAndPassword(email: _email, password: _password);

      _user = userCredential.user;
      Future.sync(() => userCredential);
      if (_user != null && !_user!.emailVerified) {
        await _user!.sendEmailVerification();

        _emailVerification = true;

        // await FirebaseAuth.instance.signOut();
        _showAlert("Waiting for Email Verification", "Verify your email through the link in your email account.");
      }
    }
    on FirebaseAuthException catch (e) {
      // Do something with exception. This try/catch is here to make sure
      // that even if the user creation fails, app.delete() runs, if is not,
      // next time Firebase.initializeApp() will fail as the previous one was
      // not deleted.
    }
    await app.delete();
    // try {
    //   // UserCredential userCredential = await FirebaseAuth
    //   //     .instance
    //   //     .createUserWithEmailAndPassword(email: _email, password: _password);
    //   // // print("User: $userCredential");
    //   //
    //   // // Check if user's email is verified
    //   // _user = userCredential.user;
    //   print("Yeeees");
    //   // print(FirebaseAuth.instance.currentUser);
    //
    //   if (_user != null && !_user!.emailVerified) {
    //     await _user!.sendEmailVerification();
    //
    //     _emailVerification = true;
    //
    //     // await FirebaseAuth.instance.signOut();
    //     _showAlert("Waiting for Email Verification", "Verify your email through the link in your email account.");
    //   }
    //
    // } on FirebaseAuthException catch (e) {
    //   print("Error $e");
    //   if (e.code == 'weak-password') {
    //     print('The password provided is too weak.');
    //   } else if (e.code == 'email-already-in-use') {
    //     print('The account already exists for that email.');
    //   }
    // } catch (e) {
    //   print("Error $e");
    // }
  }

  Future<void> linkGoogle() async {
    try{
      // Trigger the Google Authentication flow.
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      // Obtain the auth details from the request.
      final GoogleSignInAuthentication googleAuth = await googleUser!
          .authentication;
      // Create a new credential.
      final OAuthCredential googleCredential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      // Sign in to Firebase with the Google [UserCredential].
      final UserCredential userCredential =
      await FirebaseAuth.instance.signInWithCredential(googleCredential);

      final _user = userCredential.user;
      _showSnackBar(msg: "Sign in with Google!");
      print(_user);
    } catch (e) {
      print(e);
      _showSnackBar(msg: "Failed to sign in with Google: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: GestureDetector(
          child: Stack(
            children: [
              Container(
                height: double.infinity,
                width: double.infinity,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0xff65b0bb),
                      Color(0xff5a9ea8),
                      Color(0xff508c95),
                      Color(0xff467b82),
                      Color(0xff3c6970),
                      Color(0xff32585d),
                      Color(0xff28464a),
                    ],
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.only(right: 20, left: 20),
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        const SizedBox(height: 40),
                        Container(
                          width: 130,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                          ),
                          clipBehavior: Clip.hardEdge,
                          child: Image.asset(
                            "assets/images/book_finder_logo.png",
                            fit: BoxFit.fill,
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          "Book Finder",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 40,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 20),
                        buildEmail(),
                        const SizedBox(height: 15),
                        buildPassword(),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            buildEmailVerification(),
                            buildForgetPassword()
                          ],
                        ),
                        const SizedBox(height: 5),
                        buildLoginButton(),
                        buildSignupButton(),
                        const SizedBox(height: 20),
                        buildGoogle(),
                        // Row(
                        //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        //   children: [
                        //     buildFacebook(),
                        //     buildGoogle(),
                        //     buildTwitter()
                        //   ],
                        // ),
                        // const SizedBox(height: 20),
                        // Text("Book Finder",style: TextStyle(color: Colors.white,fontSize: 10))
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    // return MaterialApp(
    //   home: Scaffold(
    //     body: Padding(
    //       padding: const EdgeInsets.all(16.0),
    //       child: Column(
    //         mainAxisAlignment: MainAxisAlignment.center,
    //         children: [
    //           TextField(
    //             decoration: const InputDecoration(
    //                 hintText: "Email"
    //             ),
    //             onChanged: (value) {
    //               _email = value;
    //             },
    //             autocorrect: false,
    //           ),
    //           TextField(
    //             decoration: const InputDecoration(
    //                 hintText: "Password"
    //             ),
    //             onChanged: (value) {
    //               _password = value;
    //             },
    //             autocorrect: false,
    //             enableSuggestions: false,
    //           ),
    //           Row(
    //             mainAxisAlignment: MainAxisAlignment.center,
    //             children: [
    //               MaterialButton(
    //                 onPressed: () {
    //                   if (widget.msgTitle != null) {
    //                     _showAlert();
    //                   } else {
    //                     _checkUser();
    //                     // Navigator.push(
    //                     //   context,
    //                     //   MaterialPageRoute(builder: (context) => BooksScreen()),
    //                     // );
    //                   }
    //                 },
    //                 child: Text("Login"),
    //               ),
    //               MaterialButton(
    //                 onPressed: () {
    //                   if (widget.msgTitle != null) {
    //                     _showAlert();
    //                   } else {
    //                     _createUser();
    //                   }
    //                 },
    //                 child: Text("Create New Account"),
    //               ),
    //             ],
    //           ),
    //         ],
    //       ),
    //     ),
    //   ),
    // );
  }

  Widget buildEmail() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Email",
          style: TextStyle(
            color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10,),
        Container(
          height: 60,
          alignment: Alignment.centerLeft,
          decoration: BoxDecoration(
            color: const Color(0xffebefff),
            borderRadius: BorderRadius.circular(10),
            boxShadow: const [BoxShadow(
              color: Colors.black26,
              offset: Offset(0, 2),
            )]
          ),
          child: TextFormField(
            keyboardType: TextInputType.emailAddress,
            style: const TextStyle(color: Colors.black),
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.only(top: 14),
              prefixIcon: Icon(Icons.email,color: Color(0xff4c5166),),
              hintText: 'Email',
              hintStyle: TextStyle(color: Colors.black38)
            ),
            onChanged: (value) {
              _email = value;
            },
            autocorrect: false,
            validator: (value) => Validator.validateEmail(email: value)
          ),
        ),
      ],
    );
  }
  Widget buildPassword() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Password",
          style: TextStyle(
              color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold
          ),
        ),
        const SizedBox(height: 10,),
        Container(
          alignment: Alignment.centerLeft,
          decoration: BoxDecoration(
            color: const Color(0xffebefff),
            borderRadius: BorderRadius.circular(10),
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 6,
                offset: Offset(0, 2)
              )
            ],
          ),
          height: 60,
          child: TextFormField(
            obscureText: _secret,
            style: const TextStyle(color: Colors.black),
            decoration: InputDecoration(
              suffixIcon: IconButton(
                onPressed: () {
                  setState(() {
                    _secret = !_secret;
                  });
                },
                icon: _secret ? visibleOff : visible,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.only(top: 14),
              prefixIcon: const Icon(Icons.vpn_key, color: Color(0xff4c5166)),
              hintText: "Password",
              hintStyle: const TextStyle(color: Colors.black38)
            ),
            onChanged: (value) {
              _password = value;
            },
            autocorrect: false,
            enableSuggestions: false,
            validator: (value) => Validator.validatePassword(password: value)
          ),
        )
      ],
    );
  }
  Widget buildEmailVerification(){
    return Container(
      alignment: Alignment.centerRight,
      child: _emailVerification ? TextButton(
        child: const Text(
          "Sent Email Verification (again)",
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white, decoration: TextDecoration.underline)
        ),
        onPressed: () async {
          try {
            _emailVerification = false;
            _checkUser();

            _showSnackBar(msg: "Email verification sent!");
          } catch (e) {
            print(e);
          }
        },
      ) : Container(),
    );
  }
  Widget buildForgetPassword(){
    return Container(
      alignment: Alignment.centerRight,
      child: TextButton(
        child: const Text(
          "Forget Password",
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white, decoration: TextDecoration.underline)
        ),
        onPressed: (){
          if (_email.isNotEmpty) {
            FirebaseAuth.instance.sendPasswordResetEmail(email: _email);
            _showSnackBar(msg: "Email to reset password is sent!");
          } else {
            _showSnackBar(msg: "Provide an email!", redBg: true);
          }
        },
      ),
    );
  }
  Widget buildLoginButton(){
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: SizedBox(
        width: double.infinity,
        child:  ElevatedButton(
          onPressed: (){
            if (widget.snackMsg != null) {
              _showSnackBar();
            } else {
              _checkUser();
              // Navigator.push(
              //   context,
              //   MaterialPageRoute(builder: (context) => BooksScreen()),
              // );
            }
          },
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all(const Color(0xff3c6970)),
            elevation: MaterialStateProperty.all(10),
            shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
            padding: MaterialStateProperty.all(const EdgeInsets.all(20)),
          ),
          child: const Text(
            "Login",
            style: TextStyle(
              fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold
            ),
          ),
        ),
      ),
    );
  }
  Widget buildSignupButton(){
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: SizedBox(
        width: double.infinity,
        child:  ElevatedButton(
          onPressed: (){
            if (widget.snackMsg != null) {
              _showSnackBar();
            } else {
              _createUser();
            }
          },
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all(const Color(0xff3c6970)),
            elevation: MaterialStateProperty.all(10),
            shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
            padding: MaterialStateProperty.all(const EdgeInsets.all(20)),
          ),
          child: const Text(
            "Sign Up",
            style: TextStyle(
              fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold
            ),
          ),
        ),
      ),
    );
  }
  Widget buildGoogle(){
    return Container(
      height: 60,
      width: 60,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          borderRadius: BorderRadius.circular(20)
      ),
      child: IconButton(
        icon: Image.asset("assets/images/google.png"),
        onPressed: (){
          linkGoogle();
        },
      ),
    );
  }
  // Widget buildFacebook(){
  //   return IconButton(
  //     icon: Container(
  //       height: 50,
  //       width: 50,
  //       decoration: BoxDecoration(borderRadius: BorderRadius.circular(20)),
  //       child: Image.asset("assets/images/facebook.png"),
  //     ),
  //     onPressed: (){
  //
  //     },
  //   );
  // }
  // Widget buildTwitter() {
  //   return IconButton(
  //     icon: Container(
  //       height: 50,
  //       width: 50,
  //       padding: const EdgeInsets.all(20),
  //       decoration: BoxDecoration(
  //         color: Colors.white.withOpacity(0.5),
  //         borderRadius: BorderRadius.circular(20)
  //       ),
  //       child: Image.asset("assets/images/twitter.png"),
  //     ),
  //     onPressed: (){
  //
  //     },
  //   );
  // }
}
