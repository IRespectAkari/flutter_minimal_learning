
import 'package:flutter/material.dart';
import 'package:flutter_minimal_learning/radialAction/radial_action.dart';
import 'package:flutter_minimal_learning/radialAction/radial_action_button.dart';

import 'package:flutter_minimal_learning/todo/add_task_page.dart';
import 'package:flutter_minimal_learning/task/seed_test_tasks.dart';
import 'package:flutter_minimal_learning/task/task.dart';
import 'package:flutter_minimal_learning/todo/tag_search_header.dart';
import 'package:flutter_minimal_learning/todo/todo_list.dart';

class TodoPage extends StatefulWidget {
  final List<Task> tasks;
  final List<String> tags;
  final Future<void> Function(Task task) onTaskAdded;
  final Future<void> Function(Task task) onTaskUpdated;
  final Future<void> Function(Task task) onTaskDeleted;

  const TodoPage({
    super.key,
    required this.tasks,
    required this.tags,
    required this.onTaskAdded,
    required this.onTaskUpdated,
    required this.onTaskDeleted,
  });

  @override
  State<TodoPage> createState() => _TodoPageState();
}

class _TodoPageState extends State<TodoPage> {
  String searchQuery = '';
  String selectedTag = "";

  @override
  Widget build(BuildContext context) {
    final taskList = widget.tasks
        .where((task) => !task.hasTag('course'))
        .toList();

    final filteredTasks = taskList
        .where((task) => task.title.contains(searchQuery))
        .where((task) => selectedTag == "" ? true : task.hasTag(selectedTag))
        .toList();

    Expanded wrapEx(child) => Expanded(child: child);

    return Scaffold(

      body: Padding(
        padding: const EdgeInsets.fromLTRB(12, 0, 12, 0),
        child: Column(
          spacing: 8,
          children: [
            // _searchBar(),
            _searchHeader(widget.tags),
            // TabBar(tabs: [
            //   Tab(icon: Icon(Icons.incomplete_circle)),
            //   Tab(icon: Icon(Icons.perm_contact_cal_outlined)),
            // ]),
            _todoListExpand(filteredTasks),
          ],
        )
      ),

      floatingActionButton: RadialActionButton(
        onTap: (context) async {
          final task = await Navigator.push<Task>(
            context,
            MaterialPageRoute(builder: (_) => const AddTaskPage()),
          );

          if (task == null || task.title.trim().isEmpty) {
            return;
          }

          await widget.onTaskAdded(task);
        },

        actions: [
          // 左：終日タスク
          RadialAction(
            label: '終日',
            icon: Icons.today,
            // offset: const Offset(-96, 0),
            offset: const Offset(-146, 0),
            onSelected: _createAddTaskHandler(
              initialIsAllDay: true,
            ),
          ),

          // 左上：課題タグ付きタスク
          RadialAction(
            label: '課題',
            icon: Icons.assignment_outlined,
            // offset: const Offset(-68, -68),
            offset: const Offset(-103, -103),
            onSelected: _createAddTaskHandler(
              initialTags: ['課題'],
            ),
          ),

          // 上：緊急タグ付きタスク
          RadialAction(
            label: '緊急',
            icon: Icons.priority_high,
            // offset: const Offset(0, -96),
            offset: const Offset(0, -146),
            onSelected: _createAddTaskHandler(
              initialTags: ['緊急'],
            ),
          ),
        ],
      ),


      // floatingActionButton: FloatingActionButton(
      //   child: const Icon(Icons.add),
      //   // onPressed: () async {
      //   //   await seedTestTasks();
      //   //
      //   //   if (!context.mounted) return;
      //   //
      //   //   ScaffoldMessenger.of(context).showSnackBar(
      //   //     const SnackBar(content: Text('テストデータを登録しました')),
      //   //   );
      //   // },
      //   onPressed: () async {
      //     // final title = await Navigator.push<String>(
      //     final task = await Navigator.push<Task>(
      //       context,
      //       MaterialPageRoute(builder: (context) => const AddTaskPage()),
      //     );
      //
      //     if (task == null || task.title.trim().isEmpty) {
      //       return;
      //     }
      //
      //     final now = DateTime.now();
      //
      //     await widget.onTaskAdded(task);
      //   },
      // ),
    );
  }

  Expanded _todoListExpand(List<Task> filteredTasks) {
    return Expanded(
          child: TodoList(
            tasks: filteredTasks,

            // 完了状態の変更
            onToggle: (index) async {
              final task = filteredTasks[index];

              task.update(
                status: task.isCompleted ? TaskStatus.todo : TaskStatus.completed,
              );

              await widget.onTaskUpdated(task);
            },

            // 削除
            onDelete: (index) async {
              final task = filteredTasks[index];
              await widget.onTaskDeleted(task);
            },
          ),
        );
  }

  Padding _searchBar() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(child: TextField(
            decoration: const InputDecoration(
              labelText: 'タスクを検索',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
            ),
            onChanged: (value) => setState(() {searchQuery = value;}),
          )),
          Icon(Icons.filter_alt),
        ],
      ),
    );
  }

  Widget _searchHeader(List<String> tags) {
    return TagSearchHeader(
      tags: tags,
      selectedTag: selectedTag,
      onTagSelected: (tag) {
        setState(() {
          selectedTag = tag!;
        });
      },
      onSearchChanged: (query) {
        setState(() {
          searchQuery = query;
        });
      },
    );
  }

  Future<void> Function(BuildContext) _createAddTaskHandler({
    bool initialIsAllDay = false,
    List<String> initialTags = const [],
  }) {
    return (context) async {
      final task = await Navigator.push<Task>(
        context,
        MaterialPageRoute(
          builder: (_) => AddTaskPage(
            initialIsAllDay: initialIsAllDay,
            initialTags: initialTags,
          ),
        ),
      );

      if (task == null || task.title.trim().isEmpty) {
        return;
      }

      await widget.onTaskAdded(task);
    };
  }
}
