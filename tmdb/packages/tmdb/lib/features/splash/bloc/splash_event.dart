part of 'splash_bloc.dart';

abstract class SplashEvent extends Equatable {
  const SplashEvent();

  @override
  List<Object> get props => [];
}

class SplashStarted extends SplashEvent {}

class SplashInitializeHive extends SplashEvent {}

class SplashInitializeNetwork extends SplashEvent {}

class SplashInitializeFirebase extends SplashEvent {}

class SplashInitializeAuth extends SplashEvent {}

class SplashCheckAuthentication extends SplashEvent {}

class SplashNavigateToNext extends SplashEvent {}

class SplashRetry extends SplashEvent {}
