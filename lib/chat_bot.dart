import 'dart:convert';
import 'dart:developer';

import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ChatBot extends StatefulWidget {
  const ChatBot({super.key});

  @override
  State<ChatBot> createState() => _ChatBotState();
}

class _ChatBotState extends State<ChatBot> {
  ChatUser currentUser = ChatUser(id: "1", firstName: "Arun");
  ChatUser bot = ChatUser(id: "2", firstName: "Gemini");
  List<ChatMessage> allMessage = [];
  List<ChatUser> typingUsers = [];
  final url =
      "https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent?key=AIzaSyD0PrzHYMqG1O4B_nt2i2IHeXXiq_o0ElI";

  final headers = {'Content-Type': 'application/json'};

  getData(ChatMessage message) async {
    typingUsers.add(bot);
    allMessage.insert(0, message);
    setState(() {});
    var data = {
      "contents": [
        {
          "parts": [
            {"text": message.text}
          ]
        }
      ]
    };
    await http
        .post(Uri.parse(url), headers: headers, body: jsonEncode(data))
        .then((value) {
      if (value.statusCode == 200) {
        var result = jsonDecode(value.body);
        print(result['candidates'][0]['content']["parts"][0]['text']);

        ChatMessage m1 = ChatMessage(
          text: result['candidates'][0]['content']["parts"][0]['text'],
          user: bot,
          createdAt: DateTime.now(),
        );

        allMessage.insert(0, m1);
        setState(() {});
      } else {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Request Time Out')));
        print('Error occred');
      }
    }).catchError((e) {
      log("Errrrorrrr ");
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Something went wrong')));
    });

    typingUsers.remove(bot);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
                image: AssetImage(
                    'asset/desktop-wallpaper-whatsapp-chat-iphone-whatsapp.jpeg'),
                fit: BoxFit.fill),
          ),
          child: Column(
            children: [
              AppBar(
                backgroundColor: Colors.transparent,
                title: const Text(
                  "Google Gemini",
                  style: TextStyle(color: Colors.white),
                ),
                centerTitle: true,
              ),
              Expanded(
                child: DashChat(
                  inputOptions: const InputOptions(
                      inputTextStyle: TextStyle(color: Colors.black)),
                  typingUsers: typingUsers,
                  currentUser: currentUser,
                  onSend: (ChatMessage message) {
                    getData(message);
                  },
                  messages: allMessage,
                  messageOptions: const MessageOptions(
                    currentUserContainerColor: Colors.white,
                    currentUserTextColor: Colors.black,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
