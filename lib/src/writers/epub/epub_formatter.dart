// ignore_for_file: non_constant_identifier_names

import '../../utils/template_string.dart';

class EpubFormatter {
  bool useStylesheetFile;
  String stylesheetPath;
  String stylesheetContent;
  bool useTableForTitlePage;
  bool writeChapterStart;
  bool writeChapterEnd;

  // #region Epub Markers
  final _EPUB_STYLESHEET_TEMPLATE = '''{output_css}''';
  final _EPUB_TITLE_PAGE_START_TEMPLATE = '''
<?xml version="1.0" encoding="UTF-8"?>
<html xmlns="http://www.w3.org/1999/xhtml">
  <head>
    <title>{title} by {authorNames}</title>
    <link href="stylesheet.css" type="text/css" rel="stylesheet"/>
  </head>
  <body class="epub_titlepage">
    <h3>
      {titleHTML}
      <br/>
      by
      <br/>
      {authorHTML}
    </h3>

    <div>
      <dl class="tags">
''';
  final _EPUB_TITLE_ENTRY_TEMPLATE = '''
        <dt class="calibre3">{label}:</dt>
        <dd id="{id}" class="calibre4">{value}</dd>
''';
  final _EPUB_NO_TITLE_ENTRY_TEMPLATE = '''
        <dt class="calibre1">{value}</dt>
''';
  final _EPUB_TITLE_PAGE_END_TEMPLATE = '''
      </dl>
    </div>
  </body>
</html>
''';
  final _EPUB_TABLE_TITLE_PAGE_START_TEMPLATE = '''
<?xml version="1.0" encoding="UTF-8"?>
<html xmlns="http://www.w3.org/1999/xhtml">
  <head>
    <title>{title} by {authorNames}</title>
    <link href="stylesheet.css" type="text/css" rel="stylesheet"/>
  </head>
  <body class="epub_titlepage">
    <h3>
      {titleHTML}
      <br/>
      by
      <br/>
      {authorHTML}
    </h3>
    <div>
      <table>
''';
  final _EPUB_TABLE_TITLE_ENTRY_TEMPLATE = '''
        <tr>
          <td>
            <b>{label}:</b>
          </td>
          <td>{value}</td>
        </tr>
''';
  final _EPUB_TABLE_NO_TITLE_ENTRY_TEMPLATE = '''
        <tr>
          <td/>
          <td>{value}</td>
        </tr>
''';
  final _EPUB_TABLE_TITLE_PAGE_END_TEMPLATE = '''
      </table>
    </div>
  </body>
</html>
''';
  final _EPUB_TOC_PAGE_START_TEMPLATE = '''
<?xml version="1.0" encoding="UTF-8"?>
<ncx version="2005-1" xmlns="http://www.daisy.org/z3986/2005/ncx/">
  <head>
    <meta name="dtb:uid" content="{uid}"/>
    <meta name="dtb:depth" content="1"/>
    <meta name="dtb:totalPageCount" content="0"/>
    <meta name="dtb:maxPageNumber" content="0"/>
  </head>
  <docTitle>
    <text>{title}</text>
  </docTitle>
  <navMap>
''';
  final _EPUB_TOC_ENTRY_TEMPLATE = '''
    <navPoint id="{id}" playOrder="{order}">
      <navLabel>
        <text>{title}</text>
      </navLabel>
      <content src="{src}"/>
    </navPoint>
''';
  final _EPUB_TOC_PAGE_END_TEMPLATE = '''
  </navMap>
</ncx>
''';
  final _EPUB_CHAPTER_START_TEMPLATE = '''
<?xml version="1.0" encoding="UTF-8"?>
<html xmlns="http://www.w3.org/1999/xhtml">
  <head>
    <title>{title}</title>
    <link href="stylesheet.css" type="text/css" rel="stylesheet"/>
    <meta name="chapter_url" content="{url}" />
    <meta name="chapter_orig_title" content="{title}" />
    <meta name="chapter_toc_title" content="{title}" />
    <meta name="chapter_title" content="{title}" />
  </head>
  <body class="epub_chapter">
    <h3 class="epub_chapter_title">{title}</h3>
''';
  final _EPUB_CHAPTER_END_TEMPLATE = '''
    </div>
  </body>
</html>
''';
  final _EPUB_LOG_PAGE_START_TEMPLATE = '''
<?xml version="1.0" encoding="UTF-8"?>
<html xmlns="http://www.w3.org/1999/xhtml">
  <head>
    <title>Update Log</title>
    <link href="stylesheet.css" type="text/css" rel="stylesheet"/>
  </head>
  <body class="epub_logpage">
    <h3>Update Log</h3>
''';
  final _EPUB_LOG_UPDATE_START_TEMPLATE = '''
      <p class="log_entry">
''';
  final _EPUB_LOG_ENTRY_TEMPLATE = '''
        <b>{label}:</b>
        <span id="{id}">{value}</span>
''';
  final _EPUB_LOG_UPDATE_END_TEMPLATE = '''
      </p>
      <hr/>
''';
  final _EPUB_LOG_PAGE_END_TEMPLATE = '''
  </body>
</html>
''';
  final _EPUB_COVER_TEMPLATE = '''
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en">
  <head>
    <title>Cover</title>
    <style type="text/css" title="override_css">
      @page {
        padding: 0pt; 
        margin: 0pt
      }
      body { 
        text-align: center; 
        padding: 0pt; 
        margin: 0pt; 
      }
      div { 
        margin: 0pt; 
        padding: 0pt; 
      }
    </style>
  </head>
  <body class="epub_coverpage">
    <div>
      <img src="{coverimg}" alt="cover"/>
    </div>
  </body>
</html>
''';
  // #endregion Epub Markers

  EpubFormatter({
    this.useStylesheetFile = false,
    this.stylesheetPath = '',
    this.stylesheetContent = '',
    this.useTableForTitlePage = false,
    this.writeChapterStart = true,
    this.writeChapterEnd = true,
  });

  // stylesheet.css
  String getStylesheetTemplate() {
    return _EPUB_STYLESHEET_TEMPLATE;
  }

  void setStylesheetFile(String filePath) {
    stylesheetPath = filePath;
    useStylesheetFile = true;
  }

  void setStylesheetContent(String content) {
    stylesheetContent = content;
    useStylesheetFile = false;
  }

  String processStylesheet(String content) {
    return _EPUB_STYLESHEET_TEMPLATE.format([content]);
  }

  // title_page.xhtml
  String getTitlePageStartTemplate() {
    return useTableForTitlePage
        ? _EPUB_TABLE_TITLE_PAGE_START_TEMPLATE
        : _EPUB_TITLE_PAGE_START_TEMPLATE;
  }

  String processTitlePageStart(Map<String, dynamic> data) {
    return getTitlePageStartTemplate().formatMap(data);
  }

  String getTitleEntryTemplate({bool useLabel = false}) {
    return useLabel
        ? (useTableForTitlePage
            ? _EPUB_TABLE_TITLE_ENTRY_TEMPLATE
            : _EPUB_TITLE_ENTRY_TEMPLATE)
        : (useTableForTitlePage
            ? _EPUB_TABLE_NO_TITLE_ENTRY_TEMPLATE
            : _EPUB_NO_TITLE_ENTRY_TEMPLATE);
  }

  String processTitleEntry(Map<String, dynamic> data, {bool useLabel = false}) {
    return getTitleEntryTemplate(useLabel: useLabel).formatMap(data);
  }

  String getTitlePageEndTemplate() {
    return useTableForTitlePage
        ? _EPUB_TABLE_TITLE_PAGE_END_TEMPLATE
        : _EPUB_TITLE_PAGE_END_TEMPLATE;
  }

  String processTitlePageEnd(Map<String, dynamic> data) {
    return getTitlePageEndTemplate().formatMap(data);
  }

  // toc.ncx
  String getTOCPageStartTemplate() {
    return _EPUB_TOC_PAGE_START_TEMPLATE;
  }

  String processTOCPageStart(Map<String, dynamic> data) {
    return getTOCPageStartTemplate().formatMap(data);
  }

  String getTOCEntryTemplate() {
    return _EPUB_TOC_ENTRY_TEMPLATE;
  }

  String processTOCEntry(Map<String, dynamic> data) {
    return getTOCEntryTemplate().formatMap(data);
  }

  String getTOCPageEndTemplate() {
    return _EPUB_TOC_PAGE_END_TEMPLATE;
  }

  String processTOCPageEnd(Map<String, dynamic> data) {
    return getTOCPageEndTemplate().formatMap(data);
  }

  // chapter_x.html
  String getChapterStartTemplate() {
    return writeChapterStart ? _EPUB_CHAPTER_START_TEMPLATE : '';
  }

  String processChapterStart(Map<String, dynamic> data) {
    return getChapterStartTemplate().formatMap(data);
  }

  String getChapterEndTemplate() {
    return writeChapterEnd ? _EPUB_CHAPTER_END_TEMPLATE : '';
  }

  String processChapterEnd(Map<String, dynamic> data) {
    return getChapterEndTemplate().formatMap(data);
  }

  String processChapter(Map<String, dynamic> data, String content) {
    return processChapterStart(data) + content + processChapterEnd(data);
  }

  // log.xhtml
  String getLogPageStartTemplate() {
    return _EPUB_LOG_PAGE_START_TEMPLATE;
  }

  String processLogPageStart(Map<String, dynamic> data) {
    return getLogPageStartTemplate().formatMap(data);
  }

  String getLogUpdateStartTemplate() {
    return _EPUB_LOG_UPDATE_START_TEMPLATE;
  }

  String processLogUpdateStart(Map<String, dynamic> data) {
    return getLogUpdateStartTemplate().formatMap(data);
  }

  String getLogEntryTemplate() {
    return _EPUB_LOG_ENTRY_TEMPLATE;
  }

  String processLogEntry(Map<String, dynamic> data) {
    return getLogEntryTemplate().formatMap(data);
  }

  String getLogUpdateEndTemplate() {
    return _EPUB_LOG_UPDATE_END_TEMPLATE;
  }

  String processLogUpdateEnd() {
    return getLogUpdateEndTemplate();
  }

  String getLogPageEndTemplate() {
    return _EPUB_LOG_PAGE_END_TEMPLATE;
  }

  String processLogPageEnd() {
    return getLogPageEndTemplate();
  }

  // cover.xhtml
  String getCoverTemplate() {
    return _EPUB_COVER_TEMPLATE;
  }

  String processCover(Map<String, dynamic> data) {
    return getCoverTemplate().formatMap(data);
  }
}
