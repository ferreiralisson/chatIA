import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main(){
  runApp(ChatApp());
}

class ChatApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Chat app',
      theme: ThemeData(
        primarySwatch: Colors.blue
      ),
      home: ChatScreen(),
    );
  }
}

class ChatScreen extends StatefulWidget {
    @override
    _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<String> _messages = [];
  final ScrollController _scrollController = ScrollController();

  void _sendMessage() async {
    if(_controller.text.isNotEmpty) {
      String question = _controller.text;

      setState(() {
        _messages.add("$question");
        _controller.clear();
      });

      try {
        final response = await http.post(
          Uri.parse('http://localhost:8080/ask'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'question': question}),
        );

        if(response.statusCode == 200) {
          String answer = jsonDecode(response.body)['response'] ?? 'sem resposta';

          setState(() {
            _messages.add("$answer");
          });
        } else {
          setState(() {
            _messages.add("Erro: ${response.statusCode}");
          });
        }
      } catch (e) {
          setState(() {
            _messages.add("Erro ao se conectar no servidor");
          });
      }
    }

    _scrollToBottom();
  }

  void _scrollToBottom(){
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent, 
      duration: const Duration(microseconds: 300), 
      curve: Curves.easeOut
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter IA', 
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold
        ),),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final isSentByMe = index % 2 == 0;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
                  child: Align(
                    alignment: isSentByMe ? Alignment.centerLeft : Alignment.centerRight,
                    child: Container(
                      decoration: BoxDecoration(
                        color: isSentByMe ? Colors.blue[200] : Colors.grey[300],
                        borderRadius: BorderRadius.circular(15).copyWith(
                          topLeft: isSentByMe ? const Radius.circular(15) : Radius.circular(0),
                          topRight: isSentByMe? const Radius.circular(0) : Radius.circular(15),
                        )
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10.0),
                      child: Text(
                        _messages[index],
                        style: TextStyle(
                          color: isSentByMe ? Colors.white : Colors.black87
                        ),
                      ),
                    ),
                  ),
                );

              }
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 25.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: InputDecoration(
                        hintText: 'Digite sua mensagem...',
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide.none
                        )
                      ),
                    )
                    ),
                    const SizedBox(width: 5),
                    GestureDetector(
                      onTap: _sendMessage,
                      child: Container(
                        padding: const EdgeInsets.all(21),
                        decoration: const BoxDecoration(
                          color: Colors.blueAccent,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.send, color: Colors.white,),
                      ),
                    )
                ],
              ),
              )
        ],
      ),
      backgroundColor: Colors.grey[200],
    );
  }
}