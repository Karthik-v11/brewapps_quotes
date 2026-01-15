import 'package:equatable/equatable.dart';

class QuoteEntity extends Equatable {
  final String id;
  final String content;
  final String author;
  final String category;
  final DateTime createdAt;

  const QuoteEntity({
    required this.id,
    required this.content,
    required this.author,
    required this.category,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, content, author, category, createdAt];
}
