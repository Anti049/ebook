extension TemplateString on String {
  /// Returns a string with the [values] substituted into the template.
  /// The template string is a string with placeholders in the form of
  /// `{text}`. The text is replaced with the value in the [values] map.
  ///
  /// Example:
  /// ```dart
  /// 'Hello {name}!'.format(['World']);
  /// ```
  String format(List<dynamic> values) {
    var result = this;
    for (var i = 0; i < values.length; i++) {
      result = result.replaceFirst(RegExp(r'{.*}'), values[i].toString());
    }
    return result;
  }

  /// Returns a string with the [values] interpolated into the template.
  ///
  /// The template string is a string with placeholders in the form of
  /// `{name}`. The name is used to lookup the value in the [values] map.
  ///
  /// Example:
  /// ```dart
  /// 'Hello {name}!'.formatMap({'name': 'World'});
  /// ```
  String formatMap(Map<String, dynamic> values) {
    var result = this;
    for (final entry in values.entries) {
      result = result.replaceAll('{${entry.key}}', entry.value.toString());
    }
    return result;
  }
}

// Extend String class
