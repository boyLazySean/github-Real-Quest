import 'package:flutter/material.dart';
import 'package:flutter_sliding_up_panel/flutter_sliding_up_panel.dart';

class Todo {
  bool isDone = false;
  String title;

  Todo(this.title);
}

class MainPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(),
      home: mainPage(),
    );
  }
}

class mainPage extends StatefulWidget {
  @override
  _mainPageState createState() => _mainPageState();
}

class _mainPageState extends State<mainPage> {
  ScrollController scrollController;
  SlidingUpPanelController panelController = SlidingUpPanelController();

  @override
  void initState() {
    scrollController = ScrollController();
    scrollController.addListener(() {
      if (scrollController.offset >=
              scrollController.position.maxScrollExtent &&
          !scrollController.position.outOfRange) {
        panelController.expand();
      } else if (scrollController.offset <=
              scrollController.position.minScrollExtent &&
          !scrollController.position.outOfRange) {
        panelController.anchor();
      } else {}
    });
    super.initState();
  }

  final _items = <Todo>[];

  var _todoController = TextEditingController();
  @override
  void dispose() {
    _todoController.dispose();
    super.dispose();
  }

  void _addTodo(Todo todo) {
    setState(() {
      _items.add(todo);
      _todoController.text = "";
    });
  }

  void _deleteTodo(Todo todo) {
    setState(() {
      _items.remove(todo);
    });
  }

  void _toggleTodo(Todo todo) {
    setState(() {
      todo.isDone = !todo.isDone;
    });
  }

  DateTime _date = DateTime.now();
  TimeOfDay _time = TimeOfDay.now();

  Future<void> showTimeDialog() async {
    final TimeOfDay newTime = await showTimePicker(
      context: context,
      initialTime: _time,
    );
    if (newTime != null) {
      setState(() {
        _time = newTime;
      });
    }
  }

  Future<void> showDateDialog(BuildContext context) async {
    final newDate = await showDatePicker(
        context: context,
        initialDate: _date,
        firstDate: DateTime(2000, 7),
        lastDate: DateTime(3000, 7),
        helpText: 'Select a Date');
    if (newDate != null && newDate != _date) {
      setState(() {
        _date = newDate;
      });
    }
    return Scaffold(
        body: Column(
      children: [
        IconButton(
          icon: Icon(Icons.more_time),
          onPressed: () {},
        ),
        IconButton(
          icon: Icon(Icons.repeat),
          onPressed: () {},
        ),
      ],
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Scaffold(
          bottomNavigationBar: BottomAppBar(
            child: Row(
              children: [
                IconButton(
                  icon: Icon(Icons.menu),
                  onPressed: () {},
                ),
                Spacer(),
                IconButton(
                  icon: Icon(Icons.search),
                  onPressed: () {},
                ),
                IconButton(
                  icon: Icon(Icons.more_vert),
                  onPressed: () {},
                ),
              ],
            ),
            shape: CircularNotchedRectangle(),
          ),
          floatingActionButton: InkWell(
              splashColor: Colors.blue,
              onLongPress: () {
                _routinePopUpScreen(context);
              },
              child: FloatingActionButton(
                child: Icon(Icons.add),
                mini: true,
                onPressed: () {
                  _taskPopUpScreen(context);
                },
              )),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerDocked,
          body: SlidingUpPanelWidget(
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 15.0),
              decoration: ShapeDecoration(
                color: Colors.white,
                shadows: [
                  BoxShadow(
                    blurRadius: 5.0,
                    spreadRadius: 2.0,
                    color: Colors.white,
                  ),
                ],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(10.0),
                    topRight: Radius.circular(10.0),
                  ),
                ),
              ),
              child: Column(
                children: <Widget>[
                  Container(
                    alignment: Alignment.center,
                    child: Row(
                      children: <Widget>[
                        Icon(
                          Icons.menu,
                          size: 30,
                        ),
                        Padding(
                          padding: EdgeInsets.only(left: 8.0),
                        ),
                        Text('Click or Drag'),
                      ],
                      mainAxisAlignment: MainAxisAlignment.center,
                    ),
                  ),
                  Divider(
                    height: 0.5,
                    color: Colors.grey[300],
                  ),
                  Flexible(
                    child: Container(
                      child: ListView.separated(
                        controller: scrollController,
                        physics: ClampingScrollPhysics(),
                        itemBuilder: (BuildContext context, todo) {
                          return ListBody(
                            children: _items
                                .map((todo) => _buildItemWidget(todo))
                                .toList(),
                          );
                        },
                        separatorBuilder: (context, todo) {
                          return Divider(
                            height: 0.5,
                          );
                        },
                        shrinkWrap: true,
                        itemCount: 1,
                      ),
                      color: Colors.white,
                    ),
                  ),
                ],
                mainAxisSize: MainAxisSize.min,
              ),
            ),
            controlHeight: 50.0,
            anchor: 0.4,
            panelController: panelController,
            onTap: () {
              if (SlidingUpPanelStatus.expanded == panelController.status) {
                panelController.collapse();
              } else {
                panelController.expand();
              }
            },
            enableOnTap: true,
          ),
        )
      ],
    );
  }

  Widget _buildItemWidget(Todo todo) {
    return ListTile(
        onTap: () => _toggleTodo(todo),
        title: Text(
          todo.title,
          style: todo.isDone
              ? TextStyle(
                  decoration: TextDecoration.lineThrough,
                  fontStyle: FontStyle.italic,
                )
              : null,
        ),
        trailing: IconButton(
          icon: Icon(Icons.delete_forever),
          onPressed: () {
            _deleteTodo(todo);
          },
        ));
  }

  void _taskPopUpScreen(BuildContext context) {
    showModalBottomSheet(
      isScrollControlled: true,
      elevation: 5,
      context: context,
      builder: (context) => Padding(
        padding: EdgeInsets.all(15),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _todoController,
              keyboardType: TextInputType.text,
              autofocus: true,
              cursorHeight: 25,
              decoration: InputDecoration(
                border: InputBorder.none,
                icon: Icon(Icons.check_circle_outline),
                hintText: 'Add a New Task',
                hintStyle: TextStyle(color: Colors.grey),
              ),
              textAlignVertical: TextAlignVertical.center,
              style: TextStyle(fontSize: 18),
            ),
            Column(
              children: [
                TextFormField(
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    icon: Icon(Icons.notes),
                    hintText: 'Description',
                    hintStyle: TextStyle(fontSize: 15, color: Colors.grey),
                  ),
                  textAlignVertical: TextAlignVertical.center,
                  style: TextStyle(fontSize: 18),
                ),
                Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    IconButton(
                      icon: Icon(Icons.today),
                      onPressed: () {
                        showDateDialog(context);
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.more_time),
                      onPressed: () {
                        showTimeDialog();
                      },
                    ),
                    TextButton(
                      child: Text('Save'),
                      onPressed: () => _addTodo(Todo(_todoController.text)),
                    )
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _routinePopUpScreen(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext bc) {
        return Container(
          child: new Wrap(
            children: <Widget>[
              new ListTile(
                leading: new Icon(Icons.schedule),
                title: new Text('Add a New Routine'),
                onTap: () {
                  _addRoutineScreen(context);
                },
              ),
              new ListTile(
                leading: new Icon(Icons.people_rounded),
                title: new Text('Add a New Team-Goal'),
                onTap: () {
                  _addTeamGoalScreen(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _addRoutineScreen(BuildContext context) {
    showModalBottomSheet(
      isScrollControlled: true,
      elevation: 5,
      context: context,
      builder: (context) => Padding(
        padding: EdgeInsets.all(15),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              keyboardType: TextInputType.text,
              autofocus: true,
              cursorHeight: 25,
              decoration: InputDecoration(
                border: InputBorder.none,
                icon: Icon(Icons.check_circle_outline),
                hintText: 'Add a New Routine',
                hintStyle: TextStyle(color: Colors.grey),
              ),
              textAlignVertical: TextAlignVertical.center,
              style: TextStyle(fontSize: 18),
            ),
            Column(
              children: [
                TextFormField(
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    icon: Icon(Icons.notes),
                    hintText: 'Description',
                    hintStyle: TextStyle(fontSize: 15, color: Colors.grey),
                  ),
                  textAlignVertical: TextAlignVertical.center,
                  style: TextStyle(fontSize: 18),
                ),
                Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    IconButton(
                      icon: Icon(Icons.today),
                      onPressed: () {
                        showDateDialog(context);
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.more_time),
                      onPressed: () {
                        showTimeDialog();
                      },
                    ),
                    TextButton(
                      child: Text('Save'),
                      onPressed: () {},
                    ),
                  ],
                ),
                Divider(),
                Wrap(
                  spacing: 6.0,
                  runSpacing: 6.0,
                  children: [
                    ChoiceChip(
                      label: Text('#Health'),
                      selected: true,
                    ),
                    ChoiceChip(
                      label: Text('#Knowledge'),
                      selected: false,
                    ),
                    ChoiceChip(
                      label: Text('#Wellness'),
                      selected: false,
                    ),
                    ChoiceChip(
                      label: Text('#Motivation'),
                      selected: false,
                    ),
                    ChoiceChip(
                      label: Text('#Morning'),
                      selected: false,
                    ),
                    ChoiceChip(
                      label: Text('#Night'),
                      selected: false,
                    ),
                  ],
                )
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _addTeamGoalScreen(BuildContext context) {
    showModalBottomSheet(
      isScrollControlled: true,
      elevation: 5,
      context: context,
      builder: (context) => Padding(
        padding: EdgeInsets.all(15),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              keyboardType: TextInputType.text,
              autofocus: true,
              cursorHeight: 25,
              decoration: InputDecoration(
                border: InputBorder.none,
                icon: Icon(Icons.check_circle_outline),
                hintText: 'Add a New Team-Goal',
                hintStyle: TextStyle(color: Colors.grey),
              ),
              textAlignVertical: TextAlignVertical.center,
              style: TextStyle(fontSize: 18),
            ),
            Column(
              children: [
                TextFormField(
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    icon: Icon(Icons.notes),
                    hintText: 'Description',
                    hintStyle: TextStyle(fontSize: 15, color: Colors.grey),
                  ),
                  textAlignVertical: TextAlignVertical.center,
                  style: TextStyle(fontSize: 18),
                ),
                Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    IconButton(
                      icon: Icon(Icons.today),
                      onPressed: () {
                        showDateDialog(context);
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.more_time),
                      onPressed: () {
                        showTimeDialog();
                      },
                    ),
                    TextButton(
                      child: Text('Save'),
                      onPressed: () {},
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
