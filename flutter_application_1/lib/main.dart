import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(MainApp());
}

class MainApp extends StatelessWidget {
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Meu app',
      debugShowCheckedModeBanner: false,
      home: ApiExampleScreen(),
    );
  }
}


class ApiExampleScreen extends StatefulWidget {
  @override
  _MainState createState() => _MainState();
}

class _MainState extends State<ApiExampleScreen> {
  int contador = 0;

  void incrementar() {
    setState(() {
      contador++;
    });
  }


  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('Valor: $contador'),
        ElevatedButton(
          onPressed: incrementar, 
          child: Text('Incrementar'),
          )
      ],
    );
  }
}

Future<dynamic> getPostsStream() async {
  final response = await http.get(
    Uri.parse('https://jsonplaceholder.typicode.com/posts/1'),
  );

  if (response.statusCode == 200) {
    return jsonDecode(response.body);
  } else {
    return {"error": true};
  }
}
