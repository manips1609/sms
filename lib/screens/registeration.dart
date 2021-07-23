import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:sms/commonbutton.dart';

import 'chartroom.dart';

class RegistrationScreen extends StatefulWidget {
  static const String id = 'RegistrationScreen';
  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _auth = FirebaseAuth.instance;
  String userEmail;
  String userPassword;
  bool showSpinner = false;
  String fcmtoken;
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  AndroidNotificationChannel channel;
  CollectionReference token =
      FirebaseFirestore.instance.collection('usertokens');

  //////////////////////////////////////
  /// get firebase token
  ///////////////////////////////////

  getfcmtoken() async {
    String _token = await FirebaseMessaging.instance.getToken();
    setState(() {
      fcmtoken = _token;
    });
    print("fcmtoken----------------$fcmtoken");
  }

  // //////////////////////////////////////////////////////////
  // firebase push notification subscription
  //////////////////////////////////////////////////////////

  receivepushnotification() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      RemoteNotification notification = message.notification;
      showToast(notification.body);
      print("notification ${notification.body}");
      if (notification != null) {
        flutterLocalNotificationsPlugin.show(
            notification.hashCode,
            notification.title,
            notification.body,
            NotificationDetails(
              android: AndroidNotificationDetails(
                channel.id,
                channel.name,
                channel.description,
                icon: 'launch_background',
              ),
            ));
      }
    });
  }

  // //////////////////////////////////////////////////////////
  // Show toast message
  ////////////////////////////////////////////////////////////

  static void showToast(String message) {
    Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_SHORT,
        timeInSecForIosWeb: 100,
        gravity: ToastGravity.BOTTOM,
        fontSize: 16.0);
  }

  ////////////////////////////////////////////////////////////////////
  /// Add token and email to firebase store
  /////////////////////////////////////////////////////////////////////

  addusertoken() {
    token.add({
      "email": userEmail,
      "token": fcmtoken,
    }).then((value) {
      pagenavigation();
    });
  }

  @override
  void initState() {
    super.initState();
    getfcmtoken();
    receivepushnotification();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 25.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Flexible(
                child: Hero(
                  tag: 'logo',
                  child: Container(
                    height: 200.0,
                    child: Image.asset('images/logo.png'),
                  ),
                ),
              ),
              SizedBox(
                height: 48.0,
              ),
              TextField(
                keyboardType: TextInputType.emailAddress,
                textAlign: TextAlign.center,
                onChanged: (value) {
                  userEmail = value;
                },
                decoration:
                    cTextDecoration.copyWith(hintText: 'Enter your Email'),
              ),
              SizedBox(
                height: 20.0,
              ),
              TextField(
                obscureText: true,
                keyboardType: TextInputType.emailAddress,
                textAlign: TextAlign.center,
                onChanged: (value) {
                  userPassword = value;
                },
                decoration:
                    cTextDecoration.copyWith(hintText: 'Enter your Password'),
              ),
              SizedBox(height: 30.0),
              RoundButton(
                  title: 'Register',
                  colour: Colors.blueAccent,
                  onpressed: () async {
                    print('email $userEmail password $userPassword');
                    try {
                      final newUser =
                          await _auth.createUserWithEmailAndPassword(
                              email: userEmail, password: userPassword);
                      if (newUser != null) {
                        addusertoken();
                      }
                    } catch (e) {
                      print(e);
                    }
                  })
            ],
          ),
        ),
      ),
    );
  }

  pagenavigation() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ChatRoom()),
    );
  }
}
