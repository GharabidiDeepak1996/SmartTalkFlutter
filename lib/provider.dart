import 'package:flutter/cupertino.dart';

class GlobalProvider extends ChangeNotifier{

  var somthingSearch=' ';
  bool isPress=false;


  void searchNotifier(String value){
    this.somthingSearch=value;
    print('-----provider---->${somthingSearch}');
    notifyListeners();
  }

   void isPressSearchButton(bool value){
    this.isPress=value;
    notifyListeners();
  }
}