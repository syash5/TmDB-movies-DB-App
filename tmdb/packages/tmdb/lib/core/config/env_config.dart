import 'package:envied/envied.dart';

part 'env_config.g.dart';

@Envied()
abstract class EnvConfig {
  @EnviedField(varName: 'TMDB_API_KEY')
  static const String tmdbApiKey = _EnvConfig.tmdbApiKey;

  @EnviedField(varName: 'TMDB_BASE_URL')
  static const String tmdbBaseUrl = _EnvConfig.tmdbBaseUrl;
}
