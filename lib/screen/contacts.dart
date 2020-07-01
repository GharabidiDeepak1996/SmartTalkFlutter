import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smarttalkflutterdemo/conversation_page.dart';
import 'package:smarttalkflutterdemo/provider.dart';


class ContactPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return ContactPageList();
  }
}

class ContactPageList extends State<ContactPage> {
  final dbRef = Firestore.instance;
  double _deviceHeight;
  double _deviceWidth;
  List _muserInfo = new List();
  List serachList = new List();

  String mobileNumber;

  @override
  void initState() {
    super.initState();
    serachList = _muserInfo;
    dbRef.settings(persistenceEnabled: true); // it will work for offline fetch data .
    SharedPreferences.getInstance().then((value) {
      setState(() {
        mobileNumber = value.getString('mobileNumber');
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    _deviceHeight=MediaQuery.of(context).size.height;
    _deviceWidth=MediaQuery.of(context).size.width;

    final notifyChange = Provider.of<GlobalProvider>(context);
    String wordTying=notifyChange.somthingSearch;
    bool _isPress=notifyChange.isPress;

    if(_isPress){
      setState(() {
        if(wordTying.length<2){
          serachList.clear();
          serachList=_muserInfo;
        }else{
          serachList.clear();
          serachList = _muserInfo
              .where((item) => ((item['firstName'].toLowerCase().contains(notifyChange.somthingSearch)) ||
              (item['mobileNumber'].toLowerCase().contains(notifyChange.somthingSearch)) ||
              (item['lastName'].toLowerCase().contains(notifyChange.somthingSearch)))).toList();
        }
      });
    }
    return ChangeNotifierProvider(
      create: (BuildContext context) =>GlobalProvider(),
      child: StreamBuilder(
        stream: dbRef.collection("Users").snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          _muserInfo.clear();
          if (snapshot.hasData) {
            QuerySnapshot dataValues = snapshot.data;
            /* dataValues.documents.map((element) { //map add into list
             User userTask = User(element.data['firstName'],
                                  element.data['lastName'],
                                  element.data['mobileNumber'],
                                 element.data['lastSeen'],
                                 element.data['profileImage']);
             _muserInfo.add(userTask);
             _muserInfo.removeWhere((element) => element.mobileNumber == mobileNumber);
print('--->${_muserInfo.length}<-----');
           });*/

            dataValues.documents.forEach(( element) { //this is for list without pojo
              _muserInfo.add(element.data);
              _muserInfo.removeWhere((element) => element['mobileNumber'] == mobileNumber);
            });
            return _listUserData(context);
          }
          return Container(
            child: Center(
              child: CircularProgressIndicator(),
            ),
          );
        },
      ),
         );
  }


  Widget _listUserData(BuildContext context) {
    return ListView.builder(
      itemCount: serachList.length,
      itemBuilder: (BuildContext context, int index) {
        return Card(
          color: Colors.white,
          elevation: 3.0,
          child: ListTile(
            onTap: (){
              //receiverID,receiverTOken,ReceiverImage,senderID
              Navigator.of(context).push(MaterialPageRoute(builder:(BuildContext context) => ConversationPage(
                receiverID:serachList[index]['id'],receiverFirstName:serachList[index]['firstName'],receiverLastName:serachList[index]['lastName'] ,
                receiverimage:serachList[index]['profileImage'],receiverToken:serachList[index]['token'],lastSeen:serachList[index]['lastSeen'] ,)
              ));
            },
            leading:  CircleAvatar(
              radius: 30,
              backgroundImage: NetworkImage(serachList[index]['profileImage']),
            ),
            title: Text(
              serachList[index]['firstName'] + ' ' + serachList[index]['lastName'],
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: Colors.black),
            ),
            subtitle: Text(serachList[index]['mobileNumber']),
            trailing: trailingWidget(context,index),
          ),
        );
      },
    );
  }
  Widget trailingWidget(BuildContext context,int index){
    var timeStamp;
    if(_muserInfo[index]['lastSeen']!="online"){
      var today = DateFormat("dd-MM-yyyy").format(DateTime.now());

      final now = DateTime.now();
      var yesterday= new DateTime( now.year, now.month, now.day-1);
      final DateFormat _yesterday = DateFormat('dd-MM-yyyy');
      final  yesterdayFormat = _yesterday.format(yesterday);  //format for DateTime

      var dmyString = _muserInfo[index]['lastSeen'];
      final DateFormat _date = DateFormat('dd-MM-yyyy');
      final DateFormat _time = DateFormat('hh:mm a');  //-->HH for 24 and  hh for 12
      final DateFormat displayFormater = DateFormat('dd-MMM-yyyy HH:mm a'); //why use becoz of 2020-06-11 00:00:00.000 to remove the zeros
      final DateTime displayDate = displayFormater.parse(dmyString);  //parse for string
      final String dateFormat = _date.format(displayDate);
      final String time = _time.format(displayDate);

      if(dateFormat==today){
        timeStamp= time;
      }else if(dateFormat==yesterdayFormat){
        timeStamp= "Yesterday";
      }else{
        timeStamp= dateFormat;
      }
    }
      return ((_muserInfo[index]['lastSeen'])=='online')? Container( //online
      child:Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Text('Active Now'),
          CircleAvatar(radius: 5,
            backgroundColor: Theme.of(context).primaryColor,
          )
        ],
      ) ,
    ) :Container( //offline
      child:Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Text('Last Seen'),
          Text(timeStamp),
        ],
      ) ,
    );
  }

}
