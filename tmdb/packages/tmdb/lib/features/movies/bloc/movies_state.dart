part of 'movies_bloc.dart';

abstract class MoviesState extends Equatable {
  const MoviesState();

  @override
  List<Object> get props => [];
}

class MoviesInitial extends MoviesState {}

class MoviesLoading extends MoviesState {}

class TrendingMoviesLoaded extends MoviesState {
  final List<Movie> movies;
  final int currentPage;
  final int totalPages;
  final bool hasReachedMax;

  const TrendingMoviesLoaded(
    this.movies, {
    this.currentPage = 1,
    this.totalPages = 1,
    this.hasReachedMax = false,
  });

  @override
  List<Object> get props => [movies, currentPage, totalPages, hasReachedMax];
}

class NowPlayingMoviesLoaded extends MoviesState {
  final List<Movie> movies;
  final int currentPage;
  final int totalPages;
  final bool hasReachedMax;

  const NowPlayingMoviesLoaded(
    this.movies, {
    this.currentPage = 1,
    this.totalPages = 1,
    this.hasReachedMax = false,
  });

  @override
  List<Object> get props => [movies, currentPage, totalPages, hasReachedMax];
}

class MovieDetailsLoaded extends MoviesState {
  final MovieDetails movieDetails;

  const MovieDetailsLoaded(this.movieDetails);

  @override
  List<Object> get props => [movieDetails];
}

class SearchMoviesLoaded extends MoviesState {
  final List<Movie> movies;
  final String query;
  final int currentPage;
  final int totalPages;
  final bool hasReachedMax;

  const SearchMoviesLoaded(
    this.movies,
    this.query, {
    this.currentPage = 1,
    this.totalPages = 1,
    this.hasReachedMax = false,
  });

  @override
  List<Object> get props => [
    movies,
    query,
    currentPage,
    totalPages,
    hasReachedMax,
  ];
}

class BookmarkedMoviesLoaded extends MoviesState {
  final List<Movie> movies;

  const BookmarkedMoviesLoaded(this.movies);

  @override
  List<Object> get props => [movies];
}

class BookmarkUpdated extends MoviesState {
  final int movieId;
  final bool isBookmarked;

  const BookmarkUpdated(this.movieId, this.isBookmarked);

  @override
  List<Object> get props => [movieId, isBookmarked];
}

class MoviesError extends MoviesState {
  final String message;

  const MoviesError(this.message);

  @override
  List<Object> get props => [message];
}
