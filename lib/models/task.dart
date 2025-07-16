class Task {
  String title;
  bool isDone;
  int priority; // 1=High, 2=Medium, 3=Low

  Task({required this.title, this.isDone = false, this.priority = 2});

  Map<String, dynamic> toMap() => {
        'title': title,
        'isDone': isDone,
        'priority': priority,
      };

  factory Task.fromMap(Map<String, dynamic> map) => Task(
        title: map['title'],
        isDone: map['isDone'],
        priority: map['priority'] ?? 2,
      );
}

