import 'package:ebook/ebook.dart';
import 'package:ebook_example_dart/fanfic_metadata.dart';
import 'package:universal_io/io.dart';
import 'package:path/path.dart';

void main() {
  test();
}

void test() async {
  String currentPath =
      dirname(Platform.script.toString()).replaceFirst('file://', '');
  String outputFolder = '$currentPath/../output';
  bool read = true, write = true;
  if (write) {
    await testWrite(outputFolder);
  }
  if (read) {
    await testRead(outputFolder);
  }
}

Future<void> testRead(String outputFolder) async {
  String testFile = 'test.epub';

  EpubReader reader = EpubReader();
  Book book = await reader.read(filePath: '$outputFolder/$testFile', aliases: [
    Pair.fromMap({
      'subjects': 'fandoms',
    })
  ]);
  print(book.metadata.toString());
}

Future<void> testWrite(String outputFolder) async {
  var writer = EpubWriter();
  writer.formatter.useStylesheetFile = true;
  // Get full filepath to '.\stylesheet.css'
  String currentPath =
      dirname(Platform.script.toString()).replaceFirst('file://', '');
  String assetsPath = '$currentPath/../assets';
  final chapterContent = await File('$assetsPath/chapter.html').readAsString();
  final ao3CSS = await File('$assetsPath/ao3.css').readAsString();
  writer.formatter.setStylesheetContent(ao3CSS);
  writer.book = Book(
    chapters: [
      Chapter(
        title: 'Chapter 1',
        content: chapterContent,
        metadata: {
          'title': '1. Chapter 1',
          'url':
              'https://archiveofourown.org/works/34813381/chapters/123456789',
        },
      ),
      Chapter(
        title: 'Chapter 2',
        content: chapterContent,
        metadata: {
          'title': '2. Chapter 2',
          'url':
              'https://archiveofourown.org/works/34813381/chapters/123456789',
        },
      ),
      Chapter(
        title: 'Chapter 3',
        content: chapterContent,
        metadata: {
          'title': '3. Chapter 3',
          'url':
              'https://archiveofourown.org/works/34813381/chapters/123456789',
        },
      ),
      Chapter(
        title: 'Chapter 4',
        content: chapterContent,
        metadata: {
          'title': '4. Chapter 4',
          'url':
              'https://archiveofourown.org/works/34813381/chapters/123456789',
        },
      ),
    ],
    metadata: FanficMetadata(
      title: 'whatever this is, it isn\'t love',
      authors: [
        {
          'name': 'nploetz049',
          'url': 'https://archiveofourown.org/users/nploetz049',
        },
        {
          'name': 'nikki',
          'url': 'https://archiveofourown.org/users/nikki',
        }
      ],
      summary:
          'It was supposed to be easy. They were supposed to have fun in the scant handful of hours Camila had between work and parenting Luz. There wasn\'t supposed to be any feelings.\n\nSo why did Camila\'s heart race every time she thought of Eda?',
      extraData: {
        'source': {
          'url': 'https://archiveofourown.org/works/34813381',
        },
        'fandoms': [
          {
            'name': 'The Owl House',
            'url': 'https://archiveofourown.org/tags/The%20Owl%20House/works',
          }
        ],
        'series': {
          'name': 'whatever this is',
          'index': 2,
          'url': 'https://archiveofourown.org/series/3120495',
        },
        'published': DateTime(2021, 10, 31),
        'updated': DateTime(2023, 01, 01),
        'language': 'English',
        'characters': [
          {
            'name': 'Camila Noceda',
            'url': 'https://archiveofourown.org/tags/Camila%20Noceda/works',
          },
          {
            'name': 'Eda Clawthorne',
            'url': 'https://archiveofourown.org/tags/Eda%20Clawthorne/works',
          }
        ],
        'relationships': [
          {
            'name': 'Eda Clawthorne/Camila Noceda',
            'url':
                'https://archiveofourown.org/tags/Eda%20Clawthorne*s*Camila%20Noceda/works',
          }
        ],
        'additionalTags': [
          {
            'name': 'Friends with Benefits',
            'url':
                'https://archiveofourown.org/tags/Friends%20with%20Benefits/works',
          },
          {
            'name': 'Slow Burn',
            'url': 'https://archiveofourown.org/tags/Slow%20Burn/works',
          }
        ],
        'rating': 'Explicit',
        'status': 'Complete',
        'words': '296,615',
        'chapters': '59/59',
      },
    ),
  );
  var bookPath = '$outputFolder/test';
  await writer.write(filePath: bookPath);
}
