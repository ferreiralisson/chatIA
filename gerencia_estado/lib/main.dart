
import 'package:flutter/material.dart';
import 'package:gerencia_estado/counter.dart';
import 'package:gerencia_estado/home_screen.dart';
import 'package:provider/provider.dart';

void main(){
  runApp(
    ChangeNotifierProvider(
      create: (_) => Counter(),
      child: MyApp(),
    )
  );
}

class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Contador com Provider',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue
      ),
      home: HomeScreen(),
    );
  }
}