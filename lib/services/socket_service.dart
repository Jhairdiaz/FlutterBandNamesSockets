import 'package:flutter/cupertino.dart';
import 'package:socket_io_client/socket_io_client.dart';


enum ServerStatus {
  Online,
  Offline,
  Connecting
}

class SocketService with ChangeNotifier {

  ServerStatus _serverStatus = ServerStatus.Connecting;
  late Socket _socket;

  ServerStatus get serverStatus => _serverStatus;
  Socket get socket => _socket;

  SocketService(){
    _initConfig();
  }

  void _initConfig(){

    // Dart client   
    _socket = io('http://172.17.0.19:3000', 
    OptionBuilder()
      .setTransports(['websocket']) // for Flutter or Dart VM
      .enableAutoConnect()  // disable auto-connection      
      .build()
    );

    _socket.onConnect((_) {      
      _serverStatus = ServerStatus.Online;
      notifyListeners();
    });

    _socket.onDisconnect((_) {
      _serverStatus = ServerStatus.Offline;
      notifyListeners();
    });        

  }

}