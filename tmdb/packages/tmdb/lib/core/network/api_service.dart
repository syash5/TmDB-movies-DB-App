import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import 'package:tmdb/core/constants/urls.dart';

part 'api_service.g.dart';

@RestApi()
abstract class ApiService {
  factory ApiService(Dio dio, {String baseUrl}) = _ApiService;

  @GET(ApiEndpoints.trendingMovies)
  Future<dynamic> getTrendingMovies(
    @Query('page') int page,
  );

  @GET(ApiEndpoints.nowPlayingMovies)
  Future<dynamic> getNowPlayingMovies(
    @Query('page') int page,
  );

  @GET(ApiEndpoints.movieDetails)
  Future<dynamic> getMovieDetails(
    @Path('id') int id,
  );

  @GET(ApiEndpoints.searchMovies)
  Future<dynamic> searchMovies(
    @Query('query') String query,
    @Query('page') int page,
  );
}
