
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:numeric_keyboard/numeric_keyboard.dart';
import 'package:smarttalkflutterdemo/firestore_database.dart';
import 'package:smarttalkflutterdemo/utils.dart';

class OTPPage extends StatefulWidget {
  var number;

  OTPPage(this.number);

  @override
  State<StatefulWidget> createState() {
    return _OTPPage(number);
  }
}

class _OTPPage extends State<OTPPage> {
  FirebaseAuth _auth = FirebaseAuth.instance;

  bool isValid = false;
  var number;
  var verificationId;

  _OTPPage(this.number);

  var smsOTP = '';

  void _onKeyboardTap(String value) {
    setState(() {
      if (smsOTP.length == 5) {
        this.isValid = true;
      }
      smsOTP = smsOTP + value;
    });
  }

  @override
  void initState() {
    super.initState();
    //otp sender
    verifyPhone();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Verify your phone number'),
      ),
      body: Container(
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            //press ctrl+shift+r
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Text(
                'Enter the 6-digit code that we sent to +91 $number',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: Colors.black),
              ),
              Container(
                margin: EdgeInsets.only(top: 40.0),
                constraints: const BoxConstraints(maxWidth: 500),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    otpNumberWidget(0),
                    otpNumberWidget(1),
                    otpNumberWidget(2),
                    otpNumberWidget(3),
                    otpNumberWidget(4),
                    otpNumberWidget(5),
                  ],
                ),
              ),
              Container(
                margin: EdgeInsets.only(top: 30.0),
                child: MaterialButton(
                  shape: StadiumBorder(),
                  color: isValid
                      ? Theme.of(context).primaryColor
                      : Theme.of(context).primaryColor.withOpacity(0.5),
                  child: Text(
                    isValid ? "Let's Verify" : "Please enter OTP",
                    style: TextStyle(fontSize: 20.0, color: Colors.white),
                  ),
                  onPressed: () async {
                    AuthCredential credential = PhoneAuthProvider.getCredential(
                        verificationId: verificationId, smsCode: smsOTP);
                    await _auth
                        .signInWithCredential(credential)
                        .then((user) async {
                      //manually enter otp
                      Fluttertoast.showToast(
                          msg: 'Authentication successful',
                          toastLength: Toast.LENGTH_SHORT,
                          gravity: ToastGravity.BOTTOM);

                      utils().setSharedPreference(number);
                      MyFirestoreDatabase.rootFirebaseIsExists(context,number);

                    }).catchError((e) {
                      if (smsOTP.length == 0) {
                        Fluttertoast.showToast(
                            msg: 'Please enter the last code received',
                            toastLength: Toast.LENGTH_SHORT,
                            gravity: ToastGravity.BOTTOM);
                      } else {
                        Fluttertoast.showToast(
                            msg:
                                'Wrong code ! Please enter the last code received',
                            toastLength: Toast.LENGTH_SHORT,
                            gravity: ToastGravity.BOTTOM);
                      }
                    });
                  },
                ),
              ),
              NumericKeyboard(
                onKeyboardTap: _onKeyboardTap,
                textColor: Theme.of(context).primaryColor,
                rightIcon: Icon(Icons.backspace,
                    color: Theme.of(context).primaryColor),
                rightButtonFn: () {
                  setState(() {
                    this.isValid = false;
                    smsOTP = smsOTP.substring(0, smsOTP.length - 1);
                  });
                },
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget otpNumberWidget(int position) {
    try {
      return Container(
        height: 40,
        width: 40,
        decoration: BoxDecoration(
            border: Border.all(color: Colors.black, width: 0),
            borderRadius: const BorderRadius.all(Radius.circular(8))),
        child: Center(
            child: Text(
          smsOTP[position],
          style: TextStyle(color: Colors.black),
        )),
      );
    } catch (e) {
      return Container(
        height: 40,
        width: 40,
        decoration: BoxDecoration(
            border: Border.all(color: Colors.black, width: 0),
            borderRadius: const BorderRadius.all(Radius.circular(8))),
      );
    }
  }

  smsOTPSent(String verificationId, [int forceCodeResend]) async {
    Fluttertoast.showToast(
        msg: "We sented Verification code to you mobile number",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM);
  }

  //send otp to particular mobile number
  Future<void> verifyPhone() async {
    await _auth.verifyPhoneNumber(
        phoneNumber: '+91' + number,
        timeout: Duration(seconds: 20),
        codeSent: smsOTPSent,
        codeAutoRetrievalTimeout: (String verId) {
          //Starts the phone number verification process for the given phone number.
          //Either sends an SMS with a 6 digit code to the phone number specified, or sign's the user in and [verificationCompleted] is called.
          this.verificationId = verId;
        },

//-------------------
        verificationCompleted: (AuthCredential credential) async {
          print('it call when auto retrival is done---->${credential}');

          AuthResult result = await _auth.signInWithCredential(credential);
          FirebaseUser user = result.user;

          if (user != null) {
            utils().setSharedPreference(number);
            MyFirestoreDatabase.rootFirebaseIsExists(context,number);
          } else {
            print("Error");
          }
        },
        //internal issues
        verificationFailed: (AuthException exceptio) {
          Fluttertoast.showToast(
              msg: exceptio.message,
              toastLength: Toast.LENGTH_LONG,
              gravity: ToastGravity.BOTTOM);
        });
  }
}
