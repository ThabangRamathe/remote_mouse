import 'dart:core';
import 'dart:io';
import 'dart:async';

class SocketClient {
  SocketClient._privateConstructor();

  static final SocketClient _instance = SocketClient._privateConstructor();

  static SocketClient get instance => _instance;

  static const _PORT = 1999;
  static Socket? _socket;
  bool connected = false;
  static const String commandEnd = "!";

  Future<String> connectToServer(String ip) async {
    Completer<String> completer = Completer();
    try {
      _socket = await Socket.connect(ip, _PORT);
      connected = true;
      await fetchData("pos").then((data) => completer.complete(data));
    } catch (e) {
      print("failed");
    }
    return completer.future;
  }

  void sendCommand(String command) async {
    if (_socket != null && connected) {
      _socket!.write("$command$commandEnd");
    }
  }

  Future<String> fetchData(String command) {
    Completer<String> completer = Completer();

    if (_socket != null && connected) {
      _socket!.write("$command$commandEnd");
      _socket!.listen((data) {
        completer.complete(String.fromCharCodes(data).trim());
      });
    } else {
      completer.complete("");
    }

    return completer.future;
  }

  bool isConnected() {
    return _socket != null && connected;
  }

  void disconnectFromServer() async {
    if (_socket != null && connected) {
      _socket!.close();
      _socket = null;
      connected = false;
    }
  }

  static Future<String> getHostname(String ip) {
    Completer<String> completer = Completer();

    Socket.connect(ip, _PORT).then((socket) {
      socket.write("name$commandEnd");
      socket.listen((data) {
        completer.complete(String.fromCharCodes(data).trim());
      }, onDone: () {
        socket.close();
      });
    });

    return completer.future;
  }
}
