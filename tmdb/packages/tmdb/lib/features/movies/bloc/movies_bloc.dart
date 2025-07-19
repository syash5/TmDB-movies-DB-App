import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import 'package:tmdb/features/movies/models/movie.dart';
import 'package:tmdb/features/movies/models/movie_details.dart';

import '../repository/movie_repository.dart';

part 'movies_event.dart';
part 'movies_state.dart';

@injectable
class MoviesBloc extends Bloc<MoviesEvent, MoviesState> {
  MoviesBloc(this._movieRepository) : super(MoviesInitial()) {
    on<LoadTrendingMovies>(_onLoadTrendingMovies);
    on<LoadNowPlayingMovies>(_onLoadNowPlayingMovies);
    on<LoadMovieDetails>(_onLoadMovieDetails);
    on<SearchMovies>(_onSearchMovies);
    on<BookmarkMovie>(_onBookmarkMovie);
    on<UnbookmarkMovie>(_onUnbookmarkMovie);
    on<LoadBookmarkedMovies>(_onLoadBookmarkedMovies);
    on<ClearAllBookmarks>(_onClearAllBookmarks);
  }
  final MovieRepository _movieRepository;

  Future<void> _onLoadTrendingMovies(
    LoadTrendingMovies event,
    Emitter<MoviesState> emit,
  ) async {
    try {
      if (event.refresh || state is! TrendingMoviesLoaded) {
        emit(MoviesLoading());
        final response = await _movieRepository.getTrendingMoviesWithPagination(
          page: 1,
        );
        emit(
          TrendingMoviesLoaded(
            response.results,
            currentPage: response.page,
            totalPages: response.totalPages,
            hasReachedMax: response.page >= response.totalPages,
          ),
        );
      } else if (state is TrendingMoviesLoaded) {
        final currentState = state as TrendingMoviesLoaded;
        if (currentState.hasReachedMax) return;

        final response = await _movieRepository.getTrendingMoviesWithPagination(
          page: event.page,
        );
        final updatedMovies = [...currentState.movies, ...response.results];

        emit(
          TrendingMoviesLoaded(
            updatedMovies,
            currentPage: response.page,
            totalPages: response.totalPages,
            hasReachedMax: response.page >= response.totalPages,
          ),
        );
      }
    } catch (e) {
      emit(MoviesError('Failed to load trending movies: ${e.toString()}'));
    }
  }

  Future<void> _onLoadNowPlayingMovies(
    LoadNowPlayingMovies event,
    Emitter<MoviesState> emit,
  ) async {
    try {
      if (event.refresh || state is! NowPlayingMoviesLoaded) {
        emit(MoviesLoading());
        final response = await _movieRepository.getNowPlayingMoviesWithPagination(page: 1);
        emit(
          NowPlayingMoviesLoaded(
            response.results,
            currentPage: response.page,
            totalPages: response.totalPages,
            hasReachedMax: response.page >= response.totalPages,
          ),
        );
      } else if (state is NowPlayingMoviesLoaded) {
        final currentState = state as NowPlayingMoviesLoaded;
        if (currentState.hasReachedMax) return;

        final response = await _movieRepository.getNowPlayingMoviesWithPagination(page: event.page);
        final updatedMovies = [...currentState.movies, ...response.results];

        emit(
          NowPlayingMoviesLoaded(
            updatedMovies,
            currentPage: response.page,
            totalPages: response.totalPages,
            hasReachedMax: response.page >= response.totalPages,
          ),
        );
      }
    } catch (e) {
      emit(MoviesError('Failed to load now playing movies: ${e.toString()}'));
    }
  }

  Future<void> _onLoadMovieDetails(
    LoadMovieDetails event,
    Emitter<MoviesState> emit,
  ) async {
    try {
      emit(MoviesLoading());
      final movieDetails = await _movieRepository.getMovieDetails(
        event.movieId,
      );
      emit(MovieDetailsLoaded(movieDetails));
    } catch (e) {
      emit(MoviesError('Failed to load movie details: ${e.toString()}'));
    }
  }

  Future<void> _onSearchMovies(
    SearchMovies event,
    Emitter<MoviesState> emit,
  ) async {
    try {
      if (event.query.isEmpty) {
        emit(MoviesInitial());
        return;
      }

      if (event.page == 1) {
        emit(MoviesLoading());
        final response = await _movieRepository.searchMoviesWithPagination(
          event.query,
          page: 1,
        );
        emit(
          SearchMoviesLoaded(
            response.results,
            event.query,
            currentPage: response.page,
            totalPages: response.totalPages,
            hasReachedMax: response.page >= response.totalPages,
          ),
        );
      } else if (state is SearchMoviesLoaded) {
        final currentState = state as SearchMoviesLoaded;
        if (currentState.query != event.query) {
          // New search query, start fresh
          emit(MoviesLoading());
          final response = await _movieRepository.searchMoviesWithPagination(
            event.query,
            page: 1,
          );
          emit(
            SearchMoviesLoaded(
              response.results,
              event.query,
              currentPage: response.page,
              totalPages: response.totalPages,
              hasReachedMax: response.page >= response.totalPages,
            ),
          );
        } else if (!currentState.hasReachedMax) {
          // Load more for same query
          final response = await _movieRepository.searchMoviesWithPagination(
            event.query,
            page: event.page,
          );
          final updatedMovies = [...currentState.movies, ...response.results];

          emit(
            SearchMoviesLoaded(
              updatedMovies,
              event.query,
              currentPage: response.page,
              totalPages: response.totalPages,
              hasReachedMax: response.page >= response.totalPages,
            ),
          );
        }
      }
    } catch (e) {
      emit(MoviesError('Failed to search movies: ${e.toString()}'));
    }
  }

  Future<void> _onBookmarkMovie(
    BookmarkMovie event,
    Emitter<MoviesState> emit,
  ) async {
    try {
      await _movieRepository.bookmarkMovie(event.movie);

      emit(BookmarkUpdated(event.movie.id, true));

      if (state is BookmarkedMoviesLoaded) {
        final movies = await _movieRepository.getBookmarkedMovies();
        emit(BookmarkedMoviesLoaded(movies));
      }
    } catch (e) {
      emit(MoviesError('Failed to bookmark movie: ${e.toString()}'));
    }
  }

  Future<void> _onUnbookmarkMovie(
    UnbookmarkMovie event,
    Emitter<MoviesState> emit,
  ) async {
    try {
      await _movieRepository.removeBookmark(event.movieId);

      emit(BookmarkUpdated(event.movieId, false));

      if (state is BookmarkedMoviesLoaded) {
        final movies = await _movieRepository.getBookmarkedMovies();
        emit(BookmarkedMoviesLoaded(movies));
      }
    } catch (e) {
      emit(MoviesError('Failed to remove bookmark: ${e.toString()}'));
    }
  }

  Future<void> _onLoadBookmarkedMovies(
    LoadBookmarkedMovies event,
    Emitter<MoviesState> emit,
  ) async {
    try {
      emit(MoviesLoading());
      final movies = await _movieRepository.getBookmarkedMovies();
      emit(BookmarkedMoviesLoaded(movies));
    } catch (e) {
      if (e.toString().contains('Failed to load bookmarked movies')) {
        emit(BookmarkedMoviesLoaded([]));
      } else {
        emit(MoviesError('Failed to load bookmarked movies: ${e.toString()}'));
      }
    }
  }

  Future<void> _onClearAllBookmarks(
    ClearAllBookmarks event,
    Emitter<MoviesState> emit,
  ) async {
    try {
      await _movieRepository.clearAllBookmarks();

      emit(BookmarkedMoviesLoaded([]));
      if (state is TrendingMoviesLoaded) {
        final currentState = state as TrendingMoviesLoaded;
        emit(
          TrendingMoviesLoaded(
            currentState.movies,
            currentPage: currentState.currentPage,
            totalPages: currentState.totalPages,
            hasReachedMax: currentState.hasReachedMax,
          ),
        );
      } else if (state is NowPlayingMoviesLoaded) {
        final currentState = state as NowPlayingMoviesLoaded;
        emit(
          NowPlayingMoviesLoaded(
            currentState.movies,
            currentPage: currentState.currentPage,
            totalPages: currentState.totalPages,
            hasReachedMax: currentState.hasReachedMax,
          ),
        );
      } else if (state is SearchMoviesLoaded) {
        final currentState = state as SearchMoviesLoaded;
        emit(
          SearchMoviesLoaded(
            currentState.movies,
            currentState.query,
            currentPage: currentState.currentPage,
            totalPages: currentState.totalPages,
            hasReachedMax: currentState.hasReachedMax,
          ),
        );
      }
    } catch (e) {
      emit(MoviesError('Failed to clear all bookmarks: ${e.toString()}'));
    }
  }
}
