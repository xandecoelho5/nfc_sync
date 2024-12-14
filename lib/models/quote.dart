import 'package:equatable/equatable.dart';
import 'package:floor/floor.dart';
import 'package:json_annotation/json_annotation.dart';

part 'quote.g.dart';

@JsonSerializable()
@entity
class Quote extends Equatable {
  @primaryKey
  final int? id;
  final String? content;
  final String? author;

  const Quote({this.id, this.content, this.author});

  factory Quote.fromJson(Map<String, dynamic> json) => _$QuoteFromJson(json);
  Map<String, dynamic> toJson() => _$QuoteToJson(this);

  @override
  String toString() {
    return 'Quote{id: $id, content: $content, author: $author}';
  }

  @override
  List<Object?> get props => [id, content, author];
}
