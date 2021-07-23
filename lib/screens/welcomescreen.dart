import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:sms/screens/chartroom.dart';
import 'package:sms/commonbutton.dart';
import 'package:sms/screens/loginscreen.dart';
import 'package:sms/screens/registeration.dart';

class WelcomeScreen extends StatefulWidget {
  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final _auth = FirebaseAuth.instance;
  User loggedInUser;
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  AndroidNotificationChannel channel;

  ///////////////////////////////////////////////////////////////////////////////////
  /// get current user from firebase auth
  ///////////////////////////////////////////////////////////////////////////////////
  void getCurrentUser() {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        receivepushnotification();
        loggedInUser = user;
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ChatRoom()),
        );
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  void initState() {
    super.initState();
    getCurrentUser();
  }

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

  static void showToast(String message) {
    Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_SHORT,
        timeInSecForIosWeb: 100,
        gravity: ToastGravity.BOTTOM,
        fontSize: 16.0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Row(
              children: <Widget>[
                Hero(
                  tag: 'logo',
                  child: Container(
                      margin: EdgeInsets.only(left: 80.0),
                      child: Image.asset('images/logo.png'),
                      height: 60.0),
                ),
                Text(
                  'Chat',
                  style: TextStyle(fontSize: 40.0, fontWeight: FontWeight.w900),
                ),
              ],
            ),
            SizedBox(height: 48.0),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.0),
              child: RoundButton(
                  title: 'Log In',
                  colour: Colors.lightBlueAccent,
                  onpressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => LoginScreen()),
                    );
                  }),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.0),
              child: RoundButton(
                  title: 'Register',
                  colour: Colors.blueAccent,
                  onpressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => RegistrationScreen()),
                    );
                  }),
            ),
          ],
        ));
  }
}
