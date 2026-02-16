import 'package:dio/dio.dart';
import '../core/constants.dart';
import '../core/error.dart';

class ApiClient {
  late final Dio _dio;

  ApiClient() {
    _dio = Dio(
      BaseOptions(
        baseUrl: AppConstants.apiBaseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          options.queryParameters['apikey'] = AppConstants.apiKey;
          return handler.next(options);
        },
        onError: (error, handler) {
          return handler.next(error);
        },
      ),
    );
  }

  Future<Map<String, dynamic>> searchMovies(String query, int page) async {
    try {
      final response = await _dio.get(
        '',
        queryParameters: {
          's': query,
          'page': page,
        },
      );

      if (response.data['Response'] == 'False') {
        throw ApiError(response.data['Error']);
      }

      return response.data;
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.connectionError) {
        throw NetworkError(e.message);
      }
      throw ApiError(e.message);
    } catch (e) {
      throw GenericError(e.toString());
    }
  }

  Future<Map<String, dynamic>> getMovieDetails(String imdbId) async {
    try {
      final response = await _dio.get(
        '',
        queryParameters: {
          'i': imdbId,
          'plot': 'full',
        },
      );

      if (response.data['Response'] == 'False') {
        throw ApiError(response.data['Error']);
      }

      return response.data;
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.connectionError) {
        throw NetworkError(e.message);
      }
      throw ApiError(e.message);
    } catch (e) {
      throw GenericError(e.toString());
    }
  }
}
