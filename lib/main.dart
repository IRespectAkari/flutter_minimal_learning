import 'package:flutter/material.dart';

void main() {
  runApp(const TodoPage());
}

class TodoPage extends StatefulWidget {
  const TodoPage({super.key});

  @override
  State<TodoPage> createState() => _TodoPageState();
}

class _TodoPageState extends State<TodoPage> {

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('My Todo'),
        ),
        body: ListView(
          children: const [
            ListTile(title: Text('Flutterを勉強する')),
            ListTile(title: Text('ToDoアプリを作る')),
            ListTile(title: Text('大学の課題をやる')),
          ]
        )
      ),
    );
  }
}
