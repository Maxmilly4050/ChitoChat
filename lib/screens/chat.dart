import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ChitoChat'),
        actions: [
          IconButton(
            onPressed: () {
              FirebaseAuth.instance.signOut();
            },
            icon: Icon(Icons.logout, color: Theme.of(context).colorScheme.secondary),
          ),
        ],
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      ),
      body: const Center(
        child: Text('Let\'s chat!'),
      ),
    );
  }
}