
import 'package:flutter/material.dart';

import 'package:socket_io_client/socket_io_client.dart' as IO;

enum ServerStatus {
  online,
  offline,
  connecting
}

class SocketService with ChangeNotifier{
  ServerStatus _serverStatus = ServerStatus.connecting;
  late IO.Socket _socket;

  // -----------------------------------------------------------------------------
  SocketService(){
    _initConfig(); 
  }

  // -----------------------------------------------------------------------------
  // gets
  ServerStatus get serverStatus => _serverStatus;
  IO.Socket get socket => _socket;
  Function get emit => _socket.emit;

  // -----------------------------------------------------------------------------
    void _initConfig(){
      _socket = IO.io('http://localhost:3000/', {
          'transports': ['websocket'],
          'autoConnect' : true
        }
      );

      _socket.on('connect', (_) {
        _serverStatus = ServerStatus.online;
        notifyListeners();
      });
      
      _socket.on('disconnect', (_){
        _serverStatus = ServerStatus.offline;
        notifyListeners();
      });

      _socket.on('nuevo-mensaje', ( payload ){
        print('Nombre: ' + payload['nombre']);
        print('Mensaje: ' + payload['mensaje']);
      });
    }

  // -----------------------------------------------------------------------------
  // -----------------------------------------------------------------------------
}