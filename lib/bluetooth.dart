import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class BluetoothApp extends StatelessWidget {
  const BluetoothApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bluetooth Examples',
      theme: ThemeData(
        primarySwatch: Colors.purple,
      ),
      home: const BLEPage(),
    );
  }
}

class BLEPage extends StatefulWidget {
  const BLEPage({Key? key}) : super(key: key);

  @override
  State<BLEPage> createState() => _BLEPageState();
}

class _BLEPageState extends State<BLEPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('BLE Examples'),
      ),
      body: Column(
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    ble();
  }

  void ble(){
    FlutterBluePlus flutterBlue = FlutterBluePlus.instance;

    flutterBlue.state.listen((event) async {
      if(event == BluetoothState.off){

      }
      else if(event == BluetoothState.on){
        print("BLE IS ON!");
        scanForDevices(flutterBlue);
      }
    });
  }


  void scanForDevices(FlutterBluePlus flutterBlue) async{
    flutterBlue.scan().listen((scanResult) async{
      print(scanResult);
    });

    flutterBlue.stopScan();
  }
}




