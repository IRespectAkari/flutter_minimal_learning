import 'package:flutter/material.dart';

class AddTaskPage extends StatefulWidget {
  const AddTaskPage({super.key});

  @override
  State<AddTaskPage> createState() => _AddTaskPageState();
}

class _AddTaskPageState extends State<AddTaskPage> {
  final controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(title: const Text('タスクを追加')),
      body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              TextField(
                controller: controller,
                decoration: const InputDecoration( labelText: 'タスク名' ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: (){ Navigator.pop(context, controller.text); },
                child: const Text('追加する'),
              )
            ],
          )
      ),
    );
  }
}
