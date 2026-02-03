import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:studybuddy/mentor_profile.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:studybuddy/main_screen.dart';
import 'package:studybuddy/mentor_profile.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Main Chat Screen Widget
class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});
  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<Content> _chatHistory = []; // For AI model's context
  final user = FirebaseAuth.instance.currentUser;

  String? _currentChatId;
  late final GenerativeModel _model;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initAI();
    _loadOrCreateChat();
  }

  void _initAI() {
    // 🚨 IMPORTANT: Do NOT hardcode your API key in the code.
    // Use environment variables. Run your app from the terminal like this:
    // flutter run --dart-define="API_KEY=YOUR_GEMINI_API_KEY"
    const apiKey = 'AIzaSyAllpEr4MOwc4onaHo0IiZhHkjbg3-1-kA';
    if (apiKey.isEmpty) {
      throw Exception('API_KEY is not set in environment variables');
    }

    _model = GenerativeModel(
      model: 'gemini-1.5-flash', // A powerful and efficient model
      apiKey: apiKey,
      systemInstruction: Content.text("""
        You are Sensai, an expert and friendly AI mentor.
        - First, always provide a helpful, direct answer to the student's query.
        - If the query is a simple greeting or conversation, just chat naturally.
        - If the query is about a technical skill or an error, provide a concise solution or explanation.
        - Do not mention mentors or suggesting them in your response; that is handled separately by the application.
        - Do not give any unecessary datas like jokes, weathers, etc
        - suggest Mentors to student in which he/she has doubts.
      """),
    );
  }

  Future<void> _loadOrCreateChat() async {
    if (user == null) return;
    final chatsCol = FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .collection('chats');

    // Get the most recent chat to continue
    final snap =
        await chatsCol.orderBy('createdAt', descending: true).limit(1).get();

    if (snap.docs.isEmpty) {
      // Create a new chat if none exist
      final newChat = await chatsCol.add({
        'title': 'New Chat',
        'createdAt': FieldValue.serverTimestamp(),
      });
      setState(() => _currentChatId = newChat.id);
    } else {
      setState(() => _currentChatId = snap.docs.first.id);
    }
  }

  Future<void> _sendMessage() async {
    if (_controller.text.trim().isEmpty ||
        _currentChatId == null ||
        _isLoading) {
      return;
    }

    setState(() => _isLoading = true);
    final userMessage = _controller.text.trim();
    _controller.clear();

    final messagesCol = FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .collection('chats')
        .doc(_currentChatId!)
        .collection('messages');

    // 1. Save user's message to Firestore
    await messagesCol.add({
      'text': userMessage,
      'sender': 'user',
      'timestamp': FieldValue.serverTimestamp(),
    });
    _scrollToBottom();
    _chatHistory.add(Content.text(userMessage));

    // 2. Add a temporary "typing" message for better UX
    final typingDoc = await messagesCol.add({
      'sender': 'bot',
      'isTyping': true,
      'timestamp': FieldValue.serverTimestamp(),
    });

    try {
      // 3. Get the text-only response from the AI
      final chat = _model.startChat(history: _chatHistory);
      final response = await chat.sendMessage(Content.text(userMessage));
      final botText = response.text ?? "Sorry, I couldn't process that.";
      _chatHistory.add(
        Content.model([TextPart(botText)]),
      ); // Update history for context

      // 4. Replace the "typing" message with the actual AI response
      await typingDoc.update({'text': botText, 'isTyping': false});
      _scrollToBottom();

      // 5. Check for skills and fetch mentors
      final detectedSkills = _extractSkills(userMessage);
      if (detectedSkills.isNotEmpty) {
        final mentors = await _fetchMentorsBySkills(detectedSkills);
        if (mentors.isNotEmpty) {
          // 6. Send a NEW, SEPARATE message containing only the mentor data
          await messagesCol.add({
            'sender': 'bot',
            'timestamp': FieldValue.serverTimestamp(),
            'mentors': mentors,
            'introText':
                "Based on your question, here are some mentors who can help:",
          });
        }
      }
    } catch (e) {
      print("Error sending message: $e");
      await typingDoc.update({
        'text': '⚠️ An error occurred. Please try again later.',
        'isTyping': false,
      });
    } finally {
      setState(() => _isLoading = false);
      _scrollToBottom();
    }
  }

  List<String> _extractSkills(String message) {
    const skills = [
      'Python',
      'Flutter',
      'Data Science',
      'Machine Learning',
      'Web',
      'Firebase',
      'UI/UX',
    ];
    final foundSkills = <String>{}; // Use a Set to store unique skills
    for (final skill in skills) {
      if (message.toLowerCase().contains(skill.toLowerCase())) {
        foundSkills.add(skill);
      }
    }
    return foundSkills.toList();
  }

  Future<List<Map<String, dynamic>>> _fetchMentorsBySkills(
    List<String> skills,
  ) async {
    final query =
        await FirebaseFirestore.instance
            .collection('mentors')
            .where('skills', arrayContainsAny: skills)
            .limit(5) // Limit the number of mentors suggested
            .get();

    final uniqueMentors = <String, Map<String, dynamic>>{};
    for (final doc in query.docs) {
      final data = doc.data();
      data['id'] = doc.id;
      uniqueMentors[doc.id] =
          data; // Using a map automatically handles duplicates
    }
    return uniqueMentors.values.toList();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Sensai Chat"),
        backgroundColor: Theme.of(context).cardColor,
        elevation: 1,
      ),
      body: Column(
        children: [
          Expanded(
            child:
                _currentChatId == null
                    ? const Center(child: CircularProgressIndicator())
                    : StreamBuilder<QuerySnapshot>(
                      stream:
                          FirebaseFirestore.instance
                              .collection('users')
                              .doc(user!.uid)
                              .collection('chats')
                              .doc(_currentChatId!)
                              .collection('messages')
                              .orderBy('timestamp')
                              .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                          return const Center(child: Text("Ask me anything!"));
                        }
                        final docs = snapshot.data!.docs;
                        return ListView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.all(12),
                          itemCount: docs.length,
                          itemBuilder: (context, index) {
                            final data =
                                docs[index].data() as Map<String, dynamic>;

                            if (data['isTyping'] == true) {
                              return const TypingIndicator();
                            }

                            if (data['mentors'] != null) {
                              final mentors =
                                  (data['mentors'] as List<dynamic>)
                                      .cast<Map<String, dynamic>>();
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (data['introText'] != null)
                                    Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                        16,
                                        8,
                                        0,
                                        8,
                                      ),
                                      child: Text(
                                        data['introText'],
                                        style: TextStyle(
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                    ),
                                  ...mentors
                                      .map(
                                        (mentor) => MentorCard(mentor: mentor),
                                      )
                                      ,
                                ],
                              );
                            }

                            return ChatBubble(data: data);
                          },
                        );
                      },
                    ),
          ),
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            offset: const Offset(0, -1),
            blurRadius: 3,
            color: Colors.black.withOpacity(0.05),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  hintText: "Message Sensai...",
                  filled: true,
                  fillColor: Colors.grey.shade200,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                ),
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
            const SizedBox(width: 8),
            IconButton.filled(
              style: IconButton.styleFrom(padding: const EdgeInsets.all(12)),
              icon:
                  _isLoading
                      ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                      : const Icon(Icons.send),
              onPressed: _isLoading ? null : _sendMessage,
            ),
          ],
        ),
      ),
    );
  }
}

// ---- Reusable UI Widgets ----

class ChatBubble extends StatelessWidget {
  final Map<String, dynamic> data;
  const ChatBubble({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final isUser = data['sender'] == 'user';
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isUser ? Colors.blue : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          data['text'] ?? '',
          style: TextStyle(color: isUser ? Colors.white : Colors.black87),
        ),
      ),
    );
  }
}

class TypingIndicator extends StatelessWidget {
  const TypingIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Text("Sensai is typing..."),
      ),
    );
  }
}

class MentorCard extends StatelessWidget {
  final Map<String, dynamic> mentor;
  const MentorCard({super.key, required this.mentor});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: NetworkImage(
            mentor['avatar'] ??
                'https://placehold.co/100x100/A0C4FF/000000?text=NA',
          ),
        ),
        title: Text(mentor['firstName'] ?? 'Unnamed Mentor'),
        subtitle: Text(
          (mentor['skills'] as List<dynamic>?)?.join(', ') ??
              'No skills listed',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          // Navigate to mentor profile, passing the specific mentor's ID
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (_) => MentorProfilePage(
                    mentorUid: mentor['id'],
                    isNavigatedFromMentorsList: true,
                    mentorData: {},
                  ),
            ),
          );
        },
      ),
    );
  }
}

class MentorsListPage extends StatefulWidget {
  const MentorsListPage({super.key});

  @override
  State<MentorsListPage> createState() => _MentorsListPageState();
}

class _MentorsListPageState extends State<MentorsListPage> {
  int _selectedIndex = 1; // Set initial index to 1 for Mentors tab

  // List of widgets to display for each navigation bar item
  static final List<Widget> _pages = <Widget>[
    const Text(
      'Home Page',
      style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
    ),
    _MentorsListContent(), // The content of the mentors list page
    const Text(
      'Booking Page',
      style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
    ),
    const Text(
      'Profile Page',
      style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
    ),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    // Handle navigation based on the selected index
    if (index == 0) {
      // Navigate to Home Page
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const HomeScreen(),
        ), //changes(main screen)
      );
    } else if (index == 3) {
      // Navigate to Mentor Profile Page (for the current user)
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (context) => MentorProfilePage(
                  mentorUid: user.uid,
                  mentorData: {},
                  isNavigatedFromMentorsList: true,
                ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mentors')),
      body: _pages[_selectedIndex],
    );
  }
}

// Separate the list content into a new StatelessWidget
class _MentorsListContent extends StatelessWidget {
  get user => null;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream:
          FirebaseFirestore.instance
              .collection('users')
              .where('role', isEqualTo: 'mentor')
              .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text("No mentors found."));
        }

        final mentors = snapshot.data!.docs;

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: mentors.length,
          itemBuilder: (context, index) {
            final mentor = mentors[index];
            final data = mentor.data() as Map<String, dynamic>;

            return Card(
              margin: const EdgeInsets.only(bottom: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 2,
              shadowColor: Colors.black12,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundImage: NetworkImage(
                        data['avatar'] ??
                            'https://placehold.co/100x100/A0C4FF/000000?text=NA',
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            data['firstName'] ?? 'No Name',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            ((data['skills'] as List<dynamic>?)?.join(', ') ??
                                'No Skills'),
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        // Navigate to mentor profile
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (_) => MentorProfilePage(
                                  mentorUid: user!.uid,
                                  mentorData: {},
                                  isNavigatedFromMentorsList: true,
                                ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('View'),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
