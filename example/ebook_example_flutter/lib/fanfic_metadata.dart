import 'package:ebook/ebook.dart';
import 'package:intl/intl.dart';

class FanficMetadata extends Metadata {
  FanficMetadata({
    String title = '',
    List<dynamic> authors = const [],
    String summary = '',
    Map<String, dynamic> extraData = const {},
    String uidTemplate =
        '''fanfic-uid:{this['publisher']}-{this['source']['id']}''',
  }) : super(
          title: title,
          authors: authors,
          summary: summary,
          extraData: extraData,
          uidTemplate: uidTemplate,
        ) {
    if (!this['source'].containsKey('id')) {
      this['source']['id'] = this['source']['url'].split('/').last;
    }
    if (!extraData.containsKey('publisher')) {
      this['publisher'] = 'ao3';
    }
    this['uid'] = 'fanfic-uid:${this['publisher']}-${this['source']['id']}';
  }

  @override
  List<Map<String, dynamic>> getExtraTitleEntries() {
    final List<Map<String, dynamic>> extraTitleEntries = [];

    // Series
    if (this['series'] != null) {
      if (this['series'] is List) {
        extraTitleEntries.add({
          'label': 'Series',
          'value': this['series']
              .map((series) =>
                  'Part ${series['index']} of <a href="${series['url']}">${series['name']}</a>')
              .join('<br/>  '),
        });
      } else {
        extraTitleEntries.add({
          'label': 'Series',
          'value':
              'Part ${this['series']['index']} of <a href="${this['series']['url']}">${this['series']['name']}</a>',
        });
      }
    }
    // Fandom(s)
    if (this['fandoms'] != null) {
      extraTitleEntries.add({
        'label': 'Fandom(s)',
        'value':
            '${this['fandoms'].map((fandom) => '<a href="${fandom['url']}">${fandom['name']}</a>').join(', ')}',
      });
    }
    // Characters
    if (this['characters'] != null) {
      extraTitleEntries.add({
        'label': 'Characters',
        'value':
            '${this['characters'].map((character) => '<a href="${character['url']}">${character['name']}</a>').join(', ')}',
      });
    }
    // Relationships
    if (this['relationships'] != null) {
      extraTitleEntries.add({
        'label': 'Relationships',
        'value':
            '${this['relationships'].map((relationship) => '<a href="${relationship['url']}">${relationship['name']}</a>').join(', ')}',
      });
    }
    // Additional Tags
    if (this['additionalTags'] != null) {
      extraTitleEntries.add({
        'label': 'Additional Tags',
        'value':
            '${this['additionalTags'].map((tag) => '<a href="${tag['url']}">${tag['name']}</a>').join(', ')}',
      });
    }
    // Language
    if (this['language'] != null) {
      extraTitleEntries.add({
        'label': 'Language',
        'value': this['language'],
      });
    }
    // Published
    DateFormat dateFormat = DateFormat('MMMM d, yyyy');
    if (this['published'] != null) {
      extraTitleEntries.add({
        'label': 'Published',
        'value': dateFormat.format(this['published']),
      });
    }
    // Updated/Completed
    if (this['updated'] != null) {
      extraTitleEntries.add({
        'label': this['status'] == 'complete' ? 'Completed' : 'Updated',
        'value': dateFormat.format(this['updated']),
      });
    }
    // Words
    if (this['words'] != null) {
      extraTitleEntries.add({
        'label': 'Words',
        'value': this['words'].toString(),
      });
    }
    // Chapters
    if (this['chapters'] != null) {
      extraTitleEntries.add({
        'label': 'Chapters',
        'value': this['chapters'].toString(),
      });
    }

    // Append super entries
    extraTitleEntries.addAll(super.getExtraTitleEntries());

    return extraTitleEntries;
  }
}
