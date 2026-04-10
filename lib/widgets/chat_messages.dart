import 'package:chito_chat/widgets/message_bubble.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChatMessages extends StatelessWidget {
  const ChatMessages({super.key});

  @override
  Widget build(BuildContext context) {
    final authenticatedUser = FirebaseAuth.instance.currentUser;

    return StreamBuilder(
      stream: FirebaseFirestore.instance.collection('chat').orderBy('createdAt', descending: true).snapshots(), 
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('No messages found.'));
        }

        if (snapshot.hasError) {
          return const Center(child: Text('An error occurred while loading messages.'));
        }

        final chatDocs = snapshot.data!.docs;
        return ListView.builder(
          padding: const EdgeInsets.only(top: 20.0, left: 20.0, right: 10.0, bottom: 1.0),
          reverse: true,
          itemCount: chatDocs.length,
          itemBuilder: (context, index) {
            final chatMessage = chatDocs[index].data();
            final nextChatMessage = index + 1 < chatDocs.length ? chatDocs[index + 1].data() : null;
            final isSameUser = nextChatMessage != null && chatMessage['userId'] == nextChatMessage['userId'];

            if(isSameUser){
              return MessageBubble.next(
                message: chatMessage['text'], 
                isMe: chatMessage['userId'] == authenticatedUser!.uid);
            }else{
              return MessageBubble.first(
                userImage: chatMessage['userImage'], 
                username: chatMessage['username'], 
                message: chatMessage['text'], 
                isMe: chatMessage['userId'] == authenticatedUser!.uid);
            }
          },
        );
      },
      );
  }
}