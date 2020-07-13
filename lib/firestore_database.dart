import 'dart:ffi';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity/connectivity.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smarttalkflutterdemo/pojo/user.dart';
import 'package:smarttalkflutterdemo/registration_form.dart';
import 'package:smarttalkflutterdemo/utils.dart';

import 'home.dart';

class MyFirestoreDatabase {
  //it check already user exist or not in side realtime database and  update token firebase userID
  static Future<void> rootFirebaseIsExists(BuildContext context,String number) async {
    // User user=new User();
    final _firebaseMessage = FirebaseMessaging();
    var fireStore = Firestore.instance;
//https://medium.com/firebase-tips-tricks/how-to-use-cloud-firestore-in-flutter-9ea80593ca40
    fireStore.collection('Users').getDocuments().then((value) {
      //    print("----->${value.documents.length}");
      if(value.documents.length!=0){

        value.documents.forEach((element) {
          utils().getBase64code().then((value){

            if (element.documentID.contains(value)   ) {
              print('user is exist--->');
              _firebaseMessage.getToken().then((token) {
                fireStore
                    .collection("Users")
                    .document(value)
                    .updateData({"token": token});

                utils().getBase64code().then((value) {

                  if(value.contains("==")) {
                    var userID = value.replaceAll("==", ' ');
                    SharedPreferences.getInstance().then((value){
                      value.setBool('alreadyVisited', false);
                      value.setString('userID',userID);
                    });
                  }
                });

                Navigator.pushAndRemoveUntil(context, MaterialPageRoute(
                    builder: (BuildContext context) => HomePage()),
                        (e) => false);
              });
            } else {
              print('user not is exist--->');
              //user not exist

              utils().getBase64code().then((value) {
                if(value.contains("==")) {
                  var userID = value.replaceAll("==", ' ');
                  SharedPreferences.getInstance().then((value){
                    value.setString('userID',userID);
                    value.setBool("alreadyVisited", false);
                  });
                }
              });

              Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                      builder: (BuildContext context) => RegistrationPage(number)),
                      (e) => false);
            }
          });
        });
      }else{

        utils().getBase64code().then((value) {
          if(value.contains("==")) {
            var userID = value.replaceAll("==", ' ');
            SharedPreferences.getInstance().then((value){
              value.setString('userID',userID);
              value.setBool('alreadyVisited', false);
            });
          }
        });

        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
                builder: (BuildContext context) => RegistrationPage(number)),
                (e) => false);

      }});
  }

//insert data of new user info
  static insertUserInfo({@required context,@required firstName,@required lastName,@required mobileNumber,@required imageURl}) async {
    final FirebaseMessaging _firebaseMessage = FirebaseMessaging();
    _firebaseMessage.getToken().then((token) {
      //   Timestamp date=Timestamp.fromDate( DateTime.parse('dd-MMM-yyyy hh.mm aa')); //string to timestamp
      final firestoreInstance = Firestore.instance; // create Firestore instance
      utils().getBase64code().then((value) {
        if (value.contains("==")) {
          var userID = value.replaceAll("==", ' ');
          User user = new User(
              id: userID,
              token: token,
              firstName: firstName,
              lastName: lastName,
              mobileNumber: mobileNumber,
              lastSeen: "Default",
              profileImage: imageURl);
          firestoreInstance
              .collection("Users")
              .document(value)
              .setData(user.toJson());
        }
      });
      Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (BuildContext context) => HomePage()), (e) => false);
    });
  }


  //update imageURl
  static void updateProfileImage({String dowurl}){
    utils().getBase64code().then((value) {
      var fireStore = Firestore.instance;
      fireStore.collection("Users")
          .document(value)
          .updateData({"profileImage": dowurl}).then((value){
        Fluttertoast.showToast(msg: "Upload success");
      }).catchError((onError){
        Fluttertoast.showToast(msg: onError.toString());
      });
    });

  }

 static void checkStatusOfWifiAndMobile(){

   Connectivity().onConnectivityChanged.listen((result) {
      if(result==ConnectivityResult.mobile|| result==ConnectivityResult.wifi){
        userStatusCheck('online');
      }else{
        userStatusCheck('ofline');
      }
    });
  }

//To check whether  user online or offline
 static userStatusCheck(String status) async {
    if(status=='online'){
      utils()?.getBase64code()?.then((value) {
        var fireStore = Firestore.instance;
        fireStore.collection("Users")
            .document(value)
            ?.updateData({"lastSeen": 'online'});
      });
    }else{
     // https://firebase.flutter.dev/docs/firestore/usage/
      //var data= DateFormat.yMMd.add_jm().format(DateTime.now()); OR
      //var date=DateTime.now().toUtc();
      var date = DateFormat("dd-MMM-yyyy").add_jm().format(DateTime.now());
      utils().getBase64code().then((value) {
        var fireStore = Firestore.instance;
        fireStore.collection("Users")
            .document(value)
            ?.updateData({"lastSeen": date});
      });
    }
  }

//create charRoom
  static addChatRoom({@required senderID,@required receiverID}) async {
    String chatRoomId = (senderID + "--->" + receiverID);
    List<String> users = [senderID, receiverID];

    Map<String, dynamic> chatRoom = {
      "users": users,
      "chatRoomId": chatRoomId,
    };

    final List<String> fruits = <String>[senderID, receiverID];
    fruits.sort();

    Firestore.instance
        .collection("chatRoom")
        .document(fruits.toString())
        .setData(chatRoom)
        .catchError((e) {
      print(e);
    });
  }

  //add conversation messages
static addMessage({@required String message,@required String senderID,@required String receiverID,@required messageType})async{
    var date = DateFormat("dd-MMM-yyyy").add_jms().format(DateTime.now());
    Map<String, dynamic> chatMessageMap = {
      "sendBy":senderID ,
      "message": message,
      'time': date,
      'type':messageType,
    };

    final List<String> conversationID = <String>[senderID,receiverID];
    conversationID.sort();

    Firestore.instance.collection("chatRoom")
        .document(conversationID.toString())
        .collection("chats")
        .add(chatMessageMap).catchError((e){
      print(e.toString());
    });
   getMessage(receiverID: receiverID);
  }

  //get conversation message
  static Future getMessage({@required receiverID}) async{
    SharedPreferences sharedPreferences=await SharedPreferences.getInstance();
    String senderID=sharedPreferences.getString("userID");

    final List<String> conversationID = <String>[senderID,receiverID];
    conversationID.sort();

    return await Firestore.instance.collection("chatRoom")
        .document(conversationID.toString())
        .collection("chats")
        .orderBy("time",descending: false)
        .snapshots();
  }

  //add recent messages
static Future<void> addRecentMessages({@required receiverImage,@required lastMessage,@required receiverFirstName,@required receiverLastName,@required receiverID,@required unseenMessage,@required senderID}) async {
  var date = DateFormat("hh:mm:ss a").format(DateTime.now());



  Map<String, dynamic> chatMessageMap = {
    "image":receiverImage ,
    "lastMessage": lastMessage,
    "firstName": receiverFirstName,
    "lastName":receiverLastName,
    "receiverID":receiverID,
    "timeStamp":date,
    "unseenMessages":unseenMessage,
  };

  final List<String> conversationID = <String>[senderID,receiverID];
  conversationID.sort();

    Firestore.instance.collection('RecentChats')
    .document(senderID).collection('recent').document(conversationID.toString()).setData(chatMessageMap);
}

//to teack unseenMessages
  static Future unseenMessagesCount({@required receiverID})async{
    /*  Firestore.instance.collection("RecentChats")
        .document(receiverID).get().then((value){
        count= value.data['unseenMessages'];
    });
      return count;*/
    //OR
    SharedPreferences preferences=await SharedPreferences.getInstance();
   String senderID= preferences.getString("userID");

    final List<String> conversationID = <String>[senderID,receiverID];
    conversationID.sort();

    DocumentSnapshot ds = await Firestore.instance.collection('RecentChats').document(senderID).collection('recent')
        .document(conversationID.toString()).get();
    return ds.data["unseenMessages"];
  }

  //unseenMessageupdate by receiver side
  static Future<void> updateunseenMessages({@required receiverID}) async {

    SharedPreferences preferences=await SharedPreferences.getInstance();
    String senderID= preferences.getString("userID");

    final List<String> conversationID = <String>[senderID,receiverID];
    conversationID.sort();

    Firestore.instance.collection('RecentChats').document(receiverID).collection('recent')
        .document(conversationID.toString()).updateData({"unseenMessages": 0});
  }

  //grt all recent messages
static Future getRecentMessages() async {
  SharedPreferences sharedPreferences=await SharedPreferences.getInstance();
  String senderID=sharedPreferences.getString("userID");

   return await Firestore.instance.collection("RecentChats")
      .document(senderID)
      .collection("recent").orderBy("timeStamp",descending: true).snapshots();

   /*.getDocuments().then((value) {
       value.documents.forEach((result) {
      print("--------->${result.data}");
    });
  });*/

}

  static Future<String> getToken() async {
      var senderID = await utils().getBase64code();
      DocumentSnapshot token = await Firestore.instance.collection('Users').document(senderID).get();

      return  token.data["token"];

  }
}
