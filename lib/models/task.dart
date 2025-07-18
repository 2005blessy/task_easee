class Task {
  String title;
  bool isDone;
  int priority; // 1=High, 2=Medium, 3=Low

  Task({required this.title, this.isDone = false, this.priority = 2});

  Map<String, dynamic> toJson() {
    return {
        'title': title,
        'isDone': isDone,
        'priority': priority,
      };
  }  

  factory Task.fromJson(Map<String, dynamic> map) {
    return Task(
        title: map['title'] ,
        isDone: map['isDone'] ,
        priority: map['priority'],
      );
  }
} 

