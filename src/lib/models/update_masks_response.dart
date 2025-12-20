class UpdateMasksResponse {
  final List<int> regexErrors;
  final bool hasMasks;

  UpdateMasksResponse({required this.regexErrors, required this.hasMasks});

  factory UpdateMasksResponse.fromJson(Map<String, dynamic> json) {
    var regexErrorsJson = json['regexErrors'] as List<dynamic>;
    List<int> regexErrors = List<int>.from(regexErrorsJson);
    bool hasMasks = json['hasMasks'] ?? false;

    return UpdateMasksResponse(regexErrors: regexErrors, hasMasks: hasMasks);
  }
}
