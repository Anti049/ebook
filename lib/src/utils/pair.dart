class Pair<T, U> {
  late T first;
  late U second;

  Pair(this.first, this.second);
  Pair.fromMap(Map<T, U> map) {
    first = map.keys.first;
    second = map.values.first;
  }
}
