import 'package:cloud_firestore/cloud_firestore.dart';

class ElementTask{
  final String name;
  bool isDone;

  ElementTask({required this.name, required this.isDone});

  factory ElementTask.fromJson(Map<String, dynamic> json) {
    return ElementTask(
      name:json['name'],
      isDone:json['isDone'],
    );
  }

  factory ElementTask.fromQueryDocumentSnapshot(QueryDocumentSnapshot<Object?> e) {
    return ElementTask(
      name:e.get('name'),
      isDone: e.get('isDone'),
    );
  }


  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'isDone': isDone,
    };
  }


}