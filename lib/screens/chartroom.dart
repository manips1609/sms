import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ChatRoom extends StatefulWidget {
  @override
  _ChatRoomState createState() => _ChatRoomState();
}

class _ChatRoomState extends State<ChatRoom> {
  final _auth = FirebaseAuth.instance;
  String _email;
  final Stream<QuerySnapshot> cmessages = FirebaseFirestore.instance
      .collection("chatmessages")
      .orderBy('time')
      .snapshots();
      
  final ScrollController _scrollController = ScrollController();

  TextEditingController _textmessage = TextEditingController();
  @override
  void initState() {
    super.initState();
    getuser();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 100.0,
        centerTitle: false,
        title: Row(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundImage: AssetImage('images/user.jpg'),
            ),
            SizedBox(
              width: 20,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _email,
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 16.0,
                      fontWeight: FontWeight.normal),
                ),
                Text(
                  'online',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 14.0,
                      fontWeight: FontWeight.normal),
                ),
              ],
            ),
          ],
        ),
        elevation: 0,
      ),
      backgroundColor: Colors.blue,
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Column(
          children: [
            Expanded(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                  child: StreamBuilder(
                      stream: cmessages,
                      builder: (BuildContext context,
                          AsyncSnapshot<QuerySnapshot> snapshot) {
                        if (snapshot.hasError) {
                          Text('something went wrong');
                        }
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          Text("Loading");
                        }
                        final data = snapshot.requireData;
                        return ListView.builder(
                            controller: _scrollController,
                            itemCount: data.size,
                            itemBuilder: (context, int index) {
                              bool isMe = data.docs[index]['email'] == _email;
                              return Container(
                                margin: EdgeInsets.only(top: 10),
                                child: Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment: isMe
                                          ? MainAxisAlignment.end
                                          : MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        if (!isMe)
                                          CircleAvatar(
                                            radius: 15,
                                            backgroundImage:
                                                AssetImage('images/user.jpg'),
                                          ),
                                        SizedBox(
                                          width: 10,
                                        ),
                                        Container(
                                          padding: EdgeInsets.all(10),
                                          constraints: BoxConstraints(
                                              maxWidth: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.6),
                                          decoration: BoxDecoration(
                                              color: isMe
                                                  ? Colors.orange[700]
                                                  : Colors.grey[200],
                                              borderRadius: BorderRadius.only(
                                                topLeft: Radius.circular(16),
                                                topRight: Radius.circular(16),
                                                bottomLeft: Radius.circular(
                                                    isMe ? 12 : 0),
                                                bottomRight: Radius.circular(
                                                    isMe ? 0 : 12),
                                              )),
                                          child: Text(
                                            data.docs[index]['message'],
                                            style: TextStyle(
                                                color: isMe
                                                    ? Colors.white
                                                    : Colors.blue),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(top: 5),
                                      child: Row(
                                        mainAxisAlignment: isMe
                                            ? MainAxisAlignment.end
                                            : MainAxisAlignment.start,
                                        children: [
                                          if (!isMe)
                                            SizedBox(
                                              width: 40,
                                            ),
                                          Icon(Icons.done_all,
                                              size: 20, color: Colors.grey),
                                          SizedBox(
                                            width: 8,
                                          ),
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                              );
                            });
                      }),
                ),
              ),
            ),
            buildChatComposer()
          ],
        ),
      ),
    );
  }

  /////////////////////////////////////////////////////////////////
  /// chatcompose text field
  ///////////////////////////////////////////////////////////////

  Container buildChatComposer() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20),
      color: Colors.white,
      height: 100,
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 14),
              height: 60,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(30),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.emoji_emotions_outlined,
                    color: Colors.grey[500],
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Expanded(
                    child: TextField(
                      controller: _textmessage,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Type your message ...',
                        hintStyle: TextStyle(color: Colors.grey[500]),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: addmessage,
                    child: Icon(
                      Icons.send,
                      color: Colors.grey[500],
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  ////////////////////////////////////////////////////////////////////
  /// send message and store to firestore
  /////////////////////////////////////////////////////////////////////

  addmessage() {
    CollectionReference message =
        FirebaseFirestore.instance.collection('chatmessages');
    message.add({
      "email": _email,
      "message": _textmessage.text,
      "time": Timestamp.now()
    }).then((value) {
    _screenscroll();
      _textmessage.clear();
      print("success");
    });
  }

  _screenscroll(){
    _scrollController.animateTo(_scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 300), curve: Curves.fastOutSlowIn);
  }

  ///////////////////////////////////////////////////////////////
  /// get current user mail
  /////////////////////////////////////////////////////////////////

  getuser() {
    try {
      final currentuser = _auth.currentUser;
      setState(() {
        _email = currentuser.email;
      });
      print('currentuser ${currentuser.email}');
    } catch (e) {
      print(e);
    }
  }

    static void showToast(String message) {
    Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_SHORT,
        timeInSecForIosWeb: 100,
        gravity: ToastGravity.BOTTOM,
        fontSize: 16.0);
  }
}
