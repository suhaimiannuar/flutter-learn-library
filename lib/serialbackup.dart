import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_libserialport/flutter_libserialport.dart';
import 'dart:io' show Platform, exit;
import 'package:provider/provider.dart';


class SerialPortNow extends StatelessWidget {
  const SerialPortNow({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    SerialPort port = SerialPort(context.watch<SerialSet>().serialNow);
    return Column(
      children: [
        Text(port.description.toString()),
      ],
    );
  }
}


class SerialSet with ChangeNotifier{
  List<String> _serial = [];  //Initialize
  List<String> get serial => _serial;

  String _serialNow = "";
  String get serialNow => _serialNow;

  List<String> _baudOption = [];  //Initialize
  List<String> get baudOption => _baudOption;

  String _baudRate = "";
  String get baudRate => _baudRate;

  String _serialOut = "";
  String get serialOut => _serialOut;

  void serialPrint(String x){
    _serialOut = x + _serialOut;
    if (kDebugMode) {
      print(_serialOut);
    }
    notifyListeners();
  }

  void initBaudRate(){
    _baudOption = ['9600','115200','921600'];
    _baudRate = "115200";

    notifyListeners();
  }

  void setPort(String x) {  //change port here
    if(_serialNow.isNotEmpty){
      if(_serialNow != x){
        SerialPort port = SerialPort(_serialNow);
        port.close();
        _serialNow = x;
        notifyListeners();
      }
    }



  }

  void setBaud(String x) { //change baud rate here
    _baudRate = x;
    if (kDebugMode) {
      print(baudRate);
      print(serialNow);
    }

    notifyListeners();
  }

  void listPort(){
    if(Platform.isWindows || Platform.isLinux || Platform.isMacOS){
      _serial = SerialPort.availablePorts;
      if(_serial.isNotEmpty){
        for(String x in _serial){
          SerialPort port = SerialPort(x);
          port.close();
        }
        _serialNow = _serial.first;
      }

      if (kDebugMode) {
        print("_serialNow: $_serialNow");
      }
    }
    notifyListeners();
  }
}


class SerialApp extends StatelessWidget {
  const SerialApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const RefreshPage();
  }
}

class RefreshPage extends StatefulWidget {
  const RefreshPage({Key? key}) : super(key: key);

  @override
  State<RefreshPage> createState() => _RefreshPageState();
}

class _RefreshPageState extends State<RefreshPage> {

  @override
  void dispose() {
    super.dispose();
  }


  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 10), () {           //delay untuk allow everything is constructed. then baru kita reassign value.
      context.read<SerialSet>().listPort();
      context.read<SerialSet>().initBaudRate();
      print("Init state X");
      if(Provider.of<SerialSet>(context, listen: false).serialNow.isNotEmpty){
        SerialPort port = SerialPort(Provider.of<SerialSet>(context, listen: false).serialNow);
        var config = SerialPortConfig();
        config.baudRate = int.parse(Provider.of<SerialSet>(context, listen: false).baudRate);
        port.config = config;
        try{
          port.openReadWrite();
          SerialPortReader reader = SerialPortReader(port);
          reader.stream.listen((data) {
            print('received : $data');
          });
          Stream<String> upcomingData = reader.stream.map((data){
            return String.fromCharCodes(data);
          });
          upcomingData.listen((data) {
            print("Read data: $data");
          });
        }on SerialPortError catch (err, _){
          if(port.isOpen){
            print(SerialPort.lastError);
            port.close();
          }
        }
      }

    });
  }

  Uint8List _stringToUint8List(String s) {
    List<int> list = s.codeUnits;
    Uint8List bytes = Uint8List.fromList(list);
    return bytes;
  }


  @override
  Widget build(BuildContext context) {

    final Future<List<String>> getItem = Future<List<String>>.delayed(
      const Duration(milliseconds: 10),
          () => Provider.of<SerialSet>(context, listen: false).serial,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text("Serial App"),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.read<SerialSet>().listPort(),
        child: const Icon(Icons.refresh),
      ),
      body: Center(
        child: Column(
          children: [
            FutureBuilder(
                future: getItem,
                builder: (BuildContext context, AsyncSnapshot<List<String>> snapshot){
                  List<Widget> item;
                  if(snapshot.hasData){
                    item = <Widget>[
                      DropdownButton<String>(
                          value: context.watch<SerialSet>().serialNow,
                          items: context.watch<SerialSet>().serial.map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                          onChanged: (value) {
                            context.read<SerialSet>().setPort(value!);
                          }),
                      DropdownButton<String>(
                          value: context.watch<SerialSet>().baudRate,
                          items: context.watch<SerialSet>().baudOption.map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                          onChanged: (value) {
                            context.read<SerialSet>().setBaud(value!);
                          }),
                    ];
                  }
                  else if(snapshot.hasError){
                    item = <Widget>[
                      const Icon(
                        Icons.error_outline,
                        color: Colors.red,
                        size: 60,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 16),
                        child: Text('Error: ${snapshot.error}'),
                      ),
                    ];
                  }
                  else{
                    item = const <Widget>[
                      SizedBox(
                        width: 50,
                        height: 50,
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 16),
                        child: Text('Awaiting result...'),
                      )
                    ];
                  }
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: item,
                    ),
                  );
                }),
            const SerialPortNow(),
          ],
        ),
      ),
    );
  }
}




// class SerialPage2 extends StatefulWidget {
//   const SerialPage2({Key? key}) : super(key: key);
//
//   @override
//   State<SerialPage2> createState() => _SerialPage2State();
// }
//
// class _SerialPage2State extends State<SerialPage2> {
//
//   void _reset() {
//     setState(() {
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     List<String> availablePort = SerialPort.availablePorts;
//     var serialOut = "Test";
//
//     print(availablePort);
//     SerialPort port1 = SerialPort('COM4');
//
//     port1.openReadWrite();
//     var config = SerialPortConfig();
//     config.baudRate = 115200;
//     port1.config = config;
//
//     try{
//       print('Written Bytes: ${port1.write(_stringToUint8List('Hello'))}');
//       SerialPortReader reader = SerialPortReader(port1);
//       Stream<String> upcomingData = reader.stream.map((data){
//         return String.fromCharCodes(data);
//       });
//       upcomingData.listen((data) {
//         print("Read data: $data");
//
//         if(data.indexOf("ECAIQ,VER*32") >= 0){
//           print("Found ecaiq ver");
//           port1.write(_stringToUint8List("\$ANVER,4,1,3,AN,AMC,995339998,A8K300145,,,*3D"));
//         }
//       });
//     }on SerialPortError catch (err, _){
//       print(SerialPort.lastError);
//       port1.close();
//     }
//
//     return MaterialApp(
//       home: Scaffold(
//         floatingActionButton: FloatingActionButton(
//           onPressed: _reset,
//           tooltip: 'Refresh',
//           child: const Icon(Icons.refresh),
//         ),
//         appBar: AppBar(
//           title: const Text("Serial Communication"),
//         ),
//         body: Scrollbar(
//           child: Column(
//             children:  [
//               Text(serialOut)
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   Uint8List _stringToUint8List(String s) {
//     List<int> list = s.codeUnits;
//     Uint8List bytes = Uint8List.fromList(list);
//     return bytes;
//   }
// }
//
//
//
// class SerialPage extends StatefulWidget {
//   const SerialPage({Key? key}) : super(key: key);
//
//   @override
//   State<SerialPage> createState() => _SerialPageState();
// }
//
//
// extension IntToString on int {
//   String toHex() => '0x${toRadixString(16)}';
//   String toPadded([int width = 3]) => toString().padLeft(width, '0');
//   String toTransport() {
//     switch (this) {
//       case SerialPortTransport.usb:
//         return 'USB';
//       case SerialPortTransport.bluetooth:
//         return 'Bluetooth';
//       case SerialPortTransport.native:
//         return 'Native';
//       default:
//         return 'Unknown';
//     }
//   }
// }
//
//
//
// class _SerialPageState extends State<SerialPage> {
//   var availablePorts = [];
//
//   @override
//   void initState() {
//     super.initState();
//     initPorts();
//   }
//
//   void initPorts() {
//     setState(() => availablePorts = SerialPort.availablePorts);
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       home: Scaffold(
//         appBar: AppBar(
//           title: const Text('Flutter Serial Port example'),
//         ),
//         body: Scrollbar(
//           child: ListView(
//             children: [
//               for (final address in availablePorts)
//                 Builder(builder: (context) {
//                   final port = SerialPort(address);
//                   return ExpansionTile(
//                     title: Text(address),
//                     children: [
//                       CardListTile('Description', port.description),
//                       CardListTile('Transport', port.transport.toTransport()),
//                       CardListTile('USB Bus', port.busNumber?.toPadded()),
//                       CardListTile('USB Device', port.deviceNumber?.toPadded()),
//                       CardListTile('Vendor ID', port.vendorId?.toHex()),
//                       CardListTile('Product ID', port.productId?.toHex()),
//                       CardListTile('Manufacturer', port.manufacturer),
//                       CardListTile('Product Name', port.productName),
//                       CardListTile('Serial Number', port.serialNumber),
//                       CardListTile('MAC Address', port.macAddress),
//                     ],
//                   );
//                 }),
//             ],
//           ),
//         ),
//         floatingActionButton: FloatingActionButton(
//           child: Icon(Icons.refresh),
//           onPressed: initPorts,
//         ),
//       ),
//     );
//   }
// }
//
// class CardListTile extends StatelessWidget {
//   final String name;
//   final String? value;
//
//   const CardListTile(this.name, this.value);
//
//   @override
//   Widget build(BuildContext context) {
//     return Card(
//       child: ListTile(
//         title: Text(value ?? 'N/A'),
//         subtitle: Text(name),
//       ),
//     );
//   }
// }