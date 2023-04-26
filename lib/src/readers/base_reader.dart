import 'package:ebook/src/classes/book.dart';
import 'package:ebook/src/utils/pair.dart';

abstract class BaseReader {
  final String formatName;
  final String formatExt;
  Book? book;
  List<Pair<String, String>> aliases = [];

  BaseReader(this.formatName, this.formatExt);

  String getInputFileName() {
    return 'input.$formatExt';
  }

  String getBaseFileName() {
    return 'input';
  }

  Future<Book> read(
      {String filePath = '', List<Pair<String, String>> aliases = const []});
  Book readSync({String filePath = ''});

  String getKey(String key) {
    for (final alias in aliases) {
      if (alias.first == key) {
        return alias.second;
      }
    }
    return key;
  }
}
