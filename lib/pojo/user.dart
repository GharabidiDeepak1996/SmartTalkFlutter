import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';

class User{
    String key;
    String token;
    String id;
    String firstName;
    String lastName;
    String mobileNumber;
    String lastSeen;
    String profileImage;

   User({this.id,this.token,this.firstName, this.lastName, this.mobileNumber,this.lastSeen,this.profileImage});

  /* //this is for fetch data
    User.fromSnapshot(DataSnapshot snapshot)
        : key = snapshot.key,
          firstName =snapshot.value["firstName"],
          id=snapshot.value["id"],
          lastName = snapshot.value["lastName"],
          mobileNumber = snapshot.value["mobileNumber"],
          lastSeen=snapshot.value["lastSeen"],
          profileImage=snapshot.value["profileImage"];*/

    //this is for insert
  toJson() {
      return {
        "token":token,
        "id":id,
        "firstName": firstName,
        "lastName": lastName,
        "mobileNumber": mobileNumber,
        "lastSeen":lastSeen,
        "profileImage":profileImage
      };
    }



}



