extension NumberExtension on num? {
  String filesize([int round = 2, bool decimal = false]) {
    var size = this ?? 0;

    int divider = 1024;

    size = int.parse(size.toString());

    if (decimal) divider = 1000;

    if (size < divider) return "$size B";

    if (size < divider * divider && size % divider == 0) {
      return "${(size / divider).toStringAsFixed(0)} KB";
    }

    if (size < divider * divider) {
      return "${(size / divider).toStringAsFixed(round)} KB";
    }

    if (size < divider * divider * divider && size % divider == 0) {
      return "${(size / (divider * divider)).toStringAsFixed(0)} MB";
    }

    if (size < divider * divider * divider) {
      return "${(size / divider / divider).toStringAsFixed(round)} MB";
    }

    if (size < divider * divider * divider * divider && size % divider == 0) {
      return "${(size / (divider * divider * divider)).toStringAsFixed(0)} GB";
    }

    if (size < divider * divider * divider * divider) {
      return "${(size / divider / divider / divider).toStringAsFixed(round)} GB";
    }

    if (size < divider * divider * divider * divider * divider &&
        size % divider == 0) {
      return "${(size / divider / divider / divider / divider).toStringAsFixed(0)} TB";
    }

    if (size < divider * divider * divider * divider * divider) {
      return "${(size / divider / divider / divider / divider).toStringAsFixed(round)} TB";
    }

    if (size < divider * divider * divider * divider * divider * divider &&
        size % divider == 0) {
      return "${(size / divider / divider / divider / divider / divider).toStringAsFixed(0)} PB";
    } else {
      return "${(size / divider / divider / divider / divider / divider).toStringAsFixed(round)} PB";
    }
  }
}
