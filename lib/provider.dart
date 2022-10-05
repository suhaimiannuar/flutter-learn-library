import 'package:flutter/material.dart';
import 'package:flutterapp/provider/counter_provider.dart';
import 'package:provider/provider.dart';

class ProviderPage extends StatelessWidget {
  const ProviderPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Provider Experiment"),
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: () => context.read<Counter>().decrement(),
            key: const Key('Decrement floating action'),
            tooltip: 'Decrement',
            heroTag: null,
            child: const Icon(Icons.remove),
          ),
          const SizedBox(
            width: 10.0,
          ),
          FloatingActionButton(
            onPressed: () => context.read<Counter>().increment(),
            key: const Key('Increment floating action'),
            tooltip: 'Increment',
            heroTag: null,
            child: const Icon(Icons.add),
          ),


        ],
      ),
      body: Center(
        child: Column(
          children: [
            Text("Hello ${context.watch<Counter>().count}"),
            Count()
          ],
        ),

      ),
    );
  }
}


class Count extends StatelessWidget {
  const Count({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
        '${context.watch<Counter>().count}',
        key: const Key('counterState'),
    );
  }
}
