import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'otp_screen.dart';

class GetStartPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _GetStartPage();
  }
}

class _GetStartPage extends State<GetStartPage> {
  final TextEditingController _phoneNumberController = TextEditingController();

  bool isValid = false;

  void validate(StateSetter updateState) {
    updateState(() {
      isValid = false;
    });
    if (_phoneNumberController.text.length == 10) {
      updateState(() {
        isValid = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:AppBar(
        title: Text('SmartTalk'),
      ),
      body:     Container(
        padding: EdgeInsets.all(30.0),
        child: Column(
          children: [
            Expanded(child:  SizedBox(
              child: Image.asset('images/launcher_icon.jpg',width: 200,height: 400,),
            ),),

            Align(
              alignment: Alignment.bottomCenter,
              child:  SizedBox(
                width: MediaQuery.of(context).size.width * 0.85,
                child: MaterialButton(
                  shape: StadiumBorder(),
                  color: Theme.of(context).primaryColor,
                  child: Text(
                    'Get Start',
                    style: TextStyle(fontSize: 20.0, color: Colors.white),
                  ),
                  onPressed: () => _showModelSheet(context),
                ),
              ),
            ),
          ],
        ),
      ) ,
    );
  }

  void _showModelSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (BuildContext context, StateSetter state) {
          return new Container(
              padding: EdgeInsets.all(16),
              height: MediaQuery.of(context).size.height * 0.7,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  //1 row
                  Text(
                    'LOGIN',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: Colors.black),
                  ),
                  //2 row
                  Text(
                    'Login/Create Account quickly to manage orders',
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.normal,
                        color: Colors.black),
                  ),
                  //3 row
                  Padding(
                    padding: EdgeInsets.only(bottom: 10.0),
                    child: TextFormField(
                      controller: _phoneNumberController,
                      onChanged: (text) {
                        validate(state);
                      },
                      keyboardType: TextInputType.number,
                     autofocus: true,
                      autovalidate: true,
                     autocorrect: false,
                      maxLength: 10,
                      decoration: InputDecoration(
                        labelText: "10 digit mobile number",
                        prefix: Container(
                          padding: EdgeInsets.all(4.0),
                          child: Text(
                            "+91",
                            style: TextStyle(
                                color: Colors.black, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      validator: (value) {
                        return (value.length < 10 && value != null)? 'Please provide a valid 10 digit phone number': null ;
                      },
                    ),
                  ),
                  //4 row button
                  Container(
                      padding: EdgeInsets.all(16),
                      child: Center(
                        child: SizedBox(
                          width: MediaQuery.of(context).size.width * 0.85,
                          child: RaisedButton(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20.0)),
                            color: isValid ?Theme.of(context).primaryColor :Theme.of(context).primaryColor.withOpacity(0.5),
                            child: Text(isValid ? 'Send OTP' : 'Please enter 10 digit number',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 18.0,
                                fontWeight: FontWeight.bold),),
                            onPressed: () {
                              if(_phoneNumberController.text.length==10) {
                                Navigator.pushAndRemoveUntil( context, MaterialPageRoute(builder: (BuildContext context) =>OTPPage(_phoneNumberController.text)), (e) => false);
                              }
                            },
                            padding: EdgeInsets.all(16.0),
                          ),
                        ),
                      ))
                ],
              )
          );
        },
        );

      },
    );
  }


}
