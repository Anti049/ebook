import 'package:ebook/ebook.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:universal_io/io.dart';

import 'fanfic_data.dart';
import 'fanfic_metadata.dart';

class WritePage extends StatefulWidget {
  const WritePage({super.key});

  @override
  State<WritePage> createState() => _WritePageState();
}

class _WritePageState extends State<WritePage> {
  EpubWriter writer = EpubWriter();

  void setup() async {
    Directory? test = await getLibraryDirectory();
    writer.fileName = '${test?.path}/test.epub';
    writer.formatter.useStylesheetFile = false;
    writer.formatter.stylesheetContent =
        await rootBundle.loadString('assets/ao3.css');
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
          }
        ],
        summary:
            'It was supposed to be easy. They were supposed to have fun in the scant handful of hours Camila had between work and parenting Luz. There wasn\'t supposed to be any feelings.\n\nSo why did Camila\'s heart race every time she thought of Eda?',
        extraData: {
          'source': {
            'url': 'https://archiveofourown.org/works/34813381',
          },
          'series': {
            'name': 'whatever this is',
            'index': 2,
            'url': 'https://archiveofourown.org/series/3120495',
          },
          'published': DateTime(2021, 10, 31),
          'updated': DateTime(2023, 01, 01),
          'language': 'English',
          'fandoms': [
            {
              'name': 'The Owl House',
              'url': 'https://archiveofourown.org/tags/The%20Owl%20House/works',
            }
          ],
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
    await writer.write();
  }

  void writeBook() {}

  @override
  void initState() {
    super.initState();
    setup();
  }

  @override
  Widget build(BuildContext context) {
    String text = 'Write';
    if (writer.book != null) {
      if (writer.book!.metadata != null) {
        text = writer.book!.metadata!.title;
      }
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(text),
      ),
    );
  }
}
