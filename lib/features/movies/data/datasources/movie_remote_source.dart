import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/dio_client.dart';
import '../models/movie_model.dart';

/// Remote data source for TMDB API movie operations.
class MovieRemoteSource {
  final DioClient _client;

  MovieRemoteSource(this._client);

  /// Fetch trending movies from TMDB.
  Future<MoviesResponse> getTrendingMovies({required int page}) async {
    final response = await _client.get(
      '/trending/movie/day',
      baseUrl: ApiConstants.tmdbBaseUrl,
      queryParameters: {
        'api_key': ApiConstants.tmdbApiKey,
        'page': page,
      },
    );

    return MoviesResponse.fromJson(response.data as Map<String, dynamic>);
  }

  /// Get a specific movie by ID.
  Future<MovieModel> getMovieById(int movieId) async {
    final response = await _client.get(
      '/movie/$movieId',
      baseUrl: ApiConstants.tmdbBaseUrl,
      queryParameters: {
        'api_key': ApiConstants.tmdbApiKey,
      },
    );

    return MovieModel.fromJson(response.data as Map<String, dynamic>);
  }
}
