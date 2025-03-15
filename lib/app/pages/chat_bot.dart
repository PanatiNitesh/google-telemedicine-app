import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show debugPrint;
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => ChatScreenState();
}

class ChatScreenState extends State<ChatScreen> with SingleTickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _textScrollController = ScrollController();
  final List<Map<String, String>> _messages = [];
  bool _isMenuOpen = false;
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;
  late AnimationController _animationController;
  Animation<Offset>? _slideAnimation;

  static const String cohereEndpoint = 'https://api.cohere.ai/v1/chat';
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
    _slideAnimation = Tween<Offset>(
      begin: const Offset(1.0, 0.0),
      end: const Offset(0.0, 0.0),
    ).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeInOut));

    _startNewChat();

    if (!dotenv.isInitialized) {
      _addErrorMessage('Warning: Environment variables not yet loaded. Chat may not work until initialization completes.');
    } else {
      final apiKey = dotenv.env['COHERE_API_KEY'];
      if (apiKey == null || apiKey.isEmpty) {
        _addErrorMessage('Warning: Cohere API key not found. Chat functionality may not work.');
      }
    }

    _controller.addListener(() {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_textScrollController.hasClients) {
          _textScrollController.jumpTo(_textScrollController.position.maxScrollExtent);
        }
      });
    });
  }

  void _addErrorMessage(String message) {
    setState(() {
      _currentChat.add({'sender': 'bot', 'message': message});
      _messages.add({'sender': 'bot', 'message': message});
    });
  }

  Future<void> _initializeSpeech() async {
    try {
      bool available = await _speech.initialize(
        onError: (error) => _addErrorMessage('Speech recognition error: $error'),
      );
      if (!available) {
        _addErrorMessage('Speech recognition not available on this device.');
      }
    } catch (e) {
      _addErrorMessage('Failed to initialize speech recognition: $e');
    }
  }

  Future<void> _loadChatHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final chatHistoryJson = prefs.getString('chat_history');
      if (chatHistoryJson != null) {
        final List<dynamic> decoded = jsonDecode(chatHistoryJson);
        setState(() {
          _chatHistory.clear();
          _chatHistory.addAll(decoded.map((chat) => (chat as List<dynamic>).map((msg) => Map<String, String>.from(msg)).toList()).toList());
        });
      }
    } catch (e) {
      _addErrorMessage('Failed to load chat history: $e');
    }
  }

  Future<void> _saveChatHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final chatHistoryJson = jsonEncode(_chatHistory);
      await prefs.setString('chat_history', chatHistoryJson);
    } catch (e) {
      _addErrorMessage('Failed to save chat history: $e');
    }
  }

  Future<void> _sendMessage(String message) async {
    setState(() {
      _currentChat.add({'sender': 'user', 'message': message});
      _messages.add({'sender': 'user', 'message': message});
    });

    final cohereApiKey = dotenv.env['COHERE_API_KEY'];
    if (cohereApiKey == null || cohereApiKey.isEmpty) {
      _addErrorMessage('Error: Cohere API key not configured. Please check app settings.');
      return;
    }

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
        String botResponse = data['text'] ?? 'No response text received.';
        debugPrint("Raw Cohere response: $botResponse");
        
        botResponse = botResponse
            .replaceAll('\r\n', '\n')
            .replaceAll('\r', '\n')
            .replaceAll(RegExp(r'[^\x20-\x7E\n]'), '');
        botResponse = _formatListResponse(botResponse);
        botResponse += '\n\nPlease consult a doctor for personalized medical advice.';
        
        setState(() {
          _currentChat.add({'sender': 'bot', 'message': botResponse});
          _messages.add({'sender': 'bot', 'message': botResponse});
        });
      } else {
        String errorMessage;
        switch (response.statusCode) {
          case 401:
            errorMessage = 'Error: Invalid API key. Please check your Cohere API key.';
            break;
          case 429:
            errorMessage = 'Error: Too many requests. Please try again later.';
            break;
          case 500:
            errorMessage = 'Error: Server issue at Cohere. Please try again later.';
            break;
          default:
            errorMessage = 'Error: Server returned status ${response.statusCode}. Please try again or consult a doctor.';
        }
        _addErrorMessage(errorMessage);
      }
    } catch (e) {
      debugPrint('Error sending message: $e');
      String errorMessage = e is http.ClientException
          ? 'Error: Network issue. Please check your internet connection.'
          : 'Error: Unexpected issue ($e). Please try again or consult a doctor.';
      _addErrorMessage(errorMessage);
    }
  }

  String _formatListResponse(String response) {
    final lines = response.split('\n');
    final formattedLines = lines.map((line) {
      if (RegExp(r'^\d+\.').hasMatch(line)) {
        return line.replaceFirstMapped(RegExp(r'^\d+\.'), (match) => '${match.group(0)} ');
      }
      return line;
    }).join('\n');
    return formattedLines;
  }

  List<TextSpan> _parseBoldText(String text, double fontSize) {
    final spans = <TextSpan>[];
    final regex = RegExp(r'\*\*(.*?)\*\*');
    int lastEnd = 0;

    for (final match in regex.allMatches(text)) {
      if (match.start > lastEnd) {
        spans.add(TextSpan(
          text: text.substring(lastEnd, match.start),
          style: TextStyle(fontSize: fontSize, color: Colors.black87),
        ));
      }
      spans.add(TextSpan(
        text: match.group(1),
        style: TextStyle(
          fontSize: fontSize,
          color: Colors.black87,
          fontWeight: FontWeight.bold,
        ),
      ));
      lastEnd = match.end;
    }

    if (lastEnd < text.length) {
      spans.add(TextSpan(
        text: text.substring(lastEnd),
        style: TextStyle(fontSize: fontSize, color: Colors.black87),
      ));
    }

    return spans;
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
      try {
        bool available = await _speech.initialize(
          onError: (error) => _addErrorMessage('Speech recognition error: $error'),
        );
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
            onSoundLevelChange: null,
          );
        } else {
          _addErrorMessage('Speech recognition not available.');
        }
      } catch (e) {
        _addErrorMessage('Failed to start speech recognition: $e');
        setState(() => _isListening = false);
      }
    } else {
      setState(() => _isListening = false);
      _speech.stop();
    }
  }

  void _openCamera() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.camera);
      if (image != null) {
        setState(() {
          _currentChat.add({'sender': 'user', 'message': 'Image uploaded (path: ${image.path})'});
          _messages.add({'sender': 'user', 'message': 'Image uploaded (path: ${image.path})'});
        });
        _sendMessage('User uploaded an image for analysis. Please note that I can only provide basic health information and you should consult a doctor for proper diagnosis.');
      }
    } catch (e) {
      _addErrorMessage('Failed to open camera or upload image: $e');
    }
  }

  void _attachFile() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? file = await picker.pickImage(source: ImageSource.gallery);
      if (file != null) {
        setState(() {
          _currentChat.add({'sender': 'user', 'message': 'File attached (path: ${file.path})'});
          _messages.add({'sender': 'user', 'message': 'File attached (path: ${file.path})'});
        });
        _sendMessage('User attached a file for analysis. Please note that I can only provide basic health information and you should consult a doctor for proper diagnosis.');
      }
    } catch (e) {
      _addErrorMessage('Failed to attach file: $e');
    }
  }

  void _bookAppointment() {
    try {
      Navigator.pushNamed(context, '/book-appointment');
    } catch (e) {
      _addErrorMessage('Failed to navigate to booking page: $e');
    }
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
    final safePaddingTop = MediaQuery.of(context).padding.top;
    final safePaddingBottom = MediaQuery.of(context).padding.bottom;
    final orientation = MediaQuery.of(context).orientation;

    // Responsive panel width
    final panelWidth = screenWidth > 600
        ? screenWidth * 0.4
        : screenWidth * (orientation == Orientation.portrait ? 0.75 : 0.5);

    // Responsive input box height
    final inputBoxHeight = screenHeight * (orientation == Orientation.portrait ? 0.12 : 0.18);

    // Responsive panel height
    final appBarHeight = kToolbarHeight + safePaddingTop;
    final disclaimerHeight = screenHeight * 0.06;
    final panelHeight = screenHeight - appBarHeight - inputBoxHeight - disclaimerHeight - safePaddingBottom;

    return Scaffold(
      backgroundColor: const Color(0xFFDDDDDD),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: EdgeInsets.only(left: screenWidth * 0.04),
          child: GestureDetector(
            onTap: () {
              _startNewChat();
              Navigator.pop(context);
            },
            child: Image.asset(
              'assets/back.png',
              width: screenWidth * 0.05,
              height: screenWidth * 0.05,
              errorBuilder: (context, error, stackTrace) => Icon(
                Icons.arrow_back,
                size: screenWidth * 0.05,
              ),
            ),
          ),
        ),
        title: Text(
          'AI Health Assistant',
          style: TextStyle(
            fontSize: screenWidth * 0.06,
            fontWeight: FontWeight.w500,
            color: Colors.black,
          ),
        ),
        foregroundColor: Colors.black,
        centerTitle: false,
        actions: [
          Container(
            margin: EdgeInsets.only(right: screenWidth * 0.04),
            width: screenWidth * 0.3,
            height: screenHeight * 0.06,
            decoration: BoxDecoration(
              color: Colors.white.withAlpha((0.9 * 255).toInt()),
              borderRadius: BorderRadius.circular(screenWidth * 0.02),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: IconButton(
                    icon: Icon(
                      Icons.home,
                      size: screenWidth * 0.05,
                    ),
                    onPressed: () {
                      _startNewChat();
                      Navigator.pushNamed(context, '/home');
                    },
                    tooltip: 'Home',
                  ),
                ),
                Expanded(
                  child: IconButton(
                    icon: Icon(
                      Icons.add,
                      size: screenWidth * 0.05,
                    ),
                    onPressed: _startNewChat,
                    tooltip: 'New Chat',
                  ),
                ),
                Expanded(
                  child: IconButton(
                    icon: Icon(
                      Icons.menu,
                      size: screenWidth * 0.05,
                    ),
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
                    controller: _textScrollController,
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final message = _messages[index];
                      bool isUser = message['sender'] == 'user';
                      return Align(
                        alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                          margin: EdgeInsets.symmetric(
                            vertical: screenHeight * 0.015,
                            horizontal: screenWidth * 0.05,
                          ),
                          padding: EdgeInsets.all(screenWidth * 0.03),
                          decoration: BoxDecoration(
                            color: isUser ? Colors.white.withAlpha((0.9 * 255).toInt()) : Colors.transparent,
                            borderRadius: BorderRadius.circular(screenWidth * 0.03),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withAlpha((0.05 * 255).toInt()),
                                blurRadius: screenWidth * 0.005,
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
                                  fontSize: screenWidth * 0.03,
                                  fontWeight: FontWeight.bold,
                                  color: isUser ? Colors.blue : Colors.green,
                                ),
                              ),
                              SizedBox(height: screenHeight * 0.01),
                              isUser
                                  ? Text(
                                      message['message']!,
                                      style: TextStyle(
                                        fontSize: screenWidth * 0.04,
                                        color: Colors.black87,
                                      ),
                                      softWrap: true,
                                      overflow: TextOverflow.clip,
                                    )
                                  : RichText(
                                      text: TextSpan(
                                        children: _parseBoldText(message['message']!, screenWidth * 0.04),
                                      ),
                                      softWrap: true,
                                      overflow: TextOverflow.clip,
                                    ),
                              if (!isUser)
                                Padding(
                                  padding: EdgeInsets.only(top: screenHeight * 0.015),
                                  child: ElevatedButton(
                                    onPressed: _bookAppointment,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.blue,
                                      foregroundColor: Colors.white,
                                      padding: EdgeInsets.symmetric(
                                        horizontal: screenWidth * 0.03,
                                        vertical: screenHeight * 0.015,
                                      ),
                                      textStyle: TextStyle(fontSize: screenWidth * 0.035),
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
                  padding: EdgeInsets.all(screenWidth * 0.02),
                  color: Colors.amber.withAlpha((0.2 * 255).toInt()),
                  child: Text(
                    'Disclaimer: This is not a substitute for professional medical advice. Please consult a doctor.',
                    style: TextStyle(
                      fontSize: screenWidth * 0.03,
                      fontStyle: FontStyle.italic,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(screenWidth * 0.03),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Container(
                          constraints: BoxConstraints(
                            maxHeight: screenHeight * 0.2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(screenWidth * 0.06),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              IconButton(
                                icon: Icon(Icons.attach_file, size: screenWidth * 0.05),
                                onPressed: _attachFile,
                              ),
                              IconButton(
                                icon: Icon(Icons.camera_alt, size: screenWidth * 0.05),
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
                                    decoration: InputDecoration(
                                      hintText: 'Ask your health question...',
                                      border: InputBorder.none,
                                      contentPadding: EdgeInsets.symmetric(
                                        horizontal: screenWidth * 0.02,
                                        vertical: screenHeight * 0.015,
                                      ),
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
                                  size: screenWidth * 0.05,
                                  color: _isListening ? Colors.red : Colors.black,
                                ),
                                onPressed: _listen,
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(width: screenWidth * 0.02),
                      CircleAvatar(
                        radius: screenWidth * 0.06,
                        backgroundColor: Colors.blue,
                        child: IconButton(
                          icon: Icon(Icons.send, size: screenWidth * 0.05, color: Colors.white),
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
            if (_slideAnimation != null && _isMenuOpen)
              Positioned(
                right: 0,
                top: appBarHeight,
                width: panelWidth,
                height: panelHeight,
                child: SlideTransition(
                  position: _slideAnimation!,
                  child: Material(
                    elevation: 8,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(screenWidth * 0.03),
                      bottomLeft: Radius.circular(screenWidth * 0.03),
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(screenWidth * 0.03),
                          bottomLeft: Radius.circular(screenWidth * 0.03),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: screenWidth * 0.025,
                            offset: Offset(-screenWidth * 0.005, 0),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: screenWidth * 0.04,
                              vertical: screenHeight * 0.03,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade50,
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(screenWidth * 0.03),
                              ),
                              border: Border(
                                bottom: BorderSide(color: Colors.grey.shade300),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Chat History',
                                  style: TextStyle(
                                    fontSize: screenWidth * 0.045,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                                Row(
                                  children: [
                                    IconButton(
                                      icon: Icon(Icons.add, size: screenWidth * 0.05),
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
                                      icon: Icon(Icons.close, size: screenWidth * 0.05),
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
                                          size: screenWidth * 0.12,
                                          color: Colors.grey.shade400,
                                        ),
                                        SizedBox(height: screenHeight * 0.02),
                                        Text(
                                          'No previous chats',
                                          style: TextStyle(
                                            fontSize: screenWidth * 0.04,
                                            color: Colors.grey.shade600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                : ListView.builder(
                                    padding: EdgeInsets.symmetric(
                                      vertical: screenHeight * 0.02,
                                      horizontal: screenWidth * 0.03,
                                    ),
                                    itemCount: _chatHistory.length,
                                    itemBuilder: (context, index) {
                                      final reversedIndex = _chatHistory.length - 1 - index;
                                      final chat = _chatHistory[reversedIndex];
                                      final firstUserMessage = chat.firstWhere(
                                        (msg) => msg['sender'] == 'user',
                                        orElse: () => {'message': 'Chat ${reversedIndex + 1}'},
                                      )['message'];
                                      final lastMessageTime = DateTime.now().toString().split(' ')[0];

                                      return Card(
                                        elevation: 2,
                                        margin: EdgeInsets.symmetric(vertical: screenHeight * 0.015),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(screenWidth * 0.03),
                                        ),
                                        child: ListTile(
                                          contentPadding: EdgeInsets.symmetric(
                                            horizontal: screenWidth * 0.04,
                                            vertical: screenHeight * 0.015,
                                          ),
                                          leading: CircleAvatar(
                                            radius: screenWidth * 0.05,
                                            backgroundColor: Colors.blue.shade100,
                                            child: Text(
                                              (reversedIndex + 1).toString(),
                                              style: TextStyle(
                                                fontSize: screenWidth * 0.035,
                                                color: Colors.blue,
                                              ),
                                            ),
                                          ),
                                          title: Text(
                                            firstUserMessage ?? 'Chat ${reversedIndex + 1}',
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              fontSize: screenWidth * 0.04,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          subtitle: Row(
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  '${chat.length} messages',
                                                  style: TextStyle(
                                                    fontSize: screenWidth * 0.03,
                                                    color: Colors.grey.shade600,
                                                  ),
                                                ),
                                              ),
                                              Text(
                                                'Last: $lastMessageTime',
                                                style: TextStyle(
                                                  fontSize: screenWidth * 0.025,
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