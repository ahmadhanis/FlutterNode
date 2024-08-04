import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'socket_service.dart';

class ChatScreen extends StatefulWidget {
  final String currentUserId;
  final String chatUserId;

  const ChatScreen(
      {super.key, required this.currentUserId, required this.chatUserId});

  @override
  ChatScreenState createState() => ChatScreenState();
}

class ChatScreenState extends State<ChatScreen> {
  late SocketService socketService;
  final TextEditingController _messageController = TextEditingController();

  void _sendMessage() {
    final socketService = Provider.of<SocketService>(context, listen: false);
    if (_messageController.text.isNotEmpty) {
      socketService.sendMessage(
          widget.currentUserId, widget.chatUserId, _messageController.text);
      _messageController.clear();
    }
  }

  @override
  void dispose() {
    // socketService = Provider.of<SocketService>(context, listen: false);
    socketService.disconnect();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    socketService = Provider.of<SocketService>(context);
    final messages = socketService.messages
        .where((message) =>
            (message['fromUserId'] == widget.currentUserId &&
                message['toUserId'] == widget.chatUserId) ||
            (message['fromUserId'] == widget.chatUserId &&
                message['toUserId'] == widget.currentUserId))
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: Text('Chat with ${widget.chatUserId}'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: messages.length,
              itemBuilder: (context, index) {
                bool isSentByCurrentUser =
                    messages[index]['fromUserId'] == widget.currentUserId;
                return Container(
                  margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                  alignment: isSentByCurrentUser
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Column(
                    crossAxisAlignment: isSentByCurrentUser
                        ? CrossAxisAlignment.end
                        : CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: isSentByCurrentUser
                              ? Colors.blue
                              : Colors.grey[300],
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          messages[index]['text']!,
                          style: TextStyle(
                            color: isSentByCurrentUser
                                ? Colors.white
                                : Colors.black,
                          ),
                        ),
                      ),
                      SizedBox(height: 5),
                      Text(
                        isSentByCurrentUser
                            ? 'You'
                            : 'From: ${messages[index]['fromUserId']}',
                        style: TextStyle(
                            fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      labelText: 'Enter your message',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
