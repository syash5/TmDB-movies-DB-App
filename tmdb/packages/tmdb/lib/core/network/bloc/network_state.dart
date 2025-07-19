part of 'network_bloc.dart';

abstract class NetworkState extends Equatable {
  const NetworkState();

  @override
  List<Object> get props => [];
}

class NetworkInitial extends NetworkState {
  const NetworkInitial();
}

class NetworkConnected extends NetworkState {
  const NetworkConnected();
}

class NetworkDisconnected extends NetworkState {
  const NetworkDisconnected();
}

class NetworkChecking extends NetworkState {
  const NetworkChecking();
}

class NetworkRetrying extends NetworkState {
  const NetworkRetrying();
}

class NetworkError extends NetworkState {
  final String message;

  const NetworkError(this.message);

  @override
  List<Object> get props => [message];
}
