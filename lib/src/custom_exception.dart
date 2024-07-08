// ignore_for_file: public_member_api_docs, sort_constructors_first
abstract class CustomException implements Exception {}

class SizeException extends CustomException {
  String errorMessage;
  StackTrace stackTrace;
  SizeException({
    required this.errorMessage,
    required this.stackTrace,
  });

  @override
  String toString() =>
      'SizeException(errorMessage: $errorMessage, stackTrace: $stackTrace)';
}

class DownloadException extends CustomException {
  String errorMessage;
  StackTrace stackTrace;
  DownloadException({
    required this.errorMessage,
    required this.stackTrace,
  });

  @override
  String toString() =>
      'DownloadException(errorMessage: $errorMessage, stackTrace: $stackTrace)';
}

class GeneralException extends CustomException {
  String errorMessage;
  StackTrace? stackTrace;
  GeneralException({
    required this.errorMessage,
    this.stackTrace,
  });

  @override
  String toString() =>
      'GeneralException(errorMessage: $errorMessage, stackTrace: $stackTrace)';
}
