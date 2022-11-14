class Todo {
  String title;
  String date;

  Todo({
    this.title = "",
    this.date = "",
  });

  Todo.fromMap(Map map) :
    this.title = map['title'],
    this.date = map['date'];

  Map toMap(){
    return {
      'title': this.title,
      'date': this.date,
    };
  }
}
