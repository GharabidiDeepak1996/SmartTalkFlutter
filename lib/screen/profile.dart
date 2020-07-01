import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smarttalkflutterdemo/firestore_database.dart';
import 'package:smarttalkflutterdemo/get_start.dart';
import 'package:smarttalkflutterdemo/utils.dart';


class Profile extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _ProfileStatus();
  }
}

class _ProfileStatus extends State<Profile> {
  String firstName, lastName, profileImage, mobileNumber;
  double _deviceHeight;
  double _deviceWidth;
  bool isUploading=false;
  final  _firebaseAuth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    fetchPerson();
  }

  @override
  Widget build(BuildContext context) {
    _deviceHeight=MediaQuery.of(context).size.height;
    _deviceWidth=MediaQuery.of(context).size.width;
    return Scaffold(
      body: profileUI(),
    );
  }
  Widget profileUI() {
   if(profileImage!=null){
     return Column(
       mainAxisSize: MainAxisSize.max,
       crossAxisAlignment: CrossAxisAlignment.start,
       mainAxisAlignment: MainAxisAlignment.spaceEvenly,
       children: [
         imageWidget(),
         profileInfo(),
         signoutButton()
       ],
     );
   }else{
     return Container(
       child:Center(
         child: CircularProgressIndicator(),
       ) ,
     );
   }

  }

  Widget imageWidget() {
    return Container(
      child: Center(
        child: GestureDetector(
          onTap: (){
            getImageFromGallery();
          },
          child: isUploading? Container(
            child:Center(
              child: CircularProgressIndicator(),
            ) ,
          ) : CircleAvatar(
            minRadius: 50,
            maxRadius: 80,
            backgroundImage: NetworkImage(profileImage),
          ),
        )
      ),
          decoration:BoxDecoration(
            shape: BoxShape.circle,
            border: new Border.all(
              color: Colors.amber,
              width: 4.0,
            ),
          ) ,
    );
  }

  Widget profileInfo(){
    return Container(
      margin: EdgeInsets.only(bottom: 90.0),
      child: Column(
        children: [
          Center(child:  Text(firstName+" "+lastName,style: TextStyle(fontSize: 30.0,fontWeight: FontWeight.bold),),),
          Center(child: Text(mobileNumber,style: TextStyle(fontSize: 18.0),),)
        ],
      ),
    );
  }

  Widget signoutButton(){
    return Center(
      child: MaterialButton(
          padding:EdgeInsets.symmetric(horizontal: _deviceWidth*0.35),
          splashColor: Colors.red,
          shape: RoundedRectangleBorder(borderRadius:BorderRadius.circular(22.0)),
          elevation: 18.0,
          color:Theme.of(context).primaryColor,
          child: Text('Sign Out', style: new TextStyle(fontSize: 16.0, color: Colors.white)),
          onPressed: (){
            _firebaseAuth.signOut();
            Navigator.push(
                context, MaterialPageRoute(builder: (context) => GetStartPage()));
          }),
    );
  }

  void fetchPerson()  {
    utils().getBase64code().then((value) async{
      var result = await Firestore.instance
          .collection("Users")
          .document(value);
      result.get().then((documentSnapshot) {
        setState(() {
          firstName = documentSnapshot.data['firstName'];
          lastName = documentSnapshot.data['lastName'];
          mobileNumber = documentSnapshot.data['mobileNumber'];
          profileImage = documentSnapshot.data['profileImage'];
        });
      });
    });
  }

  Future getImageFromGallery() async {
    setState(() {
      isUploading=true;
    });
    // ignore: deprecated_member_use
    File image = await ImagePicker.pickImage(source: ImageSource.gallery);
    utils().getBase64code().then((value) async{
      StorageReference reference =FirebaseStorage.instance.ref().child("Profile Images/").child(value);
      StorageUploadTask uploadTask = reference.putFile(image);
      StorageTaskSnapshot storageTaskSnapshot;
uploadTask.onComplete.then((value){
  if(value.error==null){
    storageTaskSnapshot = value;
    storageTaskSnapshot.ref.getDownloadURL().then((downloadUrl){
      setState(() {
        profileImage = downloadUrl;
        isUploading=false;
      });
      MyFirestoreDatabase.updateProfileImage(dowurl: downloadUrl);
    });
  }
},onError: (err) {
  Fluttertoast.showToast(msg: 'This file is not an image');
});
    });
  }

}
