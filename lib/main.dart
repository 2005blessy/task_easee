import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'models/task.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Task Easee',
      themeMode: ThemeMode.system,
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      home: Scaffold(
        appBar: AppBar(
          title: Text('Task Easee'),
        ),
        body: TaskList(),
    ),
    ); 
  }
}

class TaskList extends StatefulWidget {
  const TaskList({super.key});

  @override
  State<TaskList> createState() => _TaskListState();
}

class _TaskListState extends State<TaskList> {
  List<Task> tasks = [];
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadTasks();
  }

  void saveTasks() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> taskList =
        tasks.map((task) => json.encode(task.toMap())).toList();
    await prefs.setStringList('tasks', taskList);
    print('saving tasks:${taskList.length}');
  }

  void loadTasks() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? taskList = prefs.getStringList('tasks');
    if (taskList != null) {
      print('loading tasks:${taskList.length}');
      setState(() {
        tasks = taskList
            .map((taskString) => Task.fromMap(json.decode(taskString)))
            .toList();

            tasks.sort((a, b)=> a.priority.compareTo(b.priority));
      });
    }
    else {
    print('⚠️ No tasks found in SharedPreferences');
  }
    

  }

  void addTask(String title, {int priority = 2}) {
    setState(() {
      tasks.add(Task(title: title, priority: priority));
      tasks.sort((a, b) => a.priority.compareTo(b.priority));
      _controller.clear();
    });
    saveTasks();
  }

  void toggleTask(int index) {
    setState(() {
      tasks[index].isDone = !tasks[index].isDone;
    });
    saveTasks();
  }

  void deleteTask(int index) {
    setState(() {
      tasks.removeAt(index);
    });
    saveTasks();
  }

  @override
  int _selectedPriority = 2;
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  decoration: InputDecoration(
                    labelText: 'Add a new task',
                    hintText: 'e.g., Buy groceries',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onSubmitted: (value) {
                    if (value.trim().isNotEmpty) {
                      addTask(value.trim(), priority: _selectedPriority);
                    }
                  },
                ),
              ),
              SizedBox(width: 10),
              DropdownButton<int>(
                value: _selectedPriority,
                items: [
                  DropdownMenuItem(value: 1, child: Text('High')),
                  DropdownMenuItem(value: 2, child: Text('Medium')),
                  DropdownMenuItem(value: 3, child: Text('Low')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedPriority = value;
                    });
                  }
                },
              ),
              ElevatedButton(
                onPressed: () {
                  if (_controller.text.trim().isNotEmpty) {
                    addTask(_controller.text.trim(), priority: _selectedPriority);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                ),
                child: Text('Add'),
              ),
            ],
          ),
        ),
        Expanded(
          child: tasks.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.hourglass_empty,
                          size: 64, color: Colors.grey[400]),
                      SizedBox(height: 10),
                      Text(
                        'No tasks available.',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: tasks.length,
                  itemBuilder: (context, index) {
                    final task = tasks[index];
                    return Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 4.0,
                      margin:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      child: ListTile(
                        contentPadding: EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        title: Text(
                          task.title,
                          style: TextStyle(
                            fontSize: 18,
                            decoration: task.isDone
                                ? TextDecoration.lineThrough
                                : null,
                          ),
                        ),

                        subtitle: Text(
                          task.priority == 1
                              ? 'High Priority'
                              : task.priority == 2
                                  ? 'Medium Priority'
                                  : 'Low Priority',
                          style: TextStyle(color:Colors.teal),
                        ),
                        leading: Checkbox(
                          value: task.isDone,
                          activeColor: Colors.teal,
                          onChanged: (_) => toggleTask(index),
                        ),
                        trailing: IconButton(
                          icon: Icon(Icons.delete, color: Colors.redAccent),
                          onPressed: () => deleteTask(index),
                        ),

                        onLongPress: (){
                          TextEditingController editController = TextEditingController(text: task.title);
                          showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                title: Text('Edit Task'),
                                content: TextField(
                                  controller: editController,
                                  autofocus: true,
                                  decoration: InputDecoration(
                                    hintText: 'update task title',
                                  ),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: Text('cancel'),
                                  ),
                                  ElevatedButton(onPressed: (){
                                    if(editController.text.trim().isNotEmpty){
                                      setState(() {
                                        tasks[index].title = editController.text.trim();
                                      });
                                      saveTasks();
                                      Navigator.pop(context);
                                    }
                                  }, child: Text('save')),  
                          
                                ],
                              );
                            },
                          );
                        },
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
