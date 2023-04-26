// ignore_for_file: non_constant_identifier_names
import 'package:archive/archive_io.dart';
import '../base_writer.dart';
import 'epub_formatter.dart';
import 'package:universal_io/io.dart';
import 'package:xml/xml.dart';

class EpubWriter extends BaseWriter {
  EpubFormatter formatter = EpubFormatter();
  String fileName = '';
  bool writeLog = false;

  EpubWriter({
    this.fileName = '',
    this.writeLog = false,
  }) : super('epub', '.epub') {
    // #region Epub Markers
    // #endregion Epub Markers
    if (fileName.isNotEmpty) {
      fileName = fileName.substring(0, fileName.lastIndexOf('.'));
    }
    // Aliases
    addAlias('publication', 'published');
    addAlias('modification', 'updated');
    addAlias('description', 'summary');
    addAlias('subjects', 'fandoms');
    addAlias('source', 'url');
  }

  // #region Logging
  void writeLogPage(dynamic out) {
    final String START = hasConfig('logpage_start')
        ? getConfig('logpage_start')
        : formatter.getLogPageStartTemplate();
    final String END = hasConfig('logpage_end')
        ? getConfig('logpage_end')
        : formatter.getLogPageEndTemplate();

    if (book!.logData.isNotEmpty) {
      // Log data exists, append to it
      final replaceString = '</body>';
      // write(
      //     out /*,
      //     book.logData.replaceAll(
      //       replaceString,
      //       makeLogEntry(data: getLastLogData(book.logData)) + replaceString,
      //     )*/
      //     );
    } else {
      // No log data, write a new page
      //write(out, formatter.getLogPageStartTemplate().formatMap(book.getAllMetadata()));
      //write(out, makeLogEntry());
      //write(out, formatter.getLogPageEndTemplate().formatMap(book.getAllMetadata()));
    }
  }

  @override
  Map<String, dynamic> getLastLogData(String logFile) {
    return {};
  }

  @override
  String makeLogEntry({Map<String, dynamic> data = const {}}) {
    return '';
  }
  // #endregion Logging

  @override
  Future<void> write({String filePath = ''}) async {
    if (filePath.isNotEmpty) {
      fileName = filePath;
    }
    // TODO: Write log files
    if (writeLog) {}
    // Write story
    await writeStory();
  }

  @override
  void writeSync({String filePath = ''}) {
    if (filePath.isNotEmpty) {
      fileName = filePath;
    }
    // TODO: Write log files
    if (writeLog) {}
    // Write story
    writeStorySync();
  }

  void writeStorySync() {
    // Create new zip file
    var encoder = ZipFileEncoder();
    encoder.create(getOutputFileName());
    // Create new epub directory
    final String epubDir = getBaseFileName();
    Directory epub = Directory(epubDir);
    epub.createSync();
    // Create mimetype file with content 'application/epub+zip'
    File mimetype = File('$epubDir/mimetype');
    mimetype.writeAsStringSync('application/epub+zip');
    encoder.addFile(mimetype);
    writeMetaINFSync(encoder, epubDir);
    // Create content.opf file
    writeContentSync(encoder, epubDir);
    // Create OEBPS
    writeOEBPSSync(encoder, epubDir);
    // Create TOC page
    writeTOCSync(encoder, epubDir);

    // Export final file
    encoder.close();
    // Delete temporary directory
    Directory(epubDir).deleteSync(recursive: true);
  }

  Future<void> writeStory() async {
    // Create new zip file
    var encoder = ZipFileEncoder();
    encoder.create(getOutputFileName());
    // Create new epub directory
    final String epubDir = getBaseFileName();
    Directory epub = Directory(epubDir);
    await epub.create();
    // Create mimetype file with content 'application/epub+zip'
    File mimetype = File('$epubDir/mimetype');
    await mimetype.writeAsString('application/epub+zip');
    await encoder.addFile(mimetype);
    await writeMetaINF(encoder, epubDir);
    // Create content.opf file
    await writeContent(encoder, epubDir);
    // Create OEBPS
    await writeOEBPS(encoder, epubDir);
    // Create TOC page
    await writeTOC(encoder, epubDir);

    // Export final file
    encoder.close();
    // Delete temporary directory
    //await Directory(epubDir).delete(recursive: true);
  }

  void writeMetaINFSync(ZipFileEncoder encoder, String epubDir) {
    // Create META-INF directory
    Directory metaInf = Directory('$epubDir/META-INF');
    metaInf.createSync();
    // Create container.xml file
    File container = File('$epubDir/META-INF/container.xml');
    XmlBuilder builder = XmlBuilder();
    builder.declaration(encoding: 'UTF-8');
    builder.element('container', nest: () {
      builder.attribute('version', '1.0');
      builder.attribute(
          'xmlns', 'urn:oasis:names:tc:opendocument:xmlns:container');
      builder.element('rootfiles', nest: () {
        builder.element('rootfile', nest: () {
          builder.attribute('full-path', 'content.opf');
          builder.attribute('media-type', 'application/oebps-package+xml');
        });
      });
    });
    container
        .writeAsStringSync(builder.buildDocument().toXmlString(pretty: true));
    encoder.addDirectory(metaInf);
  }

  Future<void> writeMetaINF(ZipFileEncoder encoder, String epubDir) async {
    // Create META-INF directory
    Directory metaInf = Directory('$epubDir/META-INF');
    await metaInf.create();
    // Create container.xml file
    File container = File('$epubDir/META-INF/container.xml');
    XmlBuilder builder = XmlBuilder();
    builder.declaration(encoding: 'UTF-8');
    builder.element('container', nest: () {
      builder.attribute('version', '1.0');
      builder.attribute(
          'xmlns', 'urn:oasis:names:tc:opendocument:xmlns:container');
      builder.element('rootfiles', nest: () {
        builder.element('rootfile', nest: () {
          builder.attribute('full-path', 'content.opf');
          builder.attribute('media-type', 'application/oebps-package+xml');
        });
      });
    });
    await container
        .writeAsString(builder.buildDocument().toXmlString(pretty: true));
    await encoder.addDirectory(metaInf);
  }

  void writeContentSync(ZipFileEncoder encoder, String epubDir) {
    if (book == null) {
      return;
    }
    String uniqueID =
        'epub-uid:${getMetadata('publisher')}-u${getMetadata('authorNames')[0]}-s${getMetadata('storyID')}';
    File content = File('$epubDir/content.opf');
    final builder = XmlBuilder();
    builder.declaration(encoding: 'UTF-8');
    builder.element('package', nest: () {
      builder.attribute('version', '2.0');
      builder.attribute('xmlns', 'http://www.idpf.org/2007/opf');
      builder.attribute('unique-identifier', 'epub-uid');
      // Metadata
      builder.element('metadata', nest: () {
        builder.attribute('xmlns:dc', 'http://purl.org/dc/elements/1.1/');
        builder.attribute('xmlns:opf', 'http://www.idpf.org/2007/opf');
        builder.attribute(
            'xmlns:calibre', 'http://calibre.kovidgoyal.net/2009/metadata');
        builder.element(
          'dc:identifier',
          attributes: {
            'id': 'epub-uid',
          },
          nest: uniqueID,
        );
        builder.element(
          'dc:title',
          attributes: {
            'id': 'id',
          },
          nest: getMetadata('title'),
        );
        builder.element(
          'dc:creator',
          attributes: {
            'opf:role': 'aut',
          },
          nest: getMetadata('authorNames'),
        );
        builder.element(
          'dc:language',
          nest: getMetadata('language'),
        );
        // publication
        builder.element(
          'dc:date',
          attributes: {
            'id': 'publication',
          },
          nest: getMetadata('publication'),
        );
        // creation
        // yyyy-mm-dd
        String today = DateTime.now().toString().substring(0, 10);
        builder.element(
          'dc:date',
          attributes: {
            'id': 'creation',
          },
          nest: today,
        );
        // modification
        builder.element(
          'dc:date',
          attributes: {
            'id': 'modification',
          },
          nest: getMetadata('modification'),
        );
        // calibre:timestamp
        String modification = getMetadata('modification').toString();
        modification = '${modification}T00:00:00';
        builder.element(
          'meta',
          attributes: {
            'name': 'calibre:timestamp',
            'content': modification,
          },
        );
        // description
        builder.element(
          'dc:description',
          nest: getMetadata('summary'),
        );
        // subject
        builder.element(
          'dc:subject',
          nest: getMetadata('subject'),
        );
        // publisher
        builder.element(
          'dc:publisher',
          nest: getMetadata('publisher'),
        );
        // identifier
        builder.element(
          'dc:identifier',
          attributes: {
            'opf:scheme': 'URL',
          },
          nest: getMetadata('url'),
        );
        // source
        builder.element(
          'dc:source',
          nest: getMetadata('url'),
        );
      });
      // Manifest
      builder.element('manifest', nest: () {
        // TOC
        builder.element('item', nest: () {
          builder.attribute('id', 'ncx');
          builder.attribute('href', 'toc.ncx');
          builder.attribute('media-type', 'application/x-dtbncx+xml');
        });
        // Style
        builder.element('item', nest: () {
          builder.attribute('id', 'style');
          builder.attribute('href', 'OEBPS/stylesheet.css');
          builder.attribute('media-type', 'text/css');
        });
        // Title page
        builder.element('item', nest: () {
          builder.attribute('id', 'title_page');
          builder.attribute('href', 'OEBPS/title_page.xhtml');
          builder.attribute('media-type', 'application/xhtml+xml');
        });
        // Chapters
        for (int i = 0; i < book!.chapters.length; i++) {
          String index = (i + 1).toString().padLeft(4, '0');
          builder.element('item', nest: () {
            builder.attribute('id', 'file$index');
            builder.attribute('href', 'OEBPS/file$index.xhtml');
            builder.attribute('media-type', 'application/xhtml+xml');
          });
        }
      });
      // Spine
      builder.element('spine', nest: () {
        builder.attribute('toc', 'ncx');
        builder.element('itemref', nest: () {
          builder.attribute('idref', 'title_page');
          builder.attribute('linear', 'yes');
        });
        for (int i = 0; i < book!.chapters.length; i++) {
          String index = (i + 1).toString().padLeft(4, '0');
          builder.element('itemref', nest: () {
            builder.attribute('idref', 'file$index');
            builder.attribute('linear', 'yes');
          });
        }
      });
    });
    content
        .writeAsStringSync(builder.buildDocument().toXmlString(pretty: true));
    encoder.addFile(content);
  }

  Future<void> writeContent(ZipFileEncoder encoder, String epubDir) async {
    if (book == null) {
      return;
    }
    File content = File('$epubDir/content.opf');
    final builder = XmlBuilder();
    builder.declaration(encoding: 'UTF-8');
    builder.element('package', nest: () {
      builder.attribute('version', '2.0');
      builder.attribute('xmlns', 'http://www.idpf.org/2007/opf');
      builder.attribute('unique-identifier', 'epub-uid');
      // Metadata
      builder.element('metadata', nest: () {
        builder.attribute('xmlns:dc', 'http://purl.org/dc/elements/1.1/');
        builder.attribute('xmlns:opf', 'http://www.idpf.org/2007/opf');
        builder.attribute(
            'xmlns:calibre', 'http://calibre.kovidgoyal.net/2009/metadata');
        // unique-identifier
        builder.comment('Unique ID');
        builder.element(
          'dc:identifier',
          attributes: {
            'id': 'epub-uid',
          },
          nest: book?.metadata?['uid'] ?? '',
        );
        // Publisher
        builder.element(
          'dc:publisher',
          attributes: {
            'href': getMetadata('publisher.url'),
            'id': getMetadata('publisher.id'),
          },
          nest: getMetadata('publisher.name'),
        );
        // Title
        builder.comment('Title');
        builder.element(
          'dc:title',
          attributes: {
            'id': 'id',
          },
          nest: getMetadata('title'),
        );
        // Authors
        builder.comment('Authors');
        // Build author names string
        String authorNames = '';
        final authors = getMetadata('authorNames');
        for (int i = 0; i < authors.length; i++) {
          authorNames += authors[i];
          if (i < authors.length - 2) {
            authorNames += ', ';
          } else if (i < authors.length - 1) {
            authorNames += ' & ';
          }
        }
        // Add author names
        builder.element(
          'dc:creator',
          attributes: {
            'opf:role': 'aut',
            'id': 'authors',
          },
          nest: authorNames,
        );
        // Add author metadata
        for (Map<String, String> author in getMetadata('authors')) {
          builder.element(
            'meta',
            attributes: {
              'refines': '#authors',
              'id': 'author_${getMetadata('authors').indexOf(author) + 1}',
            },
            nest: () {
              builder.element(
                'name',
                nest: author['name'],
              );
              builder.element(
                'url',
                nest: author['url'],
              );
            },
          );
        }
        // Description
        builder.comment('Description');
        builder.element(
          'dc:description',
          nest: getMetadata('description').replaceAll('\n', '&lt;br/&gt;'),
        );
        // Source
        builder.comment('Source');
        builder.element(
          'dc:source',
          nest: getMetadata('source.url'),
        );
        // Subjects
        builder.comment('Subjects');
        final subjects = getMetadata('subjects');
        for (final subject in subjects) {
          if (subject is String) {
            builder.element(
              'dc:subject',
              nest: subject,
            );
          } else {
            builder.element(
              'dc:subject',
              attributes: {
                'opf:url': subject['url'],
              },
              nest: subject['name'],
            );
          }
        }
        // Series
        if (getMetadata('series') != null) {
          builder.comment('Series');
          builder.element(
            'meta',
            attributes: {
              'name': 'calibre:series',
              'id': 'series',
              'content': getMetadata('series.name'),
            },
          );
          builder.element(
            'meta',
            attributes: {
              'name': 'calibre:series_index',
              'id': 'series_index',
              'content': getMetadata('series.index').toString(),
            },
          );
          builder.element(
            'meta',
            attributes: {
              'name': 'calibre:series_url',
              'id': 'series_url',
              'content': getMetadata('series.url'),
            },
          );
        }
        // Published
        builder.comment('Published');
        builder.element(
          'dc:date',
          attributes: {
            'id': 'publication',
          },
          nest: getMetadata('publication').toString().substring(0, 10),
        );
        // Updated
        builder.comment('Updated');
        String modification =
            getMetadata('modification').toString().substring(0, 10);
        builder.element(
          'dc:date',
          attributes: {
            'id': 'modification',
          },
          nest: modification,
        );
        builder.element(
          'meta',
          attributes: {
            'name': 'calibre:timestamp',
            'content': '${modification}T00:00:00',
          },
        );
        // Creation
        builder.comment('Creation');
        builder.element(
          'dc:date',
          attributes: {
            'id': 'creation',
          },
          nest: DateTime.now().toString().substring(0, 10),
        );
        // Language
        builder.comment('Language');
        builder.element(
          'dc:language',
          nest: getMetadata('language'),
        );
        // Rating
        builder.comment('Rating');
        builder.element(
          'meta',
          attributes: {
            'name': 'rating',
            'content': getMetadata('rating').toString(),
          },
        );
        // Status
        builder.comment('Status');
        builder.element(
          'meta',
          attributes: {
            'name': 'calibre:status',
            'content': getMetadata('status'),
          },
        );
        // Words
        builder.comment('Words');
        builder.element(
          'meta',
          attributes: {
            'name': 'calibre:words',
            'content': getMetadata('words').toString().replaceAll(',', ''),
          },
        );
        // Chapter Count
        builder.comment('Chapters');
        builder.element(
          'meta',
          attributes: {
            'name': 'calibre:chapters',
            'content': getMetadata('chapters').toString().split('/').last,
          },
        );
      });
      // Manifest
      builder.element('manifest', nest: () {
        // TOC
        builder.element('item', nest: () {
          builder.attribute('id', 'ncx');
          builder.attribute('href', 'toc.ncx');
          builder.attribute('media-type', 'application/x-dtbncx+xml');
        });
        // Style
        builder.element('item', nest: () {
          builder.attribute('id', 'style');
          builder.attribute('href', 'OEBPS/stylesheet.css');
          builder.attribute('media-type', 'text/css');
        });
        // Title page
        builder.element('item', nest: () {
          builder.attribute('id', 'title_page');
          builder.attribute('href', 'OEBPS/title_page.xhtml');
          builder.attribute('media-type', 'application/xhtml+xml');
        });
        // Chapters
        for (int i = 0; i < book!.chapters.length; i++) {
          String index = (i + 1).toString().padLeft(4, '0');
          builder.element('item', nest: () {
            builder.attribute('id', 'file$index');
            builder.attribute('href', 'OEBPS/file$index.xhtml');
            builder.attribute('media-type', 'application/xhtml+xml');
          });
        }
      });
      // Spine
      builder.element('spine', nest: () {
        builder.attribute('toc', 'ncx');
        builder.element('itemref', nest: () {
          builder.attribute('idref', 'title_page');
          builder.attribute('linear', 'yes');
        });
        for (int i = 0; i < book!.chapters.length; i++) {
          String index = (i + 1).toString().padLeft(4, '0');
          builder.element('itemref', nest: () {
            builder.attribute('idref', 'file$index');
            builder.attribute('linear', 'yes');
          });
        }
      });
    });
    await content
        .writeAsString(builder.buildDocument().toXmlString(pretty: true));
    await encoder.addFile(content);
  }

  void writeOEBPSSync(ZipFileEncoder encoder, String epubDir) {
    final oebpsPath = '$epubDir/OEBPS';

    // Create OEBPS directory
    final Directory oebpsDir = Directory(oebpsPath);
    oebpsDir.createSync();

    // Write stylesheet
    if (formatter.useStylesheetFile) {
      // Copy stylesheet file to OEBPS directory
      File stylesheet = File(formatter.stylesheetPath);
      stylesheet.copySync('$oebpsPath/stylesheet.css');
    } else {
      // Use stylesheet format and fill out with metadata
      File stylesheet = File('$oebpsPath/stylesheet.css');
      stylesheet.writeAsStringSync(formatter
          .processStylesheet(book!.metadata!.getAllData()['output_css']));
    }

    writeTitlePageSync(encoder, oebpsPath);

    // Write chapters
    // Loop through book.chapters
    for (int i = 0; i < book!.chapters.length; i++) {
      final chapter = book!.chapters[i];
      String index = (i + 1).toString().padLeft(4, '0');
      File chapterFile = File('$oebpsPath/file$index.xhtml');
      chapterFile.writeAsStringSync(
        formatter.processChapter(chapter.getAllMetadata(), chapter.content),
      );
    }

    // Write OEBPS directory
    encoder.addDirectory(oebpsDir);
  }

  Future<void> writeOEBPS(ZipFileEncoder encoder, String epubDir) async {
    final oebpsPath = '$epubDir/OEBPS';

    // Create OEBPS directory
    final Directory oebpsDir = Directory(oebpsPath);
    await oebpsDir.create();

    // Write stylesheet
    if (formatter.useStylesheetFile) {
      // Copy stylesheet file to OEBPS directory
      File stylesheet = File(formatter.stylesheetPath);
      await stylesheet.copy('$oebpsPath/stylesheet.css');
    } else {
      // Use stylesheet format and fill out with metadata
      File stylesheet = File('$oebpsPath/stylesheet.css');
      await stylesheet.writeAsString(
          formatter.processStylesheet(formatter.stylesheetContent));
    }

    await writeTitlePage(encoder, oebpsPath);

    // Write chapters
    // Loop through book.chapters
    for (int i = 0; i < book!.chapters.length; i++) {
      final chapter = book!.chapters[i];
      String index = (i + 1).toString().padLeft(4, '0');
      File chapterFile = File('$oebpsPath/file$index.xhtml');
      await chapterFile.writeAsString(
        formatter.processChapter(chapter.getAllMetadata(), chapter.content),
      );
    }

    // Write OEBPS directory
    await encoder.addDirectory(oebpsDir);
  }

  void writeTitlePageSync(ZipFileEncoder encoder, String oebpsPath) {
    // Write title page
    File titlePage = File('$oebpsPath/title_page.xhtml');
    final metadata = book!.metadata!.getAllData();
    titlePage.writeAsStringSync(
      formatter.processTitlePageStart({
        'title': metadata['title'],
        'titleHTML': metadata['titleHTML'],
        'authorNames': metadata['authorNames'].join(', '),
        'authors': metadata['authorNames'].join(', '),
        'authorHTML': metadata['authorHTML'],
      }),
    );

    final titleOrder = book!.metadata!.getExtraTitleEntries();

    for (final title in titleOrder) {
      if (title.isEmpty) continue;
      bool useLabel = title['label'] != null && title['label']!.isNotEmpty;
      titlePage.writeAsStringSync(
        formatter.processTitleEntry({
          'label': title['label'],
          'value': '${title['value']}\n'.replaceAll('\n', '<br/>  '),
          'id': title['label'].toString().toLowerCase().replaceAll(' ', '_'),
        }, useLabel: useLabel),
        mode: FileMode.append,
      );
    }

    titlePage.writeAsStringSync(
      formatter.processTitlePageEnd(
        book!.metadata!.getAllData(),
      ),
      mode: FileMode.append,
    );
  }

  Future<void> writeTitlePage(ZipFileEncoder encoder, String oebpsPath) async {
    // Write title page
    File titlePage = File('$oebpsPath/title_page.xhtml');
    final metadata = book!.metadata!.getAllData();
    await titlePage.writeAsString(
      formatter.processTitlePageStart({
        'title': metadata['title'],
        'titleHTML': metadata['titleHTML'],
        'authors': metadata['authorNames'].join(', '),
        'authorHTML': metadata['authorHTML'],
      }),
    );

    final titleOrder = book!.metadata!.getExtraTitleEntries();

    for (final title in titleOrder) {
      if (title.isEmpty) continue;
      bool useLabel = title['label'] != null && title['label']!.isNotEmpty;
      await titlePage.writeAsString(
        formatter.processTitleEntry({
          'label': title['label'],
          'value': '${title['value']}\n'.replaceAll('\n', '<br/>  '),
          'id': title['label'].toString().toLowerCase().replaceAll(' ', '_'),
        }, useLabel: useLabel),
        mode: FileMode.append,
      );
    }

    await titlePage.writeAsString(
      formatter.processTitlePageEnd(
        book!.metadata!.getAllData(),
      ),
      mode: FileMode.append,
    );
  }

  void writeTOCSync(ZipFileEncoder encoder, String epubDir) {
    // Skip if only one chapter
    if (book!.chapters.length == 1) return;
    // Create TOC file
    File tocFile = File('$epubDir/toc.ncx');
    tocFile.writeAsStringSync(
        formatter.processTOCPageStart(book!.metadata!.getAllData()));
    // Add title page
    tocFile.writeAsStringSync(
      formatter.processTOCEntry(
        {
          'id': 'title_page',
          'order': '0',
          'src': 'OEBPS/title_page.xhtml',
          'title': 'Title Page',
        },
      ),
      mode: FileMode.append,
    );
    // Loop through book.chapters
    for (int i = 0; i < book!.chapters.length; i++) {
      final chapter = book!.chapters[i];
      String index = (i + 1).toString().padLeft(4, '0');
      Map<String, dynamic> chapterMetadata = {
        'id': 'file$index',
        'order': '${i + 1}',
        'src': 'OEBPS/file$index.xhtml',
        ...chapter.getAllMetadata(),
      };
      tocFile.writeAsStringSync(
        formatter.processTOCEntry(
          chapterMetadata,
        ),
        mode: FileMode.append,
      );
    }
    tocFile.writeAsStringSync(
      formatter.processTOCPageEnd(book!.metadata!.getAllData()),
      mode: FileMode.append,
    );
    encoder.addFile(tocFile);
  }

  Future<void> writeTOC(ZipFileEncoder encoder, String epubDir) async {
    // Skip if only one chapter
    if (book!.chapters.length == 1) return;
    // Create TOC file
    File tocFile = File('$epubDir/toc.ncx');
    await tocFile.writeAsString(
        formatter.processTOCPageStart(book!.metadata!.getAllData()));
    // Add title page
    await tocFile.writeAsString(
      formatter.processTOCEntry(
        {
          'id': 'title_page',
          'order': '0',
          'src': 'OEBPS/title_page.xhtml',
          'title': 'Title Page',
        },
      ),
      mode: FileMode.append,
    );
    // Loop through book.chapters
    for (int i = 0; i < book!.chapters.length; i++) {
      final chapter = book!.chapters[i];
      String index = (i + 1).toString().padLeft(4, '0');
      Map<String, dynamic> chapterMetadata = {
        'id': 'file$index',
        'order': '${i + 1}',
        'src': 'OEBPS/file$index.xhtml',
        ...chapter.getAllMetadata(),
      };
      await tocFile.writeAsString(
        formatter.processTOCEntry(
          chapterMetadata,
        ),
        mode: FileMode.append,
      );
    }
    await tocFile.writeAsString(
      formatter.processTOCPageEnd(book!.metadata!.getAllData()),
      mode: FileMode.append,
    );
    await encoder.addFile(tocFile);
  }

  @override
  String getOutputFileName() {
    return '$fileName$formatExt';
  }

  @override
  String getBaseFileName() {
    return fileName;
  }
}
