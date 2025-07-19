import 'package:json_annotation/json_annotation.dart';

part 'movie.g.dart';

@JsonSerializable()
class Movie {
  final int id;
  final String title;
  @JsonKey(name: 'poster_path')
  final String? posterPath;
  @JsonKey(name: 'backdrop_path')
  final String? backdropPath;
  @JsonKey(name: 'release_date')
  final String? releaseDate;
  @JsonKey(name: 'vote_average')
  final double voteAverage;

  Movie({
    required this.id,
    required this.title,
    this.posterPath,
    this.backdropPath,
    this.releaseDate,
    required this.voteAverage,
  });

  factory Movie.fromJson(Map<String, dynamic> json) => _$MovieFromJson(json);
  Map<String, dynamic> toJson() => _$MovieToJson(this);

  String get fullPosterPath {
    if (posterPath == null) return '';
    return 'https://image.tmdb.org/t/p/w500$posterPath';
  }

  String get fullBackdropPath {
    if (backdropPath == null) return '';
    return 'https://image.tmdb.org/t/p/w780$backdropPath';
  }

  String get formattedReleaseDate {
    if (releaseDate == null || releaseDate!.isEmpty) return 'Unknown';
    try {
      final date = DateTime.parse(releaseDate!);
      return '${date.year}';
    } catch (e) {
      return releaseDate!;
    }
  }

  String get formattedVoteAverage {
    return voteAverage.toStringAsFixed(1);
  }
}
