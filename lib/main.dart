import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'models/task.dart'; // Make sure your Task class is defined with toJson/fromJson

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Task Easee',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode: ThemeMode.system,
      home: const LaunchDecider(),
    );
  }
}

class LaunchDecider extends StatelessWidget {
  const LaunchDecider({super.key});

  Future<bool> hasTasks() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? storedTasks = prefs.getStringList('tasks');
    return storedTasks != null && storedTasks.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: hasTasks(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // While checking SharedPreferences
          return const Scaffold(
              body: Center(child: CircularProgressIndicator()));
        } else if (snapshot.hasData && snapshot.data == true) {
          // Tasks exist → Go to TaskPage
          return const TaskPage();
        } else {
          // No tasks → Go to HomePage
          return const HomePage();
        }
      },
    );
  }
}


// HOME SCREEN
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.deepPurple[50],
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Welcome to',
                style: TextStyle(fontSize: 22, color: Colors.black87)),
            const Text('Task Easee',
                style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple)),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => const TaskPage()));
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: const Text('Get Started',
                  style: TextStyle(fontSize: 18, color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}

// TASK PAGE
class TaskPage extends StatefulWidget {
  const TaskPage({super.key});

  @override
  State<TaskPage> createState() => _TaskPageState();
}

class _TaskPageState extends State<TaskPage> {
  List<Task> _tasks = [];
  final TextEditingController _controller = TextEditingController();
  int _selectedPriority = 2;

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? storedTasks = prefs.getStringList('tasks');
    if (storedTasks != null) {
      setState(() {
        _tasks = storedTasks
            .map((taskStr) => Task.fromJson(json.decode(taskStr)))
            .toList();
      });
    }
  }

  Future<void> _saveTasks() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> taskStrings =
        _tasks.map((task) => json.encode(task.toJson())).toList();
    await prefs.setStringList('tasks', taskStrings);
  }

  void _addTask(String title, int priority) {
    setState(() {
      _tasks.add(Task(title: title, isDone: false, priority: priority));
    });
    _saveTasks();
  }

  void _toggleDone(int index) {
    setState(() {
      _tasks[index].isDone = !_tasks[index].isDone;
    });
    _saveTasks();
  }

  void _deleteTask(int index) {
    setState(() {
      _tasks.removeAt(index);
    });
    _saveTasks();
  }

  void _showEditDialog(int index) {
    _controller.text = _tasks[index].title;
    _selectedPriority = _tasks[index].priority;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Task'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _controller,
              decoration: const InputDecoration(labelText: 'Task'),
            ),
            const SizedBox(height: 10),
            DropdownButton<int>(
              value: _selectedPriority,
              items: const [
                DropdownMenuItem(value: 1, child: Text('High')),
                DropdownMenuItem(value: 2, child: Text('Medium')),
                DropdownMenuItem(value: 3, child: Text('Low')),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedPriority = value!;
                });
              },
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _tasks[index].title = _controller.text;
                _tasks[index].priority = _selectedPriority;
              });
              _saveTasks();
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showAddDialog() {
    _controller.clear();
    _selectedPriority = 2;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Task'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _controller,
              decoration: const InputDecoration(labelText: 'Task'),
            ),
            const SizedBox(height: 10),
            DropdownButton<int>(
              value: _selectedPriority,
              items: const [
                DropdownMenuItem(value: 1, child: Text('High')),
                DropdownMenuItem(value: 2, child: Text('Medium')),
                DropdownMenuItem(value: 3, child: Text('Low')),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedPriority = value!;
                });
              },
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (_controller.text.trim().isNotEmpty) {
                _addTask(_controller.text.trim(), _selectedPriority);
                Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    _tasks.sort((a, b) => a.priority.compareTo(b.priority)); // Sort by priority

    return Scaffold(
      appBar: AppBar(
        title: const Text('Task Easee'),
        backgroundColor: Colors.deepPurple,
      ),
      body: _tasks.isEmpty
          ? const Center(child: Text('No tasks found'))
          : ListView.builder(
              itemCount: _tasks.length,
              itemBuilder: (context, index) {
                final task = _tasks[index];
                return Card(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: ListTile(
                    title: Text(
                      task.title,
                      style: TextStyle(
                          decoration: task.isDone
                              ? TextDecoration.lineThrough
                              : TextDecoration.none),
                    ),
                    subtitle: Text(
                      task.priority == 1
                          ? 'High Priority'
                          : task.priority == 2
                              ? 'Medium Priority'
                              : 'Low Priority',
                      style: const TextStyle(color: Colors.grey),
                    ),
                    leading: Checkbox(
                      value: task.isDone,
                      onChanged: (_) => _toggleDone(index),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () => _deleteTask(index),
                    ),
                    onLongPress: () => _showEditDialog(index),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.deepPurple,
        onPressed: _showAddDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}
