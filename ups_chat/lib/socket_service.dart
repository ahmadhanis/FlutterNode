import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SocketService with ChangeNotifier {
  late IO.Socket socket;
  List<String> users = [];
  List<Map<String, String>> messages = [];
  Set<String> messageIds = {}; // Set to keep track of received message IDs

  void connect() {
    print('Attempting to connect to the socket server...');
    socket = IO.io('https://ups.soc-conferences.com/', <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': true,
    });

    socket.connect();

    socket.on('connect', (_) {
      print('Connected to the socket server');
    });

    socket.on('disconnect', (_) {
      print('Disconnected from the socket server');
    });

    socket.on('connect_error', (error) {
      print('Connection Error: $error');
    });

    socket.on('connect_timeout', (_) {
      print('Connection Timeout');
    });

    socket.on('error', (error) {
      print('Error: $error');
    });

    socket.on('reconnect', (_) {
      print('Reconnected to the server');
    });

    socket.on('reconnect_attempt', (_) {
      print('Reconnection Attempt');
    });

    socket.on('reconnecting', (attemptNumber) {
      print('Reconnecting... Attempt #$attemptNumber');
    });

    socket.on('reconnect_failed', (_) {
      print('Reconnection Failed');
    });

    socket.on('user_list', (data) {
      users = List<String>.from(data);
      notifyListeners();
    });

    // Listen for incoming messages
    socket.on('message', (data) {
      String messageId =
          '${data['fromUserId']}-${data['toUserId']}-${data['text']}';
      if (!messageIds.contains(messageId)) {
        messages.add({
          'fromUserId': data['fromUserId'],
          'toUserId': data['toUserId'],
          'text': data['text'],
        });
        messageIds.add(messageId);
        notifyListeners();
      }
    });
  }

  void join(String userId) {
    socket.emit('join', userId);
    print('User $userId joined the chat');
  }

  void sendMessage(String fromUserId, String toUserId, String text) {
    socket.emit('message',
        {'fromUserId': fromUserId, 'toUserId': toUserId, 'text': text});
    print('Message sent from $fromUserId to $toUserId: $text');
  }

  void disconnect() {
    socket.disconnect();
    print('Socket disconnected');
  }

  Future<void> logout(String username) async {
    final response = await http.post(
      Uri.parse('https://ups.soc-conferences.com/logout'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'username': username,
      }),
    );

    if (response.statusCode == 200) {
      var jsonResponse = jsonDecode(response.body);
      if (jsonResponse['success']) {
        disconnect();
      } else {
        print('Logout failed: ${jsonResponse['message']}');
      }
    } else {
      print('Error logging out. Status code: ${response.statusCode}');
    }
  }
}
