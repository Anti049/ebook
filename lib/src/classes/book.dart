import 'metadata.dart';
import 'chapter.dart';

class Book {
  String logData = '';
  Metadata? metadata;
  List<Chapter> chapters = [];
  Map<String, dynamic> titleEntries = {};

  /// Creates a new Book object using [metadata] to describe the book and [chapters] to contain the data for the book's chapters.
  Book({
    this.chapters = const [],
    this.metadata,
  });
}
