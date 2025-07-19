import 'package:injectable/injectable.dart';
import 'package:tmdb/core/managers/managers.dart';
import 'package:tmdb/core/network/api_service.dart';
import 'package:tmdb/features/movies/models/movie.dart';
import 'package:tmdb/features/movies/models/movie_details.dart';
import 'package:tmdb/features/movies/models/movie_response.dart';

@lazySingleton
class MovieRepository {
  final ApiService _apiService;
  final HiveManager _hiveManager;

  MovieRepository(this._apiService, this._hiveManager);

  Future<List<Movie>> getTrendingMovies({int page = 1}) async {
    final response = await _apiService.getTrendingMovies(page);

    final movieResponse = MovieResponse.fromJson(
      response as Map<String, dynamic>,
    );

    return movieResponse.results;
  }

  Future<MovieResponse> getTrendingMoviesWithPagination({int page = 1}) async {
    final response = await _apiService.getTrendingMovies(page);

    final movieResponse = MovieResponse.fromJson(
      response as Map<String, dynamic>,
    );

    return movieResponse;
  }

  Future<List<Movie>> getNowPlayingMovies({int page = 1}) async {
    final response = await _apiService.getNowPlayingMovies(page);

    final movieResponse = MovieResponse.fromJson(
      response as Map<String, dynamic>,
    );

    return movieResponse.results;
  }

  Future<MovieResponse> getNowPlayingMoviesWithPagination({
    int page = 1,
  }) async {
    final response = await _apiService.getNowPlayingMovies(page);

    final movieResponse = MovieResponse.fromJson(
      response as Map<String, dynamic>,
    );

    return movieResponse;
  }

  Future<MovieDetails> getMovieDetails(int movieId) async {
    final response = await _apiService.getMovieDetails(movieId);

    final movieDetails = MovieDetails.fromJson(
      response as Map<String, dynamic>,
    );

    return movieDetails;
  }

  Future<List<Movie>> searchMovies(String query, {int page = 1}) async {
    if (query.isEmpty) return [];

    final response = await _apiService.searchMovies(query, page);

    final movieResponse = MovieResponse.fromJson(
      response as Map<String, dynamic>,
    );

    return movieResponse.results;
  }

  Future<MovieResponse> searchMoviesWithPagination(
    String query, {
    int page = 1,
  }) async {
    if (query.isEmpty) {
      return MovieResponse(
        page: 1,
        results: [],
        totalPages: 1,
        totalResults: 0,
      );
    }

    final response = await _apiService.searchMovies(query, page);

    final movieResponse = MovieResponse.fromJson(
      response as Map<String, dynamic>,
    );

    return movieResponse;
  }

  Future<void> bookmarkMovie(Movie movie) async {
    try {
      final movieData = movie.toJson();
      await _hiveManager.addToFavorites(movie.id, movieData);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> removeBookmark(int movieId) async {
    await _hiveManager.removeFromFavorites(movieId);
  }

  Future<List<Movie>> getBookmarkedMovies() async {
    try {
      final favoritesData = await _hiveManager.getAllFavorites();
      final movies = <Movie>[];

      for (final data in favoritesData) {
        try {
          final movie = Movie.fromJson(data);
          movies.add(movie);
        } catch (e) {
          // Skip invalid movie data
        }
      }

      return movies;
    } catch (e) {
      return [];
    }
  }

  Future<bool> isMovieBookmarked(int movieId) async {
    return await _hiveManager.isFavorite(movieId);
  }

  Future<void> clearAllBookmarks() async {
    await _hiveManager.clearFavorites();
  }
}
