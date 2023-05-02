import '../classes/book.dart';

abstract class BaseWriter {
  final String formatName;
  final String formatExt;
  Book? book;
  Map<String, List<String>> aliases = {};

  BaseWriter(this.formatName, this.formatExt);

  String getOutputFileName() {
    return 'output.$formatExt';
  }

  String getBaseFileName() {
    return 'output';
  }

  bool hasConfig(String id) {
    return false;
  }

  String getConfig(String id) {
    return '';
  }

  void write({String filePath = ''}) async {}
  void writeSync({String filePath = ''}) {}

  Map<String, dynamic> getLastLogData(String logFile) {
    return {};
  }

  String makeLogEntry({Map<String, dynamic> data = const {}}) {
    return '';
  }

  dynamic getMetadata(String key) {
    if (key.contains('.')) {
      List<String> keyList = key.split('.');
      if (keyList.length == 2) {
        String key1 = keyList[0];
        String key2 = keyList[1];
        if (book!.metadata!.hasKey(key1)) {
          dynamic data = getMetadata(key1);
          if (data is Map && data.containsKey(key2)) {
            return data[key2];
          }
          return data;
        }
      }
    } else if (!book!.metadata!.hasKey(key)) {
      if (aliases.containsKey(key)) {
        List<String> aliasList = aliases[key]!;
        for (String alias in aliasList) {
          if (book!.metadata!.hasKey(alias)) {
            return book!.metadata![alias];
          }
        }
      }
    }
    return book!.metadata![key];
  }

  String getLanguageString(String languageCode) {
    switch (languageCode) {
      case 'en':
        return 'English';
      case 'es':
        return 'Spanish';
      case 'fr':
        return 'French';
      case 'de':
        return 'German';
      case 'it':
        return 'Italian';
      case 'pt':
        return 'Portuguese';
      case 'ru':
        return 'Russian';
      case 'ja':
        return 'Japanese';
      case 'zh':
        return 'Chinese';
      case 'ar':
        return 'Arabic';
      case 'ko':
        return 'Korean';
      case 'tr':
        return 'Turkish';
      case 'nl':
        return 'Dutch';
      case 'sv':
        return 'Swedish';
      case 'da':
        return 'Danish';
      case 'no':
        return 'Norwegian';
      case 'fi':
        return 'Finnish';
      case 'pl':
        return 'Polish';
      case 'cs':
        return 'Czech';
      default:
        return languageCode;
    }
  }

  void addAlias(String key, String alias) {
    if (aliases.containsKey(key)) {
      aliases[key]!.add(alias);
    } else {
      aliases[key] = [alias];
    }
  }
}
