import 'package:equatable/equatable.dart';

class CommentCategory extends Equatable {
  const CommentCategory({
    required this.id,
    required this.name,
    required this.icon,
    required this.colorHex,
    required this.isPredefined,
    required this.sortOrder,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String name;
  final String icon;
  final String colorHex;
  final bool isPredefined;
  final int sortOrder;
  final DateTime createdAt;
  final DateTime updatedAt;

  @override
  List<Object?> get props =>
      [id, name, icon, colorHex, isPredefined, sortOrder];
}

class Comment extends Equatable {
  const Comment({
    required this.id,
    required this.categoryId,
    required this.text,
    required this.tags,
    required this.isFavorite,
    required this.usageCount,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String categoryId;
  final String text;
  final List<String> tags;
  final bool isFavorite;
  final int usageCount;
  final DateTime createdAt;
  final DateTime updatedAt;

  @override
  List<Object?> get props =>
      [id, categoryId, text, isFavorite, usageCount];
}
