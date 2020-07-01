import 'dart:async';

import 'package:connectivity/connectivity.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smarttalkflutterdemo/firestore_database.dart';
import 'package:smarttalkflutterdemo/provider.dart';
import 'file:///F:/Github%20Flutter/SmartTalkFlutter/lib/screen/chats.dart';
import 'file:///F:/Github%20Flutter/SmartTalkFlutter/lib/screen/contacts.dart';
import 'package:smarttalkflutterdemo/screen/profile.dart';
import 'package:smarttalkflutterdemo/utils.dart';

class HomePage extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<GlobalProvider>(
      create: (BuildContext context) => GlobalProvider() ,
      child: HomePageWidget(),
    );
  }
}

class HomePageWidget extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    return HomePageState();
  }

}
class HomePageState extends State<HomePageWidget> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);
    MyFirestoreDatabase?.userStatusCheck('online');
    MyFirestoreDatabase.checkStatusOfWifiAndMobile();
  }

  @override
  Widget build(BuildContext context) {
    final searchBar= Provider.of<GlobalProvider>(context);
    return _tabLayout(searchBar.isPress);
  }
  Widget _tabLayout(bool isPress) {
    return DefaultTabController(
      initialIndex: 1,
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: (isPress)
              ? TextField(
            cursorColor: Colors.amber,
            cursorWidth: 5.0,
            maxLines: 1,
            minLines: 1,
            style: TextStyle(color: Colors.white),
            decoration: InputDecoration(
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Colors.blue,
                  ),
                  borderRadius: BorderRadius.circular(10.0),
                ),
                icon: Icon(
                  Icons.arrow_back,
                  color: Colors.white,
                ),
                hintText: 'Search Movies',
                hintStyle: TextStyle(color: Colors.white)),
            onChanged: (string) {
              var timerInfo =
              Provider.of<GlobalProvider>(context,listen: false);
              timerInfo.searchNotifier(string);
            },
          )
              : Text('SmartTalk'),
          actions: [
            (isPress)
                ? IconButton(
              icon: Icon(Icons.cancel),
              onPressed: () {
                var timerInfo =
                Provider.of<GlobalProvider>(context,listen: false);
                timerInfo.isPressSearchButton(false);
              },
            )
                : IconButton(
              icon: Icon(Icons.search),
              onPressed: () {
                var timerInfo =
                            Provider.of<GlobalProvider>(context,listen: false);
                        timerInfo.isPressSearchButton(true);
              },
            )
          ],
          bottom: TabBar(indicatorColor: Colors.red, tabs: [
            Tab(
              text: 'Contact',
            ),
            Tab(
              text: 'Chat',
            ),
            Tab(
              text: 'Profile',
            )
          ]),
        ),
        body: TabBarView(children: [
          ContactPage(),
          ChatPage(),
          Profile(),
        ]),
      ),
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.paused) {
      MyFirestoreDatabase?.userStatusCheck('offline');
    } else if (state == AppLifecycleState.resumed) {
      MyFirestoreDatabase?.userStatusCheck('online');
    } else if (state == AppLifecycleState.detached) {
      MyFirestoreDatabase?.userStatusCheck('offline');
    } else if (state == AppLifecycleState.inactive) {
      MyFirestoreDatabase?.userStatusCheck('offline');
    }
  }

// Be sure to cancel subscription after you are done

}


