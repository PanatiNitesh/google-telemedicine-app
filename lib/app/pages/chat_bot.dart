import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({Key? key}) : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with SingleTickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _textScrollController = ScrollController();
  final List<Map<String, String>> _messages = [];
  bool _isMenuOpen = false;
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;
  late AnimationController _animationController;
  Animation<Offset>? _slideAnimation;

  // Cohere API Key and endpoint
  final String cohereApiKey = 'PQ6mQ17KyRlPLC23OrGxEi8aW1KYDZQrtIWkyZvH'; // Replace with your actual Cohere API key
  final String cohereEndpoint = 'https://api.cohere.ai/v1/chat';

  // Chat storage
  final List<List<Map<String, String>>> _chatHistory = [];
  List<Map<String, String>> _currentChat = [];

  @override
  void initState() {
    super.initState();
    _initializeSpeech();
    _loadChatHistory();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    // Modified animation to slide from right to left
    _slideAnimation = Tween<Offset>(
      begin: const Offset(1.0, 0.0),
      end: const Offset(0.0, 0.0),
    ).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeInOut));

    // Start a new chat on app open
    _startNewChat();

    // Add listener to TextEditingController to manage text changes
    _controller.addListener(() {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_textScrollController.hasClients) {
          _textScrollController.jumpTo(_textScrollController.position.maxScrollExtent);
        }
      });
    });
  }

  void _initializeSpeech() async {
    await _speech.initialize();
  }

  // Load chat history from shared preferences
  Future<void> _loadChatHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final chatHistoryJson = prefs.getString('chat_history');
    if (chatHistoryJson != null) {
      final List<dynamic> decoded = jsonDecode(chatHistoryJson);
      setState(() {
        _chatHistory.clear();
        _chatHistory.addAll(decoded.map((chat) => (chat as List<dynamic>).map((msg) => Map<String, String>.from(msg)).toList()).toList());
      });
    }
  }

  // Save chat history to shared preferences
  Future<void> _saveChatHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final chatHistoryJson = jsonEncode(_chatHistory);
    await prefs.setString('chat_history', chatHistoryJson);
  }

  Future<void> _sendMessage(String message) async {
    setState(() {
      _currentChat.add({'sender': 'user', 'message': message});
      _messages.add({'sender': 'user', 'message': message});
    });

    try {
      final response = await http.post(
        Uri.parse(cohereEndpoint),
        headers: {
          'Authorization': 'Bearer $cohereApiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'message': 'You are a Level 1 Health Assistant. Provide very basic health information only and always recommend consulting a doctor for any specific medical concerns. Respond briefly to this query: $message',
          'max_tokens': 100,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        String botResponse = data['text'];
        botResponse += '\n\nPlease consult a doctor for personalized medical advice.';
        
        setState(() {
          _currentChat.add({'sender': 'bot', 'message': botResponse});
          _messages.add({'sender': 'bot', 'message': botResponse});
        });
      } else {
        setState(() {
          _currentChat.add({
            'sender': 'bot',
            'message': 'Error: Server returned status ${response.statusCode}. Please consult a doctor for medical advice.',
          });
          _messages.add({
            'sender': 'bot',
            'message': 'Error: Server returned status ${response.statusCode}. Please consult a doctor for medical advice.',
          });
        });
      }
    } catch (e) {
      print('Error sending message: $e');
      setState(() {
        _currentChat.add({
          'sender': 'bot',
          'message': 'Error: Check your network or API key. Please consult a doctor for medical advice.',
        });
        _messages.add({
          'sender': 'bot',
          'message': 'Error: Check your network or API key. Please consult a doctor for medical advice.',
        });
      });
    }
  }

  void _startNewChat() {
    setState(() {
      _messages.clear();
      _currentChat = [];
      _currentChat.add({
        'sender': 'bot',
        'message': 'Hello, I am a Level 1 Health Assistant. I can help answer basic health questions, but I am not a substitute for professional medical advice. What can I help with today?',
      });
      _messages.add({
        'sender': 'bot',
        'message': 'Hello, I am a Level 1 Health Assistant. I can help answer basic health questions, but I am not a substitute for professional medical advice. What can I help with today?',
      });
    });
  }

  void _listen() async {
    if (!_isListening) {
      bool available = await _speech.initialize();
      if (available) {
        setState(() => _isListening = true);
        _speech.listen(
          onResult: (val) => setState(() {
            _controller.text = val.recognizedWords;
            if (val.finalResult) {
              _isListening = false;
              if (_controller.text.isNotEmpty) {
                _sendMessage(_controller.text);
                _controller.clear();
              }
            }
          }),
        );
      }
    } else {
      setState(() => _isListening = false);
      _speech.stop();
    }
  }

  void _openCamera() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.camera);
    if (image != null) {
      setState(() {
        _currentChat.add({'sender': 'user', 'message': 'Image uploaded (path: ${image.path})'});
        _messages.add({'sender': 'user', 'message': 'Image uploaded (path: ${image.path})'});
      });
      _sendMessage('User uploaded an image for analysis. Please note that I can only provide basic health information and you should consult a doctor for proper diagnosis.');
    }
  }

  void _attachFile() async {
    final ImagePicker picker = ImagePicker();
    final XFile? file = await picker.pickImage(source: ImageSource.gallery);
    if (file != null) {
      setState(() {
        _currentChat.add({'sender': 'user', 'message': 'File attached (path: ${file.path})'});
        _messages.add({'sender': 'user', 'message': 'File attached (path: ${file.path})'});
      });
      _sendMessage('User attached a file for analysis. Please note that I can only provide basic health information and you should consult a doctor for proper diagnosis.');
    }
  }

  void _bookAppointment() {
    Navigator.pushNamed(context, '/book-appointment');
  }

  @override
  void dispose() {
    if (_currentChat.isNotEmpty && _currentChat.length > 1) {
      _chatHistory.add(List.from(_currentChat));
      _saveChatHistory();
    }
    _animationController.dispose();
    _speech.stop();
    _textScrollController.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _manageTextField(String newText) {
    List<String> lines = newText.split('\n');
    if (lines.length > 5) {
      lines = lines.sublist(lines.length - 5);
      _controller.text = lines.join('\n');
      _controller.selection = TextSelection.fromPosition(
        TextPosition(offset: _controller.text.length),
      );
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_textScrollController.hasClients) {
        _textScrollController.jumpTo(_textScrollController.position.maxScrollExtent);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final panelWidth = screenWidth * 0.6; // 60% of screen width
    final inputBoxHeight = 89.0; // Estimated height of input box including padding

    return Scaffold(
      backgroundColor: const Color(0xFFDDDDDD),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: GestureDetector(
          onTap: () {
            _startNewChat();
            Navigator.pop(context);
          },
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Image.asset(
              'assets/back.png',
              width: 24,
              height: 24,
            ),
          ),
        ),
        title: const Text(
          'AI Health Assistant',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w500,
            color: Colors.black,
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            width: 150,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  icon: const Icon(Icons.home, color: Colors.black),
                  onPressed: () {
                    _startNewChat();
                    Navigator.pushNamed(context, '/home');
                  },
                  tooltip: 'Home',
                ),
                IconButton(
                  icon: const Icon(Icons.add, color: Colors.black),
                  onPressed: _startNewChat,
                  tooltip: 'New Chat',
                ),
                IconButton(
                  icon: const Icon(Icons.menu, color: Colors.black),
                  onPressed: () {
                    setState(() {
                      _isMenuOpen = !_isMenuOpen;
                      if (_isMenuOpen) {
                        _animationController.forward();
                      } else {
                        _animationController.reverse();
                      }
                    });
                  },
                  tooltip: 'Chat History',
                ),
              ],
            ),
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: Stack(
          children: [
            Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final message = _messages[index];
                      bool isUser = message['sender'] == 'user';
                      return Align(
                        alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                          margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: screenWidth * 0.05),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isUser 
                              ? Colors.white.withOpacity(0.9)
                              : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 2,
                                offset: const Offset(0, 1),
                              ),
                            ],
                          ),
                          constraints: BoxConstraints(
                            maxWidth: screenWidth * 0.75,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                isUser ? 'USER' : 'AI HEALTH ASSISTANT',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: isUser ? Colors.blue : Colors.green,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                message['message']!,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.black87,
                                ),
                              ),
                              if (!isUser)
                                Padding(
                                  padding: const EdgeInsets.only(top: 8.0),
                                  child: ElevatedButton(
                                    onPressed: _bookAppointment,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.blue,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                      textStyle: const TextStyle(fontSize: 14),
                                    ),
                                    child: const Text('Book an Appointment'),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(8),
                  color: Colors.amber.withOpacity(0.2),
                  child: const Text(
                    'Disclaimer: This is not a substitute for professional medical advice. Please consult a doctor.',
                    style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
                    textAlign: TextAlign.center,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Container(
                          constraints: BoxConstraints(
                            maxHeight: 5 * 20.0,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(25),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.attach_file),
                                onPressed: _attachFile,
                              ),
                              IconButton(
                                icon: const Icon(Icons.camera_alt),
                                onPressed: _openCamera,
                              ),
                              Expanded(
                                child: SingleChildScrollView(
                                  controller: _textScrollController,
                                  reverse: true,
                                  child: TextField(
                                    controller: _controller,
                                    maxLines: null,
                                    keyboardType: TextInputType.multiline,
                                    decoration: const InputDecoration(
                                      hintText: 'Ask your health question...',
                                      border: InputBorder.none,
                                      contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                                    ),
                                    onChanged: (text) {
                                      _manageTextField(text);
                                    },
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: Icon(
                                  _isListening ? Icons.mic : Icons.mic_none,
                                  color: _isListening ? Colors.red : Colors.black,
                                ),
                                onPressed: _listen,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      CircleAvatar(
                        backgroundColor: Colors.blue,
                        child: IconButton(
                          icon: const Icon(Icons.send, color: Colors.white),
                          onPressed: () {
                            if (_controller.text.isNotEmpty) {
                              _sendMessage(_controller.text);
                              _controller.clear();
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            // Improved chat history panel positioning
            if (_slideAnimation != null && _isMenuOpen)
              Positioned(
                right: 0,
                bottom: inputBoxHeight, // Position it just above the chat input
                width: panelWidth,
                height: screenHeight - inputBoxHeight - MediaQuery.of(context).padding.top - kToolbarHeight - 2, // 2mm (or px) gap
                child: SlideTransition(
                  position: _slideAnimation!,
                  child: Material(
                    elevation: 8,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(12),
                      bottomLeft: Radius.circular(12),
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(12),
                          bottomLeft: Radius.circular(12),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 10,
                            offset: Offset(-2, 0),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade50,
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(12),
                              ),
                              border: Border(
                                bottom: BorderSide(color: Colors.grey.shade300),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Chat History',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                                Row(
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.add, color: Colors.blue),
                                      onPressed: () {
                                        _startNewChat();
                                        setState(() {
                                          _isMenuOpen = false;
                                          _animationController.reverse();
                                        });
                                      },
                                      tooltip: 'Start New Chat',
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.close, color: Colors.black54),
                                      onPressed: () {
                                        setState(() {
                                          _isMenuOpen = false;
                                          _animationController.reverse();
                                        });
                                      },
                                      tooltip: 'Close',
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: _chatHistory.isEmpty
                                ? Center(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.history,
                                          size: 50,
                                          color: Colors.grey.shade400,
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          'No previous chats',
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: Colors.grey.shade600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                : ListView.builder(
                                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                                    itemCount: _chatHistory.length,
                                    itemBuilder: (context, index) {
                                      final reversedIndex = _chatHistory.length - 1 - index;
                                      final chat = _chatHistory[reversedIndex];
                                      final firstUserMessage = chat.firstWhere(
                                        (msg) => msg['sender'] == 'user',
                                        orElse: () => {'message': 'Chat ${reversedIndex + 1}'},
                                      )['message'];
                                      final lastMessageTime = DateTime.now().toString().split(' ')[0]; // Placeholder

                                      return Card(
                                        elevation: 2,
                                        margin: const EdgeInsets.symmetric(vertical: 6),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: ListTile(
                                          contentPadding: const EdgeInsets.symmetric(
                                            horizontal: 16,
                                            vertical: 8,
                                          ),
                                          leading: CircleAvatar(
                                            backgroundColor: Colors.blue.shade100,
                                            child: Text(
                                              (reversedIndex + 1).toString(),
                                              style: const TextStyle(
                                                fontSize: 14,
                                                color: Colors.blue,
                                              ),
                                            ),
                                          ),
                                          title: Text(
                                            firstUserMessage ?? 'Chat ${reversedIndex + 1}',
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          subtitle: Row(
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  '${chat.length} messages',
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.grey.shade600,
                                                  ),
                                                ),
                                              ),
                                              Text(
                                                'Last: $lastMessageTime',
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  color: Colors.grey.shade500,
                                                ),
                                              ),
                                            ],
                                          ),
                                          onTap: () {
                                            setState(() {
                                              _messages.clear();
                                              _currentChat = List.from(_chatHistory[reversedIndex]);
                                              _messages.addAll(_currentChat);
                                              _isMenuOpen = false;
                                              _animationController.reverse();
                                            });
                                          },
                                        ),
                                      );
                                    },
                                  ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}