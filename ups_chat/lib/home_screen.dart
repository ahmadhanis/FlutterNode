import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ups_chat/chat_screen.dart';
import 'package:ups_chat/login_screen.dart';
import 'socket_service.dart';

class HomeScreen extends StatefulWidget {
  final String userId;
  final String userName;

  const HomeScreen({super.key, required this.userId, required this.userName});

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  late SocketService socketService;
  @override
  void initState() {
    super.initState();
    socketService = Provider.of<SocketService>(context, listen: false);
    socketService.connect();
    socketService.join(widget.userId);
  }

  @override
  void dispose() {
    // socketService = Provider.of<SocketService>(context, listen: false);
    socketService.disconnect();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // socketService = Provider.of<SocketService>(context, listen: false);
    socketService.connect();
    socketService.join(widget.userId);
  }

  void _logout() async {
    // socketService = Provider.of<SocketService>(context, listen: false);
    if (mounted) {
      await socketService.logout(widget.userId);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // socketService = Provider.of<SocketService>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('UPS Chat'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Logged in as: ${widget.userName} (ID: ${widget.userId})',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(child: Consumer<SocketService>(
            builder: (context, socketService, child) {
              final filteredUsers = socketService.users
                  .where((user) => user != widget.userId)
                  .toList();
              return ListView.builder(
                itemCount: filteredUsers.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    leading: Icon(Icons.person), // User icon on the left
                    title: Text(filteredUsers[index]),
                    trailing:
                        Icon(Icons.arrow_forward), // Arrow icon on the right
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChatScreen(
                            currentUserId: widget.userId,
                            chatUserId: filteredUsers[index],
                          ),
                        ),
                      );
                    },
                  );
                },
              );
            },
          )),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: _logout,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                padding:
                    const EdgeInsets.symmetric(vertical: 15, horizontal: 30),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Logout', style: TextStyle(fontSize: 16)),
            ),
          ),
        ],
      ),
    );
  }
}
