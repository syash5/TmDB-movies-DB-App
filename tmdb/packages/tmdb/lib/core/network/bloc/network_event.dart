part of 'network_bloc.dart';

abstract class NetworkEvent extends Equatable {
  const NetworkEvent();

  @override
  List<Object> get props => [];
}

class NetworkStarted extends NetworkEvent {
  const NetworkStarted();
}

class NetworkStatusChanged extends NetworkEvent {
  final bool isConnected;

  const NetworkStatusChanged(this.isConnected);

  @override
  List<Object> get props => [isConnected];
}

class NetworkCheckRequested extends NetworkEvent {
  const NetworkCheckRequested();
}

class NetworkRetryRequested extends NetworkEvent {
  final int retryCount;

  const NetworkRetryRequested({this.retryCount = 1});

  @override
  List<Object> get props => [retryCount];
}
