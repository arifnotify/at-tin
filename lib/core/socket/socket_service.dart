import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../constants/app_constants.dart';
import 'package:flutter/foundation.dart';

class SocketService {
  static final SocketService _instance = SocketService._internal();

  factory SocketService() => _instance;

  SocketService._internal();

  IO.Socket? socket;

  bool get isConnected => socket?.connected ?? false;

  // ==========================
  // CONNECT
  // ==========================

  void connect() {
    if (socket != null && socket!.connected) {
      print("🟢 SOCKET ALREADY CONNECTED");
      return;
    }

    socket = IO.io(
      AppConstants.baseUrl,
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .enableForceNew()
          .enableAutoConnect()
          .build(),
    );

    socket!.connect();

    socket!.onConnect((_) {
      print("🟢 SOCKET CONNECTED");
    });

    socket!.onDisconnect((_) {
      print("🔴 SOCKET DISCONNECTED");
    });

    socket!.onConnectError((error) {
      print("❌ SOCKET CONNECT ERROR => $error");
    });

    socket!.onError((error) {
      print("❌ SOCKET ERROR => $error");
    });
  }

  // ==========================
  // OFF / REMOVE LISTENERS
  // ==========================

  /// নির্দিষ্ট যেকোনো ইভেন্ট অফ করার জন্য ইউনিভার্সাল মেথড
  void off(String event) {
    socket?.off(event);
  }

  void offOrderStatusChanged() {
    socket?.off('order_status_changed');
  }

  void offOrderUpdated() {
    socket?.off('order_updated');
  }

  void offCartUpdated() {
    socket?.off('cartUpdated');
  }

  void offHomeUpdated() {
    socket?.off('home_updated');
  }

  void offProductUpdated() {
    socket?.off('product_updated');
  }

  // ==========================
  // HOME
  // ==========================

  void listenHomeUpdated(Function(dynamic) callback) {
    socket?.off('home_updated');
    socket?.on('home_updated', callback);
  }

  // ==========================
  // PRODUCT
  // ==========================

  void listenProductUpdated(Function(dynamic) callback) {
    socket?.off('product_updated');
    socket?.on('product_updated', callback);
  }

  // ==========================
  // BANNER
  // ==========================

  void listenBannerUpdated(Function(dynamic) callback) {
    socket?.off('banner_updated');
    socket?.on('banner_updated', callback);
  }

  // ==========================
  // FLASH SALE
  // ==========================

  void listenFlashSaleUpdated(Function(dynamic) callback) {
    socket?.off('flash_sale_updated');
    socket?.on('flash_sale_updated', callback);
  }

  // ==========================
  // CART
  // ==========================

  void listenCartUpdated(Function(dynamic) callback) {
    socket?.off('cartUpdated');
    socket?.on('cartUpdated', callback);
  }

  // ==========================
  // NEW ORDER
  // ==========================

  void listenNewOrder(Function(dynamic) callback) {
    socket?.off('new_order');
    socket?.on('new_order', callback);
  }

  // ==========================
  // ORDER UPDATED
  // ==========================

  void listenOrderUpdated(Function(dynamic) callback) {
    socket?.off('order_updated');
    socket?.on('order_updated', callback);
  }

  // ==========================
  // ORDER STATUS
  // ==========================

  void listenOrderStatusChanged(Function(dynamic) callback) {
    socket?.off('order_status_changed');
    socket?.on('order_status_changed', callback);
  }

  // ==========================
  // ORDER DELETE
  // ==========================

  void listenOrderDeleted(Function(dynamic) callback) {
    socket?.off('order_deleted');
    socket?.on('order_deleted', callback);
  }

  // ==========================
  // LOCATION
  // ==========================

  void listenLocationUpdated(Function(dynamic) callback) {
    socket?.off('location_updated');
    socket?.on('location_updated', callback);
  }

  // ==========================
  // USER UPDATED
  // ==========================

  void listenUserUpdated(Function(dynamic) callback) {
    socket?.off('user_updated');
    socket?.on('user_updated', callback);
  }

  // ==========================
  // USER BLOCK STATUS
  // ==========================

  void listenUserBlockStatus(Function(dynamic) callback) {
    socket?.off('user_block_status');
    socket?.on('user_block_status', callback);
  }

/////////////////////////////////////////////////////////
void listenPaymentSettingsUpdated(
    Function() callback,
) {
  socket?.off('payment_settings_updated');

  socket?.on(
    'payment_settings_updated',
    (_) {
      print("🔥 PAYMENT SETTINGS UPDATED");
      callback();
    },
  );
}

////////////////////////////////////////////////////////////////////////////////
void listenSupportLinksUpdated(
  VoidCallback callback,
) {
  socket?.off('support_links_updated');

  socket?.on(
    'support_links_updated',
    (_) {
      print("📡 SUPPORT LINKS UPDATED");
      callback();
    },
  );
}

void removePaymentSettingsListener() {
  socket?.off('payment_settings_updated');
}

  // ==========================
  // DISCONNECT & DISPOSE
  // ==========================

  void disconnect() {
    socket?.disconnect();
  }

  void dispose() {
    socket?.dispose();
    socket = null;
  }
}