import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';

import '../../managers/network_manager.dart';
import '../network_config.dart';

part 'network_event.dart';
part 'network_state.dart';

@injectable
class NetworkBloc extends Bloc<NetworkEvent, NetworkState> {
  final NetworkManager _networkManager;
  StreamSubscription<bool>? _networkSubscription;
  Timer? _debounceTimer;

  NetworkBloc(this._networkManager) : super(NetworkInitial()) {
    on<NetworkStarted>(_onNetworkStarted);
    on<NetworkStatusChanged>(_onNetworkStatusChanged);
    on<NetworkCheckRequested>(_onNetworkCheckRequested);
    on<NetworkRetryRequested>(_onNetworkRetryRequested);
  }

  Future<void> _onNetworkStarted(
    NetworkStarted event,
    Emitter<NetworkState> emit,
  ) async {
    try {
      // Initialize network manager if not already initialized
      if (!_networkManager.isInitialized) {
        await _networkManager.initialize();
      }

      // Get initial network state
      final isConnected = _networkManager.isConnected;
      emit(isConnected ? NetworkConnected() : NetworkDisconnected());

      // Listen to network changes with debouncing
      _networkSubscription = _networkManager.networkStateStream.listen((
        isConnected,
      ) {
        _debounceTimer?.cancel();
        _debounceTimer = Timer(NetworkConfig.networkStatusDebounce, () {
          add(NetworkStatusChanged(isConnected));
        });
      });
    } catch (e) {
      emit(NetworkError('Failed to start network monitoring: $e'));
    }
  }

  Future<void> _onNetworkStatusChanged(
    NetworkStatusChanged event,
    Emitter<NetworkState> emit,
  ) async {
    // Only emit if state actually changed
    if (state is NetworkConnected && !event.isConnected) {
      emit(NetworkDisconnected());
    } else if (state is NetworkDisconnected && event.isConnected) {
      emit(NetworkConnected());
    } else if (state is NetworkInitial) {
      emit(event.isConnected ? NetworkConnected() : NetworkDisconnected());
    }
  }

  Future<void> _onNetworkCheckRequested(
    NetworkCheckRequested event,
    Emitter<NetworkState> emit,
  ) async {
    if (state is NetworkChecking)
      return; // Prevent multiple simultaneous checks

    emit(NetworkChecking());

    try {
      await _networkManager.refreshNetworkState();
      final isConnected = _networkManager.isConnected;
      emit(isConnected ? NetworkConnected() : NetworkDisconnected());
    } catch (e) {
      emit(NetworkError('Failed to check network: $e'));
    }
  }

  Future<void> _onNetworkRetryRequested(
    NetworkRetryRequested event,
    Emitter<NetworkState> emit,
  ) async {
    if (state is NetworkRetrying)
      return; // Prevent multiple simultaneous retries

    emit(NetworkRetrying());

    try {
      // Exponential backoff for retries
      final retryDelay = Duration(
        seconds: event.retryCount.clamp(1, NetworkConfig.maxRetries),
      );
      await Future.delayed(retryDelay);

      await _networkManager.refreshNetworkState();
      final isConnected = _networkManager.isConnected;
      emit(isConnected ? NetworkConnected() : NetworkDisconnected());
    } catch (e) {
      emit(NetworkError('Retry failed: $e'));
    }
  }

  @override
  Future<void> close() {
    _networkSubscription?.cancel();
    _debounceTimer?.cancel();
    return super.close();
  }
}
