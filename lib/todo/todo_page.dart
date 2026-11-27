
import 'package:flutter/material.dart';

import 'package:flutter_minimal_learning/task/task.dart';
import 'package:flutter_minimal_learning/todo/tag_search_header.dart';
import 'package:flutter_minimal_learning/todo/todo_list.dart';

class TodoPage extends StatefulWidget {
  final List<Task> tasks;
  final Set<String> tags;
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
  Set<String> selectedTags = {};
  TaskStatusFilter selectedState = TaskStatusFilter.todo;

  @override
  Widget build(BuildContext context) {
    final taskList = widget.tasks
        .where((task) => !task.hasTag('course'))
        .toList();

    final filteredTasks = taskList
        .where((task) => task.title.contains(searchQuery))
        .where((task) => selectedTags.isEmpty || selectedTags.every((tag) => task.hasTag(tag)))
        .where((task) => selectedState.matches(task.status))
        .toList();

    final Map<TaskStatusFilter, int> statusCounts = {
      for(final filter in TaskStatusFilter.values)
        filter: taskList
            .where((task) => task.title.contains(searchQuery))
            .where((task) => selectedTags.isEmpty || selectedTags.every((tag) => task.hasTag(tag)))
            .where((task) => filter.matches(task.status))
            .length
    };



    return Scaffold(

      body: Padding(
        padding: const EdgeInsets.fromLTRB(12, 0, 12, 0),
        child: Column(
          spacing: 8,
          children: [
            // _searchBar(),
            _searchHeader(widget.tags, statusCounts),
            // TabBar(tabs: [
            //   Tab(icon: Icon(Icons.incomplete_circle)),
            //   Tab(icon: Icon(Icons.perm_contact_cal_outlined)),
            // ]),
            _todoListExpand(filteredTasks),
          ],
        )
      ),
    );
  }

  Expanded _todoListExpand(List<Task> filteredTasks) {
    return Expanded(
          child: TodoList(
            tasks: filteredTasks,

            // 完了状態の変更
            onToggle: (index) async {
              final task = filteredTasks[index];

              final updatedTask = task.copyWith(
                status: task.isCompleted ? TaskStatus.todo : TaskStatus.completed,
              );

              await widget.onTaskUpdated(updatedTask);
            },

            // 削除
            onDelete: (index) async {
              final task = filteredTasks[index];
              await widget.onTaskDeleted(task);
            },
          ),
        );
  }


  Widget _searchHeader(Set<String> tags, Map<TaskStatusFilter, int> statusCounts) {
    return TagSearchHeader(
      tags: tags,
      selectedTags: selectedTags,
      selectedState: selectedState,
      statusCounts: statusCounts,
      onTagSelected: (tag) {
        setState(() {
          if(tag == null || tag.isEmpty) {
            selectedTags.clear();
          }else if (selectedTags.contains(tag)) {
            selectedTags.remove(tag);
          }else {
            selectedTags.add(tag);
          }
        });
      },
      onSearchChanged: (query) {
        setState(() {
          searchQuery = query;
        });
      },
      onStateSelected: (state) {
        setState(() {
          selectedState = state;
        });
      },
    );
  }

}
