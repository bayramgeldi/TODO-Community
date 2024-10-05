import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:todo_community_ai_app/model/element.dart';

class Task {
  String title;
  String? description;
  String color;
  DateTime date;
  List<ElementTask> elements = [];

  Task({required this.title, this.description, this.color = '0xff64B5F6', required this.date, required this.elements});

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      title: json['title'],
      description: json['description'], date: DateTime.parse(json['date']),
      color: json['color'],
      elements: (json['elements'] as List).map((e) => ElementTask.fromJson(e)).toList(),
    );
  }

  factory Task.fromQueryDocumentSnapshot(QueryDocumentSnapshot<Object?> f) {
    return Task(
      title: f.get("title"),
      description: f.get("description"),
      date: DateTime.fromMillisecondsSinceEpoch(f.get("date")),
      color: f.get("color"),
      elements: (f.get('elements') as List).map((e) => ElementTask.fromJson(e)).toList(),
    );
  }
  factory Task.fromDocumentSnapshot(DocumentSnapshot<Object?> f) {
    return Task(
      title: f.get("title"),
      description: f.get("description"),
      date: DateTime.fromMillisecondsSinceEpoch(f.get("date")),
      color: f.get("color"),
      elements: (f.get('elements') as List).map((e) => ElementTask.fromJson(e)).toList(),
    );
  }



  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'color': color,
      'date': date.millisecondsSinceEpoch,
      'elements': elements.map((e) => e.toJson()).toList(),
    };
  }

}