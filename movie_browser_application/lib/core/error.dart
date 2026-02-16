abstract class AppError implements Exception {
  final String message;
  final String? details;

  AppError(this.message, [this.details]);

  @override
  String toString() => message;
}

class NetworkError extends AppError {
  NetworkError([String? details]) 
      : super('error_network', details);
}

class ApiError extends AppError {
  ApiError([String? details]) 
      : super('error_api', details);
}

class NoDataError extends AppError {
  NoDataError([String? details]) 
      : super('error_no_data', details);
}

class EmptySearchError extends AppError {
  EmptySearchError([String? details]) 
      : super('error_empty_search', details);
}

class GenericError extends AppError {
  GenericError([String? details]) 
      : super('error_generic', details);
}
