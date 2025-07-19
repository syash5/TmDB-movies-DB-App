part of 'movies_bloc.dart';

abstract class MoviesEvent extends Equatable {
  const MoviesEvent();

  @override
  List<Object> get props => [];
}

class LoadTrendingMovies extends MoviesEvent {
  final int page;
  final bool refresh;

  const LoadTrendingMovies({this.page = 1, this.refresh = false});

  @override
  List<Object> get props => [page, refresh];
}

class LoadNowPlayingMovies extends MoviesEvent {
  final int page;
  final bool refresh;

  const LoadNowPlayingMovies({this.page = 1, this.refresh = false});

  @override
  List<Object> get props => [page, refresh];
}

class LoadMovieDetails extends MoviesEvent {
  final int movieId;

  const LoadMovieDetails(this.movieId);

  @override
  List<Object> get props => [movieId];
}

class SearchMovies extends MoviesEvent {
  final String query;
  final int page;

  const SearchMovies({required this.query, this.page = 1});

  @override
  List<Object> get props => [query, page];
}

class BookmarkMovie extends MoviesEvent {
  final Movie movie;

  const BookmarkMovie(this.movie);

  @override
  List<Object> get props => [movie];
}

class UnbookmarkMovie extends MoviesEvent {
  final int movieId;

  const UnbookmarkMovie(this.movieId);

  @override
  List<Object> get props => [movieId];
}

class LoadBookmarkedMovies extends MoviesEvent {
  const LoadBookmarkedMovies();
}

class ClearAllBookmarks extends MoviesEvent {
  const ClearAllBookmarks();
}
