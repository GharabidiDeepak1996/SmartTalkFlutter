import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity/connectivity.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:random_string/random_string.dart';
import 'package:shared_preferences/shared_preferences.dart';

class utils{


  void setSharedPreference(String number,[bool status,String id])async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('mobileNumber', number);
    prefs.setString('userID',id ?? " " );
    prefs.setBool('alreadyVisited', status ?? true);
  }

 Future<String> getBase64code()async{
   SharedPreferences myPrefs = await SharedPreferences.getInstance();
   String mobileNumber =  myPrefs.getString('mobileNumber');
   var base64ID =  base64?.encode(utf8?.encode(mobileNumber ?? " "));
   return base64ID;
  }



  void checkFormeStatus(bool status) async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('alreadyVisited', status);
  }






  /*Future<String> dateStatus(String timeStamp) async{ // error:-A value of type 'String' can't be returned from method 'dateStatus'
    // because it has a return type of 'Future<String> to solve this error to use async


  }*/
}