import 'package:flutter/material.dart';

class ClockApp extends StatelessWidget {
  const ClockApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Map Examples',
      theme: ThemeData(
        primarySwatch: Colors.purple,
      ),
      home: const ClockPage(),
    );
  }
}

class ClockPage extends StatefulWidget {
  const ClockPage({Key? key}) : super(key: key);

  @override
  State<ClockPage> createState() => _ClockPageState();
}

class _ClockPageState extends State<ClockPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Stream Examples'),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.refresh),
        onPressed: (){
          setState(() {
          });
        },
      ),
      body: Center(
        child: StreamBuilder<int?>(
          stream: getNumbers(),
          builder: (context, snapshot){
            if(snapshot.connectionState == ConnectionState.waiting) {
              return const Text('Wait.');
            }
            else if(snapshot.hasData) {
              int number = snapshot.data!;
              return Text("Value: $number");
            }
            else{
              return const Text("No data.");
            }
          },
        ),
      ),
    );
  }

  Stream<int?> getNumbers() async*{
    await Future.delayed(const Duration(seconds: 4));
    yield 1;

    await Future.delayed(const Duration(seconds: 1));
    yield 2;

    await Future.delayed(const Duration(seconds: 1));
    yield 3;
  }
}

