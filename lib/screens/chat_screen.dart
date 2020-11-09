import 'package:flutter/material.dart';
import 'package:flash_chat/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


final _firestore= FirebaseFirestore.instance;
User loggedInUser;


class ChatScreen extends StatefulWidget {
  static String id ='chat_screen';
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final messageTextController = TextEditingController();
  final _auth =FirebaseAuth.instance;
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
        stream: _firestore.collection('messages').orderBy('dateTime', descending: false)
            .snapshots(),
        builder: (_, snapshot){
          if(!snapshot.hasData){
            return Center(
              child: CircularProgressIndicator(
                backgroundColor: Colors.lightBlueAccent,
              ),
            );
          }
          final messages= snapshot.data.docs.reversed;
          List<MessageBubble> messageWidgets =[];
          for(var message in messages){
            final messageText= message.data()['messageText'];
            final messageSender =message.data()['sender'];

            final currentUser=loggedInUser.email;
            // if (currentUser == messageSender){
            //
            // }


            final messageBubble =MessageBubble(
                messageSender: messageSender,
                messageText: messageText,
                // to check the condition if current user is the same as
                // logged in user? do below to return true or false:
                isMe: currentUser == messageSender);
            messageWidgets.add(messageBubble);
          }
          return Expanded(
            child: ListView(
              padding: EdgeInsets.symmetric(horizontal: 10.0,
                  vertical: 20.0),
              children: messageWidgets,
            ),
          );
        });
  }
}


class MessageBubble extends StatelessWidget {
  MessageBubble({this.messageSender, this.messageText, this.isMe});
  final String messageSender;
  final String messageText;
  final bool isMe;

  @override
  Widget build(BuildContext context) {

    return Padding(
      padding: EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment: isMe == true? CrossAxisAlignment.end: CrossAxisAlignment.start,
        children: [
          Text(messageSender,
            style:TextStyle(
              fontSize: 12.0,
              color: Colors.white54 ,
            ) ,),
          Material(
            borderRadius:isMe== true? BorderRadius.only(topLeft: Radius.circular(30.0),
                bottomLeft: Radius.circular(30.0),
            bottomRight: Radius.circular(30.0)) : BorderRadius.only(topRight: Radius.circular(30.0),
                bottomLeft: Radius.circular(30.0),
                bottomRight: Radius.circular(30.0)),
            elevation: 6.0,
            color: isMe == true? Colors.lightBlueAccent : Colors.greenAccent,
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

