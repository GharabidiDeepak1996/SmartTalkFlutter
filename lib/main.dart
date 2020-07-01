
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smarttalkflutterdemo/home.dart';
import 'package:smarttalkflutterdemo/provider.dart';
import 'package:smarttalkflutterdemo/registration_form.dart';

import 'get_start.dart';

void main()  => runApp (
    MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Demo',
      theme: ThemeData(
          primaryColor: Colors.green,
          accentColor: Colors.greenAccent
      ),
      home: MainScreen()
    )
);

class MainScreen extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
  return _MainScreen();
  }

}
class _MainScreen extends State<MainScreen>{
  bool alreadyVisited;

  @override
  void initState() {
    super.initState();
   _getVisitingFlag();
  }
  @override
  Widget build(BuildContext context) {
    return (alreadyVisited==true)? GetStartPage():HomePage();
  }
  //SharedPrefe get
  _getVisitingFlag() async{
    SharedPreferences preferences=await SharedPreferences.getInstance();
    setState(() {
      this.alreadyVisited=preferences.getBool('alreadyVisited') ?? true;
    });
  //  return alreadyVisited;
  }
}