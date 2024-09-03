import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // Initialize Firebase

  final FirebaseFirestore firestore =
      FirebaseFirestore.instance; // Get Firestore instance

  runApp(MaterialApp(
    title: 'Firestore Example',
    home:
        MyHomePage.withFirestore(firestore: firestore), // Use named constructor
  ));
}

class MyHomePage extends StatelessWidget {
  // Named constructor
  const MyHomePage.withFirestore({Key? key, required this.firestore})
      : super(key: key);

  // Default constructor
  MyHomePage.defaultInstance({Key? key})
      : firestore = FirebaseFirestore.instance,
        super(key: key);

  final FirebaseFirestore firestore;

  CollectionReference get messages => firestore.collection('messages');

  Future<void> _addMessage() async {
    await messages.add(<String, dynamic>{
      'message': 'Hello world!',
      'created_at': FieldValue.serverTimestamp(),
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Firestore Example'),
      ),
      body: MessageList(firestore: firestore), // Pass Firestore to MessageList
      floatingActionButton: FloatingActionButton(
        onPressed: _addMessage,
        tooltip: 'Add Message',
        child: const Icon(Icons.add),
        backgroundColor: Colors.teal, // Change button color
        foregroundColor: Colors.white, // Change icon color
        elevation: 8.0, // Change elevation
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0), // Change shape
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation
          .endTop, // Positioning the button at the bottom center
    );
  }
}

class MessageList extends StatefulWidget {
  const MessageList({Key? key, required this.firestore})
      : super(key: key);

  final FirebaseFirestore firestore;

  @override
  _MessageListState createState() => _MessageListState();
}

class _MessageListState extends State<MessageList> {
  final TextEditingController _messageController = TextEditingController();

  Future<void> _sendMessage() async {
    final String message = _messageController.text.trim();
    if (message.isNotEmpty) {
      await widget.firestore.collection('messages').add({
        'message': message,
        'created_at': FieldValue.serverTimestamp(),
      });
      _messageController.clear(); // Clear the input field
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: widget.firestore.collection('messages').snapshots(),
            builder:
                (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (!snapshot.hasData)
                return const Center(child: Text('Loading...'));
              final int messageCount = snapshot.data!.docs.length;
              return ListView.builder(
                itemCount: messageCount,
                itemBuilder: (_, int index) {
                  final DocumentSnapshot document = snapshot.data!.docs[index];
                  final String message =
                      document['message'] ?? '<No message retrieved>';
                  return ListTile(
                    title: Text(message),
                    subtitle: Text('Message ${index + 1} of $messageCount'),
                  );
                },
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
                    hintText: 'Enter your message',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 8.0),
              ElevatedButton(
                onPressed: _sendMessage,
                child: Text('Send'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _messageController
        .dispose(); // Clean up the controller when the widget is disposed
    super.dispose();
  }
}
