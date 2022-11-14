import 'dart:convert';
import 'package:flutter/material.dart';
import 'new_todo.dart';
import 'todo.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'dart:collection';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_calendar_carousel/classes/event.dart';
import 'package:flutter_calendar_carousel/flutter_calendar_carousel.dart';
import 'package:intl/intl.dart';

void main() => runApp(Main());

class Main extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Home(),
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
    );
  }
}

class Home extends StatefulWidget {
  @override
  HomeState createState() => HomeState();
}

class HomeState extends State<Home> with SingleTickerProviderStateMixin{
  var list = [];
  var sharedPreferences;
  TextEditingController titleController = new TextEditingController();
  final StreamController<String> _stateControllerdropdown =
  StreamController.broadcast();
  final StreamController<int> _stateControllerTabBar =
  StreamController.broadcast();
  StreamController<String> _fromDateController = StreamController.broadcast();
  String fromDateVar = "DD MMM YYYY";
  int selectedValue = 0;
  Map<int, Widget> widgetTab = {
    0: Container(margin: EdgeInsets.symmetric(horizontal: 10),height: 33, child: Center(child: Text('Today'))),
    1: Container(margin: EdgeInsets.symmetric(horizontal: 10),height: 33, child: Center(child: Text('Tomorrow'))),
    2: Container(margin: EdgeInsets.symmetric(horizontal: 10),height: 33, child: Center(child: Text('Upcoming'))),
  };

  @override
  void initState() {
    loadSharedPreferencesAndData();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _stateControllerTabBar.close();
    _stateControllerTabBar.close();
    _stateControllerdropdown.close();
  }

  void loadSharedPreferencesAndData() async {
    sharedPreferences = await SharedPreferences.getInstance();
    loadData();
  }

  List designlists(){
    List sublist = [];
    if (list.length != 0){
      if(selectedValue == 0){
        return  sublist = list.where((x) => datediff(x.date) == 0).toList();
      }
      else if(selectedValue == 1){
        return sublist = list.where((x) => datediff(x.date) == 1).toList();
      }
      else{
        return sublist = list.where((x) => datediff(x.date)  >  1).toList();
      }
      }
    else{
      return sublist;
    }
    }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "ToDo's",
        ),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () => goToAddToDo(),
      ),
      body: _design()
    );
  }

  Widget emptyList(){
    return Center(
    child:  Text("No ToDo Found")
    );
  }

  Widget _design(){
    return Column(
      children: [
        searchBox(),
        tabBar(),
        StreamBuilder<int>(
        stream: _stateControllerTabBar.stream,
        initialData: 0,
        builder: (context, snapshot) {
            return Expanded(
            child: list.isEmpty ?  emptyList() : buildListView(),
            );
    })

      ],
    );
  }
  Widget buildListView() {
    var mainList = [];
    mainList = designlists();
   return StreamBuilder<String>(
        stream: _stateControllerdropdown.stream,
        initialData: "",
        builder: (context, snapshot) {
          return ListView.builder(
            itemCount: mainList.length,
            itemBuilder: (BuildContext context,int index){
              if (mainList.length == 0) {
                return emptyList();
              }
              else if (titleController.text == ""){
                return buildListTile(mainList[index]);
              }
              else{
                if (mainList[index].title.toLowerCase()
                    .contains(titleController.text.toLowerCase())) {
                  return buildListTile(mainList[index]);
                }
                else {
                  return Container();
                }
              }
              //}
            },
          );
        }
    );
  }

  Widget buildListTile(Todo item) {
    return Container(
     margin: EdgeInsets.only(bottom: 10),
      child: ListTile(
        onTap: () => goToEditToDo(item),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
        tileColor: Colors.white,
        title: Text(
          item.title + "\n" + item.date,
          style: TextStyle(
            fontSize: 16,
            color: Colors.black,
          ),
        ),
        trailing: Container(
          padding: EdgeInsets.all(0),
          margin: EdgeInsets.symmetric(vertical: 12),
          height: 35,
          width: 35,
            decoration: BoxDecoration(
            color: Colors.red,
            borderRadius: BorderRadius.circular(10),
          ),
          child: IconButton(
            color: Colors.white,
            iconSize: 18,
            icon: Icon(Icons.delete),
            onPressed: () {
              removeItem(item);
            },
          ),
        ),
      ),
    );
  }

  void goToAddToDo(){
    Navigator.of(context).push(MaterialPageRoute(builder: (context){
      return NewTodoView();
    })).then((obj){
      if(obj != null) {
        addItem(Todo(title: obj.title,date: obj.date));
        setState(() {});
      }
    });
  }

  void addItem(Todo item){
    list.insert(0, item);
    saveData();
  }


  void goToEditToDo(item){
    Navigator.of(context).push(MaterialPageRoute(builder: (context){
      return NewTodoView(item: item);
    })).then((obj){
      if(obj != null) {
        editItem(item, obj);
        setState(() {});
      }
    });
  }

  void editItem(Todo item ,Todo obj){
    item.title = obj.title;
    item.date = obj.date;
    saveData();
  }

  void removeItem(Todo item){
    list.remove(item);
    saveData();
    setState(() {});
  }

  void loadData() {
    List<String> listString = sharedPreferences.getStringList('list');
    if(listString != null){
      list = listString.map(
        (item) => Todo.fromMap(json.decode(item))
      ).toList();
      setState((){});
    }
  }

  void saveData(){
    List<String> stringList = list.map(
      (item) => json.encode(item.toMap()
    )).toList();
    sharedPreferences.setStringList('list', stringList);
  }

  Widget tabBar(){
    return StreamBuilder<int>(
        stream: _stateControllerTabBar.stream,
        initialData: 0,
        builder: (context, snapshot) {
          return CupertinoSegmentedControl(
            padding: EdgeInsets.only(bottom: 20,right: 20,left: 20),
            unselectedColor: Colors.white,
            selectedColor: Colors.green,
            borderColor: Colors.green,
            children: widgetTab,
            onValueChanged: (int i) async {
              selectedValue = i;
              _stateControllerTabBar.add(selectedValue);
            },
            groupValue: selectedValue,
          );
        });
  }

  Widget searchBox() {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 20,horizontal: 10),
      padding: EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: TextField(
        controller: titleController,
        onChanged: (value) => _runFilter(value),
        decoration: InputDecoration(
          contentPadding: EdgeInsets.all(0),
          prefixIcon: Icon(
            Icons.search,
            color: Colors.black,
            size: 20,
          ),
          prefixIconConstraints: BoxConstraints(
            maxHeight: 20,
            minWidth: 25,
          ),
          border: InputBorder.none,
          hintText: "Search ToDo's",
          hintStyle: TextStyle(color: Colors.grey),
        ),
      ),
    );
  }


  datediff(String date){
    var difference;
    DateFormat readFormat = new DateFormat('dd MMM yyyy');
    DateFormat writeFormat = new DateFormat('yyyy-MM-dd');
    String finalDate;
    var fromDateDT = readFormat.parse(date);
    finalDate = writeFormat.format(fromDateDT);
    final date1 = DateTime(int.parse(finalDate.split("-")[0]), int.parse(finalDate.split("-")[1]), int.parse(finalDate.split("-")[2]));
    final now = DateTime.now();
    final date2 = DateTime(now.year, now.month,  now.day);
    return difference = date1.difference(date2).inDays;

  }

  void _runFilter(String value) {
    _stateControllerdropdown.add(value);
  }

}
