import 'package:flutter/material.dart';
import 'todo.dart';
import 'package:flutter_calendar_carousel/classes/event.dart';
import 'package:flutter_calendar_carousel/flutter_calendar_carousel.dart';
import 'package:intl/intl.dart';
import 'dart:async';

class NewTodoView extends StatefulWidget {
   var item;

  NewTodoView({ this.item });

  @override
  _NewTodoViewState createState() => _NewTodoViewState();
}

class _NewTodoViewState extends State<NewTodoView> {
  TextEditingController titleController = new TextEditingController();
  StreamController<String> _fromDateController = StreamController.broadcast();
  String fromDateVar = "DD MMM YYYY";
   Todo obj = new Todo();
  @override
  void initState() {
    super.initState();
    titleController = new TextEditingController(
      text: widget.item != null ? widget.item.title : null
    );
    if (widget.item != null){
      fromDateVar = widget.item.date;
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          title: Text(
            widget.item != null ? 'Edit todo' : 'New todo',
          ),
          centerTitle: true,
        ),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              TextField(
                controller: titleController,
                autofocus: false,
                onSubmitted: (value) => submit(),
                decoration: InputDecoration(labelText: 'Title'),
              ),
              SizedBox(height: 14.0,),
              _fromDate(),
              InkWell(
              onTap: () => submit(),
               child: Container(
                  margin: EdgeInsets.only(left: 7, top: 10, right: 7, bottom: 10),
                  padding: EdgeInsets.symmetric(vertical: 7),
                  decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(16.7)),
                  alignment: Alignment.center,
                  child: Text(
                    widget.item != null  ? "Update" : "Save",
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.white,),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void submit(){
    if (titleController.text == ""){
     return showError(context,"Please Enter Title");
    }
    if (fromDateVar == "DD MMM YYYY" || fromDateVar == ""){
      return  showError(context,"Please select date");
    }
    if(widget.item == null) {
      obj.title = titleController.text;
      obj.date = fromDateVar;
    }
    else{
      widget.item.title = titleController.text;
      widget.item.date = fromDateVar;
    }
    Navigator.of(context).pop(widget.item == null ? obj : widget.item);
  }

  _showMsg(var value) {
    ScaffoldMessenger.of(context).showSnackBar(new SnackBar(
        content: new Text(value)
    ));
  }

  showError(var context, String text, {var height = 50.0, var width = 50.0}) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        content: Container(
          height: height,
          width: width,
          child: Center(
              child: Text(text, style: TextStyle(color: Colors.black, fontSize: 14))),
        ),
      ),
    );
  }


  _showCalendar(StreamController streamController) {
    return showDialog(
      context: context,
        builder: (context) => AlertDialog(
          content: Container(
            child: CalendarCarousel<Event>(
              onDayPressed: (DateTime date, List<Event> events) {
                _setDate(date, streamController);
                Navigator.pop(context);
              },
              weekendTextStyle: TextStyle(
                color: Colors.black,
              ),
              weekdayTextStyle: TextStyle(
                color: Colors.black,
              ),
              thisMonthDayBorderColor: Colors.transparent,
              nextMonthDayBorderColor: Colors.transparent,
              prevMonthDayBorderColor: Colors.transparent,
              todayBorderColor: Colors.green,
              todayButtonColor: Colors.green,
              selectedDayTextStyle: TextStyle(color: Colors.green),
              weekFormat: false,
              dayButtonColor: Colors.transparent,
              height: 300,
              width: 300,
              daysHaveCircularBorder: false,
            ),
          ),
        ),
    );
  }

  _setDate(DateTime date, StreamController streamController) {
    var split = date.toString().split(" ");
    String selectedDate = split[0];

    DateFormat readFormat = new DateFormat('yyyy-MM-dd');
    DateFormat writeFormat = new DateFormat('dd MMM yyyy');
    String finalDate;

    var fromDateDT = readFormat.parse(selectedDate);
    finalDate = writeFormat.format(fromDateDT);
    fromDateVar = finalDate;

   streamController.add(finalDate);
  }

  _fromdateClick() {
    _showCalendar(_fromDateController);
  }

  _fromDate() {
    return InkWell(
      onTap: () => _fromdateClick(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Text("Date", style: TextStyle(color: Colors.black, fontSize: 12)),
          SizedBox(height: 10.7),
          Row(
            children: <Widget>[
              Expanded(
                  child: StreamBuilder<String>(
                      stream: _fromDateController.stream,
                      initialData: fromDateVar,
                      builder: (context, snapshot) {
                        return Text(snapshot.data.toString(), style: TextStyle(color: Colors.black, fontSize: 12));
                      })),
              IconButton(
                color: Colors.red,
                iconSize: 18,
                icon: Icon(Icons.calendar_month,color: Colors.green,),
                onPressed: () {},
              )
            ],
          ),
          SizedBox(height: 8),
          Container(
            height: 0.5,
            color: Colors.black,
          ),
          SizedBox(height: 33.3),
        ],
      ),
    );
  }
}
