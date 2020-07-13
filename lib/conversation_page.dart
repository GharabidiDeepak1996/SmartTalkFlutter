import 'dart:convert';
import 'dart:io';
import 'dart:ui';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smarttalkflutterdemo/firestore_database.dart';
import 'package:smarttalkflutterdemo/local_notification.dart';
import 'package:smarttalkflutterdemo/utils.dart';


class ConversationPage extends StatefulWidget {
  var receiverID,
      receiverToken,
      receiverimage,
      receiverFirstName,
      receiverLastName,
      lastSeen;

  @override
  State<StatefulWidget> createState() {
    return ConversationPageStatus(receiverID, receiverToken, receiverimage,
        receiverFirstName, receiverLastName, lastSeen);
  }

  ConversationPage(
      {this.receiverID,
      this.receiverToken,
      this.receiverFirstName,
      this.receiverLastName,
      this.receiverimage,
      this.lastSeen});
}

class ConversationPageStatus extends State<ConversationPage> {
  var receiverID,
      receiverToken,
      receiverimage,
      receiverFirstName,
      receiverLastName,
      senderID,
      lastSeen;

  ConversationPageStatus(
      this.receiverID,
      this.receiverToken,
      this.receiverimage,
      this.receiverFirstName,
      this.receiverLastName,
      this.lastSeen);

  TextEditingController _textEditingController = new TextEditingController();

  double _deviceHeight, _deviceWidth;
  var _formKey = GlobalKey<FormState>();
  Stream _chatMessageStream;
   int count=0;
  @override
  void initState() {
    super.initState();
    MyFirestoreDatabase.getMessage(receiverID: receiverID).then((value) =>{
      setState((){
        _chatMessageStream= value;
      })
    });

    SharedPreferences.getInstance().then((value){
    setState(() {
      this.senderID=value.getString("userID");
    });
    });
       //update count
   MyFirestoreDatabase.updateunseenMessages(receiverID: receiverID);
    MyFirestoreDatabase?.unseenMessagesCount(receiverID: receiverID)?.then((value){
      setState(() {
        count=value;
      });
    });

  }
  @override
  Widget build(BuildContext context) {
    _deviceHeight = MediaQuery.of(context).size.height;
    _deviceWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        title: Text(this.widget.receiverFirstName + receiverLastName),
      ),
        body: _conversationPageUI(),
    );
  }

  Widget _conversationPageUI() {
    return Stack(
      overflow: Overflow.visible,
      children: [
        //message list
        _messageListView(),
        Align(
          alignment: Alignment.bottomCenter,
          child: _messagField(),
        )
      ],
    );
  }
  //https://stackoverflow.com/questions/50844519/flutter-streambuilder-vs-futurebuilder
//A Future can't listen to a variable change. It's a one time response. Instead you'll need to use a Stream
  Widget _messageListView() {
    return Container(
        height: _deviceHeight * 0.78,
        width: _deviceWidth,
        child: StreamBuilder(
            stream: _chatMessageStream,
            builder: (context,snapshot){
              if(snapshot.connectionState == ConnectionState.done || snapshot.hasData) {
                return ListView.builder(
                    itemCount: snapshot.data.documents.length,
                    itemBuilder: (BuildContext _context, int _index) {
                      return Padding(
                        padding: EdgeInsets.only(bottom: 10),
                        child: _textMessageBubble(
                            snapshot.data.documents[_index].data['message'],
                          snapshot.data.documents[_index].data['time'],
                          snapshot.data.documents[_index].data['sendBy'],
                          snapshot.data.documents[_index].data['type'],),
                      );
                    });
              }else{
                return Container(
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                );
              }
            }),
    );
  }

   Widget _textMessageBubble(String message,String timeStamp,String senderId,String type) {
    //here will decide which one come to right shift and which one is left
    final DateFormat _time = DateFormat('hh:mm a');  //-->HH for 24 and  hh for 12
    final DateFormat displayFormater = DateFormat('dd-MMM-yyyy HH:mm:ss a'); //why use becoz of 2020-06-11 00:00:00.000 to remove the zeros
    final DateTime displayDate = displayFormater.parse(timeStamp);
    final String time = _time.format(displayDate);


if(senderId==senderID){
  return Container(
      alignment: Alignment.centerRight,
      child: Container(
          padding: EdgeInsets.all(15.0),
          margin: EdgeInsets.symmetric(horizontal: 10.0),
          decoration: BoxDecoration(
            color: Colors.lightGreenAccent,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(23),
              topRight: Radius.circular(23),
              bottomLeft: Radius.circular(23),),),
          constraints:BoxConstraints(minWidth: 0.10,maxWidth:250.0 ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              (type=="Image")? Image.network(message) :Text(message,style:TextStyle(fontSize: 16, fontWeight: FontWeight.w400,fontFamily:"PTSansNarrow", ),),
              Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(time,style:TextStyle(fontSize: 16, fontWeight: FontWeight.w400,fontFamily:"PTSansNarrow", ),),
                ],
              )
            ],
          )
      )
  );
}else{
  return Container(
      alignment: Alignment.centerLeft,
      child: Container(
          padding: EdgeInsets.all(15.0),
          margin: EdgeInsets.symmetric(horizontal: 10.0),
          decoration: BoxDecoration(
            color: Colors.black12,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(23),
              topRight: Radius.circular(23),
              bottomRight: Radius.circular(23),),),
          constraints:BoxConstraints(minWidth: 0.10,maxWidth:250.0 ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              (type=="Image")? Image.network(message) : Text(message,style:TextStyle(fontSize: 16, fontWeight: FontWeight.w400,fontFamily:"PTSansNarrow", ),),
              Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(time,style:TextStyle(fontSize: 16, fontWeight: FontWeight.w400,fontFamily:"PTSansNarrow", ),),
                ],
              )
            ],
          )
      )
  );
}

  }

  Widget _messagField() {
    return Container(
     height: _deviceHeight * 0.08,
      margin: EdgeInsets.symmetric(horizontal: _deviceWidth * 0.01, vertical: _deviceHeight * 0.00),
      decoration: BoxDecoration(
          color: Colors.white),
      child: Form(
          key: _formKey,
          child:Stack(
            children: [
                Positioned(
                  right: 70.0,
                  child:   _messageTextField(),),
              Positioned(
                top: 5.0,
                right: 70.0,
                child:_attachImageButton(), ),
              Positioned(
                left: 308.0,
                child: _sendMessageButton(),),


            ],
          )
      ),
    );
  }

  Widget _messageTextField() {
    return Center(
      child: SizedBox(
        width: _deviceWidth * 0.80,
        child: TextFormField(
          controller:_textEditingController,
          validator: (value) {
            return (value.length == 0) ? "Please enter a message" : null;
          },
          cursorColor: Colors.white,
          decoration: InputDecoration(
              border:OutlineInputBorder(
                borderRadius: BorderRadius.circular(30.0)
              ),
              hintText: "Type a message",
              hintStyle: TextStyle(color: Colors.grey,),),
          autocorrect: false,
        ),
      ),
    );
  }
  Widget _sendMessageButton() {
    return Container(
      child: MaterialButton(
        padding: EdgeInsets.symmetric(vertical: 15.0),
         color: Theme.of(context).primaryColor,
          shape: CircleBorder(),
        child: Icon(
          Icons.send,
          color: Colors.white,
        ),
          onPressed: () {
            if (_formKey.currentState.validate()) {
              MyFirestoreDatabase.addChatRoom(senderID: senderID,receiverID: receiverID);
              MyFirestoreDatabase.addMessage(message: _textEditingController.text, senderID: senderID, receiverID: receiverID,messageType: "Text");

              //recentMessage Converstion
             setState(() {
               count=count+1;
             });
              MyFirestoreDatabase.addRecentMessages(receiverImage: receiverimage, lastMessage: _textEditingController.text, receiverFirstName:receiverFirstName,receiverLastName:receiverLastName,
                  receiverID: receiverID, unseenMessage: count,senderID: senderID);

              sendNotification(_textEditingController.text);

              _formKey.currentState.reset();
              FocusScope.of(context).unfocus(); //clear the text Field

            }
          }),
    );
  }
  Widget _attachImageButton(){
    return Container(
      child: IconButton(icon:Icon(
        Icons.attach_file,
        color: Colors.black,
      ) ,
          onPressed: (){
           getImageFormGallery(context);
          }
      ),
    );
  }

  Future getImageFormGallery(BuildContext context) async{
    //Open gallery
    File image = await ImagePicker.pickImage(source: ImageSource.gallery);
    showModalBottomSheet(
      isScrollControlled: true,
        context: context,
        builder: (BuildContext context){
          return Scaffold(
            body:  Stack( //stack only work on scaffold
              overflow: Overflow.visible,
              children: [
                //image
                Align(
                  alignment: Alignment.center,
                  child: Container(
                    child: Image.file(
                      image ,
                      width: 300,
                      height: 200,
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child:  _textFieldAndButton(image),
                )
              ],
            ),
          );
        });
  }

  Widget _textFieldAndButton(File imageURl) {
   return  Row(
     children: [
       //TextField
     Container(
     width: 320,
     padding: EdgeInsets.all(10.0),
     child: TextField(
       decoration: InputDecoration(
           hintText: 'Add a caption...',
           hintStyle: TextStyle(color: Colors.grey),
           filled: true,
           fillColor: Colors.white70,
           border: OutlineInputBorder(
               borderRadius: BorderRadius.circular(30.0)
           )
       ),
     ),
   ),

       //Button
        Expanded(
            child: Container(
            height: 70.0,
          child: MaterialButton(
            color: Theme.of(context).primaryColor,
            textColor: Colors.white,
            onPressed: () {
                StorageReference reference =FirebaseStorage.instance.ref().child("Conversation Images/").child(senderID);
                StorageUploadTask uploadTask = reference.putFile(imageURl);

                StorageTaskSnapshot storageTaskSnapshot;
                uploadTask.onComplete.then((value){
                  if(value.error==null){
                    storageTaskSnapshot = value;
                    storageTaskSnapshot.ref.getDownloadURL().then((downloadUrl){
                      MyFirestoreDatabase.addChatRoom(senderID: senderID,receiverID: receiverID);
                      MyFirestoreDatabase.addMessage(message: downloadUrl, senderID: senderID, receiverID: receiverID,messageType: "Image");
                    });
                  }
                },onError: (err) {
                  print(err);
                });

              Navigator.of(context).pop(); //close the BottomSheet
            },
            elevation: 2.0,
            child: Icon(
              Icons.send,
              size: 24,
            ),
            shape: CircleBorder(),
          ),
        ))
      ],
   );
  }

  Future<void> sendNotification(String message) async {
    final postUrl = 'https://fcm.googleapis.com/fcm/send';
    final headers = {
      'content-type': 'application/json',
      'Authorization': 'key=AAAA6wRVnuw:APA91bGArvjhEqFgNAQuITGJ7VSMHHgBNia00phQdbn6U8Dv37_OOjDfyocpxQ4pI9hXhwok0-z-9CBVhIPaGvz7DYumzteZlGtYUV7kIlzSmg928bRLVcHG1S-tGFwzJ5xYRa5kNtHB'
    };

    final data = {
      "notification": {"body":message, "title":receiverFirstName+' '+receiverLastName},
      "priority": "high",
      "data": {
        "click_action": "FLUTTER_NOTIFICATION_CLICK",
        "id": "1",
        "status": "done",
        "sound": 'default',
        "screen": "yourTopicName",
      },
      "to": receiverToken};

    final response = await http.post(postUrl,
        body: json.encode(data),
        encoding: Encoding.getByName('utf-8'),
        headers: headers,);

    if (response.statusCode == 200) {
      print('test ok push CFM');
    } else {
      print(' CFM error');
    }
  }
}
