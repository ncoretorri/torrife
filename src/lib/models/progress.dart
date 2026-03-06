class Progress {
  final String hash;
  final double progress;
  final String status;
  final bool isProcessed;
  final int downloadRate;
  final int uploadRate;

  Progress({
    required this.hash,
    required this.progress,
    required this.status,
    required this.isProcessed,
    required this.downloadRate,
    required this.uploadRate,
  });

  factory Progress.fromJson(Map<String, dynamic> json) {
    return Progress(
      hash: json['hash'] ?? '',
      progress: (json['progress'] ?? 0).toDouble(),
      status: json['status'] ?? '',
      isProcessed: json['isProcessed'] ?? false,
      downloadRate: json['downloadRate'] ?? 0,
      uploadRate: json['uploadRate'] ?? 0,
    );
  }
}
