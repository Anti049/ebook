import 'package:archive/archive_io.dart';
import 'package:ebook/ebook.dart';
import 'package:ebook/src/classes/book.dart';
import 'package:ebook/src/classes/metadata.dart';
import 'package:ebook/src/readers/base_reader.dart';
import 'package:ebook/src/utils/pair.dart';
import 'package:universal_io/io.dart';
import 'package:xml/xml.dart';

class EpubReader extends BaseReader {
  String fileName = '';

  EpubReader() : super('epub', '.epub');

  @override
  Future<Book> read(
      {String filePath = '',
      List<Pair<String, String>> aliases = const []}) async {
    if (aliases.isNotEmpty) {
      this.aliases = aliases;
    }
    fileName = filePath;
    String titlePage = '';
    // Metadata
    String title = '';
    List<Map<String, String>> authors = [];
    String summary = '';
    Map<String, dynamic> extraData = {};
    // Chapters
    List<String> chapterPages = [];
    List<Chapter> chapters = [];

    // Read zip file from disk
    var bytes = await File(fileName).readAsBytes();
    // Decode the Zip file
    var archive = ZipDecoder().decodeBytes(bytes);
    // Files to read:
    //  content.opf
    //  toc.ncx
    //  stylesheet.css
    //  OEBPS/*.xhtml
    // Read data from META-INF/container.xml
    var contentFile = archive.findFile('content.opf');
    // Convert the Zip file to a string
    var content = String.fromCharCodes(contentFile!.content);
    // Parse XML from the string
    var contentXML = XmlDocument.parse(content);

    // Publisher
    extraData[getKey('uid')] =
        contentXML.findAllElements('dc:identifier').first.text;
    extraData[getKey('publisher')] = {
      'name': contentXML.findAllElements('dc:publisher').first.text,
      'url': contentXML
              .findAllElements('dc:publisher')
              .first
              .getAttribute('href') ??
          '',
      'id':
          contentXML.findAllElements('dc:publisher').first.getAttribute('id') ??
              '',
    };

    // Title
    title = contentXML.findAllElements('dc:title').first.text;

    // Authors
    authors = contentXML
        .findAllElements('meta')
        .where((e) {
          return e.getAttribute('id').toString().contains('author_');
        })
        .map((e) => {
              'name': e.findElements('name').first.text,
              'url': e.findElements('url').first.text,
            })
        .toList();

    // Description
    summary = contentXML
        .findAllElements('dc:description')
        .first
        .text
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>');

    // Source
    extraData[getKey('source')] = {
      'url': contentXML.findAllElements('dc:source').first.text,
    };

    // Subjects
    extraData[getKey('subjects')] = contentXML
        .findAllElements('dc:subject')
        .map(
          (e) => {
            'name': e.text,
            'url': e.getAttribute('opf:url') ?? '',
          },
        )
        .toList();

    // Series
    if (contentXML
        .findAllElements('meta')
        .where((element) => element.getAttribute('id') == 'series')
        .isNotEmpty) {
      final nameXML = contentXML
          .findAllElements('meta')
          .where((element) => element.getAttribute('id') == 'series');
      extraData[getKey('series')] = {
        'name': contentXML
                .findAllElements('meta')
                .where((element) => element.getAttribute('id') == 'series')
                .first
                .getAttribute('content') ??
            '',
        'index': contentXML
                .findAllElements('meta')
                .where(
                    (element) => element.getAttribute('id') == 'series_index')
                .first
                .getAttribute('content') ??
            '',
        'url': contentXML
                .findAllElements('meta')
                .where((element) => element.getAttribute('id') == 'series_url')
                .first
                .getAttribute('content') ??
            '',
      };
    }

    // Published
    extraData[getKey('published')] = DateTime.parse(
      contentXML
          .findAllElements('dc:date')
          .where((element) => element.getAttribute('id') == 'publication')
          .first
          .text,
    );

    // Updated
    extraData[getKey('updated')] = DateTime.parse(
      contentXML
          .findAllElements('dc:date')
          .where((element) => element.getAttribute('id') == 'modification')
          .first
          .text,
    );

    // Language
    extraData[getKey('language')] =
        contentXML.findAllElements('dc:language').first.text;

    // Rating
    extraData[getKey('rating')] = contentXML
        .findAllElements('meta')
        .where((element) => element.getAttribute('name') == 'rating')
        .first
        .getAttribute('content');

    // Status
    extraData[getKey('status')] = contentXML
        .findAllElements('meta')
        .where((element) => element.getAttribute('name') == 'calibre:status')
        .first
        .getAttribute('content');

    // Words
    extraData[getKey('words')] = int.parse(
      contentXML
          .findAllElements('meta')
          .where((element) => element.getAttribute('name') == 'calibre:words')
          .first
          .getAttribute('content')
          .toString(),
    );

    // Chapters
    String chapterCount = contentXML
        .findAllElements('meta')
        .where((element) => element.getAttribute('name') == 'calibre:chapters')
        .first
        .getAttribute('content')
        .toString();

    // Pages
    var pages = contentXML.findAllElements('item');
    for (final page in pages) {
      // if page's media-type is 'application/xhtml+xml'
      if (page.getAttribute('media-type') == 'application/xhtml+xml') {
        var href = page.getAttribute('href');
        var id = page.getAttribute('id');
        if (id.toString().contains('title')) {
          titlePage = href.toString();
        } else {
          chapterPages.add(href.toString());
        }
      }
    }
    int chapterStart = 0;
    if (titlePage.isEmpty) {
      titlePage = chapterPages.first;
      chapterStart = 1;
    }

    // Title Page
    var titleFile = archive.findFile(titlePage);
    var titleContent = String.fromCharCodes(titleFile!.content);
    var titleXML = XmlDocument.parse(titleContent);

    // Characters
    var characterXML = titleXML
        .findAllElements('dd')
        .where((element) => element.getAttribute('id') == 'characters');
    if (characterXML.isNotEmpty) {
      extraData[getKey('characters')] = characterXML.first
          .findAllElements('a')
          .map((e) => {
                'name': e.text,
                'url': e.getAttribute('href') ?? '',
              })
          .toList();
    }

    // Relationships
    var relationshipXML = titleXML
        .findAllElements('dd')
        .where((element) => element.getAttribute('id') == 'relationships');
    if (relationshipXML.isNotEmpty) {
      extraData[getKey('relationships')] = relationshipXML.first
          .findAllElements('a')
          .map((e) => {
                'name': e.text,
                'url': e.getAttribute('href') ?? '',
              })
          .toList();
    }

    // Additional Tags
    var additionalTagsXML = titleXML
        .findAllElements('dd')
        .where((element) => element.getAttribute('id') == 'additional_tags');
    if (additionalTagsXML.isNotEmpty) {
      extraData[getKey('additionalTags')] = additionalTagsXML.first
          .findAllElements('a')
          .map((e) => {
                'name': e.text,
                'url': e.getAttribute('href') ?? '',
              })
          .toList();
    }

    // Chapters
    for (var i = chapterStart; i < chapterPages.length; i++) {
      var chapterFile = archive.findFile(chapterPages[i]);
      var chapterContent = String.fromCharCodes(chapterFile!.content);
      var chapterXML = XmlDocument.parse(chapterContent);

      var chapterURL = chapterXML
          .findAllElements('meta')
          .where((element) => element.getAttribute('name') == 'chapter_url')
          .first
          .getAttribute('content');
      var chapterTitle = chapterXML.findAllElements('title').first.text;
      var chapterText = chapterXML.findAllElements('div').first.toString();

      chapters.add(
        Chapter(
          title: chapterTitle,
          content: chapterText,
          metadata: {
            'title': chapterTitle,
            'url': chapterURL,
          },
        ),
      );
    }
    extraData['chapters'] = '${chapters.length}/$chapterCount';

    return Book(
      metadata: Metadata(
        title: title,
        authors: authors,
        summary: summary,
        extraData: extraData,
      ),
      chapters: chapters,
    );
  }

  @override
  Book readSync({String filePath = ''}) {
    return Book();
  }
}
