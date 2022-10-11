import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:serial_port_win32/serial_port_win32.dart';


class MyApp2 extends StatelessWidget {
  const MyApp2({super.key});
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}


class _MyHomePageState extends State<MyHomePage> {
  var ports = <String>[];
  late SerialPort port;

  final sendData = Uint8List.fromList(List.filled(4, 1, growable: false));

  String data = '';

  void _getPortsAndOpen() {
    ports = SerialPort.getAvailablePorts();
    print(ports);
    if (ports.isNotEmpty) {
      port = SerialPort(ports[0], openNow: false, ReadIntervalTimeout: 1, ReadTotalTimeoutConstant: 2);
      port.open();
      print("am here? ");
      print(port.isOpened);
      // port.readBytesOnListen(8, (value) {
      //   data = value.toString();
      //   print(data);
      //   setState(() {});
      // });

      port.readBytesOnListen(50, (data) => print(String.fromCharCodes(data)));
    }
    setState(() {});
    // setState(() {
    //   ports = SerialPort.getAvailablePorts();
    // });
  }

  void _send(){
    // print(sendData);
    print(port.writeBytesFromUint8List(sendData));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              ports.toString(),
              style: Theme.of(context).textTheme.headline4,
            ),
            Text(data),
            ElevatedButton(
              onPressed: () {
                port.close();
              },
              child: Text("close"),
            ),
            ElevatedButton(
              onPressed: () {
                _send();
              },
              child: Text("write"),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _getPortsAndOpen,
        tooltip: 'GetPorts',
        child: Icon(Icons.search),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}