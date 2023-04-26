class Chapter {
  String title;
  String content;
  Map<String, dynamic> metadata = {};

  /// Creates a new Chapter object using [title] to describe the chapter, [content] to contain the data for the chapter, and [metadata] to contain any extra data.
  /// - [title] can be any string.
  /// - [content] can be an HTML string.
  /// - [metadata] can be any map of data
  ///   - MUST include:
  ///     - 'title': The chapter's title (will be taken from [title] parameter if unspecified).
  ///   - CAN include:
  ///     - 'id': The chapter's ID.
  ///     - 'url': The chapter's URL (if web-based).
  Chapter({this.title = '', this.content = '', this.metadata = const {}}) {
    if (!metadata.containsKey('title')) {
      metadata['title'] = title;
    }
  }

  Map<String, dynamic> getAllMetadata() {
    return metadata;
  }

  dynamic getMetadata(String key) {
    return metadata[key];
  }

  void addMetadata(String key, dynamic value) {
    metadata[key] = value;
  }
}
