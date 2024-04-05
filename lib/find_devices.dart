import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ping_discover_network_forked/ping_discover_network_forked.dart';
import 'package:remotemouse/mouse_control.dart';
import 'package:remotemouse/socket_client.dart';

class FindDevicesScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _FindDevicesScreenState();
}

class _FindDevicesScreenState extends State<FindDevicesScreen> {
  List<String> ipAddresses = [];
  List<String> hosts = [];

  Completer<void>? _completer;

  bool isRefreshing = false;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Remote Mouse'),
        ),
        body: Column(
          children: [
            Expanded(
                child: isRefreshing
                    ? const Center(
                        child: CircularProgressIndicator(),
                      )
                    : RefreshIndicator(
                        onRefresh: scanNetwork,
                        child: ListView.builder(
                          itemCount: hosts.length,
                          itemBuilder: (context, index) {
                            return GestureDetector(
                              onTap: () => connectToDevice(hosts[index]),
                              child: Card(
                                  child: ListTile(
                                title: Text(hosts[index]
                                    .substring(0, hosts[index].indexOf(":"))),
                              )),
                            );
                          },
                        ))),
            ElevatedButton(
                onPressed: isRefreshing ? null : scanNetwork,
                child: Text("Find Devices"))
          ],
        ),
      ),
    );
  }

  void connectToDevice(String host) async {
    String ip = host.substring(host.indexOf(":") + 1);
    String name = host.substring(0, host.indexOf(":"));
    bool result = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => MouseControlPage(ip: ip, name: name)));

    if (result != null && result) {
      SocketClient.instance.disconnectFromServer();
    }
  }

  Future<void> getHostnames() async {
    for (final ip in ipAddresses) {
      await SocketClient.getHostname(ip).then((value) => setState(() {
            hosts.add("$value:$ip");
          }));
    }

    setState(() {
      isRefreshing = false;
    });
    _completer!.complete();
  }

  Future<void> scanNetwork() async {
    setState(() {
      isRefreshing = true;
    });
    _completer = Completer();
    ipAddresses = [];
    hosts = [];
    await getIps();
    getHostnames();
    return _completer!.future;
  }

  Future<void> getHosts() async {
    const platform = MethodChannel('network_scan');

    try {
      final List<String> addr = await platform.invokeMethod('hostnames');
      hosts = addr;
    } on PlatformException catch (e) {
      print("Failed to scan network: '${e.message}'.");
    }
  }

  Future<void> getIps() async {
    final stream = NetworkAnalyzer.discover2('192.168.0', 1999);
    Completer<void> completer = Completer();

    stream.listen((NetworkAddress addr) {
      if (addr.exists) {
        // print(addr.toString());
        // print('Found device: ${addr.ip}:1999');
        ipAddresses.add(addr.ip);
      }
    }).onDone(() => completer.complete());

    return completer.future;
  }
}
