// ignore_for_file: prefer_const_constructors, avoid_unnecessary_containers

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'models/item.dart';

void main() {
  runApp(const App());
}

class App extends StatelessWidget {
  const App({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Todo App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.brown),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  // const HomePage({Key? key}) : super(key: key);
  var items = <Item>[];
  HomePage() {
    items = [];
    // items.add(Item(title: 'Bisnaga', done: false));
    // items.add(Item(title: 'Própolis', done: true));
    // items.add(Item(title: 'Sachê', done: false));
  }

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  var newTaskController = TextEditingController();

  void addItem() {
    if (newTaskController.text.isEmpty) {
      // set up the button
      Widget okButton = TextButton(
        child: Text(
          "OK",
          style: TextStyle(color: Colors.black),
        ),
        onPressed: () {
          Navigator.pop(context);
        },
      );
      AlertDialog alert = AlertDialog(
        title: Text("Oops..."),
        content: Text("Please insert a text before adding a new item!"),
        actions: [
          okButton,
        ],
      );
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return alert;
        },
      );
      return;
    }
    setState(() {
      widget.items.add(
        Item(title: newTaskController.text, done: false),
      );
      newTaskController.text = "";
      save();
    });
  }

  void remove(int index) {
    setState(() {
      widget.items.removeAt(index);
      save();
    });
  }

  Future load() async {
    var prefs = await SharedPreferences.getInstance();
    var data = prefs.getString('data');

    if (data != null) {
      Iterable decoded = jsonDecode(data);
      List<Item> result = decoded.map((x) => Item.fromJson(x)).toList();
      setState(() {
        widget.items = result;
      });
    }
  }

  save() async {
    var prefs = await SharedPreferences.getInstance();
    await prefs.setString('data', jsonEncode(widget.items));
  }

  _HomePageState() {
    load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextFormField(
          controller: newTaskController,
          keyboardType: TextInputType.text,
          style: TextStyle(
            color: Colors.white,
          ),
          decoration: InputDecoration(
              labelText: "Nova Tarefa",
              labelStyle: TextStyle(
                color: Colors.white,
              )),
        ),
      ),
      body: ListView.builder(
        itemCount: widget.items.length,
        itemBuilder: (BuildContext context, int index) {
          final item = widget.items[index];
          return Dismissible(
            child: CheckboxListTile(
              activeColor: Colors.brown,
              checkColor: Colors.white,
              title: Text(item.title),
              value: item.done,
              onChanged: (value) {
                setState(() {
                  item.done = value!;
                  save();
                });
              },
            ),
            key: Key(item.title),
            background: Container(
              alignment: Alignment.centerRight,
              padding: EdgeInsets.only(right: 15.0),
              color: Colors.brown.withOpacity(0.8),
              child: Icon(Icons.delete, color: Colors.white),
            ),
            direction: DismissDirection.endToStart,
            onDismissed: (direction) {
              if (direction == DismissDirection.endToStart) {
                remove(index);
              } else {
                ScaffoldMessenger.of(context)
                    .showSnackBar(SnackBar(content: Text("Swipe to right")));
              }
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: addItem,
        child: Icon(
          Icons.add,
          color: Colors.white,
        ),
        backgroundColor: Colors.brown,
      ),
    );
  }
}
