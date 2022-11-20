import 'dart:convert';

class DocumentModel {
  final String title;
  final String uid;
  final bool pinned;
  final bool favorite;
  final List content;
  final DateTime createdAt;
  final String id;

  DocumentModel({
    required this.title,
    required this.uid,
    required this.content,
    required this.createdAt,
    required this.id,
    required this.pinned,
    required this.favorite,
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'uid': uid,
      'contents': content,
      'pinned': pinned,
      'favorite': favorite,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'id': id,
    };
  }

  factory DocumentModel.fromMap(Map<String, dynamic> map) {
    return DocumentModel(
      title: map['title'] ?? '',
      uid: map['uid'] ?? '',
      pinned: map['pinned'] ?? '',
      favorite: map['favorite'] ?? '',
      content: List.from(map['contents']),
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt']),
      id: map['_id'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory DocumentModel.fromJson(String source) => DocumentModel.fromMap(json.decode(source));
}