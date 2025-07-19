import 'dart:async';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class NetworkManager {
  NetworkManager();

  final Connectivity _connectivity = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;

  bool _isConnected = true;
  bool _isInitialized = false;

  // Stream controller for network state changes
  final _networkStateController = StreamController<bool>.broadcast();

  /// Stream of network connectivity state
  Stream<bool> get networkStateStream => _networkStateController.stream;

  /// Current network connectivity state
  bool get isConnected => _isConnected;

  /// Check if network manager is initialized
  bool get isInitialized => _isInitialized;

  /// Initialize network monitoring
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Check initial connectivity
      await _checkInitialConnectivity();

      // Listen to connectivity changes
      _connectivitySubscription = _connectivity.onConnectivityChanged.listen(
        _onConnectivityChanged,
        onError: (error) {
          if (kDebugMode) {
            print('Network connectivity error: $error');
          }
        },
      );

      _isInitialized = true;

      if (kDebugMode) {
        print('NetworkManager initialized - Connected: $_isConnected');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error initializing NetworkManager: $e');
      }
    }
  }

  /// Check initial connectivity state
  Future<void> _checkInitialConnectivity() async {
    try {
      final List<ConnectivityResult> connectivityResults = await _connectivity
          .checkConnectivity();
      await _updateConnectivityState(connectivityResults);
    } catch (e) {
      if (kDebugMode) {
        print('Error checking initial connectivity: $e');
      }
      _isConnected = false;
    }
  }

  /// Handle connectivity changes
  Future<void> _onConnectivityChanged(List<ConnectivityResult> results) async {
    await _updateConnectivityState(results);
  }

  /// Update connectivity state based on results
  Future<void> _updateConnectivityState(
    List<ConnectivityResult> results,
  ) async {
    bool hasConnection = false;

    // Check if any connection type is available
    for (final result in results) {
      if (result != ConnectivityResult.none) {
        hasConnection = true;
        break;
      }
    }

    // If connectivity shows available, verify with actual internet access
    if (hasConnection) {
      hasConnection = await _hasInternetAccess();
    }

    if (_isConnected != hasConnection) {
      _isConnected = hasConnection;
      _networkStateController.add(_isConnected);

      if (kDebugMode) {
        print(
          'Network state changed: ${_isConnected ? 'Connected' : 'Disconnected'}',
        );
      }
    }
  }

  /// Verify actual internet access by pinging a reliable server
  Future<bool> _hasInternetAccess() async {
    try {
      final result = await InternetAddress.lookup(
        'google.com',
      ).timeout(const Duration(seconds: 5));
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (e) {
      if (kDebugMode) {
        print('Internet access check failed: $e');
      }
      return false;
    }
  }

  /// Force refresh network state
  Future<void> refreshNetworkState() async {
    if (!_isInitialized) {
      await initialize();
      return;
    }

    try {
      final connectivityResults = await _connectivity.checkConnectivity();
      await _updateConnectivityState(connectivityResults);
    } catch (e) {
      if (kDebugMode) {
        print('Error refreshing network state: $e');
      }
    }
  }

  /// Check if network is available (one-time check)
  Future<bool> checkNetworkAvailability() async {
    try {
      final connectivityResults = await _connectivity.checkConnectivity();

      bool hasConnection = false;
      for (final result in connectivityResults) {
        if (result != ConnectivityResult.none) {
          hasConnection = true;
          break;
        }
      }

      if (hasConnection) {
        hasConnection = await _hasInternetAccess();
      }

      return hasConnection;
    } catch (e) {
      if (kDebugMode) {
        print('Error checking network availability: $e');
      }
      return false;
    }
  }

  /// Get current connectivity type
  Future<String> getConnectivityType() async {
    try {
      final connectivityResults = await _connectivity.checkConnectivity();

      if (connectivityResults.isEmpty) {
        return 'None';
      }

      // Return the first available connection type
      final result = connectivityResults.first;
      switch (result) {
        case ConnectivityResult.wifi:
          return 'WiFi';
        case ConnectivityResult.mobile:
          return 'Mobile';
        case ConnectivityResult.ethernet:
          return 'Ethernet';
        case ConnectivityResult.vpn:
          return 'VPN';
        case ConnectivityResult.bluetooth:
          return 'Bluetooth';
        case ConnectivityResult.other:
          return 'Other';
        case ConnectivityResult.none:
        default:
          return 'None';
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error getting connectivity type: $e');
      }
      return 'Unknown';
    }
  }

  /// Get network status information
  Future<Map<String, dynamic>> getNetworkStatus() async {
    final connectivityType = await getConnectivityType();

    return {
      'isConnected': _isConnected,
      'connectivityType': connectivityType,
      'isInitialized': _isInitialized,
      'timestamp': DateTime.now().toIso8601String(),
    };
  }

  /// Dispose of the network manager
  void dispose() {
    _connectivitySubscription?.cancel();
    _networkStateController.close();
    _isInitialized = false;

    if (kDebugMode) {
      print('NetworkManager disposed');
    }
  }
}
