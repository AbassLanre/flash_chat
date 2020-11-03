import 'package:flutter/material.dart';
import 'package:flash_chat/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


final _firestore= FirebaseFirestore.instance;


class ChatScreen extends StatefulWidget {
  static String id ='chat_screen';
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final messageTextController = TextEditingController();
  final _auth =FirebaseAuth.instance;
  User loggedInUser;
  String messageText;



  void getCurrentUSer() {
    try{
      final User user=  _auth.currentUser;
      if(user != null){
        loggedInUser= user;
        print(user.email);
      }
    }catch(e){
      print(e);
    }
  }

  // void getMessages() async {
  //   final messages = await _firestore.collection('messages').get();
  //   for(var unknownMessage in messages.docs){
  //     print(unknownMessage.data());
  //   }
  // }

  // void messagesStream()async{
  //  await for( var messageSnapshot in  _firestore.collection('messages').snapshots()){
  //    for(var unknownMessage in messageSnapshot.docs){
  //       print(unknownMessage.data());
  //    }
  //  }
  // }
  @override
  void initState() {
    super.initState();
    getCurrentUSer();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: null,
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.close),
              onPressed: () {
                // messagesStream();
                _auth.signOut();
                Navigator.pop(context);
              }),
        ],
        title: Text('⚡️Chat'),
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            MessageStreamer(),
            Container(
              decoration: kMessageContainerDecoration,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      controller: messageTextController,
                      onChanged: (value) {
                        messageText=value;
                      },
                      decoration: kMessageTextFieldDecoration,
                    ),
                  ),
                  FlatButton(
                    onPressed: () {
                      messageTextController.clear();
                      _firestore.collection('messages').add({
                        'messageText': messageText,
                        'sender': loggedInUser.email,
                      });
                    },
                    child: Text(
                      'Send',
                      style: kSendButtonTextStyle,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MessageStreamer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return  StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('messages').snapshots(),
        builder: (_, snapshot){
          if(!snapshot.hasData){
            return Center(
              child: CircularProgressIndicator(
                backgroundColor: Colors.lightBlueAccent,
              ),
            );
          }
          final messages= snapshot.data.docs;
          List<MessageBubble> messageWidgets =[];
          for(var message in messages){
            final messageText= message.data()['messageText'];
            final messageSender =message.data()['sender'];

            final messageWidget =MessageBubble(
                messageSender: messageSender,
                messageText: messageText);
            messageWidgets.add(messageWidget);
          }
          return Expanded(
            child: ListView(
              padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 20.0),
              children: messageWidgets,
            ),
          );
        });
  }
}


class MessageBubble extends StatelessWidget {
  MessageBubble({this.messageSender, this.messageText});
  final String messageSender;
  final String messageText;
  @override
  Widget build(BuildContext context) {

    return Padding(
      padding: EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(messageSender,
            style:TextStyle(
              fontSize: 12.0,
              color: Colors.white ,
            ) ,),
          Material(
            borderRadius: BorderRadius.circular(30.0),
            elevation: 6.0,
            color: Colors.lightBlueAccent,
            child: Padding(
              padding: EdgeInsets.all(10.0),
              child: Text(messageText,
                style: TextStyle(fontSize: 19.0,
                    color: Colors.white),),
            ),
          ),

        ],
      ),
    );
  }
}

