import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

class VideoConsultPage extends StatefulWidget {
  final String doctorName;
  final String callId; // Generated when scheduling consultation

  const VideoConsultPage({
    super.key,
    required this.doctorName,
    required this.callId,
  });

  @override
  State<VideoConsultPage> createState() => _VideoConsultPageState();
}

class _VideoConsultPageState extends State<VideoConsultPage> {
  // WebRTC Components
  final RTCVideoRenderer _localRenderer = RTCVideoRenderer();
  final RTCVideoRenderer _remoteRenderer = RTCVideoRenderer();
  RTCPeerConnection? _peerConnection;
  MediaStream? _localStream;

  // Firebase
  late CollectionReference _callsRef;
  StreamSubscription<QuerySnapshot>? _messagesSub;
  String? _userId;
  bool _isCaller = false;

  // Call State
  bool _isMuted = false;
  bool _isVideoOff = false;
  bool _isConnected = false;
  Timer? _callTimer;
  int _callDuration = 0;

  // WebRTC Configuration
  final Map<String, dynamic> _rtcConfig = {
    'iceServers': [
      {'urls': 'stun:stun.l.google.com:19302'},
    ]
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
    await Firebase.initializeApp();
    _callsRef = FirebaseFirestore.instance.collection('calls');
    _userId = const Uuid().v4();
    _startCall();
  }

  Future<void> _startCall() async {
    // 1. Get user media
    _localStream = await navigator.mediaDevices.getUserMedia({
      'audio': true,
      'video': {'facingMode': 'user'}
    });
    _localRenderer.srcObject = _localStream;

    // 2. Create peer connection
    _peerConnection = await createPeerConnection(_rtcConfig);

    // 3. Add ICE candidate handler
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

    // 4. Add remote stream handler
    _peerConnection!.onAddStream = (MediaStream stream) {
      _remoteRenderer.srcObject = stream;
      if (mounted) {
        setState(() {
          _isConnected = true;
          _startCallTimer();
        });
      }
    };

    // 5. Check if we're the first participant (caller)
    final callDoc = await _callsRef.doc(widget.callId).get();
    _isCaller = !callDoc.exists;

    if (_isCaller) {
      // Create offer if caller
      final offer = await _peerConnection!.createOffer();
      await _peerConnection!.setLocalDescription(offer);
      _sendFirestoreMessage({
        'type': 'offer',
        'sdp': offer.sdp,
        'sender': _userId,
      });
    }

    // 6. Listen for signaling messages
    _messagesSub = _callsRef
        .doc(widget.callId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
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
  }

  void _handleSignalingMessage(Map<String, dynamic> data) async {
    switch (data['type']) {
      case 'offer':
        await _peerConnection?.setRemoteDescription(
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
        await _peerConnection?.setRemoteDescription(
          RTCSessionDescription(data['sdp'], 'answer'),
        );
        break;

      case 'candidate':
        await _peerConnection?.addCandidate(RTCIceCandidate(
          data['candidate']['candidate'],
          data['candidate']['sdpMid'],
          data['candidate']['sdpMLineIndex'],
        ));
        break;
    }
  }

  void _sendFirestoreMessage(Map<String, dynamic> message) {
    _callsRef
        .doc(widget.callId)
        .collection('messages')
        .add({
          ...message,
          'timestamp': FieldValue.serverTimestamp(),
        });
  }

  void _startCallTimer() {
    _callTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() => _callDuration++);
      }
    });
  }

  String get _formattedDuration {
    final minutes = (_callDuration ~/ 60).toString().padLeft(2, '0');
    final seconds = (_callDuration % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  void _toggleMute() {
    setState(() => _isMuted = !_isMuted);
    _localStream?.getAudioTracks().forEach((track) => track.enabled = !_isMuted);
  }

  void _toggleVideo() {
    setState(() => _isVideoOff = !_isVideoOff);
    _localStream?.getVideoTracks().forEach((track) => track.enabled = !_isVideoOff);
  }

  Future<void> _endCall() async {
    _callTimer?.cancel();
    await _peerConnection?.close();
    await _localStream?.dispose();
    _messagesSub?.cancel();
    await _callsRef.doc(widget.callId).delete(); // Cleanup Firestore
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Remote Video (Doctor)
          if (_isConnected)
            RTCVideoView(_remoteRenderer)
          else
            const Center(child: CircularProgressIndicator(color: Colors.white)),

          // Local Video Preview
          Positioned(
            top: 40,
            right: 20,
            child: Container(
              width: 120,
              height: 160,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white, width: 2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: RTCVideoView(_localRenderer),
              ),
            ),
          ),

          // Call Duration
          if (_isConnected)
            Positioned(
              top: 20,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _formattedDuration,
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ),

          // Call Controls
          Positioned(
            bottom: 30,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                FloatingActionButton(
                  heroTag: "mute",
                  backgroundColor: _isMuted ? Colors.red : Colors.grey[800],
                  onPressed: _toggleMute,
                  child: Icon(
                    _isMuted ? Icons.mic_off : Icons.mic,
                    color: Colors.white,
                  ),
                ),
                FloatingActionButton(
                  heroTag: "end",
                  backgroundColor: Colors.red,
                  onPressed: () {
                    _endCall();
                    Navigator.pop(context);
                  },
                  child: const Icon(Icons.call_end, color: Colors.white),
                ),
                FloatingActionButton(
                  heroTag: "video",
                  backgroundColor: _isVideoOff ? Colors.red : Colors.grey[800],
                  onPressed: _toggleVideo,
                  child: Icon(
                    _isVideoOff ? Icons.videocam_off : Icons.videocam,
                    color: Colors.white,
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
          style: const TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            _endCall();
            Navigator.pop(context);
          },
        ),
      ),
    );
  }
}