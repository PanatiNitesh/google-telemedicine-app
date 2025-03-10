// import 'package:flutter/material.dart';
// import 'package:camera/camera.dart';
// import 'package:file_picker/file_picker.dart';
// import 'package:flutter_sound/flutter_sound.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'dart:io';

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   final cameras = await availableCameras();
//   runApp(MaterialApp(
//     home: AIChatPage(cameras: cameras),
//   ));
// }

// class AIChatPage extends StatefulWidget {
//   final List<CameraDescription> cameras;
//   const AIChatPage({super.key, required this.cameras});

//   @override
//   _AIChatPageState createState() => _AIChatPageState();
// }

// class _AIChatPageState extends State<AIChatPage> {
//   final TextEditingController _controller = TextEditingController();
//   final List<Map<String, dynamic>> _messages = [];
//   CameraController? _cameraController;
//   FlutterSoundRecorder _recorder = FlutterSoundRecorder();
//   bool _isRecording = false;

//   @override
//   void initState() {
//     super.initState();
//     _initializeCamera();
//     _initRecorder();
//   }

//   Future<void> _initializeCamera() async {
//     if (widget.cameras.isNotEmpty) {
//       _cameraController = CameraController(widget.cameras[0], ResolutionPreset.medium);
//       await _cameraController!.initialize();
//       setState(() {});
//     } else {
//       _messages.add({'message': 'No camera available.', 'isUser': false});
//     }
//   }

//   Future<void> _initRecorder() async {
//     await _recorder.openRecorder();
//     await Permission.microphone.request();
//   }

//   void _sendMessage(String text) {
//     if (text.trim().isEmpty) return;
//     setState(() {
//       _messages.add({'message': text, 'isUser': true});
//       _messages.add({'message': 'I got your message: "$text".', 'isUser': false});
//     });
//     _controller.clear();
//   }

//   Future<void> _takePicture() async {
//     if (_cameraController == null || !_cameraController!.value.isInitialized) return;
//     final XFile picture = await _cameraController!.takePicture();
//     setState(() {
//       _messages.add({'message': 'Photo captured: ${picture.path}', 'isUser': true});
//     });
//   }

//   Future<void> _pickFile() async {
//     FilePickerResult? result = await FilePicker.platform.pickFiles();
//     if (result != null) {
//       setState(() {
//         _messages.add({'message': 'File attached: ${result.files.single.name}', 'isUser': true});
//       });
//     }
//   }

//   Future<void> _toggleRecording() async {
//     if (_isRecording) {
//       String? path = await _recorder.stopRecorder();
//       setState(() {
//         _messages.add({'message': 'Voice recorded: $path', 'isUser': true});
//         _isRecording = false;
//       });
//     } else {
//       Directory tempDir = await getTemporaryDirectory();
//       String path = '${tempDir.path}/voice_${DateTime.now().millisecondsSinceEpoch}.aac';
//       await _recorder.startRecorder(toFile: path);
//       setState(() {
//         _isRecording = true;
//       });
//     }
//   }

//   @override
//   void dispose() {
//     _controller.dispose();
//     _cameraController?.dispose();
//     _recorder.closeRecorder();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('AI Assistant')),
//       body: Column(
//         children: [
//           Expanded(
//             child: _messages.isEmpty
//                 ? const Center(child: ChatBubble(message: 'What can I help with?', isUser: false))
//                 : ListView.builder(
//                     padding: const EdgeInsets.all(16),
//                     itemCount: _messages.length,
//                     itemBuilder: (context, index) {
//                       final message = _messages[index];
//                       return Column(
//                         children: [
//                           Align(
//                             alignment: message['isUser'] ? Alignment.centerRight : Alignment.centerLeft,
//                             child: ChatBubble(message: message['message'], isUser: message['isUser']),
//                           ),
//                           const SizedBox(height: 10),
//                         ],
//                       );
//                     },
//                   ),
//           ),
//           Container(
//             padding: const EdgeInsets.all(8),
//             color: Colors.grey[200],
//             child: Row(
//               children: [
//                 IconButton(icon: const Icon(Icons.attach_file, color: Colors.blue), onPressed: _pickFile),
//                 IconButton(icon: const Icon(Icons.camera_alt, color: Colors.blue), onPressed: _takePicture),
//                 IconButton(
//                   icon: Icon(_isRecording ? Icons.stop : Icons.mic, color: Colors.blue),
//                   onPressed: _toggleRecording,
//                 ),
//                 Expanded(
//                   child: TextField(
//                     controller: _controller,
//                     decoration: InputDecoration(
//                       hintText: 'Type your message...',
//                       border: OutlineInputBorder(borderRadius: BorderRadius.circular(25), borderSide: BorderSide.none),
//                       filled: true,
//                       fillColor: Colors.white,
//                       contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//                     ),
//                     onSubmitted: _sendMessage,
//                   ),
//                 ),
//                 IconButton(icon: const Icon(Icons.send, color: Colors.blue), onPressed: () => _sendMessage(_controller.text)),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }


// class ChatBubble extends StatelessWidget {
//   final String message;
//   final bool isUser;

//   const ChatBubble({super.key, required this.message, required this.isUser});

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
//       decoration: BoxDecoration(
//         color: isUser ? Colors.blue : Colors.grey[300],
//         borderRadius: BorderRadius.circular(20),
//       ),
//       child: Text(
//         message,
//         style: TextStyle(color: isUser ? Colors.white : Colors.black),
//       ),
//     );
//   }
// }
