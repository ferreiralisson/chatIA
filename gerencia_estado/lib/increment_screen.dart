import 'package:flutter/material.dart';
import 'package:gerencia_estado/counter.dart';
import 'package:provider/provider.dart';

class IncrementScreen extends StatelessWidget{

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Incrementar Contador'),
      ),
      body: Center(
        child: ElevatedButton(
        onPressed: () {
          Provider.of<Counter>(context, listen: false).increment();
        }, 
        child: Text('Incrementar')
        ),
      )
    );
  }
}