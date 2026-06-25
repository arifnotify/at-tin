import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketService {
  static final SocketService _instance =
      SocketService._internal();

  factory SocketService() => _instance;

  SocketService._internal();

  late IO.Socket socket;

  void connect() {
    socket = IO.io(
      'https://attinbackend.onrender.com',
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .enableForceNew()
          .enableAutoConnect()
          .build(),
    );

    socket.connect();

    socket.onConnect((_) {
      print('🟢 SOCKET CONNECTED');
    });

    socket.onDisconnect((_) {
      print('🔴 SOCKET DISCONNECTED');
    });

    socket.onConnectError((data) {
      print('❌ SOCKET ERROR: $data');
    });
  }

  void listenHomeUpdated(
    Function(dynamic data) callback,
  ) {
    socket.on(
      'home_updated',
      callback,
    );
  }

  void dispose() {
    socket.dispose();
  }
}