import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import 'package:permission_handler/permission_handler.dart';

class VideoConsultPage extends StatefulWidget {
  final String doctorName;
  final String callId;

  const VideoConsultPage({
    super.key,
    required this.doctorName,
    required this.callId,
  });

  @override
  State<VideoConsultPage> createState() => _VideoConsultPageState();
}

class _VideoConsultPageState extends State<VideoConsultPage> {
  final RTCVideoRenderer _localRenderer = RTCVideoRenderer();
  final RTCVideoRenderer _remoteRenderer = RTCVideoRenderer();
  RTCPeerConnection? _peerConnection;
  MediaStream? _localStream;

  late CollectionReference _callsRef;
  StreamSubscription<QuerySnapshot>? _messagesSub;
  String? _userId;
  bool _isCaller = false;

  bool _isMuted = false;
  bool _isVideoOff = false;
  bool _isConnected = false;
  Timer? _callTimer;
  int _callDuration = 0;

  final Map<String, dynamic> _rtcConfig = {
    'iceServers': [
      {'urls': 'stun:stun.l.google.com:19302'},
    ],
  };

  @override
  void initState() {
    super.initState();
    _initRenderers();
    _initFirebase();
  }

  @override
  void dispose() {
    _endCall();
    _localRenderer.dispose();
    _remoteRenderer.dispose();
    super.dispose();
  }

  Future<void> _initRenderers() async {
    await _localRenderer.initialize();
    await _remoteRenderer.initialize();
  }

  Future<void> _initFirebase() async {
    try {
      await Firebase.initializeApp();
      _callsRef = FirebaseFirestore.instance.collection('calls');
      _userId = const Uuid().v4();
      await _startCall();
    } catch (e) {
      _showError('Failed to initialize call: $e');
    }
  }

  Future<void> _startCall() async {
    try {
      if (!await _requestPermissions()) {
        _showError('Camera and microphone permissions are required.');
        return;
      }

      _localStream = await navigator.mediaDevices.getUserMedia({
        'audio': true,
        'video': {'facingMode': 'user'},
      });
      _localRenderer.srcObject = _localStream;

      _peerConnection = await createPeerConnection(_rtcConfig);
      _localStream!.getTracks().forEach((track) {
        _peerConnection!.addTrack(track, _localStream!);
      });

      _peerConnection!.onIceCandidate = (RTCIceCandidate candidate) {
        _sendFirestoreMessage({
          'type': 'candidate',
          'candidate': {
            'candidate': candidate.candidate,
            'sdpMid': candidate.sdpMid,
            'sdpMLineIndex': candidate.sdpMLineIndex,
          },
          'sender': _userId,
        });
      };

      _peerConnection!.onAddStream = (MediaStream stream) {
        _remoteRenderer.srcObject = stream;
        if (mounted) {
          setState(() {
            _isConnected = true;
            _startCallTimer();
          });
        }
      };

      final callDoc = await _callsRef.doc(widget.callId).get();
      _isCaller = !callDoc.exists;

      if (_isCaller) {
        final offer = await _peerConnection!.createOffer();
        await _peerConnection!.setLocalDescription(offer);
        _sendFirestoreMessage({
          'type': 'offer',
          'sdp': offer.sdp,
          'sender': _userId,
        });
      }

      _messagesSub = _callsRef
          .doc(widget.callId)
          .collection('messages')
          .orderBy('timestamp')
          .snapshots()
          .listen((snapshot) {
            for (var change in snapshot.docChanges) {
              if (change.type == DocumentChangeType.added) {
                final data = change.doc.data() as Map<String, dynamic>;
                if (data['sender'] != _userId) {
                  _handleSignalingMessage(data);
                }
              }
            }
          });
    } catch (e) {
      _showError('Failed to start call: $e');
    }
  }

  Future<bool> _requestPermissions() async {
    final status = await [Permission.camera, Permission.microphone].request();
    return status[Permission.camera]!.isGranted &&
        status[Permission.microphone]!.isGranted;
  }

  void _handleSignalingMessage(Map<String, dynamic> data) async {
    try {
      if (_peerConnection == null) return;

      switch (data['type']) {
        case 'offer':
          await _peerConnection!.setRemoteDescription(
            RTCSessionDescription(data['sdp'], 'offer'),
          );
          final answer = await _peerConnection!.createAnswer();
          await _peerConnection!.setLocalDescription(answer);
          _sendFirestoreMessage({
            'type': 'answer',
            'sdp': answer.sdp,
            'sender': _userId,
          });
          break;

        case 'answer':
          await _peerConnection!.setRemoteDescription(
            RTCSessionDescription(data['sdp'], 'answer'),
          );
          break;

        case 'candidate':
          if (await _peerConnection!.getRemoteDescription() != null) {
            await _peerConnection!.addCandidate(
              RTCIceCandidate(
                data['candidate']['candidate'],
                data['candidate']['sdpMid'],
                data['candidate']['sdpMLineIndex'],
              ),
            );
          }
          break;
      }
    } catch (e) {
      _showError('Signaling error: $e');
    }
  }

  void _sendFirestoreMessage(Map<String, dynamic> message) {
    _callsRef.doc(widget.callId).collection('messages').add({
      ...message,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  void _startCallTimer() {
    _callTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) setState(() => _callDuration++);
    });
  }

  String get _formattedDuration {
    final minutes = (_callDuration ~/ 60).toString().padLeft(2, '0');
    final seconds = (_callDuration % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  void _toggleMute() {
    setState(() => _isMuted = !_isMuted);
    _localStream?.getAudioTracks().forEach(
      (track) => track.enabled = !_isMuted,
    );
  }

  void _toggleVideo() {
    setState(() => _isVideoOff = !_isVideoOff);
    _localStream?.getVideoTracks().forEach(
      (track) => track.enabled = !_isVideoOff,
    );
  }

  Future<void> _endCall() async {
    try {
      _callTimer?.cancel();
      _messagesSub?.cancel();
      _localRenderer.srcObject = null;
      _remoteRenderer.srcObject = null;
      await _localStream?.dispose();
      await _peerConnection?.close();
      await _callsRef.doc(widget.callId).update({'endedBy': _userId});
    } catch (e) {
      _showError('Failed to end call: $e');
    }
  }

  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    }
  }

  void _showMoreOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder:
          (context) => Container(
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[900],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(
                    Icons.closed_caption,
                    color: Colors.white,
                  ),
                  title: const Text(
                    'Caption',
                    style: TextStyle(color: Colors.white),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _showError('Caption feature not implemented yet.');
                    // Add caption logic here
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.translate, color: Colors.white),
                  title: const Text(
                    'Audio Translator',
                    style: TextStyle(color: Colors.white),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _showError('Audio Translator feature not implemented yet.');
                    // Add audio translator logic here
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.mic, color: Colors.white),
                  title: const Text(
                    'Audio Record',
                    style: TextStyle(color: Colors.white),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _showError('Audio Record feature not implemented yet.');
                    // Add audio record logic here
                  },
                ),
              ],
            ),
          ),
    );
  }

  // Replace the build method in VideoConsultPage with this
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Remote video (full screen)
          _isConnected
              ? RTCVideoView(
                _remoteRenderer,
                objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                mirror: false,
              )
              : const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
          // Local video (small square)
          Positioned(
            top: screenHeight * 0.05,
            right: screenWidth * 0.05,
            child: Container(
              width: screenWidth * 0.3,
              height: screenHeight * 0.2,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white, width: 2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: RTCVideoView(
                  _localRenderer,
                  mirror: true,
                  objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                ),
              ),
            ),
          ),
          // Call duration
          if (_isConnected)
            Positioned(
              top: screenHeight * 0.02,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _formattedDuration,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: screenWidth * 0.04,
                    ),
                  ),
                ),
              ),
            ),
          // Control buttons
          Positioned(
            bottom: screenHeight * 0.05,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Mute button
                FloatingActionButton(
                  heroTag: "mute",
                  backgroundColor: _isMuted ? Colors.red : Colors.grey[800],
                  onPressed: _toggleMute,
                  child: Icon(
                    _isMuted ? Icons.mic_off : Icons.mic,
                    color: Colors.white,
                    size: screenWidth * 0.06,
                  ),
                ),
                // End call button
                FloatingActionButton(
                  heroTag: "end",
                  backgroundColor: Colors.red,
                  onPressed: () async {
                    await _endCall();
                    if (mounted) Navigator.pop(context);
                  },
                  child: Icon(
                    Icons.call_end,
                    color: Colors.white,
                    size: screenWidth * 0.06,
                  ),
                ),
                // Video button
                FloatingActionButton(
                  heroTag: "video",
                  backgroundColor: _isVideoOff ? Colors.red : Colors.grey[800],
                  onPressed: _toggleVideo,
                  child: Icon(
                    _isVideoOff ? Icons.videocam_off : Icons.videocam,
                    color: Colors.white,
                    size: screenWidth * 0.06,
                  ),
                ),
                // More options button
                FloatingActionButton(
                  heroTag: "more",
                  backgroundColor: Colors.grey[800],
                  onPressed: _showMoreOptions,
                  child: Icon(
                    Icons.more_vert,
                    color: Colors.white,
                    size: screenWidth * 0.06,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          widget.doctorName,
          style: TextStyle(color: Colors.white, fontSize: screenWidth * 0.05),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Colors.white,
            size: screenWidth * 0.06,
          ),
          onPressed: () async {
            await _endCall();
            if (mounted) Navigator.pop(context);
          },
        ),
      ),
    );
  }
}
