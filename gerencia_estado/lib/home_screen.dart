import 'package:flutter/material.dart';
import 'package:gerencia_estado/counter.dart';
import 'package:gerencia_estado/increment_screen.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Contador com Provider')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Contador'),
            Consumer<Counter>(
              builder: (context, counter, child) {
                return Text('${counter.count}', style: TextStyle(fontSize: 48));
              },
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => IncrementScreen()
                    )
                  );
              }, 
              child: Text('Incrementar')
              ),
          ],
        ),
      ),
    );
  }
}
