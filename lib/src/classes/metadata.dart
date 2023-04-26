import 'package:ebook/src/utils/template_string.dart';

class Metadata {
  String title;
  List<dynamic> authors;
  String summary;
  String coverURL;
  Map<String, dynamic> extraData;
  String uidTemplate;
  List<List<String>> aliases;

  /// Creates a new Metadata object using [title] to describe the book's title, [authors] to describe the book's authors, [summary] to describe the book's summary, [subjects] to describe the book's subjects, and [extraData] to describe any extra data.
  /// [authors] can be either a list of strings or a list of maps with the keys 'name' and 'url'.
  /// [extraData] can be any map of data.
  Metadata({
    this.title = '',
    this.authors = const [],
    this.summary = '',
    this.coverURL = '',
    this.extraData = const {},
    this.uidTemplate = '''epub-uid:{this['title']}-u{this['authorNames'][0]}''',
    this.aliases = const [],
  }) {
    // If title is not empty
    if (extraData.containsKey('source')) {
      this['titleHTML'] =
          '<b><a id="title" href="${this['source']['url']}">$title</a></b>';
    } else {
      this['titleHTML'] = '<b><span id="title">$title</span></b>';
    }
    if (authors.isNotEmpty) {
      String authorHTML = '';
      List<String> htmls = [];
      // Loop through authors
      for (int i = 0; i < authors.length; i++) {
        // Add author to metadata
        htmls.add(
            '<a id="authors" class="authorLink" href="${authors[i]["url"]}">${authors[i]["name"]}</a>');
      }
      // Join authors
      // author1 and author2
      // author1, author2, and author3
      // author1, author2, author3, and author4
      if (htmls.length == 2) {
        authorHTML = '${htmls[0]} and ${htmls[1]}';
      } else if (htmls.length > 2) {
        for (int i = 0; i < htmls.length; i++) {
          if (i == htmls.length - 1) {
            authorHTML += 'and ${htmls[i]}';
          } else if (i == htmls.length - 2) {
            authorHTML += '${htmls[i]}, ';
          } else {
            authorHTML += '${htmls[i]}, ';
          }
        }
      } else {
        authorHTML = htmls[0];
      }
      // Add authors to metadata
      this['authorHTML'] = authorHTML;
      // Separate author's names in authorNames variable
      this['authorNames'] = [];
      for (int i = 0; i < authors.length; i++) {
        this['authorNames'].add(authors[i]['name']);
      }
      this['uid'] = uidTemplate.formatMap(getAllData());
    }
  }

  static Metadata blank() {
    return Metadata(
      title: '',
      authors: [],
      summary: '',
      extraData: {},
    );
  }

  static Metadata get empty => blank();

  Map<String, dynamic> getAllData() {
    return {
      'title': title,
      'authors': authors,
      'summary': summary,
      ...extraData,
    };
  }

  Map<String, dynamic> getData({List<String> exclude = const []}) {
    Map<String, dynamic> data = {};
    // Loop through all data
    for (String key in getAllData().keys) {
      // Check if key is not in exclude list
      if (!exclude.contains(key)) {
        // Add key to data
        data[key] = getAllData()[key];
      }
    }
    return data;
  }

  bool hasKey(String key) {
    return getAllData().containsKey(key);
  }

  dynamic getValue(String key) {
    return getAllData()[key];
  }

  dynamic operator [](String key) {
    return getValue(key);
  }

  void operator []=(String key, dynamic value) {
    extraData[key] = value;
  }

  List<Map<String, dynamic>> getExtraTitleEntries() {
    return [
      {
        'label': '',
        'value': '${this['summary']}'.replaceAll('\n', '<br/>'),
      }
    ];
  }
}
