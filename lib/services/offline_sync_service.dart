import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/bag_qr_model.dart';
import '../models/waste_item_model.dart';

enum NetworkConnectionState {
  online,
  offline,
}

class QueuedSyncItem {
  final String id;
  final String itemType; // 'waste_drop', 'qr_scan', 'collection_request'
  final Map<String, dynamic> payload;
  final DateTime queuedAt;
  bool isSynced;

  QueuedSyncItem({
    required this.id,
    required this.itemType,
    required this.payload,
    required this.queuedAt,
    this.isSynced = false,
  });
}

/// Manages offline-first caching and automatic synchronization
class OfflineSyncService extends ChangeNotifier {
  static final OfflineSyncService _instance = OfflineSyncService._internal();
  factory OfflineSyncService() => _instance;
  OfflineSyncService._internal();

  NetworkConnectionState _networkState = NetworkConnectionState.online;
  final List<QueuedSyncItem> _syncQueue = [];
  int _totalSyncedCount = 48;
  bool _isSyncing = false;

  NetworkConnectionState get networkState => _networkState;
  bool get isOnline => _networkState == NetworkConnectionState.online;
  List<QueuedSyncItem> get pendingQueue =>
      _syncQueue.where((item) => !item.isSynced).toList();
  int get pendingCount => pendingQueue.length;
  int get totalSyncedCount => _totalSyncedCount;
  bool get isSyncing => _isSyncing;

  void toggleNetworkMode() {
    _networkState = _networkState == NetworkConnectionState.online
        ? NetworkConnectionState.offline
        : NetworkConnectionState.online;
    notifyListeners();

    if (_networkState == NetworkConnectionState.online && pendingCount > 0) {
      syncPendingQueue();
    }
  }

  void setNetworkMode(NetworkConnectionState state) {
    if (_networkState != state) {
      _networkState = state;
      notifyListeners();
      if (_networkState == NetworkConnectionState.online && pendingCount > 0) {
        syncPendingQueue();
      }
    }
  }

  /// Enqueues a waste item log or collection request
  void queueWasteItem(WasteItemModel item) {
    _syncQueue.add(
      QueuedSyncItem(
        id: item.id,
        itemType: 'waste_drop',
        payload: {
          'detectedObject': item.detectedObject,
          'category': item.category.name,
          'confidence': item.confidence,
          'weightKg': item.weightKg,
          'wardId': item.wardId,
          'operatorId': item.operatorId,
          'timestamp': item.timestamp.toIso8601String(),
        },
        queuedAt: DateTime.now(),
      ),
    );
    notifyListeners();

    if (isOnline) {
      syncPendingQueue();
    }
  }

  /// Enqueues a scanned QR bag
  void queueBagQr(BagQrModel bag) {
    _syncQueue.add(
      QueuedSyncItem(
        id: bag.bagId,
        itemType: 'qr_scan',
        payload: bag.toJson(),
        queuedAt: DateTime.now(),
      ),
    );
    notifyListeners();

    if (isOnline) {
      syncPendingQueue();
    }
  }

  /// Manually or automatically flushes the offline queue to the server
  Future<int> syncPendingQueue() async {
    if (_isSyncing || !isOnline || pendingCount == 0) return 0;

    _isSyncing = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 700));

    final countToSync = pendingCount;
    for (final item in _syncQueue) {
      item.isSynced = true;
    }
    _totalSyncedCount += countToSync;
    _isSyncing = false;
    notifyListeners();
    return countToSync;
  }

  void clearSyncedHistory() {
    _syncQueue.removeWhere((item) => item.isSynced);
    notifyListeners();
  }
}
