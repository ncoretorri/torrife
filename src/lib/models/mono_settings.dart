class MonoSettings {
  int maximumConnections;
  int maximumDownloadRate;
  int diskCacheBytes;
  int maximumDiskReadRate;
  int maximumDiskWriteRate;
  int maximumHalfOpenConnections;
  int maximumOpenFiles;
  int maximumUploadRate;

  MonoSettings({
    required this.maximumConnections,
    required this.maximumDownloadRate,
    required this.diskCacheBytes,
    required this.maximumDiskReadRate,
    required this.maximumDiskWriteRate,
    required this.maximumHalfOpenConnections,
    required this.maximumOpenFiles,
    required this.maximumUploadRate,
  });

  factory MonoSettings.fromJson(Map<String, dynamic> json) {
    return MonoSettings(
      maximumConnections: json['maximumConnections'] as int,
      maximumDownloadRate: json['maximumDownloadRate'] as int,
      diskCacheBytes: json['diskCacheBytes'] as int,
      maximumDiskReadRate: json['maximumDiskReadRate'] as int,
      maximumDiskWriteRate: json['maximumDiskWriteRate'] as int,
      maximumHalfOpenConnections: json['maximumHalfOpenConnections'] as int,
      maximumOpenFiles: json['maximumOpenFiles'] as int,
      maximumUploadRate: json['maximumUploadRate'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'maximumConnections': maximumConnections,
      'maximumDownloadRate': maximumDownloadRate,
      'diskCacheBytes': diskCacheBytes,
      'maximumDiskReadRate': maximumDiskReadRate,
      'maximumDiskWriteRate': maximumDiskWriteRate,
      'maximumHalfOpenConnections': maximumHalfOpenConnections,
      'maximumOpenFiles': maximumOpenFiles,
      'maximumUploadRate': maximumUploadRate,
    };
  }
}
