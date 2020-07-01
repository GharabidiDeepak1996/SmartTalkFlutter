
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:smarttalkflutterdemo/conversation_page.dart';
import 'package:smarttalkflutterdemo/firestore_database.dart';
import 'package:smarttalkflutterdemo/screen/contacts.dart';

class ChatPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _ChatPage();
  }
}

class _ChatPage extends State<ChatPage> {
  double _deviceHieght;
  double _deviceWidth;
  Stream _chatMessageStream;

  @override
  void initState() {
    super.initState();
    MyFirestoreDatabase.getRecentMessages().then((value) {
      setState(() {
        _chatMessageStream = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    _deviceWidth = MediaQuery
        .of(context)
        .size
        .width;
    _deviceHieght = MediaQuery
        .of(context)
        .size
        .height;

    return Scaffold(
        body: Container(
            height: _deviceHieght,
            width: _deviceWidth,
            child: _recentConversationListView(),
        )
    );;
  }

  Widget _recentConversationListView() {
    return StreamBuilder(
        stream: _chatMessageStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done ||
              snapshot.hasData) {
            return ListView.builder(
                itemCount: snapshot.data.documents.length,
                itemBuilder: (BuildContext _context, int _index) {
                  return _widgetListTile(context,snapshot.data.documents[_index].data['image'],snapshot.data.documents[_index].data['firstName'],
                    snapshot.data.documents[_index].data['lastName'],
                      snapshot.data.documents[_index].data['lastMessage'],snapshot.data.documents[_index].data['timeStamp'],
                      snapshot.data.documents[_index].data['unseenMessages'], snapshot.data.documents[_index].data['receiverID'],); //snapshot.data.documents[_index].data['message'];
                });
          } else {
            return Container(
              child: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }
        });
  }
   _widgetListTile(BuildContext context,String image,String firstName,String lastName,String message,String time,int count,String receiverID){
    return Card(
      child: ListTile(
        onTap: () async {
         var token=await MyFirestoreDatabase.getToken();
         Navigator.of(context).push(MaterialPageRoute(builder:(BuildContext context) => ConversationPage(receiverID: receiverID,receiverToken: token,receiverFirstName:
           firstName,receiverLastName: lastName,receiverimage: image,)));
        },
        leading:CircleAvatar(
          radius: 30,
          backgroundImage: NetworkImage(image),
        ),
        title:Text(firstName+" "+lastName) ,
        subtitle:Text(message) ,
        trailing:_widgetTrailing(time,count)
      ),
    );
  }
  _widgetTrailing(String time,int unseenMessages){
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Text(time),
        Container(
          child:(unseenMessages!=0)?CircleAvatar(
            radius: 15,
            backgroundColor: Theme.of(context).primaryColor,
            child: Text(unseenMessages.toString(),style: TextStyle(color: Colors.white),),
          ): Text(" "),
        )

      ],
    );
  }
}