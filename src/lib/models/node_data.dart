import 'package:torri/models/torrent_content.dart';

class NodeData {
  final String title;
  final TorrentContent? data;
  List<NodeData> children = [];

  bool get isLeaf => data != null;

  bool? get downloading {
    if (isLeaf) {
      return data!.wanted;
    }

    if (children.isNotEmpty) {
      if (children.every((x) => x.downloading == true)) {
        return true;
      }

      if (children.every((x) => x.downloading == false)) {
        return false;
      }
    }

    return null;
  }

  set downloading(bool? value) {
    if (isLeaf) {
      data!.wanted = value == true ? true : false;
    } else {
      for (var x in children) {
        x.downloading = value;
      }
    }
  }

  bool get hasError {
    if (isLeaf) {
      return data!.hasError;
    }

    if (children.isNotEmpty) {
      return children.any((x) => x.hasError);
    }

    return false;
  }

  set hasError(bool value) {
    if (isLeaf) {
      data!.hasError = value;
    }
  }

  NodeData(this.title, this.data);
}
