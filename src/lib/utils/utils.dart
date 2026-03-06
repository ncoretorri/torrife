import 'package:intl/intl.dart';

class Utils {
  static final f = NumberFormat("###.#");

  static String formatBytes(num bytes) {
    const units = ["B", "KB", "MB", "GB", "TB", "PB"];
    var size = bytes.toDouble();
    var unitIndex = 0;

    while (size >= 1024 && unitIndex < units.length - 1) {
      size /= 1024;
      unitIndex++;
    }

    return "${f.format(size)} ${units[unitIndex]}";
  }
}
