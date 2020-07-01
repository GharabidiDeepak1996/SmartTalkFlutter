import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:smarttalkflutterdemo/firestore_database.dart';
import 'package:smarttalkflutterdemo/home.dart';
import 'package:smarttalkflutterdemo/pojo/user.dart';
import 'package:smarttalkflutterdemo/utils.dart';

//https://fidev.io/firebase-database-in-flutter/
class RegistrationPage extends StatefulWidget {
  String mobileNumber;

  RegistrationPage(this.mobileNumber);

  @override
  State<StatefulWidget> createState() {
    return _RegistrationPage(mobileNumber);
  }
}

//"https://cdn0.iconfinder.com/data/icons/occupation-002/64/programmer-programming-occupation-avatar-512.png"
class _RegistrationPage extends State<RegistrationPage> {
  _RegistrationPage(this.mobileNumber);

  double _deviceHeight;
  double _deviceWidth;
  String mobileNumber;
  String imageUrl =
      "https://cdn0.iconfinder.com/data/icons/occupation-002/64/programmer-programming-occupation-avatar-512.png"; //default
  bool isUploading = false;

  final TextEditingController _firstName = new TextEditingController();
  final TextEditingController _lastNmae = new TextEditingController();

  final _formKey = GlobalKey<FormState>();
  bool isValid = false;

  @override
  void initState() {
    super.initState();
    utils().checkFormeStatus(true);
  }

  @override
  Widget build(BuildContext context) {
    _deviceHeight = MediaQuery.of(context).size.height;
    _deviceWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Container(
        alignment: Alignment.center,
        child: signupPageUI(),
      ),
    );
  }

  Widget signupPageUI() {
    return Container(
        height: _deviceHeight * 0.75,
        padding: EdgeInsets.symmetric(horizontal: _deviceWidth * 0.10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.start,
          // mainAxisSize: MainAxisSize.max,
          children: [
            _headingWidget(),
            _inputForm(),
            _submitButton() //this is bzco of spaceing
          ],
        ));
  }

  Widget _headingWidget() {
    return Container(
      height: _deviceHeight * 0.15,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Let's get going!",
            style: TextStyle(fontSize: 30, fontWeight: FontWeight.w700),
          ),
          Text(
            "Please enter your details.",
            style: TextStyle(fontSize: 25, fontWeight: FontWeight.w200),
          ),
        ],
      ),
    );
  }

  Widget _inputForm() {
    return Container(
      height: _deviceWidth * 0.65,
      child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _imageSelectorWidget(),
              _firstNameWidget(),
              _lastNameWidget(),
              // _submitButton()
            ],
          )),
    );
  }

  Widget _imageSelectorWidget() {
    return Align(
        alignment: Alignment.center,
        child: GestureDetector(
          onTap: () {
            getImageFromGallery();
          },
          child: isUploading
              ? Container(
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                )
              : Container(
                  height: _deviceHeight * 0.15,
                  width: _deviceWidth * 0.30,
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(500),
                    image: DecorationImage(
                      fit: BoxFit.cover,
                      image: NetworkImage(imageUrl),
                    ),
                  ),
                ),
        ));
  }

  Widget _firstNameWidget() {
    return Container(
      child: TextFormField(
        onChanged: (text) {
          _checkStatusOfTextFiled();
        },
        controller: _firstName,
        decoration: InputDecoration(
          hintText: 'Enter your first name',
          labelText: 'First Name',
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(5.0)),
          errorStyle: TextStyle(
            color: Colors.red,
            fontSize: 15.0,
          ),
        ),
        validator: (String value) {
          return value.isEmpty ? 'Please enter your first name' : null;
        },
      ),
    );
  }

  Widget _lastNameWidget() {
    return TextFormField(
      onChanged: (text) {
        _checkStatusOfTextFiled();
      },
      controller: _lastNmae,
      decoration: InputDecoration(
        hintText: 'Enter your last name',
        labelText: 'Last Name',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(5.0)),
        errorStyle: TextStyle(
          color: Colors.red,
          fontSize: 15.0,
        ),
      ),
      validator: (String value) {
        return value.isEmpty ? 'Please enter your last name' : null;
      },
    );
  }

  Widget _submitButton() {
    return Align(
      alignment: Alignment.center,
      child: RaisedButton(
          child: Text(
            'Register',
            style: TextStyle(fontSize: 20.0, color: Colors.white),
          ),
          color: (isValid)
              ? Theme.of(context).primaryColor
              : Theme.of(context).primaryColor.withOpacity(0.5),
          shape: StadiumBorder(),
          onPressed: () {
            if (_formKey.currentState.validate() &&
                _firstName.text.length > 3 &&
                _lastNmae.text.length > 3) {
              utils().checkFormeStatus(false);
               MyFirestoreDatabase.insertUserInfo(context: context, firstName: _firstName.text, lastName: _lastNmae.text,
                 mobileNumber: mobileNumber, imageURl: imageUrl);
            }
          }),
    );
  }

  //this is required for to check button status
  _checkStatusOfTextFiled() {
    setState(() {
      isValid = false;
      if (_firstName.text.length > 3 && _lastNmae.text.length > 3) {
        isValid = true;
      }
    });
  }

  //image Upload on Firestore
   Future getImageFromGallery() async {
    setState(() {
      isUploading = true;
    });
    // ignore: deprecated_member_use
    File image = await ImagePicker.pickImage(source: ImageSource.gallery);
    utils().getBase64code().then((value) async {
      StorageReference reference =
      FirebaseStorage.instance.ref().child("Profile Images/").child(value);
      StorageUploadTask uploadTask = reference.putFile(image);
      var dowurl = await (await uploadTask.onComplete).ref.getDownloadURL();
      MyFirestoreDatabase.updateProfileImage(dowurl: dowurl);
      setState(() {
        isUploading = false;
        imageUrl = dowurl;
      });
    });
  }
}
