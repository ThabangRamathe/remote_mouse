import 'dart:async';
import 'package:flutter/material.dart';
import 'package:remotemouse/socket_client.dart';

class MouseControlPage extends StatefulWidget {
  final String ip;
  final String name;

  MouseControlPage({required this.ip, required this.name});

  @override
  _MouseControlPageState createState() => _MouseControlPageState();
}

class _MouseControlPageState extends State<MouseControlPage> {
  Timer? _timer;

  int cursorX = 0;
  int cursorY = 0;

  bool loading = true;

  @override
  void initState() {
    super.initState();
    SocketClient.instance
        .connectToServer(widget.ip)
        .then((data) => processCursorPos(data));
  }

  void processCursorPos(String data) {
    if (data == "") return;

    setState(() {
      cursorX = int.parse(data.substring(0, data.indexOf(",")));
      cursorY = int.parse(data.substring(data.indexOf(",") + 1));
    });
    setState(() {
      loading = false;
    });
  }

  void _moveCursor(int dx, int dy) async {
    cursorX += (dx * 10);
    cursorY += (dy * 10);

    SocketClient.instance.sendCommand('M $cursorY,$cursorY');
  }

  void _leftClick() {
    SocketClient.instance.sendCommand('L');
  }

  void _rightClick() {
    SocketClient.instance.sendCommand('R');
  }

  void _startTimer() {
    _timer = Timer.periodic(Duration(milliseconds: 50), (timer) {
      SocketClient.instance.sendCommand('M $cursorX,$cursorY');
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    SocketClient.instance.disconnectFromServer();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text(widget.name),
        ),
        body: loading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : Column(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onPanStart: (details) {
                        _startTimer();
                      },
                      onPanUpdate: (details) {
                        setState(() {
                          cursorX += details.delta.dx.toInt();
                          cursorY += details.delta.dy.toInt();
                        });
                      },
                      onPanEnd: (details) {
                        _timer?.cancel();
                      },
                      onTap: () {
                        _leftClick();
                      },
                      child: Container(
                        color: Colors.grey[200],
                        child: const Center(
                          child: Text(
                            'Drag to Move Cursor',
                            style: TextStyle(fontSize: 24),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: _leftClick,
                        child: const Text('Left Click'),
                      ),
                      ElevatedButton(
                        onPressed: _rightClick,
                        child: const Text('Right Click'),
                      ),
                    ],
                  ),
                ],
              ),
      ),
    );
  }
}
