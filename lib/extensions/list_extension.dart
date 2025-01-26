extension ListExtension<T> on List<T> {
  List<T> takeLast(int count) {
    if (count <= 0) return <T>[];
    return sublist(length - count < 0 ? 0 : length - count);
  }
}
