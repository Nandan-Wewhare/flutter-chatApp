import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class ChatRoom extends StatefulWidget {
  final String email;
  ChatRoom(this.email);

  @override
  _ChatRoomState createState() => _ChatRoomState();
}

class _ChatRoomState extends State<ChatRoom> {
  final _msgController = TextEditingController();
  var uuid = Uuid();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.email),
      ),
      body: Container(
        child: Stack(
          children: [
            StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection(
                      "users/${FirebaseAuth.instance.currentUser.email}/chats/${widget.email}/messages")
                  .orderBy("time")
                  .snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasData) {
                  return ListView.builder(
                    itemBuilder: (context, index) {
                      return MessageTile(
                          message: snapshot.data.docs[index].data()["content"],
                          sendByMe:
                              snapshot.data.docs[index].data()["sender"] ==
                                      FirebaseAuth.instance.currentUser.email
                                  ? true
                                  : false);
                    },
                    itemCount: snapshot.data.docs.length,
                  );
                }
                return Center();
              },
            ),
            Container(
              alignment: Alignment.bottomCenter,
              width: MediaQuery.of(context).size.width,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                color: Color(0x54FFFFFF),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _msgController,
                        decoration: InputDecoration(
                            filled: true,
                            fillColor: Color(0xffececec),
                            hintText: "Message ...",
                            hintStyle: TextStyle(
                              fontSize: 16,
                            ),
                            border: InputBorder.none),
                      ),
                    ),
                    SizedBox(
                      width: 16,
                    ),
                    GestureDetector(
                      onTap: () {
                        if (_msgController.text.isNotEmpty) {
                          FirebaseFirestore.instance
                              .collection(
                                  "users/${FirebaseAuth.instance.currentUser.email}/chats/${widget.email}/messages")
                              .doc(uuid.v1())
                              .set({
                            "content": _msgController.text,
                            "sender": FirebaseAuth.instance.currentUser.email,
                            "reciever": widget.email,
                            "time": Timestamp.now()
                          });
                          FirebaseFirestore.instance
                              .collection(
                                  "users/${widget.email}/chats/${FirebaseAuth.instance.currentUser.email}/messages")
                              .doc(uuid.v1())
                              .set({
                            "content": _msgController.text,
                            "sender": FirebaseAuth.instance.currentUser.email,
                            "reciever": widget.email,
                            "time": Timestamp.now()
                          });
                          setState(() => _msgController.clear());
                        }
                      },
                      child: Container(
                        height: 40,
                        width: 40,
                        decoration: BoxDecoration(
                            gradient: LinearGradient(
                                colors: [
                                  const Color(0x36FFFFFF),
                                  const Color(0x0FFFFFFF)
                                ],
                                begin: FractionalOffset.topLeft,
                                end: FractionalOffset.bottomRight),
                            borderRadius: BorderRadius.circular(40)),
                        padding: EdgeInsets.all(12),
                        child: Icon(
                          Icons.send,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MessageTile extends StatelessWidget {
  final String message;
  final bool sendByMe;

  MessageTile({@required this.message, @required this.sendByMe});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
          top: 8, bottom: 8, left: sendByMe ? 0 : 24, right: sendByMe ? 24 : 0),
      alignment: sendByMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin:
            sendByMe ? EdgeInsets.only(left: 30) : EdgeInsets.only(right: 30),
        padding: EdgeInsets.only(top: 17, bottom: 17, left: 20, right: 20),
        decoration: BoxDecoration(
          color: sendByMe ? Colors.indigo : Colors.black,
          borderRadius: sendByMe
              ? BorderRadius.only(
                  topLeft: Radius.circular(23),
                  topRight: Radius.circular(23),
                  bottomLeft: Radius.circular(23))
              : BorderRadius.only(
                  topLeft: Radius.circular(23),
                  topRight: Radius.circular(23),
                  bottomRight: Radius.circular(23)),
        ),
        child: Text(message,
            textAlign: TextAlign.start,
            style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w300)),
      ),
    );
  }
}
