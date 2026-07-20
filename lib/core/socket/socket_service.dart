import 'package:socket_io_client/socket_io_client.dart' as IO;


class SocketService {


  static final SocketService _instance =
      SocketService._internal();


  factory SocketService() => _instance;


  SocketService._internal();



  IO.Socket? socket;



  void connect(){


    if(socket != null && socket!.connected){
      print(
        "🟢 SOCKET ALREADY CONNECTED",
      );
      return;
    }



    socket = IO.io(

      'https://attinbackend.onrender.com',

      IO.OptionBuilder()

          .setTransports(
            ['websocket'],
          )

          .enableAutoConnect()

          .enableForceNew()

          .build(),

    );




    socket!.connect();




    socket!.onConnect((_) {

      print(
        "🟢 SOCKET CONNECTED",
      );

    });




    socket!.onDisconnect((_) {

      print(
        "🔴 SOCKET DISCONNECTED",
      );

    });




    socket!.onConnectError((error){

      print(
        "❌ SOCKET ERROR: $error",
      );

    });


  }





  void listenHomeUpdated(
      Function(dynamic data) callback,
  ){



    if(socket == null){


      print(
        "❌ Socket not initialized",
      );


      return;

    }



    socket!.on(
      'home_updated',
      callback,
    );


    print(
      "👂 HOME UPDATE LISTENER ATTACHED",
    );


  }


  //////////////////////////////////////////////////////////////////
  void listenProductUpdated(
    Function(dynamic data) callback,
) {

  if(socket == null){
    print("Socket not initialized");
    return;
  }


  socket!.off(
    'product_updated',
  );


  socket!.on(
    'product_updated',
    callback,
  );


  print(
    "👂 PRODUCT UPDATE LISTENER ATTACHED",
  );

}


//////////////////////////////////////////////////
void listenCartUpdated(
  Function(dynamic) callback,
) {

  socket?.off("cart_updated");

  socket?.on(
    "cart_updated",
    callback,
  );

  print("👂 CART UPDATE LISTENER ATTACHED");
}







  void dispose(){


    socket?.dispose();


    socket = null;


  }



}